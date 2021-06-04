//
//  PlayerContentViewController.h
//  AVPlayerDemo
//
//  Created by HN on 2021/6/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayerContentViewController : UIViewController

@property (nonatomic, assign) NSInteger index;
@property (copy, nonatomic) NSString *url;

@end

NS_ASSUME_NONNULL_END