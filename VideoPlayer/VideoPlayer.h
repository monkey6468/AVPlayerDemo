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
    VideoPlayerStatusUnknown            = 0,
    VideoPlayerStatusReady              = 1,
    VideoPlayerStatusReadyToPlay        = 2,
    VideoPlayerStatusPlaying            = 3,
    VideoPlayerStatusPaused             = 4,
    VideoPlayerStatusFinished           = 5,
    VideoPlayerStatusChangeEsolution    = 6,
    VideoPlayerStatusDownload           = 7,
    VideoPlayerStatusFailed             = 8,
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
       playerStatus:(VideoPlayerStatus)status
              error:(NSError *_Nullable)error;

@end
NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
@interface VideoPlayer : UIView

/// 充满模式，默认VideoRenderModeFillEdge
@property (assign, nonatomic) VideoRenderMode renderMode;
/// 视频播放状态
@property (assign, nonatomic) VideoPlayerStatus status;
/// 默认0；无限循环(NSUIntegerMax)
@property (nonatomic, assign) NSUInteger autoPlayCount;
/// 视频地址
@property (copy, nonatomic) NSString *videoUrl;
/// 是否需要预览图(耗时)
@property (assign, nonatomic) BOOL bNeedPreView;
/// VideoPlayer 代理
@property (weak, nonatomic) id <VideoPlayerDelegate>delegate;
/// 获取帧图片
@property (strong, nonatomic, readonly) UIImage *preViewImage;
/// 赋值帧图片
@property (strong, nonatomic, readwrite) NSString *preViewImageUrl;

/// 视频宽度
@property (assign, nonatomic, readonly) CGFloat width;
/// 视频高度
@property (assign, nonatomic, readonly) CGFloat height;
/// 视频总时长
@property (assign, nonatomic, readonly) NSTimeInterval duration;
/// 视频当前进度时长
@property (assign, nonatomic, readonly) NSTimeInterval currentTime;
@property (assign, nonatomic) BOOL bDebug; /// 调试日志输出。默认关闭
/// 设置播放速率
- (void)setRate:(float)rate;
/**
 * 设置静音
 */
//- (void)setMute:(BOOL)bEnable;
/// 开始播放
- (void)playerStart;
/// 暂停播放
- (void)playerPause;
/// 继续播放
- (void)playerResume;
/// 停止播放
- (void)playerStop;
/// 播放跳转到音视频流某个时间
/// @param time 流时间，单位为秒
- (void)seekToTime:(float)time;

@end

NS_ASSUME_NONNULL_END
