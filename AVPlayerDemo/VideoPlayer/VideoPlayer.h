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

@property (strong, nonatomic) UIImage *frameImage; // 帧图片
@property (nonatomic, strong, nullable) AVAsset *asset;

@property (nonatomic, assign, readonly, getter=isPlaying) BOOL playing;
@property (nonatomic, assign, readonly, getter=isPlayFailed) BOOL playFailed;
@property (nonatomic, assign, readonly, getter=isPreparingPlay) BOOL preparingPlay;

@property (nonatomic, assign) BOOL needAutoPlay;
@property (nonatomic, assign) NSUInteger autoPlayCount; // 无效

- (void)reset;
- (void)preparPlay;


// 获取图片第一帧
- (void)getFirstFrameWithVideoWithAsset:(AVAsset *)asset
                                  block:(void(^)(UIImage *image))block;
@end

NS_ASSUME_NONNULL_END
