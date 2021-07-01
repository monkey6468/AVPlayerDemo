//
//  VideoPlayer.m
//
//  Created by HN on 2021/6/30.
//

#import "VideoPlayer.h"
@interface VideoPlayer ()

@property(nonatomic, strong, readonly) AVPlayerLayer *playerLayer;
//当前播放url
@property(nonatomic, strong) NSURL *url;
//底部控制视图
@property(nonatomic, strong) VideoPlayerControlView *controlView;
//播放状态
@property(nonatomic, assign, readwrite) VideoPlayerStatus status;
//原始约束
@property(nonatomic, strong) NSArray *oldConstriants;
//添加标题
@property(nonatomic, strong) UILabel *titleLabel;
//加载动画
@property(nonatomic, strong) UIActivityIndicatorView *activityIndeView;
@property(nonatomic, assign) BOOL isShouldToHiddenSubviews;
@property(nonatomic, strong) UIButton *playOrPauseButton;
@property(nonatomic, assign) BOOL isFirstPrepareToPlay;
/// 自动播放次数。默认无限循环(NSUIntegerMax)
@property (nonatomic, assign) NSUInteger autoPlayCountTemp;
@property (strong, nonatomic) id playbackTimerObserver;

@end
static NSInteger count = 0;

@implementation VideoPlayer

#pragma mark - life
- (instancetype)initWithUrl:(NSURL *)url {
    if (self = [super init]) {
        _url = url;
        self.autoPlayCountTemp = NSUIntegerMax;
        [self setupPlayerUI];
        [self assetWithURL:url];
    }
    return self;
}

- (void)assetWithURL:(NSURL *)url {
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
    self.anAsset = [[AVURLAsset alloc] initWithURL:url options:options];
    NSArray *keys = @[@"duration"];

    __weak typeof(self) weakSelf = self;
    [self.anAsset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        NSError *error = nil;
        AVKeyValueStatus tracksStatus = [weakSelf.anAsset statusOfValueForKey:@"duration" error:&error];
        switch (tracksStatus) {
            case AVKeyValueStatusLoaded: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!CMTIME_IS_INDEFINITE(weakSelf.anAsset.duration)) {
                        if (weakSelf.anAsset.duration.timescale > 0) {
                            CGFloat second = weakSelf.anAsset.duration.value /
                            weakSelf.anAsset.duration.timescale;
                            weakSelf.controlView.totalTime =
                            [weakSelf convertTime:second];
                            weakSelf.controlView.minValue = 0;
                            weakSelf.controlView.maxValue = second;
                        }
                    }
                });
            } break;
            case AVKeyValueStatusFailed: {
                // NSLog(@"AVKeyValueStatusFailed失败,请检查网络,或查看plist中是否添加App
                // Transport Security Settings");
            } break;
            case AVKeyValueStatusCancelled: {
                NSLog(@"AVKeyValueStatusCancelled取消");
            } break;
            case AVKeyValueStatusUnknown: {
                NSLog(@"AVKeyValueStatusUnknown未知");
            } break;
            case AVKeyValueStatusLoading: {
                NSLog(@"AVKeyValueStatusLoading正在加载");
            } break;
        }
    }];

    [self setupPlayerWithAsset:self.anAsset];
}

- (void)setupPlayerWithAsset:(AVURLAsset *)asset {
    self.item = [[AVPlayerItem alloc] initWithAsset:asset];
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.item];
    [self.playerLayer displayIfNeeded];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self addPeriodicTimeObserver];
    //添加KVO
    [self addKVO];
    //添加消息中心
    [self addNotificationCenter];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
    [self stop];
}

