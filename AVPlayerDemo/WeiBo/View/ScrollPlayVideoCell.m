//
//  ScrollPlayVideoCell.m
//  ScrollPlayVideo
//
//  Created by 郑旭 on 2017/10/23.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "ScrollPlayVideoCell.h"
#import "ScrollPlayVideoHeader.h"
@interface ScrollPlayVideoCell()<SBPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIView *videoBackView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *headImageButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@end
@implementation ScrollPlayVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self addSubviews];
    [self setUI];
}
- (void)setUI
{
    self.videoBackView.userInteractionEnabled = YES;
    [self.likeButton setImage:[UIImage imageNamed:@"ICON点赞"] forState:UIControlStateNormal];
    [self.likeButton setImage:[UIImage imageNamed:@"ICON已点赞"] forState:UIControlStateSelected];
}
- (void)addSubviews
{
    
}
- (void)shouldToPlay
{
    [self.videoBackView addSubview:self.player];
    self.player.frame = CGRectMake(0, 0, self.videoBackView.frame.size.width, self.videoBackView.frame.size.height);
//    [self.player mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.right.bottom.mas_equalTo(self.videoBackView);
//    }];
}
- (void)shouldToStop
{
    [self.player stop];
}
- (IBAction)playButtonClick:(UIButton *)sender {
    [sender setSelected:!sender.isSelected];
    if ([self.delegate respondsToSelector:@selector(playButtonClick:)]) {
        
        [self.delegate playButtonClick:sender];
    }
}

- (SBPlayer *)player
{
    if (!_player) {
        _player = [[SBPlayer alloc] initWithUrl:[NSURL URLWithString:@"https://video.cnhnb.com/video/mp4/miniapp/2021/03/20/8664f5edc73e4d6891caeb4aa14ee337.mp4"]];
        _player.playerSuperView  = self.videoBackView;
        //设置播放器背景颜色
        _player.backgroundColor = [UIColor clearColor];
        //设置播放器填充模式 默认SBLayerVideoGravityResizeAspectFill，可以不添加此语句
        _player.mode = SBLayerVideoGravityResizeAspectFill;
        _player.delegate = self;
    }
    return _player;
}
- (IBAction)headImageButtonClick:(id)sender {
}
- (IBAction)commentButtonClick:(id)sender {
}
- (IBAction)likeButtonClick:(UIButton *)sender {
    
    [sender setSelected:!sender.isSelected];
    NSInteger likeCount = [sender.titleLabel.text integerValue];
    if (sender.isSelected) {
        likeCount += 1;
    }else
    {
        likeCount -= 1;
    }
    [sender setTitle:[NSString stringWithFormat:@"%ld",likeCount] forState:UIControlStateNormal];
    
}
- (IBAction)shareButtonClike:(id)sender {
}
#pragma mark - SBPlayerDelegate
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
