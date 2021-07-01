//
//  AVPlayerView.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "AVPlayerView.h"
#import "CacheHelpler.h"
#import "AVPlayerManager.h"
#import <CoreServices/UTType.h>
#import "Utility.h"

@interface AVPlayerView () <NSURLSessionTaskDelegate, NSURLSessionDataDelegate, AVAssetResourceLoaderDelegate>
@property (nonatomic, strong) UIImageView *thumbImageView;

@property (strong, nonatomic) NSURL *sourceURL; // 视频路径
@property (strong, nonatomic) NSString *sourceScheme; //路径Scheme
@property (strong, nonatomic) AVURLAsset *urlAsset; // 视频资源
@property (strong, nonatomic) AVPlayerItem *playerItem; // 视频资源载体
@property (strong, nonatomic) AVPlayer *player; // 视频播放器
@property (strong, nonatomic) AVPlayerLayer *playerLayer; //视频播放器图形化载体
@property (strong, nonatomic) id timeObserver; //视频播放器周期性调用的观察者

@property (strong, nonatomic) NSMutableData *data; //视频缓冲数据
@property (copy, nonatomic) NSString *mimeType; //资源格式
@property (assign, nonatomic) long long expectedContentLength; // 资源大小
@property (strong, nonatomic) NSMutableArray *pendingRequests; // 存储AVAssetResourceLoadingRequest的数组

@property (copy, nonatomic) NSString *cacheFileKey; //缓存文件key值
@property (strong, nonatomic) NSOperation *queryCacheOperation;    // 查找本地视频缓存数据的NSOperation
@property (strong, nonatomic) dispatch_queue_t cancelLoadingQueue;

@property (strong, nonatomic) CombineOperation *combineOperation;
@property (assign, nonatomic) BOOL retried;
/// 自动播放次数。默认无限循环(NSUIntegerMax)
@property (nonatomic, assign) NSUInteger autoPlayCountTemp;
//@property (strong, nonatomic) UIImage *preViewImage;

@property (copy, nonatomic) NSString *videoUrl;
@end

@implementation AVPlayerView

//重写initWithFrame
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //初始化存储AVAssetResourceLoadingRequest的数组
        self.pendingRequests = [NSMutableArray array];
        
        self.autoPlayCountTemp = NSUIntegerMax;

        //初始化播放器
        self.player = [AVPlayer new];
        //添加视频播放器图形化载体AVPlayerLayer
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.layer addSublayer:self.playerLayer];
        
        //初始化取消视频加载的队列
        self.cancelLoadingQueue = dispatch_queue_create("com.start.cancelloadingqueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //禁止隐式动画
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.playerLayer.frame = self.layer.bounds;
    [CATransaction commit];
    [self addSubview:self.thumbImageView];
}

- (void)dealloc {
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    [self.player removeObserver:self forKeyPath:@"timeControlStatus"];
    [self.player removeTimeObserver:self.timeObserver];
}

#pragma mark - other
//取消播放
- (void)cancelLoading {
    //暂停视频播放
    [self pause];
    
    //隐藏playerLayer
    [self.playerLayer setHidden:YES];
    
    //取消下载任务
    if (self.combineOperation) {
        [self.combineOperation cancel];
        self.combineOperation = nil;
    }
    
    //取消查找本地视频缓存数据的NSOperation任务
    [self.queryCacheOperation cancel];
    
    self.player = nil;
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    self.playerItem = nil;
    self.playerLayer.player = nil;
    
    __weak __typeof(self) wself = self;
    dispatch_async(self.cancelLoadingQueue, ^{
        //取消AVURLAsset加载，这一步很重要，及时取消到AVAssetResourceLoaderDelegate视频源的加载，避免AVPlayer视频源切换时发生的错位现象
        [wself.urlAsset cancelLoading];
        wself.data = nil;
        //结束所有视频数据加载请求
        [wself.pendingRequests enumerateObjectsUsingBlock:^(id loadingRequest, NSUInteger idx, BOOL * stop) {
            if (![loadingRequest isFinished]) {
                [loadingRequest finishLoading];
            }
        }];
        [wself.pendingRequests removeAllObjects];
    });
    
    self.retried = NO;
}

