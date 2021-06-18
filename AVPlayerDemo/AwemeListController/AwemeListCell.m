//
//  AwemeListCell.m
//  AVPlayerDemo
//
//  Created by HN on 2021/6/17.
//

#import "AwemeListCell.h"
#import "AVPlayerView.h"

#import "Utility.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface AwemeListCell ()<AVPlayerUpdateDelegate>

@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UIImageView *pauseIcon;
@property (weak, nonatomic) IBOutlet UIView *playerStatusBar;

@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet UITextView *pathTextView;

@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
//@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (nonatomic, strong) UITapGestureRecognizer *singleTapGesture;

@end

@implementation AwemeListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self initSubViews];
}

- (void)initSubViews {
    //init player view;
    self.playerView = [AVPlayerView new];
    self.playerView.delegate = self;
    [self.contentView addSubview:self.playerView];
    
    [self.contentView insertSubview:self.container aboveSubview:self.playerView];
    
    self.singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.container addGestureRecognizer:self.singleTapGesture];
    
    self.playerView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
}

// cell 重用
- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.isPlayerReady = NO;
    [self.playerView cancelLoading];
    [self.pauseIcon setHidden:YES];
}


//gesture
- (void)handleGesture:(UITapGestureRecognizer *)sender {
    [self singleTapAction];
}

- (void)singleTapAction {
    [self showPauseViewAnim:[self.playerView rate]];
    [self.playerView updatePlayerState];
}

//暂停播放动画
- (void)showPauseViewAnim:(CGFloat)rate {
    if (rate == 0) {
        [UIView animateWithDuration:0.25f
                         animations:^{
            self.pauseIcon.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self.pauseIcon setHidden:YES];
        }];
    } else {
        [self.pauseIcon setHidden:NO];
        self.pauseIcon.transform = CGAffineTransformMakeScale(1.8f, 1.8f);
        self.pauseIcon.alpha = 1.0f;
        [UIView animateWithDuration:0.25f delay:0
                            options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.pauseIcon.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        } completion:^(BOOL finished) {
        }];
    }
}

//加载动画
- (void)startLoadingPlayItemAnim:(BOOL)isStart {
    if (isStart) {
        self.playerStatusBar.backgroundColor = UIColor.whiteColor;
        [self.playerStatusBar setHidden:NO];
        [self.playerStatusBar.layer removeAllAnimations];
        
        CAAnimationGroup *animationGroup = [[CAAnimationGroup alloc]init];
        animationGroup.duration = 0.5;
        animationGroup.beginTime = CACurrentMediaTime() + 0.5;
        animationGroup.repeatCount = MAXFLOAT;
        animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        CABasicAnimation * scaleAnimation = [CABasicAnimation animation];
        scaleAnimation.keyPath = @"transform.scale.x";
        scaleAnimation.fromValue = @(1.0f);
        scaleAnimation.toValue = @(1.0f * ScreenWidth);
        
        CABasicAnimation * alphaAnimation = [CABasicAnimation animation];
        alphaAnimation.keyPath = @"opacity";
        alphaAnimation.fromValue = @(1.0f);
        alphaAnimation.toValue = @(0.5f);
        [animationGroup setAnimations:@[scaleAnimation, alphaAnimation]];
        [self.playerStatusBar.layer addAnimation:animationGroup forKey:nil];
    } else {
        [self.playerStatusBar.layer removeAllAnimations];
        [self.playerStatusBar setHidden:YES];
    }
    
}

#pragma mark - AVPlayerUpdateDelegate
- (void)avPlayerView:(AVPlayerView *)playerView onProgressUpdate:(CGFloat)current total:(CGFloat)total {
    //播放进度更新
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%.2lf", current];
    self.durationLabel.text = [NSString stringWithFormat:@"%.2lf", total];
}

- (void)avPlayerView:(AVPlayerView *)playerView onPlayItemStatusUpdate:(AVPlayerItemStatus)status {
//    switch (status) {
//        case AVPlayerItemStatusUnknown:
//            [self startLoadingPlayItemAnim:YES];
//            break;
//        case AVPlayerItemStatusReadyToPlay:
//            [self startLoadingPlayItemAnim:NO];
//
//            self.isPlayerReady = YES;
//
//            if (self.onPlayerReady) {
//                self.onPlayerReady();
//            }
//            break;
//        case AVPlayerItemStatusFailed:
//            [self startLoadingPlayItemAnim:NO];
//            break;
//        default:
//            break;
//    }
}
- (void)avPlayerView:(AVPlayerView *)playerView playerStatus:(VideoPlayerStatus)status error:(NSError *)error {
        NSLog(@"playerStatus: %ld url: %@", self.index, self.videoUrl);
//    NSLog(@"playerStatus: %ld url: %@", self.index, playerView.videoUrl);
    [Utility videoPlayer:nil
            playerStatus:status
                   error:error
                tipLabel:self.tipLabel];
    if (status == VideoPlayerStatusUnknown) {
        [self startLoadingPlayItemAnim:YES];
    } else if (status == VideoPlayerStatusReadyToPlay) {
        [self startLoadingPlayItemAnim:NO];

        self.isPlayerReady = YES;

        if (self.onPlayerReady) {
            self.onPlayerReady();
        }
    } else if (status == VideoPlayerStatusFailed) {
        [self startLoadingPlayItemAnim:NO];
    }
//    [self playerStatus:status tipLabel:self.tipLabel];
}

- (void)playerStatus:(AVPlayerItemStatus)status
           tipLabel:(UILabel *)tipLabel {
//    NSLog(@"%ld %@",(long)status, error.description);
    if (status == AVPlayerItemStatusUnknown) {
        tipLabel.text = @"视频还未播放";
    } else if (status == AVPlayerItemStatusReadyToPlay) {
        tipLabel.text = @"视频加载中...";
//    } else if (status == VideoPlayerStatusPlaying) {
//        tipLabel.text = @"视频播放中...";
//    } else if (status == VideoPlayerStatusPaused) {
//        tipLabel.text = @"视频已暂停";
//    } else if (status == VideoPlayerStatusFinished) {
//        tipLabel.text = @"视频已结束";
//    } else if (status == VideoPlayerStatusChangeEsolution) {
//        if (player.height/player.width <= 4/3.0) {
//            player.renderMode = VideoRenderModeFillEdge;
//        } else {
//            player.renderMode = VideoRenderModeFillScreen;
//        }
    } else {
        tipLabel.text = @"视频播放中...";
    }
}

- (void)play {
    [self.playerView play];
    [self.pauseIcon setHidden:YES];
}

- (void)pause {
    [self.playerView pause];
    [self.pauseIcon setHidden:NO];
}

- (void)replay {
    [self.playerView replay];
    [self.pauseIcon setHidden:YES];
}

- (void)startDownloadBackgroundTask {
    [self.playerView setPlayerWithUrl:self.videoUrl];

//    self.playerView.videoUrl = self.videoUrl;
//    NSString *playUrl = _videoUrl;
//    [self.playerView setPlayerWithUrl:self.videoUrl];
}

- (void)startDownloadHighPriorityTask {
    [self.playerView startDownloadTask:[[NSURL alloc] initWithString:self.videoUrl] isBackground:NO];
}

#pragma mark - set data
- (void)setVideoUrl:(NSString *)videoUrl {
    _videoUrl = videoUrl;
    self.pathTextView.text = videoUrl;
}

- (void)setIndex:(NSInteger)index {
    _index = index;
    self.indexLabel.text = [NSString stringWithFormat:@"%ld", index];
}

@end
