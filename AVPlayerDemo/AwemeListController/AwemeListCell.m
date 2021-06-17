//
//  AwemeListCell.m
//  AVPlayerDemo
//
//  Created by HN on 2021/6/17.
//

#import "AwemeListCell.h"
#import "AVPlayerView.h"

#import "Masonry.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define SafeAreaBottomHeight ((ScreenHeight >= 812.0) && [[UIDevice currentDevice].model isEqualToString:@"iPhone"]  ? 30 : 0)

@interface AwemeListCell()<AVPlayerUpdateDelegate>

@property (nonatomic, strong) UIView                   *container;
@property (nonatomic ,strong) UIImageView              *pauseIcon;
@property (nonatomic, strong) UIView                   *playerStatusBar;
@property (nonatomic, strong) UITapGestureRecognizer   *singleTapGesture;

@end

@implementation AwemeListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = UIColor.redColor;
    [self initSubViews];
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
    
    _pauseIcon = [[UIImageView alloc] init];
    _pauseIcon.image = [UIImage imageNamed:@"icon_play_pause"];
    _pauseIcon.contentMode = UIViewContentModeCenter;
    _pauseIcon.layer.zPosition = 3;
    _pauseIcon.hidden = YES;
    [_container addSubview:_pauseIcon];
    
    
    //init player status bar
    _playerStatusBar = [[UIView alloc]init];
    _playerStatusBar.backgroundColor = UIColor.whiteColor;
    [_playerStatusBar setHidden:YES];
    [_container addSubview:_playerStatusBar];
    
    
    
    
    
    
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

}

-(void)prepareForReuse {
    [super prepareForReuse];
    
    _isPlayerReady = NO;
    [_playerView cancelLoading];
    [_pauseIcon setHidden:YES];
    
}

-(void)layoutSubviews {
    [super layoutSubviews];
}



//HoverTextViewDelegate delegate
-(void)hoverTextViewStateChange:(BOOL)isHover {
    _container.alpha = isHover ? 0.0f : 1.0f;
}

//gesture
- (void)handleGesture:(UITapGestureRecognizer *)sender {
    [self singleTapAction];
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
