//
//  VideoListCell.h
//  ScrollPlayVideo
//
//  Created by 郑旭 on 2017/10/23.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBPlayer.h"

@class VideoListCell;
@protocol VideoListCellDelegate <NSObject>
@optional
- (void)playerTapActionWithIsShouldToHideSubviews:(BOOL)isHide;
- (void)playButtonClick:(UIButton *)sender;
@end

@interface VideoListCell : UITableViewCell
@property (nonatomic,strong) SBPlayer *player;
@property (weak, nonatomic) IBOutlet UIView *topblackView;

@property (weak, nonatomic) IBOutlet UIView *videoFirstImageView;
@property (nonatomic,weak) id<VideoListCellDelegate> delegate;
- (void)shouldToPlay;
@property (nonatomic,assign) NSInteger row;

@property (copy, nonatomic) NSString *videoUrl;

@end
