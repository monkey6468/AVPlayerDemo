//
//  AVPlayerView.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "VideoPlayer.h"
//typedef NS_ENUM(NSInteger, VideoPlayerStatus) {
//    VideoPlayerStatusUnknown            = 0,
//    VideoPlayerStatusReady              = 1,
//    VideoPlayerStatusReadyToPlay        = 2,
//    VideoPlayerStatusPlaying            = 3,
//    VideoPlayerStatusPaused             = 4,
//    VideoPlayerStatusFinished           = 5,
//    VideoPlayerStatusChangeEsolution    = 6,
//    VideoPlayerStatusDownload           = 7,
//    VideoPlayerStatusFailed             = 8,
//};

typedef NS_ENUM(NSInteger, VideoRenderMode) {
    VideoRenderModeFillScreen        = 0,   ///<  图像铺满屏幕，不留黑边，如果图像宽高比不同于屏幕宽高比，部分画面内容会被裁剪掉。
    VideoRenderModeFillEdge,                ///< 图像适应屏幕，保持画面完整，但如果图像宽高比不同于屏幕宽高比，会有黑边的存在。
};


@class AVPlayerView;
//自定义Delegate，用于进度、播放状态更新回调
@protocol AVPlayerUpdateDelegate <NSObject>

@required
//播放进度更新回调方法
- (void)avPlayerView:(AVPlayerView *)playerView
    onProgressUpdate:(CGFloat)current
               total:(CGFloat)total;

//播放状态更新回调方法
- (void)avPlayerView:(AVPlayerView *)playerView
        playerStatus:(VideoPlayerStatus)status
               error:(NSError *)error;

@end


//封装了AVPlayerLayer的自定义View
@interface AVPlayerView : UIView

/// 充满模式，默认VideoRenderModeFillEdge
@property (assign, nonatomic) VideoRenderMode renderMode;
/// 视频播放状态
@property (assign, nonatomic) VideoPlayerStatus status;
/// 自动播放次数。默认无限循环(NSUIntegerMax)
@property (nonatomic, assign, readwrite) NSUInteger autoPlayCount;

/// 是否需要预览图(耗时)
//@property (assign, nonatomic) BOOL bNeedPreView;
///// 获取帧图片
//@property (strong, nonatomic, readonly) UIImage *preViewImage;
///// 赋值帧图片
//@property (strong, nonatomic, readwrite) NSString *preViewImageUrl;

//播放进度、状态更新代理
@property (weak, nonatomic) id<AVPlayerUpdateDelegate> delegate;

/// 设置播放路径
- (void)setVideoUrl:(NSString *)videoUrl needCache:(BOOL)bNeedCache;

/// 视频宽度
@property (assign, nonatomic) CGFloat videoWidth;
/// 视频高度
@property (assign, nonatomic) CGFloat videoHeight;
/// 视频总时长
@property (assign, nonatomic, readonly) NSTimeInterval duration;
/// 视频当前进度时长
@property (assign, nonatomic, readonly) NSTimeInterval currentTime;

//取消播放
- (void)cancelLoading;

//开始视频资源下载任务
- (void)startDownloadTask:(NSURL *)URL isBackground:(BOOL)isBackground;

//更新AVPlayer状态，当前播放则暂停，当前暂停则播放
- (void)updatePlayerState;

//播放
- (void)play;

//暂停
- (void)pause;

//重新播放
- (void)replay;

//播放速度
- (CGFloat)rate;

//重新请求
- (void)retry;


@end
