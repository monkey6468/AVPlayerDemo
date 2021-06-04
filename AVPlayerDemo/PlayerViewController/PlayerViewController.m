//
//  PlayerViewController.m
//  AVPlayerDemo
//
//  Created by HN on 2021/6/2.
//

#import "PlayerViewController.h"
#import "VideoPlayer.h"

@interface PlayerViewController ()<VideoPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (assign, nonatomic) NSTimeInterval duration;
@property (assign, nonatomic) NSTimeInterval currentTime;

@property (strong, nonatomic) VideoPlayer *videoPlayer;

@property (assign, nonatomic) NSInteger playIndex;
@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.playIndex = 0;
    
    self.videoPlayer = [[VideoPlayer alloc]init];
    self.videoPlayer.delegate = self;
    self.videoPlayer.frame = self.playerView.bounds;
    [self.playerView addSubview:self.videoPlayer];
//    [self.videoPlayer setRate:3];
//    self.videoPlayer.contentMode = VideoRenderModeFillScreen;
    self.videoPlayer.autoPlayCount = NSUIntegerMax;
    [self onActionPlay:self.playButton];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (IBAction)onActionStop:(UIButton *)sender {
    [self.videoPlayer playerStop];
    
    [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
    [self videoPlayer:self.videoPlayer duration:0 currentTime:0];
}

- (IBAction)onActionJump:(UIButton *)sender {
    CGFloat time = self.videoPlayer.currentTime;
    [self.videoPlayer seekToTime:time+4];
 }

- (IBAction)onActionUp:(UIButton *)sender {
    self.playIndex--;
    if (self.playIndex < 0) {
        self.playIndex = self.urlsArray.count-1;
    }
    
    [self play];
}

- (IBAction)onActionPlay:(UIButton *)sender {
    
    if ([sender.titleLabel.text isEqualToString:@"播放"]) {
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
        [self play];
    } else if ([sender.titleLabel.text isEqualToString:@"暂停"]) {
        [sender setTitle:@"继续" forState:UIControlStateNormal];
        [self.videoPlayer playerPause];
    } else if ([sender.titleLabel.text isEqualToString:@"继续"]) {
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
        [self.videoPlayer playerResume];
    }
    
}

- (void)play {
    [self.videoPlayer playerStop];
    [self videoPlayer:self.videoPlayer duration:0 currentTime:0];

    NSString *url = self.urlsArray[self.playIndex];
    NSLog(@"url: %@", url);
    
    [self.videoPlayer startPlay:url setPreView:YES];
}

- (IBAction)onActionDown:(UIButton *)sender {
    self.playIndex++;
    if (self.playIndex > self.urlsArray.count-1) {
        self.playIndex = 0;
    }
    
    [self play];
}



#pragma mark - VideoPlayerDelegate
- (void)videoPlayer:(VideoPlayer *)player duration:(NSTimeInterval)duration currentTime:(NSTimeInterval)currentTime {
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%0.2lf", currentTime];
    self.durationLabel.text = [NSString stringWithFormat:@"%0.2lf", duration];
//    NSLog(@"----allTime:%f--------currentTime:%f----progress:%f---",duration,currentTime,currentTime/duration);
}

- (void)videoPlayerPaused:(VideoPlayer *)player {
    NSLog(@"%s",__func__);
}

- (void)videoPlayerFinished:(VideoPlayer *)player {
    NSLog(@"%s",__func__);
}

- (void)videoPlayer:(VideoPlayer *)player playerStatus:(VideoPlayerStatus)playerStatus error:(NSError *)error {
//    NSLog(@"%ld %@",(long)playerStatus, error.description);
    if (playerStatus == VideoPlayerStatusReady) {
        self.tipLabel.text = @"视频加载中...";
    } else if (playerStatus == VideoPlayerStatusPlaying) {
        self.tipLabel.text = @"视频播放中...";
    } else if (playerStatus == VideoPlayerStatusPaused) {
        self.tipLabel.text = @"视频已暂停";
    } else if (playerStatus == VideoPlayerStatusFinished) {
        self.tipLabel.text = @"视频已结束";
    } else if (playerStatus == VideoPlayerStatusChangeEsolution) {
        if (player.height/player.width <= 4/3.0) {
            player.contentMode = VideoRenderModeFillEdge;
        } else {
            player.contentMode = VideoRenderModeFillScreen;
        }
    }
}

@end