//开始视频资源下载任务
- (void)startDownloadTask:(NSURL *)URL isBackground:(BOOL)isBackground {
    self.status = VideoPlayerStatusDownload;
    
    __weak __typeof(self) wself = self;
    self.queryCacheOperation = [[CacheHelpler sharedWebCache] queryURLFromDiskMemory:self.cacheFileKey cacheQueryCompletedBlock:^(id data, BOOL hasCache) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (hasCache) {
                NSLog(@"xwh: hasCache");
                return;
            }
            
            if (wself.combineOperation != nil) {
                [wself.combineOperation cancel];
            }
            
            wself.combineOperation = [[Downloader sharedDownloader] downloadWithURL:URL responseBlock:^(NSHTTPURLResponse *response) {
                wself.data = [NSMutableData data];
                wself.mimeType = response.MIMEType;
                wself.expectedContentLength = response.expectedContentLength;
                [wself processPendingRequests];
            } progressBlock:^(NSInteger receivedSize, NSInteger expectedSize, NSData *data) {
                [wself.data appendData:data];
                //处理视频数据加载请求
                [wself processPendingRequests];
            } completedBlock:^(NSData *data, NSError *error, BOOL finished) {
                if (!error && finished) {
                    //下载完毕，将缓存数据保存到本地
                    [[CacheHelpler sharedWebCache] storeDataToDiskCache:wself.data key:wself.cacheFileKey extension:@"mp4"];
                }
            } cancelBlock:^{
            } isBackground:isBackground];
        });
    }];
}

//更新AVPlayer状态，当前播放则暂停，当前暂停则播放
- (void)updatePlayerState {
    if (self.player.rate == 0) {
        [self play];
    } else {
        [self pause];
    }
}

//播放
- (void)play {
    if (self.autoPlayCountTemp == 0) {
        self.autoPlayCountTemp = self.autoPlayCount;
        [self replay];
    } else {
        [[AVPlayerManager shareManager] play:self.player];
    }
}

//暂停
- (void)pause {
    self.status = VideoPlayerStatusPaused;
    [[AVPlayerManager shareManager] pause:self.player];
}

//重新播放
- (void)replay {
    [[AVPlayerManager shareManager] replay:self.player];
}

//播放速度
- (CGFloat)rate {
    return [self.player rate];
}

//重新请求
- (void)retry {
    [self cancelLoading];
    self.videoUrl = self.sourceURL.absoluteString;
    self.retried = YES;
}

- (void)didPlayToEndTime:(NSNotification *)notify {
    if (notify.object == self.playerItem) {
        self.status = VideoPlayerStatusFinished;
    }
}

- (void)processPendingRequests {
    NSMutableArray *requestsCompleted = [NSMutableArray array];
    //获取所有已完成AVAssetResourceLoadingRequest
    [self.pendingRequests enumerateObjectsUsingBlock:^(AVAssetResourceLoadingRequest *loadingRequest, NSUInteger idx, BOOL * stop) {
        //判断AVAssetResourceLoadingRequest是否完成
        BOOL didRespondCompletely = [self respondWithDataForRequest:loadingRequest];
        //结束AVAssetResourceLoadingRequest
        if (didRespondCompletely){
            [requestsCompleted addObject:loadingRequest];
            [loadingRequest finishLoading];
        }
    }];
    //移除所有已完成AVAssetResourceLoadingRequest
    [self.pendingRequests removeObjectsInArray:requestsCompleted];
}

- (BOOL)respondWithDataForRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    //设置AVAssetResourceLoadingRequest的类型、支持断点下载、内容大小
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(self.mimeType), NULL);
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    loadingRequest.contentInformationRequest.contentType = CFBridgingRelease(contentType);
    loadingRequest.contentInformationRequest.contentLength = self.expectedContentLength;
    
    //AVAssetResourceLoadingRequest请求偏移量
    long long startOffset = loadingRequest.dataRequest.requestedOffset;
    if (loadingRequest.dataRequest.currentOffset != 0) {
        startOffset = loadingRequest.dataRequest.currentOffset;
    }
    //判断当前缓存数据量是否大于请求偏移量
    if (self.data.length < startOffset) {
        return NO;
    }
    //计算还未装载到缓存数据
    NSUInteger unreadBytes = self.data.length - (NSUInteger)startOffset;
    //判断当前请求到的数据大小
    NSUInteger numberOfBytesToRespondWidth = MIN((NSUInteger)loadingRequest.dataRequest.requestedLength, unreadBytes);
    //将缓存数据的指定片段装载到视频加载请求中
    [loadingRequest.dataRequest respondWithData:[self.data subdataWithRange:NSMakeRange((NSUInteger)startOffset, numberOfBytesToRespondWidth)]];
    //计算装载完毕后的数据偏移量
    long long endOffset = startOffset + loadingRequest.dataRequest.requestedLength;
    //判断请求是否完成
    BOOL didRespondFully = self.data.length >= endOffset;
    
    return didRespondFully;
}

