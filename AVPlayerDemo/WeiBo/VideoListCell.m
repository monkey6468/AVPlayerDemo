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
#import "SDImageCache.h"

@interface VideoListCell () <VideoPlayerDelegate>
@property(weak, nonatomic) IBOutlet UIView *videoBackView;
@property(weak, nonatomic) IBOutlet UILabel *contentLabel;
@property(weak, nonatomic) IBOutlet UIButton *playButton;
@property(weak, nonatomic) IBOutlet UIImageView *preImageView;

/// 视频宽度
@property (assign, nonatomic) CGFloat videoWidth;
/// 视频高度
@property (assign, nonatomic) CGFloat videoHeight;

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

#pragma mark - other
- (BOOL)isVideoPortrait:(CGAffineTransform)t {
    BOOL isPortrait = NO;
    // Portrait
    if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0) {
        isPortrait = YES;
    }
    // PortraitUpsideDown
    if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0) {
        isPortrait = YES;
    }
    // LandscapeRight
    if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0) {
        isPortrait = NO;
    }
    // LandscapeLeft
    if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0) {
        isPortrait = NO;
    }
    return isPortrait;
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
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        NSString *imageUrl = [Utility getFrameImagePathWithVideoPath:self.videoUrl];
        NSString *key = [manager cacheKeyForURL:[NSURL URLWithString:imageUrl]];
        SDImageCache *cache = [SDImageCache sharedImageCache];
        //此方法会先从memory中取。
        UIImage *image = [cache imageFromDiskCacheForKey:key];
        if (image) {
            CGFloat width = image.size.width;
            CGFloat height = image.size.height;
            [self setPlayerModeWithWidth:width height:height];
        } else {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
                AVURLAsset *anAsset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:self.videoUrl] options:options];
                NSArray *tracks = [anAsset tracksWithMediaType:AVMediaTypeVideo];
                if ([tracks count] > 0) {
                    AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
                    CGFloat width = videoTrack.naturalSize.width;
                    CGFloat height = videoTrack.naturalSize.height;
                    CGAffineTransform t = videoTrack.preferredTransform;//这里的矩阵有旋转角度，转换一下即可
                    if ([self isVideoPortrait:t] == NO) {
                        self.videoHeight = height;
                        self.videoWidth = width;
                    } else {
                        self.videoWidth = height;
                        self.videoHeight = width;
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setPlayerModeWithWidth:self.videoWidth height:self.videoHeight];
                    });
                }
            });
        }
    }
    return _player;
}

#pragma mark - set data
- (void)setRow:(NSInteger)row {
    _row = row;
    self.playButton.tag = 788 + row;
}

- (void)setPlayerModeWithWidth:(CGFloat)width height:(CGFloat)height {
    if (height / width <= 4 / 3.0) {
        self.player.mode = VideoPlayerGravityResize;
    } else {
        self.player.mode = VideoPlayerGravityResizeAspect;
    }
}

- (void)setVideoUrl:(NSString *)videoUrl {
    _videoUrl = videoUrl;
    
    __weak typeof(self) weakSelf = self;
    NSString *imageUrl = [Utility getFrameImagePathWithVideoPath:videoUrl];
    [self.preImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image) {
            CGFloat width = image.size.width;
            CGFloat height = image.size.height;
            if (height / width <= 4 / 3.0) {
                weakSelf.preImageView.contentMode = UIViewContentModeScaleToFill;
            } else {
                weakSelf.preImageView.contentMode = UIViewContentModeScaleAspectFit;
            }
        }
    }];
}
@end
