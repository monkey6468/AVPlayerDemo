//
//  ViewController.m
//  AVPlayerDemo
//
//  Created by HN on 2021/6/1.
//

#import "ViewController.h"
#import "PlayerViewController.h"
#import "VideoPageViewController.h"
#import "JPVideoPlayerWeiBoListViewController.h"
#import "AwemeListController.h"

#import "Utility.h"
#import "CacheHelpler.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self onActionPlay:nil];
//    [self onActionAwemeList:nil];
}


- (IBAction)onActionPlay:(UIButton *)sender {
    PlayerViewController *vc = [[PlayerViewController alloc]init];
    vc.urlsArray = [Utility getUrls];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)onActionPlayList:(UIButton *)sender {
    VideoPageViewController *vc = [[VideoPageViewController alloc]init];
    vc.urlsArray = [Utility getUrls];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)onActionWeiboPlay:(UIButton *)sender {
    JPVideoPlayerWeiBoListViewController *vc = [[JPVideoPlayerWeiBoListViewController alloc] initWithPlayStrategyType:JPScrollPlayStrategyTypeBestVideoView];
//    vc.urlsArray = [Utility getUrls];
//    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onActionAwemeList:(UIButton *)sender {
    AwemeListController *vc = [[AwemeListController alloc]init];
    vc.urlsArray = [Utility getUrls];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)onActionClearCache:(UIButton *)sender {
    [[CacheHelpler sharedWebCache] clearCache:^(NSString *cacheSize) {
        NSLog(@"%@",cacheSize);
    }];
}

@end
