//
//  VideoCell.m
//  AVPlayerDemo
//
//  Created by HN on 2021/7/1.
//

#import "VideoCell.h"

#import "UIImageView+WebCache.h"
#import "Utility.h"

@interface VideoCell ()

@property(weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation VideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - set data
- (void)setModel:(VideoInfo *)model {
    _model = model;
    
    if (model.type == VideoInfoTypeVideo) {
        self.playButton.hidden = NO;
        self.textLabel.hidden = YES;
    } else {
        self.playButton.hidden = YES;
        self.textLabel.text = @"我是图片";
    }
    
    NSString *imageUrl = [Utility getFrameImagePathWithVideoPath:model.videoUrl];
    [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//        if (image) {
//            CGFloat width = image.size.width;
//            CGFloat height = image.size.height;
//            if (height / width <= 4 / 3.0) {
//                weakSelf.preImageView.contentMode = UIViewContentModeScaleToFill;
//            } else {
//                weakSelf.preImageView.contentMode = UIViewContentModeScaleAspectFit;
//            }
//        }
    }];
}

@end
