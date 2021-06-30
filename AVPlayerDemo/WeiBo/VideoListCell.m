//
//  VideoListCell.m
//  ScrollPlayVideo
//
//  Created by 郑旭 on 2017/10/23.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "VideoListCell.h"

@interface VideoListCell()<VideoPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIView *videoBackView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end
@implementation VideoListCell

- (void)dealloc {

}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUI];
}
- (void)setUI
{
    self.videoBackView.userInteractionEnabled = YES;
}

- (void)shouldToPlay
{
    [self.videoBackView addSubview:self.player];
    [self layoutIfNeeded];
    self.player.frame = CGRectMake(0, 0, self.videoBackView.frame.size.width, self.videoBackView.frame.size.height);
}

- (void)shouldToStop
{
    [self.player stop];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //    self.player.frame = CGRectMake(0, 0, self.videoBackView.frame.size.width, self.videoBackView.frame.size.height);
}

- (IBAction)playButtonClick:(UIButton *)sender {
    [sender setSelected:!sender.isSelected];
    if ([self.delegate respondsToSelector:@selector(playButtonClick:)]) {
        
        [self.delegate playButtonClick:sender];
    }
}

- (VideoPlayer *)player
{
    if (!_player) {
        _player = [[VideoPlayer alloc] initWithUrl:[NSURL URLWithString:self.videoUrl]];
        //设置播放器背景颜色
        _player.backgroundColor = [UIColor clearColor];
        //设置播放器填充模式 默认VideoPlayerGravityResizeAspectFill，可以不添加此语句
        _player.mode =VideoPlayerGravityResizeAspectFill;
        _player.delegate = self;
    }
    return _player;
}

#pragma mark - VideoPlayerDelegate
- (void)playerTapActionWithIsShouldToHideSubviews:(BOOL)isHide
{
    if ([self.delegate respondsToSelector:@selector(playerTapActionWithIsShouldToHideSubviews:)]) {
        [self.delegate playerTapActionWithIsShouldToHideSubviews:isHide];
    }
}
- (void)setRow:(NSInteger)row
{
    _row = row;
    self.playButton.tag = 788+row;
}
@end
