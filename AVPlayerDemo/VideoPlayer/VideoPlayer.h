//
//  VideoPlayer.h
//  AVPlayerDemo
//
//  Created by HN on 2021/6/1.
//
// 参考 YBImageBrowserDemo

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, VideoPlayerStatus) {
    VideoPlayerStatusReady        = 0,
    VideoPlayerStatusPlaying      = 1,
    VideoPlayerStatusFinished,
    VideoPlayerStatusFailed,
};

NS_ASSUME_NONNULL_BEGIN

@interface VideoPlayer : UIView
/// 帧图片
@property (strong, nonatomic) UIImage *frameImage;
@property (nonatomic, strong, nullable) AVAsset *asset;

@property (assign, nonatomic) VideoPlayerStatus playerStatus;
/// 默认0；无限循环(NSUIntegerMax)
@property (nonatomic, assign) NSUInteger autoPlayCount;

@property (assign, nonatomic) NSTimeInterval duration;
- (void)reset;
- (void)preparPlay;


// 获取图片第一帧
- (void)getFirstFrameWithVideoWithAsset:(AVAsset *)asset
                                  block:(void(^)(UIImage *image))block;
@end

NS_ASSUME_NONNULL_END
