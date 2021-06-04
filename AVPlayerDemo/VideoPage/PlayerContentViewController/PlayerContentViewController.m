//
//  PlayerContentViewController.m
//  AVPlayerDemo
//
//  Created by HN on 2021/6/4.
//

#import "PlayerContentViewController.h"
#import "VideoPlayer.h"

@interface PlayerContentViewController ()<VideoPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (nonatomic, strong) UILabel *indexLabel;

@property (assign, nonatomic) NSTimeInterval duration;
@property (assign, nonatomic) NSTimeInterval currentTime;

@property (strong, nonatomic) VideoPlayer *videoPlayer;

@property (assign, nonatomic) NSInteger playIndex;
@end

@implementation PlayerContentViewController

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
    
    [self settingUI];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"\n---------\n%li>>>>>>>viewDidDisappear\n---------\n",(long)self.index);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"\n---------\n%li>>>>>>>viewDidAppear\n---------\n",(long)self.index);
}

- (void)dealloc {
    NSLog(@"\n---------\n%li>>>>>>>%s\n---------\n",(long)self.index,__func__);
}

#pragma mark - UI
- (void)settingUI {
    self.view.backgroundColor = [UIColor colorWithRed:(arc4random()%256/255.0) green:(arc4random()%256/255.0) blue:(arc4random()%256/255.0) alpha:1];
    // Do any additional setup after loading the view.
    
    self.indexLabel = [[UILabel alloc] init];
    [self.view addSubview:self.indexLabel];
    self.indexLabel.font = [UIFont boldSystemFontOfSize:100];
    self.indexLabel.text = @(self.index).stringValue;
    self.indexLabel.textColor = [UIColor whiteColor];
//    CGFloat color = 10*self.index/255.f;
//    self.view.backgroundColor = [UIColor colorWithRed:color green:color blue:color alpha:1];
    [self.indexLabel sizeToFit];
    self.indexLabel.center = self.view.center;
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
//    self.playIndex--;
//    if (self.playIndex < 0) {
//        self.playIndex = self.urlsArray.count-1;
//    }
//
//    [self play];
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

    NSString *url = self.url;//self.urlsArray[self.playIndex];
    NSLog(@"url: %@", url);
    
    [self.videoPlayer startPlay:url setPreView:YES];
}

- (IBAction)onActionDown:(UIButton *)sender {
//    self.playIndex++;
//    if (self.playIndex > self.urlsArray.count-1) {
//        self.playIndex = 0;
//    }
//    
//    [self play];
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
            player.contentMode = VideoRenderModeFillScreen;
        } else {
            player.contentMode = VideoRenderModeFillEdge;
        }
    }
}

@end
