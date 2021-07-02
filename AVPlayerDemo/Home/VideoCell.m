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
    [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
}

@end
