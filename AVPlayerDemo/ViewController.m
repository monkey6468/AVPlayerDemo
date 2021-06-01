//
//  ViewController.m
//  AVPlayerDemo
//
//  Created by HN on 2021/6/1.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) UIImageView *videoPlayImageView;
@property (nonatomic, assign) CMTime currentTime;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self clearNavigationBackground:[UIColor clearColor]];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = backBtn;
    
    [self bindData];
    [self observePlayProgress];
}

- (void)bindData {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
}

static char overViewKey;

- (UIView *)overView
{
    return objc_getAssociatedObject(self, &overViewKey);
}

- (void)setOverView:(UIView *)overView
{
    objc_setAssociatedObject(self, &overViewKey, overView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)clearNavigationBackground:(UIColor *)backgroundColor {
    if (!self.overView) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.overView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.navigationController.navigationBar.bounds), CGRectGetHeight(self.navigationController.navigationBar.bounds))];
        self.overView.userInteractionEnabled = NO;
        [self.navigationController.navigationBar.subviews.firstObject insertSubview:self.overView atIndex:0];
        self.overView.bounds = self.navigationController.navigationBar.subviews.firstObject.bounds;
    }
    self.overView.backgroundColor = backgroundColor;
}

- (void)observePlayProgress{
    [self.playerLayer removeFromSuperlayer];
    [self.view.layer addSublayer:self.playerLayer];
    __weak typeof(self) wSelf = self;
    [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        NSArray *loadedRanges = wSelf.avPlayer.currentItem.seekableTimeRanges;
        if (loadedRanges.copy > 0) {
            NSTimeInterval currentTime = CMTimeGetSeconds(wSelf.avPlayer.currentItem.currentTime);
            NSTimeInterval duration = CMTimeGetSeconds(wSelf.avPlayer.currentItem.duration);
            NSLog(@"----allTime:%f--------currentTime:%f----progress:%f---",duration,currentTime,currentTime/duration);
            if (currentTime >= duration) {
                [wSelf playerReplay];
            }
        }
    }];
}

#pragma mark - KVO
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

- (UIImage *)getFirstImageofvideo {
    AVAsset *asset = nil;
    AVAssetImageGenerator *imageGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    if (imageGen) {
        imageGen.appliesPreferredTrackTransform = YES;
        CMTime actualTime;
        CGImageRef cgImage = [imageGen copyCGImageAtTime:CMTimeMakeWithSeconds(0, 30) actualTime:&actualTime error:nil];
        if (cgImage) {
            UIImage *image = [UIImage imageWithCGImage:cgImage];
            CGImageRelease(cgImage);
            return image;
        }
    }
    return nil;
}

#pragma mark - Player
- (AVPlayer *)avPlayer {
    if (!_avPlayer) {
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:@"https://video.cnhnb.com/video/mp4/douhuo/2021/03/24/59fa99dc757a4d44b3a09e5fdcd9d6e3.mp4"]];
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
        _playerLayer.frame = self.view.bounds;
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