#pragma mark - other
// FIXME: Tracking time,跟踪时间的改变
- (void)addPeriodicTimeObserver {
    __weak typeof(self) weakSelf = self;
    self.playbackTimerObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1000.0)
                                                                           queue:dispatch_get_main_queue()
                                                                      usingBlock:^(CMTime time) {
        if (weakSelf.item.status == AVPlayerItemStatusReadyToPlay) {
            if (weakSelf.controlView.isTouchingSlider == NO) {
                if (weakSelf.isPlaying) {
                    weakSelf.controlView.value = weakSelf.item.currentTime.value /(CGFloat) weakSelf.item.currentTime.timescale;
                } else {
                    if (weakSelf.status != VideoPlayerStatusPaused) {
                        weakSelf.controlView.value = 0;
                    }
                }
            }
            
            if (!CMTIME_IS_INDEFINITE(weakSelf.anAsset.duration)) {
                weakSelf.controlView.currentTime = [weakSelf convertTime:weakSelf.controlView.value];
            }
            if (count >= 500) {
                [weakSelf setSubViewsIsHide:YES];
                if ([weakSelf.delegate respondsToSelector:@selector(playerTapActionWithIsShouldToHideSubviews:)]) {
                    [weakSelf.delegate playerTapActionWithIsShouldToHideSubviews:YES];
                }
            } else {
                if ([weakSelf.delegate respondsToSelector:@selector(playerTapActionWithIsShouldToHideSubviews:)]) {
                    [weakSelf.delegate playerTapActionWithIsShouldToHideSubviews:NO];
                }
            }
            count += 1;
        }
    }];
}

// TODO: KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus itemStatus =
        [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        
        switch (itemStatus) {
            case AVPlayerItemStatusUnknown: {
                self.status = VideoPlayerStatusUnknown;
                NSLog(@"AVPlayerItemStatusUnknown");
            } break;
            case AVPlayerItemStatusReadyToPlay: {
                self.status = VideoPlayerStatusReadyToPlay;
                NSLog(@"AVPlayerItemStatusReadyToPlay");
            } break;
            case AVPlayerItemStatusFailed: {
                self.status = VideoPlayerStatusFailed;
                NSLog(@"AVPlayerItemStatusFailed");
            } break;
            default:
                break;
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) { //监听播放器的下载进度
        NSArray *loadedTimeRanges = [self.item loadedTimeRanges];
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue]; // 获取缓冲区域
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval timeInterval =
        startSeconds + durationSeconds; // 计算缓冲总进度
        CMTime duration = self.item.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        //缓存值
        self.controlView.bufferValue = timeInterval / totalDuration;
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) { //监听播放器在缓冲数据的状态
        self.status = VideoPlayerStatusBuffering;
        if (self.player.status == VideoPlayerStatusPlaying ||
            self.player.status == AVPlayerStatusReadyToPlay) {
            return;
        }
        if (!self.activityIndeView.isAnimating) {
            [self setSubViewsIsHide:YES];
            self.activityIndeView.hidden = NO;
            [self.activityIndeView startAnimating];
        }
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        if (self.isFirstPrepareToPlay) {
            NSLog(@"缓冲达到可播放");
            [self.activityIndeView stopAnimating];
            self.activityIndeView.hidden = YES;
            [self setSubViewsIsHide:YES];
            //改动
            // self.pauseOrPlayView.hidden = YES;
            [self play];
            self.isFirstPrepareToPlay = NO;
        }
    } else if ([keyPath isEqualToString:@"rate"]) { //当rate==0时为暂停,rate==1时为播放,当rate等于负数时为回放
        if ([[change objectForKey:NSKeyValueChangeNewKey] integerValue] == 0) {
            _isPlaying = false;
            self.status = VideoPlayerStatusPaused;
        } else {
            _isPlaying = true;
            self.status = VideoPlayerStatusPlaying;
        }
    }
}

