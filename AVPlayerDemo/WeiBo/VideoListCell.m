//
//  VideoListCell.m
//  ScrollPlayVideo
//
//  Created by 郑旭 on 2017/10/23.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "Utility.h"
#import "VideoListCell.h"

@interface VideoListCell () <VideoPlayerDelegate>
@property(weak, nonatomic) IBOutlet UIView *videoBackView;
@property(weak, nonatomic) IBOutlet UILabel *contentLabel;
@property(weak, nonatomic) IBOutlet UIButton *playButton;
@property(weak, nonatomic) IBOutlet UIImageView *preImageView;

@end
@implementation VideoListCell

- (void)dealloc {
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUI];
}
- (void)setUI {
    self.videoBackView.userInteractionEnabled = YES;
}

- (void)shouldToPlay {
    [self.videoBackView addSubview:self.player];
    [self layoutIfNeeded];
    self.player.frame = CGRectMake(0, 0, self.videoBackView.frame.size.width, self.videoBackView.frame.size.height);
}

- (void)shouldToStop {
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

#pragma mark - VideoPlayerDelegate
- (void)playerTapActionWithIsShouldToHideSubviews:(BOOL)isHide {
    if ([self.delegate respondsToSelector:@selector(playerTapActionWithIsShouldToHideSubviews:)]) {
        [self.delegate playerTapActionWithIsShouldToHideSubviews:isHide];
    }
}

- (void)videoPlayer:(VideoPlayer *)videoPlayer onProgressUpdate:(CGFloat)current {
}

#pragma mark - get data
- (VideoPlayer *)player {
    if (!_player) {
        _player = [[VideoPlayer alloc] initWithUrl:[NSURL URLWithString:self.videoUrl]];
        //设置播放器背景颜色
        _player.backgroundColor = [UIColor clearColor];
        _player.delegate = self;
    }
    return _player;
}

#pragma mark - set data
- (void)setRow:(NSInteger)row {
    _row = row;
    self.playButton.tag = 788 + row;
}

- (void)setVideoUrl:(NSString *)videoUrl {
    _videoUrl = videoUrl;
    
    __weak typeof(self) weakSelf = self;
    NSString *imageUrl = [Utility getFrameImagePathWithVideoPath:videoUrl
                                                   showWatermark:YES];
    [self.preImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil options:SDWebImageQueryMemoryDataSync completed:^(UIImage *_Nullable image, NSError *_Nullable error, SDImageCacheType cacheType,  NSURL *_Nullable imageURL) {
        if (image) {
            CGFloat width = image.size.width;
            CGFloat height = image.size.height;
            if (height / width <= 4 / 3.0) {
                weakSelf.preImageView.contentMode = UIViewContentModeScaleToFill;
//                weakSelf.player.mode = VideoPlayerGravityResize;
            } else {
                weakSelf.preImageView.contentMode = UIViewContentModeScaleAspectFit;
//                weakSelf.player.mode = VideoPlayerGravityResizeAspect;
            }
        }
    }];
}
@end
