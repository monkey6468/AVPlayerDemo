//
//  VideoListCell.h
//  ScrollPlayVideo
//
//  Created by 郑旭 on 2017/10/23.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoPlayer.h"
#import "VideoInfo.h"

@class VideoListCell;
@protocol VideoListCellDelegate <NSObject>
@optional
- (void)playerTapActionWithIsShouldToHideSubviews:(BOOL)isHide;
- (void)playButtonClick:(UIButton *)sender;
@end

@interface VideoListCell : UITableViewCell
@property(weak, nonatomic) IBOutlet UIView *videoBackView;

@property(nonatomic, assign) NSInteger row;
@property(strong, nonatomic) VideoInfo *model;

@property(weak, nonatomic) id<VideoListCellDelegate> delegate;

@property(nonatomic, strong) VideoPlayer *player;

- (void)shouldToPlay;

@end
