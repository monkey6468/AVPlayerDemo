//
//  PlayerContentViewController.h
//  AVPlayerDemo
//
//  Created by HN on 2021/6/4.
//

#import <UIKit/UIKit.h>

#import "VideoPlayer.h"

@interface PlayerContentViewController : UIViewController

@property (nonatomic, assign) NSInteger index;
@property (copy, nonatomic) NSString *url;

@property (strong, nonatomic) VideoPlayer *videoPlayer;

@end