//
#warning 实时的话会导致卡顿
- (void)getVideoEsolutionWithAsset:(AVURLAsset *)urlAsset {
    NSTimeInterval t0 = CFAbsoluteTimeGetCurrent();
    // 尝试从缓存读取图片设置视频分辨率
    // key
    NSString *imageUrl = [Utility getFrameImagePathWithVideoPath:self.videoUrl];
    NSString *imageKey = imageUrl;
    [[CacheHelpler sharedWebCache] queryURLFromDiskMemory:imageKey
    cacheQueryCompletedBlock:^(id data, BOOL hasCache) {
        if (hasCache) {
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL fileURLWithPath:data]]];
            CGFloat width = image.size.width;
            CGFloat height = image.size.height;
            self.videoHeight = height;
            self.videoWidth = width;

            self.status = VideoPlayerStatusChangeEsolution;
        } else {
            NSArray *tracks = [urlAsset tracksWithMediaType:AVMediaTypeVideo];
            if ([tracks count] > 0) {
                AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
                CGFloat width = videoTrack.naturalSize.width;
                CGFloat height = videoTrack.naturalSize.height;
                CGAffineTransform t = videoTrack.preferredTransform;//这里的矩阵有旋转角度，转换一下即可
                if ([self isVideoPortrait:t] == NO) {
                    self.videoHeight = height;
                    self.videoWidth = width;
                } else {
                    self.videoWidth = height;
                    self.videoHeight = width;
                }
                self.status = VideoPlayerStatusChangeEsolution;
            }
        }
    } extension:@"jpg"];
    NSArray *tracks = [urlAsset tracksWithMediaType:AVMediaTypeVideo];
    if ([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGFloat width = videoTrack.naturalSize.width;
        CGFloat height = videoTrack.naturalSize.height;
        CGAffineTransform t = videoTrack.preferredTransform;//这里的矩阵有旋转角度，转换一下即可
        if ([self isVideoPortrait:t] == NO) {
            self.videoHeight = height;
            self.videoWidth = width;
        } else {
            self.videoWidth = height;
            self.videoHeight = width;
        }
        self.status = VideoPlayerStatusChangeEsolution;
    }
    NSTimeInterval t1 = CFAbsoluteTimeGetCurrent();
    NSLog(@"%s: %f",__func__, t1-t0);
}

- (void)getImageFromDisk:(void(^)(BOOL hasCache))block {
    NSString *imageUrl = [Utility getFrameImagePathWithVideoPath:self.videoUrl];
    NSString *imageKey = imageUrl;
    [[CacheHelpler sharedWebCache] queryURLFromDiskMemory:imageKey
    cacheQueryCompletedBlock:^(id data, BOOL hasCache) {
        if (hasCache) {
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL fileURLWithPath:data]]];
            CGFloat width = image.size.width;
            CGFloat height = image.size.height;
            self.videoHeight = height;
            self.videoWidth = width;

            self.status = VideoPlayerStatusChangeEsolution;
        } else {
            
        }
    } extension:@"jpg"];
}
- (NSURL *)getSchemeResourceLoaderWithURL:(NSURL *)url scheme:(NSString *)scheme {
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    components.scheme = scheme;
    return components.URL;
}

- (NSString *)getSourceSchemeWithURL:(NSURL *)url {
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:self.sourceURL resolvingAgainstBaseURL:NO];
    return components.scheme;
}

#pragma mark ---- 获取图片第一帧
- (void)getFirstFrameWithVideoWithAsset:(AVAsset *)asset
                                  block:(void(^)(UIImage *image))block
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        assetGen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(0.0, 600);
        NSError *error = nil;
        CMTime actualTime;
        CGImageRef image = [assetGen copyCGImageAtTime:time
                                            actualTime:&actualTime
                                                 error:&error];
        UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
        CGImageRelease(image);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.thumbImageView.image = videoImage;
            if (block) {
                block(videoImage);
            }
        });
    });
}

- (BOOL)isVideoPortrait:(CGAffineTransform)t {
    BOOL isPortrait = NO;
    // Portrait
    if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0) {
        isPortrait = YES;
    }
    // PortraitUpsideDown
    if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0) {
        isPortrait = YES;
    }
    // LandscapeRight
    if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0) {
        isPortrait = NO;
    }
    // LandscapeLeft
    if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0) {
        isPortrait = NO;
    }
    return isPortrait;
}

