//
//  DYVideoListCell.h
//  AVPlayerDemo
//
//  Created by HN on 2021/6/30.
//

#import <UIKit/UIKit.h>
#import "VideoPlayer.h"
#import "VideoInfo.h"

@interface DYVideoListCell : UITableViewCell
@property(weak, nonatomic) IBOutlet UIView *videoBackView;

@property(nonatomic, assign) NSInteger row;
@property(strong, nonatomic) VideoInfo *model;

@property(nonatomic, strong) VideoPlayer *player;

- (void)shouldToPlay;

@end
