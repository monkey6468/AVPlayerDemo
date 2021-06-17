//
//  AwemeListCell.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "AwemeListCell.h"
#import "AVPlayerView.h"

#import "Masonry.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define SafeAreaBottomHeight ((ScreenHeight >= 812.0) && [[UIDevice currentDevice].model isEqualToString:@"iPhone"]  ? 30 : 0)

@interface AwemeListCell()<AVPlayerUpdateDelegate>

@property (nonatomic, strong) UIView                   *container;
@property (nonatomic ,strong) CAGradientLayer          *gradientLayer;
@property (nonatomic ,strong) UIImageView              *pauseIcon;
@property (nonatomic, strong) UIView                   *playerStatusBar;
@property (nonatomic ,strong) UIImageView              *musicIcon;
@property (nonatomic, strong) UITapGestureRecognizer   *singleTapGesture;
@property (nonatomic, assign) NSTimeInterval           lastTapTime;
@property (nonatomic, assign) CGPoint                  lastTapPoint;

@end

@implementation AwemeListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.redColor;
        _lastTapTime = 0;
        _lastTapPoint = CGPointZero;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    //init player view;
    _playerView = [AVPlayerView new];
    _playerView.delegate = self;
    [self.contentView addSubview:_playerView];
    
    //init hover on player view container
    _container = [UIView new];
    [self.contentView addSubview:_container];
    
    _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [_container addGestureRecognizer:_singleTapGesture];
    
    _gradientLayer = [CAGradientLayer layer];
//    _gradientLayer.colors = @[(__bridge id)ColorClear.CGColor, (__bridge id)ColorBlackAlpha20.CGColor, (__bridge id)ColorBlackAlpha40.CGColor];
    _gradientLayer.locations = @[@0.3, @0.6, @1.0];
    _gradientLayer.startPoint = CGPointMake(0.0f, 0.0f);
    _gradientLayer.endPoint = CGPointMake(0.0f, 1.0f);
    [_container.layer addSublayer:_gradientLayer];
    
    _pauseIcon = [[UIImageView alloc] init];
    _pauseIcon.image = [UIImage imageNamed:@"icon_play_pause"];
    _pauseIcon.contentMode = UIViewContentModeCenter;
    _pauseIcon.layer.zPosition = 3;
    _pauseIcon.hidden = YES;
    [_container addSubview:_pauseIcon];
    
    //init hoverTextView
//    _hoverTextView = [HoverTextView new];
//    _hoverTextView.delegate = self;
//    _hoverTextView.hoverDelegate = self;
//    [self addSubview:_hoverTextView];
    
    //init player status bar
    _playerStatusBar = [[UIView alloc]init];
    _playerStatusBar.backgroundColor = UIColor.whiteColor;
    [_playerStatusBar setHidden:YES];
    [_container addSubview:_playerStatusBar];
    
    //init aweme message
    _musicIcon = [[UIImageView alloc]init];
    _musicIcon.contentMode = UIViewContentModeCenter;
    _musicIcon.image = [UIImage imageNamed:@"icon_home_musicnote3"];
    [_container addSubview:_musicIcon];
    
    
    
    
    
    
    //init focus action
    
    [_playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [_container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [_pauseIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.height.mas_equalTo(100);
    }];

    //make constraintes
    [_playerStatusBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).inset(49.5f + SafeAreaBottomHeight);
        make.width.mas_equalTo(1.0f);
        make.height.mas_equalTo(0.5f);
    }];
    
    [_musicIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.bottom.equalTo(self).inset(60 + SafeAreaBottomHeight);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(25);
    }];
    

}

-(void)prepareForReuse {
    [super prepareForReuse];
    
    _isPlayerReady = NO;
    [_playerView cancelLoading];
    [_pauseIcon setHidden:YES];
    
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _gradientLayer.frame = CGRectMake(0, self.frame.size.height - 500, self.frame.size.width, 500);
    [CATransaction commit];
}



//HoverTextViewDelegate delegate
-(void)hoverTextViewStateChange:(BOOL)isHover {
    _container.alpha = isHover ? 0.0f : 1.0f;
}

//gesture
- (void)handleGesture:(UITapGestureRecognizer *)sender {
    switch (sender.view.tag) {
        default: {
            //获取点击坐标，用于设置爱心显示位置
            CGPoint point = [sender locationInView:_container];
            //获取当前时间
            NSTimeInterval time = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
            //判断当前点击时间与上次点击时间的时间间隔
            if(time - _lastTapTime > 0.25f) {
                //推迟0.25秒执行单击方法
                [self performSelector:@selector(singleTapAction) withObject:nil afterDelay:0.25f];
            }else {
                //取消执行单击方法
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTapAction) object: nil];
                //执行连击显示爱心的方法
                [self showLikeViewAnim:point oldPoint:_lastTapPoint];
            }
            //更新上一次点击位置
            _lastTapPoint = point;
            //更新上一次点击时间
            _lastTapTime =  time;
            break;
        }
    }
    
}

- (void)singleTapAction {
    [self showPauseViewAnim:[_playerView rate]];
    [_playerView updatePlayerState];
}

//暂停播放动画
- (void)showPauseViewAnim:(CGFloat)rate {
    if(rate == 0) {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             self.pauseIcon.alpha = 0.0f;
                         } completion:^(BOOL finished) {
                             [self.pauseIcon setHidden:YES];
                         }];
    }else {
        [_pauseIcon setHidden:NO];
        _pauseIcon.transform = CGAffineTransformMakeScale(1.8f, 1.8f);
        _pauseIcon.alpha = 1.0f;
        [UIView animateWithDuration:0.25f delay:0
                            options:UIViewAnimationOptionCurveEaseIn animations:^{
                                self.pauseIcon.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                            } completion:^(BOOL finished) {
                            }];
    }
}

