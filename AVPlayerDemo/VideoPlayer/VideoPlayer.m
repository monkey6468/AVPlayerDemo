//
//  VideoPlayer.m
//  AVPlayerDemo
//
//  Created by HN on 2021/6/1.
//

#import "VideoPlayer.h"

#import <AVFoundation/AVFoundation.h>

#import <objc/runtime.h>

@interface VideoPlayer ()

@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, assign) CMTime currentTime;

@property (strong, nonatomic) UIView *playView;
@property (copy, nonatomic) NSString *url; /// 视频播放地址
@property (nonatomic, strong) UIImageView *videoPlayImageView;

@end

@implementation VideoPlayer

- (void)showInView:(UIView *)playView {
    self.playView = playView;
    [self initConfig];
    
    UIImage *image = [self getFirstFrameWithVideoWithURL:self.url size:playView.frame.size];
    if (self.videoPlayImageView) {
        self.videoPlayImageView.frame = CGRectMake(0, 0, playView.frame.size.width, playView.frame.size.height);
        [self.playerLayer addSublayer:self.videoPlayImageView.layer];
        self.videoPlayImageView.image = image;
    }
}

#pragma mark ---- 获取图片第一帧
- (UIImage *)getFirstFrameWithVideoWithURL:(NSString *)url size:(CGSize)size
{
    // 获取视频第一帧
    NSURL *videoUrl = [NSURL URLWithString:url];
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoUrl options:opts];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(size.width, size.height);
    NSError *error = nil;
    CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(0, 10) actualTime:NULL error:&error];
    return [UIImage imageWithCGImage:img];
}

#pragma mark - life
- (instancetype)initWithUrl:(NSString *)url {
    if (self = [super init]) {
        self.url = url;
    }
    return self;
}

- (void)dealloc {
    [self clearPlayer];
}

- (void)initConfig {
//    [self clearNavigationBackground:[UIColor clearColor]];

//    [self addNotify];
    [self addObservePlayProgress];
}

#pragma mark - UI
//- (void)clearNavigationBackground:(UIColor *)backgroundColor {
//    if (!self.overView) {
//        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//        self.overView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.navigationController.navigationBar.bounds), CGRectGetHeight(self.navigationController.navigationBar.bounds))];
//        self.overView.userInteractionEnabled = NO;
//        [self.navigationController.navigationBar.subviews.firstObject insertSubview:self.overView atIndex:0];
//        self.overView.bounds = self.navigationController.navigationBar.subviews.firstObject.bounds;
//    }
//    self.overView.backgroundColor = backgroundColor;
//}

#pragma mark - other
- (void)addNotify {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
}

#pragma mark KVO
- (void)addObservePlayProgress {
    [self.playerLayer removeFromSuperlayer];
    [self.playView.layer addSublayer:self.playerLayer];

    __weak typeof(self) wSelf = self;
    [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        NSArray *loadedRanges = wSelf.avPlayer.currentItem.seekableTimeRanges;
        if (loadedRanges.copy > 0) {
            wSelf.videoPlayImageView.hidden = YES;
            
            NSTimeInterval currentTime = CMTimeGetSeconds(wSelf.avPlayer.currentItem.currentTime);
            NSTimeInterval duration = CMTimeGetSeconds(wSelf.avPlayer.currentItem.duration);
            NSLog(@"----allTime:%f--------currentTime:%f----progress:%f---",duration,currentTime,currentTime/duration);
            if (currentTime >= duration) {
                [wSelf playerReplay];
            }
        }
    }];
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//    NSLog(@"=======================keyPath:%@\n,object:%@\n,change:%@\n,context:%@\n",keyPath,object,change,context);
//    //[self.avPlayer play];
//}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"=======================keyPath:%@\n,object:%@\n,change:%@\n,context:%@\n",keyPath,object,change,context);
    if (context == nil) {
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark player opearation
- (void)appBecomeActive {
    @try {
        [self.avPlayer seekToTime:self.currentTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            if (finished) {
                [self.avPlayer play];
            }
        }];
    } @catch (NSException *exception) {
        [self.avPlayer play];
    } @finally {
    }
}

- (void)appWillResignActive {
    if (self.avPlayer) {
        [self.avPlayer pause];
        self.currentTime = self.avPlayer.currentTime;
    }
}

- (void)playPause {
    if (self.avPlayer) {
        [self.avPlayer pause];
    }
}

- (void)playerReplay {
//    [self.avPlayer seekToTime:CMTimeMake(0, 1)];
//    [self.avPlayer play];
    [self.avPlayer seekToTime:CMTimeMake(0, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        [self.avPlayer play];
    }];
}

- (void)clearPlayer {
    [self.avPlayer.currentItem removeObserver:self forKeyPath:@"status"];
    [self.avPlayer pause];
    self.avPlayer = nil;
}


#pragma mark - get data
- (AVPlayer *)avPlayer {
    if (!_avPlayer) {
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:self.url]];
        if (playerItem) {
            [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
            //[playerItem removeObserver:self forKeyPath:@"status"];
            _avPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
            [_avPlayer play];
        }
    }
    return _avPlayer;
}

- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
        _playerLayer.frame = self.playView.bounds;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;    //视频填充模式
    }
    return _playerLayer;
}

- (UIImageView *)videoPlayImageView {
    if (!_videoPlayImageView) {
        _videoPlayImageView = [UIImageView new];
        _videoPlayImageView.layer.shadowColor = [UIColor grayColor].CGColor;
        _videoPlayImageView.layer.shadowOffset = CGSizeMake(1, 1);
        _videoPlayImageView.layer.shadowOpacity = 1;
    }
    return _videoPlayImageView;
}

@end