#pragma mark KVO
// 给AVPlayerLayer添加周期性调用的观察者，用于更新视频播放进度
- (void)addProgressObserver {
    __weak __typeof(self) weakSelf = self;
    //AVPlayer添加周期性回调观察者，一秒调用一次block，用于更新视频播放进度
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1000.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if (weakSelf.playerItem.status == AVPlayerItemStatusReadyToPlay) {
            //获取当前播放时间
            float current = CMTimeGetSeconds(time);
            //获取视频播放总时间
            float total = CMTimeGetSeconds([weakSelf.playerItem duration]);
            
           
            //重新播放视频
            if (total == current) {
                if (weakSelf.autoPlayCountTemp == NSUIntegerMax) {
                    [weakSelf replay];
                } else {
                    --weakSelf.autoPlayCountTemp;
                    if (weakSelf.autoPlayCountTemp > 0) {
                        [weakSelf replay];
                    }
                }
            }
            //更新视频播放进度方法回调
            if ([weakSelf.delegate respondsToSelector:@selector(avPlayerView:onProgressUpdate:total:)]) {
                [weakSelf.delegate avPlayerView:weakSelf
                               onProgressUpdate:current
                                          total:total];
            }
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
}

// 响应KVO值变化的方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.player) {
        if ([keyPath isEqualToString:@"timeControlStatus"]) {
            if (self.player.timeControlStatus == AVPlayerTimeControlStatusPaused) {
                // not to do
            } else if (self.player.timeControlStatus == AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate) {
                // not to do
            } else if (self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
                self.status = VideoPlayerStatusPlaying;
            }
        }
    }
    
    if (object == self.playerItem) {
        //AVPlayerItem.status
        if ([keyPath isEqualToString:@"status"]) {
            if (self.playerItem.status == AVPlayerItemStatusUnknown) {
                self.status = VideoPlayerStatusUnknown;
            } else if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                //视频源装备完毕，则显示playerLayer
                self.status = VideoPlayerStatusReadyToPlay;
                [self.playerLayer setHidden:NO];
            } else if (self.playerItem.status == AVPlayerItemStatusFailed) {
                self.status = VideoPlayerStatusFailed;
                if (!self.retried) {
                    [self retry];
                }
            }
        } else {
            return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}

#pragma mark - AVAssetResourceLoaderDelegate

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    //创建用于下载视频源的NSURLSessionDataTask，当前方法会多次调用，所以需判断self.task == nil
    if (_combineOperation == nil) {
        //将当前的请求路径的scheme换成https，进行普通的网络请求
        NSURL *videoUrl = [self getSchemeResourceLoaderWithURL:[loadingRequest.request URL] scheme:self.sourceScheme];
        [self startDownloadTask:videoUrl isBackground:YES];
    }
    //将视频加载请求依此存储到pendingRequests中，因为当前方法会多次调用，所以需用数组缓存
    [self.pendingRequests addObject:loadingRequest];
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    //AVAssetResourceLoadingRequest请求被取消，移除视频加载请求
    [self.pendingRequests removeObject:loadingRequest];
}

#pragma mark - get data
- (UIImageView *)thumbImageView {
    if (!_thumbImageView) {
        _thumbImageView = [UIImageView new];
        _thumbImageView.layer.masksToBounds = YES;
    }
    return _thumbImageView;
}

- (NSTimeInterval)duration {
    return CMTimeGetSeconds(self.player.currentItem.currentTime);
}

- (NSTimeInterval)currentTime {
    return CMTimeGetSeconds(self.player.currentItem.duration);
}

