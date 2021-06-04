//
//  ViewController.m
//  AVPlayerDemo
//
//  Created by HN on 2021/6/1.
//

#import "ViewController.h"
#import "PlayerViewController.h"
#import "VideoPageViewController.h"

#import "Utility.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self onActionPlay:nil];
    [self onActionPlayList:nil];
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

@end
