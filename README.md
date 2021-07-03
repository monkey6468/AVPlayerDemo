# AVPlayerDemo
用于仿微博首页、抖音列表视频播放

* <strong>为了达到比较流利的播放效果</strong>

## 一、实现原理

1、基于系统播放器自定义
```
@interface VideoPlayer : UIView <VideoPlayerControlViewDelegate, UIGestureRecognizerDelegate>
// AVPlayer
@property(nonatomic, strong) AVPlayer *player;
// AVPlayer的播放item
@property(nonatomic, strong) AVPlayerItem *item;
//总时长
@property(nonatomic, assign) CGFloat totalTime;
//当前时间
@property(nonatomic, assign) CGFloat currentTime;
//播放器Playback Rate
@property(nonatomic, assign) CGFloat rate;
//播放状态
@property(nonatomic, assign, readonly) VideoPlayerStatus status;
// videoGravity设置屏幕填充模式，（只写）
@property(nonatomic, assign, readwrite) VideoPlayerGravity mode;
//是否正在播放
@property(nonatomic, assign, readonly) BOOL isPlaying;
//是否全屏显示
@property(nonatomic, assign) BOOL isFullScreenDisplay;
//是否全屏
@property(nonatomic, assign, readonly) BOOL isFullScreen;
/// 自动播放次数。默认无限循环(NSUIntegerMax)
@property (nonatomic, assign, readwrite) NSUInteger autoPlayCount;
//设置标题
@property(nonatomic, copy) NSString *title;
//与url初始化
- (instancetype)initWithUrl:(NSURL *)url;
- (instancetype)initWithUrl:(NSURL *)url delegate:(id<VideoPlayerDelegate>)delegate;
//播放
- (void)play;
//暂停
- (void)pause;
//停止 （移除当前视频播放下一个或者销毁视频，需调用Stop方法）
- (void)stop;
- (void)seekToTimeTo:(CGFloat)seekTime;

@property(nonatomic, weak) id<VideoPlayerDelegate> delegate;

@end
```

2、有视频的首帧预览图，但是没有预览图尺寸，也没有视频的尺寸，故视频的充满模式主要基于图片的尺寸。
```
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSString *imageUrl = [Utility getFrameImagePathWithVideoPath:self.model.videoUrl];
    NSString *key = [manager cacheKeyForURL:[NSURL URLWithString:imageUrl]];
    SDImageCache *cache = [SDImageCache sharedImageCache];
    //此方法会先从memory中取。
    UIImage *image = [cache imageFromDiskCacheForKey:key];
    if (image) {
        CGFloat width = image.size.width;
        CGFloat height = image.size.height;
        [self setPlayerModeWithWidth:width height:height];
    } else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
            AVURLAsset *anAsset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:self.model.videoUrl] options:options];
            NSArray *tracks = [anAsset tracksWithMediaType:AVMediaTypeVideo];
            if ([tracks count] > 0) {
                AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
                CGFloat width = videoTrack.naturalSize.width;
                CGFloat height = videoTrack.naturalSize.height;
                CGAffineTransform t = videoTrack.preferredTransform;//这里的矩阵有旋转角度，转换一下即可
                if ([self isVideoPortrait:t] == NO) {
                    self.videoHeight = height;
                    self.videoWidth = width;
                } else {
                    self.videoWidth = height;
                    self.videoHeight = width;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setPlayerModeWithWidth:self.videoWidth height:self.videoHeight];
                });
            }
        });
    }

```

```
- (void)setPlayerModeWithWidth:(CGFloat)width height:(CGFloat)height {
    if (height / width <= 4 / 3.0) {
        self.player.mode = VideoPlayerGravityResizeAspect;
    } else {
        self.player.mode = VideoPlayerGravityResizeAspectFill;
    }
}
```
3、视频的充满模式 可以通过`SDWebImage`内的缓存拿到。
```
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSString *imageUrl = [Utility getFrameImagePathWithVideoPath:self.model.videoUrl];
    NSString *key = [manager cacheKeyForURL:[NSURL URLWithString:imageUrl]];
    SDImageCache *cache = [SDImageCache sharedImageCache];
    //此方法会先从memory中取。
    UIImage *image = [cache imageFromDiskCacheForKey:key];
```

## 二、效果图
![](screenshots/2021-07-02.mp4)

## 三、存在的问题！！！

因为首次加载内存没有视频预览图片（视频没有尺寸信息），故首次加载还存在视频模式显示问题

## 五、文档参考

参考：https://github.com/czhen09/ScrollPlayVideo

### 更多问题请issue me！！！
