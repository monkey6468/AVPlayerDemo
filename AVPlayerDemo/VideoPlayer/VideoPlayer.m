//
//  VideoPlayer.m
//  AVPlayerDemo
//
//  Created by HN on 2021/6/1.
//

#import "VideoPlayer.h"

@interface VideoPlayer ()

@property (nonatomic, strong) UIImageView *thumbImageView;

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (nonatomic) id observer;

@property (nonatomic, assign) CGFloat curruntVolumeValue; /// 记录系统声音


@end

@implementation VideoPlayer{
    AVPlayerLayer *_playerLayer;
    BOOL _active;
}

- (void)dealloc {
    [self removeObserverForSystem];
    [self reset];
    [self.player removeTimeObserver:self.observer];
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
            if (block) {
                block(videoImage);
            }
        });
    });
}

#pragma mark - life
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initValue];
        self.backgroundColor = UIColor.clearColor;
        
        [self addSubview:self.thumbImageView];
        [self addObserverForSystem];
        
//        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToTapGesture:)];
//        [self addGestureRecognizer:_tapGesture];
    }
    return self;
}

- (void)initValue {
    _playing = NO;
    _active = YES;
    _needAutoPlay = YES;
    _autoPlayCount = 0;
    _playFailed = NO;
    _preparingPlay = NO;
}

- (void)reset {
    [self removeObserverForPlayer];
    
    // If set '_playerLayer.player = nil' or '_player = nil', can not cancel observeing of 'addPeriodicTimeObserverForInterval'.
    [_player pause];
    self.playerItem = nil;
    [_playerLayer removeFromSuperlayer];
    _playerLayer = nil;

    [self finishPlay];
}

#pragma mark - private

- (void)videoJumpWithScale:(float)scale {
    CMTime startTime = CMTimeMakeWithSeconds(scale, _player.currentTime.timescale);
    
    if (CMTIME_IS_INDEFINITE(startTime) || CMTIME_IS_INVALID(startTime)) return;
    
    [self.player seekToTime:startTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self startPlay];
}

- (void)preparPlay {
    _preparingPlay = YES;
    _playFailed = NO;
            
    if (!_playerLayer) {
        self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset];
        _player = [AVPlayer playerWithPlayerItem:self.playerItem];
        
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;    //视频填充模式
        [self.layer insertSublayer:_playerLayer above:self.thumbImageView.layer];

        self.curruntVolumeValue = _player.volume;

        [self addObserverForPlayer];
    } else {
        [self videoJumpWithScale:0];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _playerLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)startPlay {
    if (_player) {
        _playing = YES;
        
        [_player play];
    }
}

- (void)finishPlay {
    _playing = NO;
}

- (void)playerPause {
    if (_player) {
        [_player pause];
    }
}

- (BOOL)autoPlay {
    if (self.autoPlayCount == NSUIntegerMax) {
        [self preparPlay];
    } else if (self.autoPlayCount > 0) {
        --self.autoPlayCount;
        [self preparPlay];
    } else {
        return NO;
    }
    return YES;
}

#pragma mark - observe

- (void)addObserverForPlayer {
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    __weak typeof(self) wSelf = self;
    self.observer = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1000.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong typeof(wSelf) self = wSelf;
        if (!self) return;
        float duration = (CGFloat)time.timescale;
        float currentTime = (time.value) / duration;
        NSLog(@"----allTime:%f--------currentTime:%f----progress:%f---",duration,currentTime,currentTime/duration);
//        if (currentTime == 0) {
//            self.actionBar.slider.value = 0;
//        }
//        [self.actionBar setCurrentValue:currentTime];
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
}

- (void)removeObserverForPlayer {
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (object == self.playerItem) {
        if ([keyPath isEqualToString:@"status"]) {
            [self playerItemStatusChanged];
        }
    }
}

- (void)didPlayToEndTime:(NSNotification *)noti {
    if (noti.object == self.playerItem) {
        [self finishPlay];
    }
}

- (void)playerItemStatusChanged {
    if (!_active) return;
    
    _preparingPlay = NO;
    
    switch (self.playerItem.status) {
        case AVPlayerItemStatusReadyToPlay: {
            // Delay to update UI.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self startPlay];
//                double max = CMTimeGetSeconds(self.playerItem.duration);
            });
        }
            break;
        case AVPlayerItemStatusUnknown: {
            _playFailed = YES;
            [self reset];
        }
            break;
        case AVPlayerItemStatusFailed: {
            _playFailed = YES;
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
    _active = NO;
    [self playerPause];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    _active = YES;
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

#pragma mark - set data
- (void)setFrameImage:(UIImage *)frameImage {
    _frameImage = frameImage;
    self.thumbImageView.image = frameImage;
    self.thumbImageView.frame = self.bounds;
}

#pragma mark - get data
- (UIImageView *)thumbImageView {
    if (!_thumbImageView) {
        _thumbImageView = [UIImageView new];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.layer.masksToBounds = YES;
    }
    return _thumbImageView;
}
@end
