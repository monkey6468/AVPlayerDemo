//
//  VideoPlayer.h
//
//  Created by HN on 2021/6/30.
//

#import "VideoPlayerControlView.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

//横竖屏的时候过渡动画时间，设置为0.0则是无动画
#define kTransitionTime 0.2

//填充模式枚举值
typedef NS_ENUM(NSInteger, VideoPlayerGravity) {
   VideoPlayerGravityResizeAspect,
   VideoPlayerGravityResizeAspectFill,
   VideoPlayerGravityResize,
};

//播放状态枚举值
typedef NS_ENUM(NSInteger, VideoPlayerStatus) {
    VideoPlayerStatusFailed,
    VideoPlayerStatusReadyToPlay,
    VideoPlayerStatusUnknown,
    VideoPlayerStatusBuffering,
    VideoPlayerStatusPlaying,
    VideoPlayerStatusStopped,
    
#warning <#message#>
//    VideoPlayerStatusUnknown            = 0,
    VideoPlayerStatusReady              = 1,
//    VideoPlayerStatusReadyToPlay        = 2,
//    VideoPlayerStatusPlaying            = 3,
    VideoPlayerStatusPaused             = 4,
    VideoPlayerStatusFinished           = 5,
    VideoPlayerStatusChangeEsolution    = 6,
    VideoPlayerStatusDownload           = 7,
//    VideoPlayerStatusFailed             = 8,
};

@class VideoPlayer;
@protocol VideoPlayerDelegate <NSObject>
@optional
- (void)playerTapActionWithCurrentTimeValue:(CGFloat)currentTimeValue;
- (void)playerTapActionWithIsShouldToHideSubviews:(BOOL)isHide;
@end
@interface VideoPlayer : UIView <VideoPlayerControlViewDelegate, UIGestureRecognizerDelegate> 
// AVPlayer
@property(nonatomic, strong) AVPlayer *player;
// AVPlayer的播放item
@property(nonatomic, strong) AVPlayerItem *item;
//总时长
@property(nonatomic, assign) CMTime totalTime;
//当前时间
@property(nonatomic, assign) CMTime currentTime;
//资产AVURLAsset
@property(nonatomic, strong) AVURLAsset *anAsset;
//播放器Playback Rate
@property(nonatomic, assign) CGFloat rate;
//播放状态
@property(nonatomic, assign, readonly) VideoPlayerStatus status;
// videoGravity设置屏幕填充模式，（只写）
@property(nonatomic, assign) VideoPlayerGravity mode;
//是否正在播放
@property(nonatomic, assign, readonly) BOOL isPlaying;
//是否全屏
@property(nonatomic, assign, readonly) BOOL isFullScreen;
/// 自动播放次数。默认无限循环(NSUIntegerMax)
@property (nonatomic, assign, readwrite) NSUInteger autoPlayCount;
//设置标题
@property(nonatomic, copy) NSString *title;
//与url初始化
- (instancetype)initWithUrl:(NSURL *)url;
//播放
- (void)play;
//暂停
- (void)pause;
//停止 （移除当前视频播放下一个或者销毁视频，需调用Stop方法）
- (void)stop;
- (void)setPlayerTimeValueTo:(CGFloat)value;

@property(nonatomic, assign) BOOL isHidenAllSubviews;
@property(nonatomic, weak) id<VideoPlayerDelegate> delegate;

@end
