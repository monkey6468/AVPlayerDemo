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
    VideoPlayerStatusUnknown        = 0,
    VideoPlayerStatusReady,
    VideoPlayerStatusPlaying,
    VideoPlayerStatusPaused,
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

@optional
- (void)videoPlayer:(VideoPlayer *_Nullable)view
           duration:(NSTimeInterval)duration
        currentTime:(NSTimeInterval)currentTime;
/// 播放状态
- (void)videoPlayer:(VideoPlayer *_Nullable)view
       playerStatus:(VideoPlayerStatus)playerStatus
              error:(NSError *_Nullable)error;
/// 播放暂停
- (void)videoPlayerPaused:(VideoPlayer *_Nullable)view;
/// 播放结束
- (void)videoPlayerFinished:(VideoPlayer *_Nullable)view;

@end
NS_ASSUME_NONNULL_BEGIN

@interface VideoPlayer : UIView

/// 充满模式，默认VideoRenderModeAspectFit
@property (assign, nonatomic) VideoPlayerStatus playerStatus;
@property (assign, nonatomic) VideoRenderMode contentMode;

/// 默认0；无限循环(NSUIntegerMax)
@property (nonatomic, assign) NSUInteger autoPlayCount;

@property (weak, nonatomic) id <VideoPlayerDelegate>delegate;
/// 帧图片
@property (strong, nonatomic, readonly) UIImage *preViewImage;

/// 视频宽度
@property (assign, nonatomic, readonly) NSInteger width;
/// 视频高度
@property (assign, nonatomic, readonly) NSInteger height;

/// 设置播放速率
- (void)setRate:(float)rate;
/**
 * 设置静音
 */
//- (void)setMute:(BOOL)bEnable;

/// 启动从指定URL播放
/// @param url 视频地址
/// @param bNeed 是否需要预览图(耗时)
- (BOOL)startPlay:(NSString *)url setPreView:(BOOL)bNeed;

/// 停止播放
- (void)playerStop;
/// 暂停播放
- (void)playerPause;
/// 继续播放
- (void)playerResume;
/**
 * 播放跳转到音视频流某个时间
 * @param time 流时间，单位为秒
 * @return 0 = OK
 */
//- (int)seek:(float)time;

// 获取图片第一帧，内部实现加载
- (void)getFirstFrameWithVideoWithAsset:(AVAsset *)asset
                                  block:(void(^)(UIImage *image))block;
@end

NS_ASSUME_NONNULL_END
