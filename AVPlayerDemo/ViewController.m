//
//  ViewController.m
//  AVPlayerDemo
//
//  Created by HN on 2021/6/1.
//

#import "ViewController.h"
#import "VideoListViewController.h"
#import "DYVideoListViewController.h"
#import "AwemeListController.h"

#import "Utility.h"
#import "CacheHelpler.h"
#import "SDImageCache.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self onActionPlay:nil];
    [self onActionAwemeList:nil];
}

- (IBAction)onActionWeiboPlay:(UIButton *)sender {
    VideoListViewController *vc = [[VideoListViewController alloc]init];
    vc.urlsArray = [Utility getUrls];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onActionAwemeList:(UIButton *)sender {
    DYVideoListViewController *vc = [[DYVideoListViewController alloc]init];
    vc.urlsArray = [Utility getUrls];
    [self.navigationController pushViewController:vc animated:YES];
//    AwemeListController *vc = [[AwemeListController alloc]init];
//    vc.urlsArray = [Utility getUrls];
//    vc.modalPresentationStyle = UIModalPresentationFullScreen;
//    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)onActionClearCache:(UIButton *)sender {
    //获取缓存图片的大小(字节)
    NSUInteger bytesCache = [[SDImageCache sharedImageCache] totalDiskSize];
    
    //换算成 MB (注意iOS中的字节之间的换算是1000不是1024)
    float MBCache = bytesCache/1000./1000.;
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        NSLog(@"异步清除图片缓存: %lf MB",MBCache);
    }];
}

@end