//添加KVO
- (void)addKVO {
    if (self.item || self.item != nil) {
        //监听状态属性
        [self.item addObserver:self
                    forKeyPath:@"status"
                       options:NSKeyValueObservingOptionNew
                       context:nil];
        //监听网络加载情况属性
        [self.item addObserver:self
                    forKeyPath:@"loadedTimeRanges"
                       options:NSKeyValueObservingOptionNew
                       context:nil];
        //监听播放的区域缓存是否为空
        [self.item addObserver:self
                    forKeyPath:@"playbackBufferEmpty"
                       options:NSKeyValueObservingOptionNew
                       context:nil];
        //缓存可以播放的时候调用
        [self.item addObserver:self
                    forKeyPath:@"playbackLikelyToKeepUp"
                       options:NSKeyValueObservingOptionNew
                       context:nil];
    }
    if (self.player || self.player != nil) {
        //监听暂停或者播放中
        [self.player addObserver:self
                      forKeyPath:@"rate"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    }
}

// MARK:添加消息中心
- (void)addNotificationCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.player currentItem]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)removeNotificationCenter {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[self.player currentItem]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

// MARK: NotificationCenter
- (void)playerItemDidPlayToEndTimeNotification:(NSNotification *)notification {
    [self.item seekToTime:kCMTimeZero];
    count = 0;
    [self pause];
    [self.playOrPauseButton setSelected:NO];
    
    //重新播放视频
    if (self.autoPlayCountTemp == NSUIntegerMax) {
        [self play];
    } else {
        --self.autoPlayCountTemp;
        if (self.autoPlayCountTemp > 0) {
            [self play];
        }
    }
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    UIInterfaceOrientation _interfaceOrientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    switch (_interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight: {
            _isFullScreen = YES;
            if (!self.oldConstriants) {
                self.oldConstriants = [self getCurrentVC].view.constraints;
            }
            [self.controlView updateConstraintsIfNeeded];
            //删除UIView animate可以去除横竖屏切换过渡动画
            [UIView animateWithDuration:kTransitionTime delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0. options:UIViewAnimationOptionTransitionCurlUp animations:^{
                [[UIApplication sharedApplication].keyWindow addSubview:self];
//                [self
//                mas_makeConstraints:^(MASConstraintMaker
//                *make) {
//                    make.edges.mas_equalTo([UIApplication
//                    sharedApplication].keyWindow);
//                }];
                [self layoutIfNeeded];
            }
                             completion:nil];
        } break;
        case UIInterfaceOrientationPortraitUpsideDown:
        case UIInterfaceOrientationPortrait: {
            _isFullScreen = NO;
            //删除UIView animate可以去除横竖屏切换过渡动画
            [UIView animateKeyframesWithDuration:kTransitionTime delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear
             animations:^{
//                [self
//                mas_remakeConstraints:^(MASConstraintMaker
//                *make) {
//                    make.top.left.right.bottom.mas_equalTo(self.playerSuperView);
//                }];
                [self layoutIfNeeded];
            }
             completion:nil];
        } break;
        case UIInterfaceOrientationUnknown:
            NSLog(@"UIInterfaceOrientationUnknown");
            break;
    }
    [[self getCurrentVC].view layoutIfNeeded];
}

- (void)willResignActive:(NSNotification *)notification {
    if (self.isPlaying) {
        [self setSubViewsIsHide:NO];
        count = 0;
        [self pause];
        [self.playOrPauseButton setSelected:NO];
    }
}

- (void)willEnterForeground:(NSNotification *)notification {
    if (!self.isPlaying) {
        [self setSubViewsIsHide:YES];
        count = 5;
        [self play];
        [self.playOrPauseButton setSelected:YES];
    }
}

// MARK: 设置界面 在此方法下面可以添加自定义视图，和删除视图
- (void)setupPlayerUI {
    [self setSubViewsIsHide:YES];
    self.activityIndeView.hidden = NO;
    [self.activityIndeView startAnimating];
    //添加标题
    [self addSubview:self.titleLabel];
    //添加点击事件
    [self addGestureEvent];
    //添加控制视图
    [self addSubview:self.controlView];
    //添加加载视图
    [self addSubview:self.activityIndeView];
    //初始化时间
    [self initTimeLabels];
    //播放暂停
    [self addSubview:self.playOrPauseButton];
    self.playOrPauseButton.hidden = YES;
    self.isFirstPrepareToPlay = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.controlView.center = self.center;
    self.controlView.frame =
    CGRectMake(0, self.frame.size.height - 44, self.frame.size.width, 44);
    
    self.activityIndeView.center = self.center;
    self.activityIndeView.bounds = CGRectMake(0, 0, 80, 80);
    
    self.playOrPauseButton.center = self.center;
    self.playOrPauseButton.bounds = CGRectMake(0, 0, 70, 70);
}

//初始化时间
- (void)initTimeLabels {
    self.controlView.currentTime = @"00:00";
    self.controlView.totalTime = @"00:00";
}

//添加点击事件
- (void)addGestureEvent {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(handleTapAction:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
}
- (void)handleTapAction:(UITapGestureRecognizer *)gesture {
    if (self.isHidenAllSubviews) {
        if ([self.delegate respondsToSelector:@selector
             (playerTapActionWithCurrentTimeValue:)]) {
            [self.delegate
             playerTapActionWithCurrentTimeValue:self.controlView.value];
        }
    } else {
        self.isShouldToHiddenSubviews = !self.isShouldToHiddenSubviews;
        if (self.isShouldToHiddenSubviews) {
            [self setSubViewsIsHide:NO];
            count = 0;
            if ([self.delegate respondsToSelector:@selector
                 (playerTapActionWithIsShouldToHideSubviews:)]) {
                [self.delegate playerTapActionWithIsShouldToHideSubviews:NO];
            }
        } else {
            
            [self setSubViewsIsHide:YES];
            count = 5;
            if ([self.delegate respondsToSelector:@selector
                 (playerTapActionWithIsShouldToHideSubviews:)]) {
                [self.delegate playerTapActionWithIsShouldToHideSubviews:YES];
            }
        }
    }
}

- (void)playOrPauseButtonClick:(UIButton *)button {
    if (self.activityIndeView.isAnimating) {
        [self.activityIndeView stopAnimating];
        self.activityIndeView.hidden = YES;
    }
    if (!self.isPlaying) {
        [self play];
    } else {
        [self pause];
    }
}

#pragma mark - VideoPlayerControlViewDelegate
- (void)controlView:(VideoPlayerControlView *)controlView pointSliderLocationWithCurrentValue:(CGFloat)value {
    count = 0;
    CMTime pointTime = CMTimeMake(value * self.item.currentTime.timescale,
                                  self.item.currentTime.timescale);
    [self.item seekToTime:pointTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)controlView:(VideoPlayerControlView *)controlView draggedPositionWithSlider:(UISlider *)slider {
    count = 0;
    CMTime pointTime =
    CMTimeMake(controlView.value * self.item.currentTime.timescale,
               self.item.currentTime.timescale);
    [self.item seekToTime:pointTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)setPlayerTimeValueTo:(CGFloat)value {
    CMTime pointTime = CMTimeMake(value * self.item.currentTime.timescale, self.item.currentTime.timescale);
    [self.item seekToTime:pointTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)controlView:(VideoPlayerControlView *)controlView
    withLargeButton:(UIButton *)button {
    count = 0;
    if ([UIScreen mainScreen].bounds.size.width <
        [UIScreen mainScreen].bounds.size.height) {
        [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
    } else {
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
    }
}

// MARK: UIGestureRecognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[VideoPlayerControlView class]]) {
        return NO;
    }
    return YES;
}

//将数值转换成时间
- (NSString *)convertTime:(CGFloat)second {
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second / 3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}

//旋转方向
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice]
         respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        UIInterfaceOrientation val = orientation;
        
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    if (orientation == UIInterfaceOrientationLandscapeRight ||
        orientation == UIInterfaceOrientationLandscapeLeft) {
        // 设置横屏
    } else if (orientation == UIInterfaceOrientationPortrait) {
        // 设置竖屏
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        //
    }
}

#pragma mark - player operation
- (void)play {
    if (self.player) {
        [self.player play];
        [self.playOrPauseButton setSelected:YES];
    }
}

- (void)pause {
    if (self.player) {
        self.status = VideoPlayerStatusPaused;
        [self.player pause];
        [self.playOrPauseButton setSelected:NO];
    }
}

- (void)stop {
    if (self.item || self.item != nil) {
        [self.item removeObserver:self forKeyPath:@"status"];
        [self.item removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [self.item removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [self.item removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
    if (self.player || self.player != nil) {
        [self.player removeTimeObserver:self.playbackTimerObserver];
        [self.player removeObserver:self forKeyPath:@"rate"];
    }
    
    [self removeNotificationCenter];
    
    if (self.player) {
        [self pause];
        self.anAsset = nil;
        self.item = nil;
        self.controlView.value = 0;
        self.controlView.currentTime = @"00:00";
        self.controlView.totalTime = @"00:00";
        self.player = nil;
        [self.activityIndeView stopAnimating];
        [self.activityIndeView removeFromSuperview];
        self.activityIndeView = nil;
        [self removeFromSuperview];
    }
}

#pragma mark - get data
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return self.playerLayer.player;
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

- (CGFloat)rate {
    return self.player.rate;
}

- (NSString *)title {
    return self.titleLabel.text;
}

- (UIButton *)playOrPauseButton {
    if (!_playOrPauseButton) {
        _playOrPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playOrPauseButton setImage:[UIImage imageNamed:@"播放按钮"]
                            forState:UIControlStateNormal];
        [_playOrPauseButton setShowsTouchWhenHighlighted:YES];
        [_playOrPauseButton setImage:[UIImage imageNamed:@"播放按钮 暂停"]
                            forState:UIControlStateSelected];
        [_playOrPauseButton addTarget:self
                               action:@selector(playOrPauseButtonClick:)
                     forControlEvents:UIControlEventTouchUpInside];
    }
    return _playOrPauseButton;
}

//懒加载控制视图
- (VideoPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [[VideoPlayerControlView alloc] init];
        _controlView.delegate = self;
        _controlView.backgroundColor = [UIColor clearColor];
    }
    return _controlView;
}

//懒加载ActivityIndicateView
- (UIActivityIndicatorView *)activityIndeView {
    if (!_activityIndeView) {
        _activityIndeView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityIndeView.hidesWhenStopped = YES;
    }
    return _activityIndeView;
}

//懒加载标题
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC {
    UIViewController *result = nil;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow *tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    return result;
}

#pragma mark - set data
- (void)setPlayer:(AVPlayer *)player {
    self.playerLayer.player = player;
}

- (void)setRate:(CGFloat)rate {
    self.player.rate = rate;
}

- (void)setMode:(VideoPlayerGravity)mode {
    switch (mode) {
        case VideoPlayerGravityResizeAspect:
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            break;
        case VideoPlayerGravityResizeAspectFill:
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            break;
        case VideoPlayerGravityResize:
            self.playerLayer.videoGravity = AVLayerVideoGravityResize;
            break;
    }
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)setIsHidenAllSubviews:(BOOL)isHidenAllSubviews {
    _isHidenAllSubviews = isHidenAllSubviews;
    if (isHidenAllSubviews) {
        [self.controlView removeFromSuperview];
        [self.playOrPauseButton removeFromSuperview];
        [self.titleLabel removeFromSuperview];
        self.player.volume = 0;
    }
}

//设置子视图是否隐藏
- (void)setSubViewsIsHide:(BOOL)isHide {
    self.controlView.hidden = isHide;
    self.playOrPauseButton.hidden = isHide;
    self.titleLabel.hidden = isHide;
}

- (void)setAutoPlayCount:(NSUInteger)autoPlayCount {
    _autoPlayCount = autoPlayCount;
    self.autoPlayCountTemp = autoPlayCount;
}
@end