#pragma mark - set data
//设置播放路径
- (void)setVideoUrl:(NSString *)videoUrl needCache:(BOOL)bNeedCache {
    self.videoUrl = videoUrl;

    self.status = VideoPlayerStatusReady;

    //播放路径
    self.sourceURL = [NSURL URLWithString:videoUrl];
    
    //获取路径schema
    self.sourceScheme = [self getSourceSchemeWithURL:self.sourceURL];
    
    //路径作为视频缓存key
    self.cacheFileKey = self.sourceURL.absoluteString;
    
    __weak __typeof(self) wself = self;
    //查找本地视频缓存数据
    self.queryCacheOperation = [[CacheHelpler sharedWebCache] queryURLFromDiskMemory:self.cacheFileKey cacheQueryCompletedBlock:^(id data, BOOL hasCache) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //hasCache是否有缓存，data为本地缓存路径
            if (hasCache) {
                wself.sourceURL = [NSURL fileURLWithPath:data];
                wself.urlAsset = [AVURLAsset URLAssetWithURL:wself.sourceURL options:nil];
                [wself getVideoEsolutionWithAsset:wself.urlAsset];
            } else {
                //当前路径无缓存，则将视频的网络路径的scheme改为其他自定义的scheme类型，http、https这类预留的scheme类型不能使AVAssetResourceLoaderDelegate中的方法回调
                if (bNeedCache) {
#warning 为了获取缓冲时的分辨率
                    AVURLAsset *urlAssetTemp = [AVURLAsset URLAssetWithURL:wself.sourceURL options:nil];
                    [wself getVideoEsolutionWithAsset:urlAssetTemp];
                    
                    wself.sourceURL = [wself getSchemeResourceLoaderWithURL:wself.sourceURL scheme:@"streaming"];
                    wself.urlAsset = [AVURLAsset URLAssetWithURL:wself.sourceURL options:nil];
                    [wself.urlAsset.resourceLoader setDelegate:wself queue:dispatch_get_main_queue()];
                } else {
                    wself.sourceURL = wself.sourceURL;
                    wself.urlAsset = [AVURLAsset URLAssetWithURL:wself.sourceURL options:nil];
                    [wself getVideoEsolutionWithAsset:wself.urlAsset];
                }
            }
            
            //初始化AVPlayerItem
            wself.playerItem = [AVPlayerItem playerItemWithAsset:wself.urlAsset];
            //观察playerItem.status属性
            [wself.playerItem addObserver:wself forKeyPath:@"status" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
            //切换当前AVPlayer播放器的视频源
            wself.player = [[AVPlayer alloc] initWithPlayerItem:wself.playerItem];
            [wself.player addObserver:wself forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:nil];
            wself.playerLayer.player = wself.player;
            
            {
                if (self.videoHeight/self.videoWidth <= 4/3.0) {
                    self.renderMode = VideoRenderModeFillEdge;
                    self.thumbImageView.contentMode = UIViewContentModeScaleAspectFit;
                    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
                } else {
                    self.renderMode = VideoRenderModeFillScreen;
                    self.thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
                    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                }
            }
            
            //给AVPlayerLayer添加周期性调用的观察者，用于更新视频播放进度
            [wself addProgressObserver];
        });
    } extension:@"mp4"];
}

- (void)setStatus:(VideoPlayerStatus)status {
    _status = status;
    
    //视频播放状体更新方法回调
    if ([self.delegate respondsToSelector:@selector(avPlayerView:playerStatus:error:)]) {
        [self.delegate avPlayerView:self playerStatus:self.status error:self.playerItem.error];
    }
    
    if (status == VideoPlayerStatusReady) {
        self.thumbImageView.hidden = NO;
    } else if (status == VideoPlayerStatusPlaying) {
        self.thumbImageView.hidden = YES;
    }
}

- (void)setAutoPlayCount:(NSUInteger)autoPlayCount {
    _autoPlayCount = autoPlayCount;
    self.autoPlayCountTemp = autoPlayCount;
}

//- (void)setPreViewImageUrl:(NSString * _Nonnull)preViewImageUrl {
//    _preViewImageUrl = preViewImageUrl;
//
//    NSTimeInterval t0 = CFAbsoluteTimeGetCurrent();
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:preViewImageUrl]]];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSTimeInterval t1 = CFAbsoluteTimeGetCurrent();
//            {
//                NSLog(@"预览图片(URL)加载时间: %f", t1-t0);
//            }
//            CGFloat width = image.size.width;
//            CGFloat height = image.size.height;
//            self.videoWidth = width;
//            self.videoHeight = height;
//
//            self.status = VideoPlayerStatusChangeEsolution;
//            self.preViewImage = image;
//        });
//    });
//}
//
//- (void)setPreViewImage:(UIImage *)preViewImage {
//    _preViewImage = preViewImage;
//
//    self.videoHeight = preViewImage.size.height;
//    self.videoWidth = preViewImage.size.width;
//
//    if (self.videoHeight/self.videoWidth <= 4/3.0) {
//        self.renderMode = VideoRenderModeFillEdge;
//        self.thumbImageView.contentMode = UIViewContentModeScaleAspectFit;
//    } else {
//        self.renderMode = VideoRenderModeFillScreen;
//        self.thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
//    }
//    self.thumbImageView.image = preViewImage;
//    self.thumbImageView.frame = self.bounds;
//}
@end
