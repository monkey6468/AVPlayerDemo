//
//  VideoPlayer.m
//  AVPlayerDemo
//
//  Created by HN on 2021/6/1.
//

#import "VideoPlayer.h"

@interface VideoPlayer ()

@property (nonatomic, strong) UIImageView *thumbImageView;
/// 帧图片
@property (strong, nonatomic) UIImage *preViewImage;

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVAsset *asset;
@property (nonatomic) id observer;

@property (nonatomic, assign) CGFloat curruntVolumeValue; /// 记录系统声音
@property (assign, nonatomic, getter=isActiving) BOOL bActive;
@property (assign, nonatomic) CGFloat videoWidth;
@property (assign, nonatomic) CGFloat videoHeight;
@property (assign, nonatomic) NSTimeInterval duration;
@property (assign, nonatomic) NSTimeInterval currentTime; /// 视频当前进度时长
@property (assign, nonatomic) float rate;
@property (assign, nonatomic, getter=isSetPreViewRenderMode) BOOL bSetPreViewRenderMode; /// 图片填充模式
@property (assign, nonatomic, getter=isSetVideoRenderMode) BOOL bSetVideoRenderMode; /// 视频填充模式

@end

@implementation VideoPlayer

- (void)dealloc {
    [self removeObserverForPlayer];
    [self removeObserverForSystem];
    [self reset];
    [self.player removeTimeObserver:self.observer];
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    // If set 'self.playerLayer.player = nil' or 'self.player = nil', can not cancel observeing of 'addPeriodicTimeObserverForInterval'.
    self.player = nil;
}

#pragma mark - life

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initValue];
    self.backgroundColor = UIColor.clearColor;
    
    [self addSubview:self.thumbImageView];
    [self addObserverForSystem];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self awakeFromNib];
    }
    return self;
}

- (void)initValue {
    self.renderMode = VideoRenderModeFillEdge;
    self.bActive = YES;
    self.autoPlayCount = 0;
    self.rate = 1;
    self.bDebug = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

#pragma mark - UI
- (void)updateUIWithRenderModel {
    if (self.isSetPreViewRenderMode == NO) {
        if (self.thumbImageView) {
            self.bSetPreViewRenderMode = YES;
            if (self.renderMode == VideoRenderModeFillScreen) {
                self.thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
            } else if (self.renderMode == VideoRenderModeFillEdge) {
                self.thumbImageView.contentMode = UIViewContentModeScaleAspectFit;
            }
        }
    }
    
    if (self.isSetVideoRenderMode == NO) {
        if (self.playerLayer) {
            self.bSetVideoRenderMode = YES;
            if (self.renderMode == VideoRenderModeFillScreen) {
                self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            } else if (self.renderMode == VideoRenderModeFillEdge) {
                self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            }
        }
    }
}

#pragma mark - other
- (void)updateWithDuration:(NSTimeInterval)duration
               currentTime:(NSTimeInterval)currentTime {
    self.duration = duration>=0?duration:0;
    self.currentTime = currentTime;
    if ([self.delegate respondsToSelector:@selector(videoPlayer:duration:currentTime:)]) {
        [self.delegate videoPlayer:self duration:self.duration currentTime:self.currentTime];
    }
}

#pragma mark - private
- (void)videoJumpWithScale:(float)scale {
    CMTime startTime = CMTimeMakeWithSeconds(scale, self.player.currentTime.timescale);
    
    if (CMTIME_IS_INDEFINITE(startTime) || CMTIME_IS_INVALID(startTime)) return;
    
    [self.player seekToTime:startTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self playerResume];
}

- (void)playerStart {
    if (self.status == VideoPlayerStatusFinished) {
        [self removeObserverForPlayer];
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = nil;
    }
    
    if (!self.playerLayer) {
        
        if (self.isSetVideoRenderMode == NO && self.isSetPreViewRenderMode == NO) {
            NSArray *tracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
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
        } else {
            if (self.status == VideoPlayerStatusFinished) {
                self.bSetPreViewRenderMode = NO;
                self.bSetVideoRenderMode = NO;
            }
        }
        
        self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset];
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        [self.layer insertSublayer:self.playerLayer above:self.thumbImageView.layer];

        self.curruntVolumeValue = self.player.volume;

        [self addObserverForPlayer];
    } else {
        [self videoJumpWithScale:0];
    }
}

