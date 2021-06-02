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

typedef NS_ENUM(NSInteger, VideoPlayerContentMode) {
    VideoPlayerContentModeScaleToFill        = 0,
    VideoPlayerContentModeAspectFit,
    VideoPlayerContentModeAspectFill
};

@class VideoPlayer;
@protocol VideoPlayerDelegate <NSObject>

- (void)videoPlayer:(VideoPlayer *_Nullable)view duration:(NSTimeInterval)duration currentTime:(NSTimeInterval)currentTime;

@end
NS_ASSUME_NONNULL_BEGIN

@interface VideoPlayer : UIView
/// 帧图片
@property (strong, nonatomic) UIImage *frameImage;
@property (nonatomic, strong, nullable) AVAsset *asset;

/// 充满模式，默认VideoPlayerContentModeAspectFit
@property (assign, nonatomic) VideoPlayerStatus playerStatus;
@property (assign, nonatomic) VideoPlayerContentMode contentMode;

/// 默认0；无限循环(NSUIntegerMax)
@property (nonatomic, assign) NSUInteger autoPlayCount;

@property (weak, nonatomic) id <VideoPlayerDelegate>delegate;
- (void)reset;
- (void)preparPlay;


// 获取图片第一帧
- (void)getFirstFrameWithVideoWithAsset:(AVAsset *)asset
                                  block:(void(^)(UIImage *image))block;
@end

NS_ASSUME_NONNULL_END
