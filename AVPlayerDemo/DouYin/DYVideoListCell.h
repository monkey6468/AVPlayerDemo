//
//  DYVideoListCell.h
//  AVPlayerDemo
//
//  Created by HN on 2021/6/30.
//

#import <UIKit/UIKit.h>
#import "VideoPlayer.h"
#import "VideoInfo.h"

@class DYVideoListCell;
@protocol DYVideoListCellDelegate <NSObject>
@optional
- (void)playButtonClick:(UIButton *)sender;
@end

@interface DYVideoListCell : UITableViewCell
@property(weak, nonatomic) IBOutlet UIView *videoBackView;

@property(nonatomic, assign) NSInteger row;
@property(strong, nonatomic) VideoInfo *model;

@property(weak, nonatomic) id<DYVideoListCellDelegate> delegate;

@property(nonatomic, strong) VideoPlayer *player;

- (void)shouldToPlay;

@end
