//
//  ImageCache.m
//  AVPlayerDemo
//
//  Created by HN on 2021/6/21.
//

#import "ImageCache.h"
#import "CacheHelpler.h"

@interface ImageCache ()

@property (copy, nonatomic) NSString *cacheFileKey; //缓存文件key值

@property (strong, nonatomic) CombineOperation *combineOperation;
@property (strong, nonatomic) NSOperation *queryCacheOperation;    // 查找本地视频缓存数据的NSOperation

@property (strong, nonatomic) NSMutableData *data; //视频缓冲数据
@property (copy, nonatomic) NSString *mimeType; //资源格式
@property (assign, nonatomic) long long expectedContentLength; // 资源大小

@end

@implementation ImageCache

- (void)setImageUrl:(NSString *)imageUrl {
    self.cacheFileKey = imageUrl;
    
    __weak __typeof(self) wself = self;
    //查找本地视频缓存数据
    self.queryCacheOperation = [[CacheHelpler sharedWebCache] queryURLFromDiskMemory:self.cacheFileKey cacheQueryCompletedBlock:^(id data, BOOL hasCache) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //hasCache是否有缓存，data为本地缓存路径
            if (!hasCache) {
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
            } else {
                //当前路径有缓存，则使用本地路径作为播放源
//                wself.sourceURL = [NSURL fileURLWithPath:data];
            }
            //初始化AVURLAsset
//            wself.urlAsset = [AVURLAsset URLAssetWithURL:wself.sourceURL options:nil];
//            {
//                NSArray *tracks = [wself.urlAsset tracksWithMediaType:AVMediaTypeVideo];
//                if ([tracks count] > 0) {
//                    AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
//                    CGFloat width = videoTrack.naturalSize.width;
//                    CGFloat height = videoTrack.naturalSize.height;
//                    CGAffineTransform t = videoTrack.preferredTransform;//这里的矩阵有旋转角度，转换一下即可
//                    if ([self isVideoPortrait:t] == NO) {
//                        self.videoHeight = height;
//                        self.videoWidth = width;
//                    } else {
//                        self.videoWidth = height;
//                        self.videoHeight = width;
//                    }
//                    self.status = VideoPlayerStatusChangeEsolution;
//                }
//            }
//
//            //设置AVAssetResourceLoaderDelegate代理
//            [wself.urlAsset.resourceLoader setDelegate:wself queue:dispatch_get_main_queue()];
//            //初始化AVPlayerItem
//            wself.playerItem = [AVPlayerItem playerItemWithAsset:wself.urlAsset];
//            //观察playerItem.status属性
//            [wself.playerItem addObserver:wself forKeyPath:@"status" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
//            //切换当前AVPlayer播放器的视频源
//            wself.player = [[AVPlayer alloc] initWithPlayerItem:wself.playerItem];
//            [wself.player addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:nil];
//            wself.playerLayer.player = wself.player;
//
//            {
//                if (self.videoHeight/self.videoWidth <= 4/3.0) {
//                    self.renderMode = VideoRenderModeFillEdge;
//                    self.thumbImageView.contentMode = UIViewContentModeScaleAspectFit;
//                    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
//                } else {
//                    self.renderMode = VideoRenderModeFillScreen;
//                    self.thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
//                    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//                }
//            }
//
//            //给AVPlayerLayer添加周期性调用的观察者，用于更新视频播放进度
//            [wself addProgressObserver];
        });
    } extension:@"jpg"];

}
- (void)startDownloadTask:(NSURL *)URL isBackground:(BOOL)isBackground {
    __weak __typeof(self) wself = self;
    self.queryCacheOperation = [[CacheHelpler sharedWebCache] queryURLFromDiskMemory:self.cacheFileKey cacheQueryCompletedBlock:^(id data, BOOL hasCache) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (hasCache) {
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
                    [[CacheHelpler sharedWebCache] storeDataToDiskCache:data key:URL.absoluteString extension:@"jpg"];
                }
            } cancelBlock:^{
            } isBackground:isBackground];
        });
    }];

}

- (void)processPendingRequests {
    NSMutableArray *requestsCompleted = [NSMutableArray array];
    //获取所有已完成AVAssetResourceLoadingRequest
//    [self.pendingRequests enumerateObjectsUsingBlock:^(AVAssetResourceLoadingRequest *loadingRequest, NSUInteger idx, BOOL * stop) {
//        //判断AVAssetResourceLoadingRequest是否完成
//        BOOL didRespondCompletely = [self respondWithDataForRequest:loadingRequest];
//        //结束AVAssetResourceLoadingRequest
//        if (didRespondCompletely){
//            [requestsCompleted addObject:loadingRequest];
//            [loadingRequest finishLoading];
//        }
//    }];
//    //移除所有已完成AVAssetResourceLoadingRequest
//    [self.pendingRequests removeObjectsInArray:requestsCompleted];
}

//- (BOOL)respondWithDataForRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
//    //设置AVAssetResourceLoadingRequest的类型、支持断点下载、内容大小
//    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(self.mimeType), NULL);
//    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
//    loadingRequest.contentInformationRequest.contentType = CFBridgingRelease(contentType);
//    loadingRequest.contentInformationRequest.contentLength = self.expectedContentLength;
//
//    //AVAssetResourceLoadingRequest请求偏移量
//    long long startOffset = loadingRequest.dataRequest.requestedOffset;
//    if (loadingRequest.dataRequest.currentOffset != 0) {
//        startOffset = loadingRequest.dataRequest.currentOffset;
//    }
//    //判断当前缓存数据量是否大于请求偏移量
//    if (self.data.length < startOffset) {
//        return NO;
//    }
//    //计算还未装载到缓存数据
//    NSUInteger unreadBytes = self.data.length - (NSUInteger)startOffset;
//    //判断当前请求到的数据大小
//    NSUInteger numberOfBytesToRespondWidth = MIN((NSUInteger)loadingRequest.dataRequest.requestedLength, unreadBytes);
//    //将缓存数据的指定片段装载到视频加载请求中
//    [loadingRequest.dataRequest respondWithData:[self.data subdataWithRange:NSMakeRange((NSUInteger)startOffset, numberOfBytesToRespondWidth)]];
//    //计算装载完毕后的数据偏移量
//    long long endOffset = startOffset + loadingRequest.dataRequest.requestedLength;
//    //判断请求是否完成
//    BOOL didRespondFully = self.data.length >= endOffset;
//
//    return didRespondFully;
//}

@end