#pragma mark player operation releated
- (void)reset {
    [self.player pause];
    self.playerItem = nil;
}

- (void)endPlayWithNeedAutoPlay:(BOOL)bNeed {
    if (self.player) {
        self.status = VideoPlayerStatusFinished;

        if (bNeed) {
            [self autoPlay];
        } else {
            [self reset];
            self.player = nil;
//            [self.player removeTimeObserver:self.observer];
        }
    }
}

- (void)finishPlay {
    if (self.player) {
        [self endPlayWithNeedAutoPlay:YES];
    }
}

- (void)playerStop {
    if (self.player) {
        [self endPlayWithNeedAutoPlay:NO];
    }
}

- (void)playerPause {
    if (self.player) {
        [self.player pause];
        self.status = VideoPlayerStatusPaused;
    }
}

- (void)playerResume {
    if (self.player) {
        [self.player play];
        self.player.rate = self.rate;
    }
}

- (void)autoPlay {
    if (self.autoPlayCount == NSUIntegerMax) {
        [self playerStart];
    } else if (self.autoPlayCount > 0) {
        --self.autoPlayCount;
        [self playerStart];
    }
}

#pragma mark - observe

- (void)addObserverForPlayer {
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.player addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:nil];

    __weak typeof(self) wSelf = self;
    self.observer = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1000.0)
                                                              queue:dispatch_get_main_queue()
                                                         usingBlock:^(CMTime time) {

        NSArray *loadedRanges = wSelf.player.currentItem.seekableTimeRanges;
        if (loadedRanges.copy > 0) {
            NSTimeInterval currentTime = CMTimeGetSeconds(wSelf.player.currentItem.currentTime);
            NSTimeInterval duration = CMTimeGetSeconds(wSelf.player.currentItem.duration);
            [wSelf updateWithDuration:duration currentTime:currentTime];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
}

- (void)removeObserverForPlayer {
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.player removeObserver:self forKeyPath:@"timeControlStatus"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.playerItem) {
        if ([keyPath isEqualToString:@"status"]) {
            [self playerItemStatusChanged];
        }
    }
    
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
}

- (void)didPlayToEndTime:(NSNotification *)noti {
    if (noti.object == self.playerItem) {
        [self finishPlay];
    }
}

- (void)playerItemStatusChanged {
    if (!self.isActiving) return;
    
    switch (self.playerItem.status) {
        case AVPlayerItemStatusReadyToPlay: {
            // Delay to update UI.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.status = VideoPlayerStatusReadyToPlay;
                [self playerResume];
            });
        }
            break;
        case AVPlayerItemStatusUnknown: {
            self.status = VideoPlayerStatusUnknown;
            [self reset];
        }
            break;
        case AVPlayerItemStatusFailed: {
            self.status = VideoPlayerStatusFailed;
            [self reset];
        }
            break;
    }
}

- (void)removeObserverForSystem {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)addObserverForSystem {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarFrame) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:)   name:AVAudioSessionRouteChangeNotification object:nil];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    self.bActive = NO;
    [self playerPause];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    self.bActive = YES;
    [self playerResume];
}

//- (void)didChangeStatusBarFrame {
//    [self playerPause];
//}

- (void)audioRouteChangeListenerCallback:(NSNotification*)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *interuptionDict = notification.userInfo;
        NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
        switch (routeChangeReason) {
            case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
                [self playerPause];
                break;
        }
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

#pragma mark - get data
- (UIImageView *)thumbImageView {
    if (!_thumbImageView) {
        _thumbImageView = [UIImageView new];
        _thumbImageView.layer.masksToBounds = YES;
    }
    return _thumbImageView;
}

- (CGFloat)width {
    return self.videoWidth;
}

