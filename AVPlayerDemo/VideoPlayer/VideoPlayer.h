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
    VideoPlayerStatusChangeEsolution,
    VideoPlayerStatusFailed,
};

typedef NS_ENUM(NSInteger, VideoRenderMode) {
    VideoRenderModeFillScreen        = 0,   ///<  图像铺满屏幕，不留黑边，如果图像宽高比不同于屏幕宽高比，部分画面内容会被裁剪掉。
    VideoRenderModeFillEdge,                ///< 图像适应屏幕，保持画面完整，但如果图像宽高比不同于屏幕宽高比，会有黑边的存在。
};

@class VideoPlayer;
@protocol VideoPlayerDelegate <NSObject>

@optional
- (void)videoPlayer:(VideoPlayer *_Nullable)player
           duration:(NSTimeInterval)duration
        currentTime:(NSTimeInterval)currentTime;
/// 播放状态
- (void)videoPlayer:(VideoPlayer *_Nullable)player
       playerStatus:(VideoPlayerStatus)playerStatus
              error:(NSError *_Nullable)error;
/// 播放暂停
- (void)videoPlayerPaused:(VideoPlayer *_Nullable)player;
/// 播放结束
- (void)videoPlayerFinished:(VideoPlayer *_Nullable)player;

@end
NS_ASSUME_NONNULL_BEGIN

@interface VideoPlayer : UIView

/// 充满模式，默认VideoRenderModeFillEdge
@property (assign, nonatomic) VideoRenderMode contentMode;

/// 默认0；无限循环(NSUIntegerMax)
@property (nonatomic, assign) NSUInteger autoPlayCount;

@property (weak, nonatomic) id <VideoPlayerDelegate>delegate;
/// 帧图片
@property (strong, nonatomic, readonly) UIImage *preViewImage;

/// 视频宽度
@property (assign, nonatomic, readonly) CGFloat width;
/// 视频高度
@property (assign, nonatomic, readonly) CGFloat height;

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