//连击爱心动画
- (void)showLikeViewAnim:(CGPoint)newPoint oldPoint:(CGPoint)oldPoint {
    UIImageView *likeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_home_like_after"]];
    CGFloat k = ((oldPoint.y - newPoint.y)/(oldPoint.x - newPoint.x));
    k = fabs(k) < 0.5 ? k : (k > 0 ? 0.5f : -0.5f);
    CGFloat angle = M_PI_4 * -k;
    likeImageView.frame = CGRectMake(newPoint.x, newPoint.y, 80, 80);
    likeImageView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(angle), 0.8f, 1.8f);
    [_container addSubview:likeImageView];
    [UIView animateWithDuration:0.2f
                          delay:0.0f
         usingSpringWithDamping:0.5f
          initialSpringVelocity:1.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         likeImageView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(angle), 1.0f, 1.0f);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5f
                                               delay:0.5f
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              likeImageView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(angle), 3.0f, 3.0f);
                                              likeImageView.alpha = 0.0f;
                                          }
                                          completion:^(BOOL finished) {
                                              [likeImageView removeFromSuperview];
                                          }];
                     }];
}

//加载动画
-(void)startLoadingPlayItemAnim:(BOOL)isStart {
    if (isStart) {
        _playerStatusBar.backgroundColor = UIColor.whiteColor;
        [_playerStatusBar setHidden:NO];
        [_playerStatusBar.layer removeAllAnimations];
        
        CAAnimationGroup *animationGroup = [[CAAnimationGroup alloc]init];
        animationGroup.duration = 0.5;
        animationGroup.beginTime = CACurrentMediaTime() + 0.5;
        animationGroup.repeatCount = MAXFLOAT;
        animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        CABasicAnimation * scaleAnimation = [CABasicAnimation animation];
        scaleAnimation.keyPath = @"transform.scale.x";
        scaleAnimation.fromValue = @(1.0f);
        scaleAnimation.toValue = @(1.0f * ScreenWidth);
        
        CABasicAnimation * alphaAnimation = [CABasicAnimation animation];
        alphaAnimation.keyPath = @"opacity";
        alphaAnimation.fromValue = @(1.0f);
        alphaAnimation.toValue = @(0.5f);
        [animationGroup setAnimations:@[scaleAnimation, alphaAnimation]];
        [self.playerStatusBar.layer addAnimation:animationGroup forKey:nil];
    } else {
        [self.playerStatusBar.layer removeAllAnimations];
        [self.playerStatusBar setHidden:YES];
    }
    
}

// AVPlayerUpdateDelegate
-(void)onProgressUpdate:(CGFloat)current total:(CGFloat)total {
    //播放进度更新
}

-(void)onPlayItemStatusUpdate:(AVPlayerItemStatus)status {
    switch (status) {
        case AVPlayerItemStatusUnknown:
            [self startLoadingPlayItemAnim:YES];
            break;
        case AVPlayerItemStatusReadyToPlay:
            [self startLoadingPlayItemAnim:NO];
            
            _isPlayerReady = YES;
            
            if(_onPlayerReady) {
                _onPlayerReady();
            }
            break;
        case AVPlayerItemStatusFailed:
            [self startLoadingPlayItemAnim:NO];
            break;
        default:
            break;
    }
}

// update method
- (void)setAweme:(NSString *)aweme {
    _aweme = aweme;
    
//    [_nickName setText:[NSString stringWithFormat:@"@%@", aweme.author.nickname]];
//    [_desc setText:aweme.desc];
//    [_musicName setText:[NSString stringWithFormat:@"%@ - %@", aweme.music.title, aweme.music.author]];
//    [_favoriteNum setText:[NSString formatCount:aweme.statistics.digg_count]];
//    [_commentNum setText:[NSString formatCount:aweme.statistics.comment_count]];
//    [_shareNum setText:[NSString formatCount:aweme.statistics.share_count]];
//
//    __weak __typeof(self) wself = self;
//    [_musicAlum.album setImageWithURL:[NSURL URLWithString:aweme.music.cover_thumb.url_list.firstObject] completedBlock:^(UIImage *image, NSError *error) {
//        if(!error) {
//            wself.musicAlum.album.image = [image drawCircleImage];
//        }
//    }];
//    [_avatar setImageWithURL:[NSURL URLWithString:aweme.author.avatar_thumb.url_list.firstObject] completedBlock:^(UIImage *image, NSError *error) {
//        if(!error) {
//            wself.avatar.image = [image drawCircleImage];
//        }
//    }];
    
}

- (void)play {
    [_playerView play];
    [_pauseIcon setHidden:YES];
}

- (void)pause {
    [_playerView pause];
    [_pauseIcon setHidden:NO];
}

- (void)replay {
    [_playerView replay];
    [_pauseIcon setHidden:YES];
}

- (void)startDownloadBackgroundTask {
    NSString *playUrl = _aweme;// YES ? _aweme.video.play_addr.url_list.firstObject : _aweme.video.play_addr_lowbr.url_list.firstObject;
    [_playerView setPlayerWithUrl:playUrl];
}

- (void)startDownloadHighPriorityTask {
    NSString *playUrl = _aweme;// = YES ? _aweme.video.play_addr.url_list.firstObject : _aweme.video.play_addr_lowbr.url_list.firstObject;
    [_playerView startDownloadTask:[[NSURL alloc] initWithString:playUrl] isBackground:NO];
}

@end
