//
//  VideoPlayer.h
//  AVPlayerDemo
//
//  Created by HN on 2021/6/1.
//
// 参考 YBImageBrowserDemo

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoPlayer : UIView

@property (nonatomic, strong) UIImageView *thumbImageView;

@property (nonatomic, strong, nullable) AVAsset *asset;

@property (nonatomic, assign, readonly, getter=isPlaying) BOOL playing;

@property (nonatomic, assign, readonly, getter=isPlayFailed) BOOL playFailed;

@property (nonatomic, assign, readonly, getter=isPreparingPlay) BOOL preparingPlay;

@property (strong, nonatomic) AVPlayer *player;

- (void)reset;

- (void)preparPlay;

@property (nonatomic, assign) BOOL needAutoPlay;

@property (nonatomic, assign) NSUInteger autoPlayCount; // 无效

// 获取图片第一帧
- (UIImage *)getFirstFrameWithVideoWithURL:(NSString *)url size:(CGSize)size;
@end

NS_ASSUME_NONNULL_END