- (CGFloat)height {
    return self.videoHeight;
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

#pragma mark - set data
- (void)setPreViewImage:(UIImage *)preViewImage {
    _preViewImage = preViewImage;
    
    self.thumbImageView.image = preViewImage;
    self.thumbImageView.frame = self.bounds;
}

- (void)setRenderMode:(VideoRenderMode)contentMode {
    _renderMode = contentMode;
    
    [self updateUIWithRenderModel];
}

- (void)setRate:(float)rate {
    _rate = rate;
}

- (void)seekToTime:(float)time {
    [self videoJumpWithScale:time];
}

- (void)setStatus:(VideoPlayerStatus)playerStatus {
    _status = playerStatus;
    if ([self.delegate respondsToSelector:@selector(videoPlayer:playerStatus:error:)]) {
        [self.delegate videoPlayer:self playerStatus:self.status error:self.playerItem.error];
    }
    
    if (playerStatus == VideoPlayerStatusReady) {
        self.thumbImageView.hidden = NO;
    } else if (playerStatus == VideoPlayerStatusPlaying) {
        self.thumbImageView.hidden = YES;
        
        [self updateUIWithRenderModel];
        
    } else if (playerStatus == VideoPlayerStatusPaused) {
        // to do
    } else if (playerStatus == VideoPlayerStatusFinished) {
        
        NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentItem.currentTime);
        NSTimeInterval duration = CMTimeGetSeconds(self.player.currentItem.duration);
        [self updateWithDuration:duration currentTime:currentTime];
        
    }
}

- (void)setPreViewImageUrl:(NSString * _Nonnull)preViewImageUrl {
    _preViewImageUrl = preViewImageUrl;
    
    NSTimeInterval t0 = CFAbsoluteTimeGetCurrent();
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:preViewImageUrl]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isSetPreViewRenderMode == NO) {
                NSTimeInterval t1 = CFAbsoluteTimeGetCurrent();
                if (self.bDebug) {
                    NSLog(@"预览图片(URL)加载时间: %f", t1-t0);
                }
                CGFloat width = image.size.width;
                CGFloat height = image.size.height;
                self.videoWidth = width;
                self.videoHeight = height;
                
                self.status = VideoPlayerStatusChangeEsolution;
            }
            self.preViewImage = image;
        });
    });
}

- (void)setVideoUrl:(NSString *)videoUrl {
    _videoUrl = videoUrl;
    
    self.bSetPreViewRenderMode = NO;
    self.bSetVideoRenderMode = NO;
    if (videoUrl.length == 0) {
        return ;
    }
    
    if (self.asset == nil) {
        [self setVideoAVAsset];
    }
    
    if (self.preViewImage == nil && self.asset == nil) {
        [self setPreViewImage];
    }
}

- (void)setBNeedPreView:(BOOL)bNeedPreView {
    _bNeedPreView = bNeedPreView;
    
    if (self.preViewImage == nil && self.asset == nil) {
        [self setPreViewImage];
    }
}

- (void)setVideoAVAsset {
    NSTimeInterval t11 = CFAbsoluteTimeGetCurrent();
    AVURLAsset *videoAVAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:self.videoUrl] options:nil];
    NSTimeInterval t21 = CFAbsoluteTimeGetCurrent();
    if (self.bDebug) {
        NSLog(@"视频资源加载时间: %f", t21-t11);
    }
    
    if (videoAVAsset == nil) {
        return ;
    }
    self.asset = videoAVAsset;
    self.status = VideoPlayerStatusReady;
}

- (void)setPreViewImage {
    if (self.bNeedPreView) {
        NSTimeInterval t0 = CFAbsoluteTimeGetCurrent();
        __weak typeof(self) wSelf = self;
        [self getFirstFrameWithVideoWithAsset:self.asset
                                        block:^(UIImage * _Nonnull image) {
            if (image) {
                
                if (self.isSetPreViewRenderMode == NO) {
                    CGFloat width = image.size.width;
                    CGFloat height = image.size.height;
                    self.videoWidth = width;
                    self.videoHeight = height;
                    
                    self.status = VideoPlayerStatusChangeEsolution;
                }
                wSelf.preViewImage = image;
            }
            NSTimeInterval t1 = CFAbsoluteTimeGetCurrent();
            
            if (self.bDebug) {
                NSLog(@"预览图片(内置)加载时间: %f", t1-t0);
            }
        }];
    } else {
        self.bSetPreViewRenderMode = YES;
    }
}
@end
