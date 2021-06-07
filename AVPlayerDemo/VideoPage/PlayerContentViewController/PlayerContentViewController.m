//
//  PlayerContentViewController.m
//  AVPlayerDemo
//
//  Created by HN on 2021/6/4.
//

#import "PlayerContentViewController.h"

#import "Utility.h"

@interface PlayerContentViewController ()<VideoPlayerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *containtView;

@property (nonatomic, strong) UILabel *indexLabel;
@end

@implementation PlayerContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self settingUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self settingPlayer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    NSLog(@"\n---------\n%li>>>>>>>viewDidDisappear\n---------\n",(long)self.index);
    if (self.videoPlayer.status == VideoPlayerStatusPlaying) {
        [self.videoPlayer playerPause];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    NSLog(@"\n---------\n%li>>>>>>>viewDidAppear\n---------\n",(long)self.index);
//    NSTimeInterval startTime = CFAbsoluteTimeGetCurrent();
//    NSTimeInterval time = startTime-self.enterTime;
//    NSLog(@"time: %lf",time);
    if (self.videoPlayer == nil) return;
    
    if (self.videoPlayer.status != VideoPlayerStatusPlaying) {
        self.textView.text = self.url;
        [self.videoPlayer playerStart];
    }
}

- (void)dealloc {
//    NSLog(@"\n---------\n%li>>>>>>>%s\n---------\n",(long)self.index,__func__);
    self.videoPlayer = nil;
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
    self.indexLabel.textAlignment = NSTextAlignmentCenter;
    self.indexLabel.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
}
 
- (void)settingPlayer {
    self.videoPlayer = [[VideoPlayer alloc]init];
    self.videoPlayer.delegate = self;
    self.videoPlayer.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    [self.view addSubview:self.videoPlayer];
    
//    [self.videoPlayer setRate:3];
//    self.videoPlayer.renderMode = VideoRenderModeFillScreen;
    self.videoPlayer.autoPlayCount = NSUIntegerMax;
    [self onActionPlay:self.playButton];
    
    [self.view insertSubview:self.containtView aboveSubview:self.videoPlayer];
    [self.view insertSubview:self.indexLabel aboveSubview:self.videoPlayer];
}

#pragma mark - other
- (IBAction)onActionBack:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
 }

- (IBAction)onActionStop:(UIButton *)sender {
    [self.videoPlayer playerStop];
    
    [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
}

- (IBAction)onActionJump:(UIButton *)sender {
    CGFloat time = self.videoPlayer.currentTime;
    [self.videoPlayer seekToTime:time+4];
 }

- (IBAction)onActionPlay:(UIButton *)sender {
    
    if ([sender.titleLabel.text isEqualToString:@"播放"]) {
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
        if (self.videoPlayer.status == VideoPlayerStatusFinished) {
            [self.videoPlayer playerStart];
        } else {
            [self playReady];
        }
    } else if ([sender.titleLabel.text isEqualToString:@"暂停"]) {
        [sender setTitle:@"继续" forState:UIControlStateNormal];
        [self.videoPlayer playerPause];
    } else if ([sender.titleLabel.text isEqualToString:@"继续"]) {
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
        [self.videoPlayer playerResume];
    }
    
}

- (void)playReady {
    if (self.videoPlayer.status != VideoPlayerStatusUnknown
        ||self.videoPlayer.status != VideoPlayerStatusFailed
        || self.videoPlayer.status != VideoPlayerStatusFinished) {
        [self.videoPlayer playerStop];
    }

    NSString *url = self.url;
    NSLog(@"playReady index:%ld url: %@",self.index, url);
    self.videoPlayer.preViewImageUrl = [Utility getFrameImagePathWithVideoPath:url showWatermark:YES];
    self.videoPlayer.videoUrl = url;
//    self.enterTime = CFAbsoluteTimeGetCurrent();
}



#pragma mark - VideoPlayerDelegate
- (void)videoPlayer:(VideoPlayer *)player duration:(NSTimeInterval)duration currentTime:(NSTimeInterval)currentTime {
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%0.2lf", currentTime];
    self.durationLabel.text = [NSString stringWithFormat:@"%0.2lf", duration];
//    NSLog(@"----allTime:%f--------currentTime:%f----progress:%f---",duration,currentTime,currentTime/duration);
}

- (void)videoPlayer:(VideoPlayer *)player playerStatus:(VideoPlayerStatus)status error:(NSError *)error {
//    if (self.bLeave == YES) {
//        self.videoPlayer = nil;
////        [self.videoPlayer playerPause];
//        return;
//    };

    NSLog(@"playerStatus: %ld url: %@", self.index, player.videoUrl);
    [Utility videoPlayer:player
            playerStatus:status
                   error:error
                tipLabel:self.tipLabel];
}

@end
