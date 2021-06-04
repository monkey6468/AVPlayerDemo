//
//  ViewController.m
//  AVPlayerDemo
//
//  Created by HN on 2021/6/1.
//

#import "ViewController.h"
#import "PlayerViewController.h"
#import "VideoPageViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self onActionPlay:nil];
}


- (IBAction)onActionPlay:(UIButton *)sender {
    PlayerViewController *vc = [[PlayerViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onActionPlayList:(UIButton *)sender {
    VideoPageViewController *vc = [[VideoPageViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
