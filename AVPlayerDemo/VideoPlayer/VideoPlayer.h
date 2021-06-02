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

typedef NS_ENUM(NSInteger, VideoRenderMode) {
    VideoRenderModeScaleToFill        = 0,
    VideoRenderModeAspectFit,
    VideoRenderModeAspectFill
};

@class VideoPlayer;
@protocol VideoPlayerDelegate <NSObject>

- (void)videoPlayer:(VideoPlayer *_Nullable)view duration:(NSTimeInterval)duration currentTime:(NSTimeInterval)currentTime;

@end
NS_ASSUME_NONNULL_BEGIN

@interface VideoPlayer : UIView
@property (nonatomic, strong, nullable) AVAsset *asset;

/// 充满模式，默认VideoRenderModeAspectFit
@property (assign, nonatomic) VideoPlayerStatus playerStatus;
@property (assign, nonatomic) VideoRenderMode contentMode;

/// 默认0；无限循环(NSUIntegerMax)
@property (nonatomic, assign) NSUInteger autoPlayCount;

@property (weak, nonatomic) id <VideoPlayerDelegate>delegate;

/// 视频宽度
@property (assign, nonatomic, readonly) NSInteger width;
/// 视频高度
@property (assign, nonatomic, readonly) NSInteger height;

- (void)reset;
- (void)preparPlay;

/**
 * 设置播放速率
 * @param rate 正常速度为1.0；小于为慢速；大于为快速。最大建议不超过2.0
 */
//- (void)setRate:(float)rate;
/**
 * 设置静音
 */
//- (void)setMute:(BOOL)bEnable;

// 获取图片第一帧，内部实现加载
- (void)getFirstFrameWithVideoWithAsset:(AVAsset *)asset
                                  block:(void(^)(UIImage *image))block;
@end

NS_ASSUME_NONNULL_END
