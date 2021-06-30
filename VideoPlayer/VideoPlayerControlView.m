//
//  VideoPlayerControlView.m
//  VideoPlayer
//
//  Created by HN on 2021/6/30.
//

#import "VideoPlayerControlView.h"
@interface VideoPlayerControlView ()
//当前时间
@property(nonatomic, strong) UILabel *timeLabel;
//总时间
@property(nonatomic, strong) UILabel *totalTimeLabel;
//进度条
@property(nonatomic, strong) UISlider *slider;
//缓存进度条
@property(nonatomic, strong) UISlider *bufferSlier;
@end

static NSInteger padding = 8;
@implementation VideoPlayerControlView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//懒加载
- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor whiteColor];
    }
    return _timeLabel;
}

- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc] init];
        _totalTimeLabel.textAlignment = NSTextAlignmentLeft;
        _totalTimeLabel.font = [UIFont systemFontOfSize:12];
        _totalTimeLabel.textColor = [UIColor whiteColor];
    }
    return _totalTimeLabel;
}
- (UISlider *)slider {
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        [_slider setThumbImage:[UIImage imageNamed:@"knob"]
                      forState:UIControlStateNormal];
        _slider.continuous = YES;
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [_slider addTarget:self action:@selector(handleSliderPosition:) forControlEvents:UIControlEventValueChanged];
        [_slider addTarget:self action:@selector(onActionTouchUpOutInside:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
        [_slider addGestureRecognizer:self.tapGesture];
        _slider.maximumTrackTintColor = [UIColor clearColor];
        _slider.minimumTrackTintColor = [UIColor whiteColor];
    }
    return _slider;
}
//- (UIButton *)largeButton{
//    if (!_largeButton) {
//        _largeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _largeButton.contentMode = UIViewContentModeScaleToFill;
//        [_largeButton setImage:[UIImage imageNamed:@"full_screen"]
//        forState:UIControlStateNormal];
//        [_largeButton addTarget:self action:@selector(hanleLargeBtn:)
//        forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _largeButton;
//}
- (UISlider *)bufferSlier {
    if (!_bufferSlier) {
        _bufferSlier = [[UISlider alloc] init];
        [_bufferSlier setThumbImage:[UIImage new] forState:UIControlStateNormal];
        _bufferSlier.continuous = YES;
        _bufferSlier.minimumTrackTintColor = [UIColor redColor];
        _bufferSlier.minimumValue = 0.f;
        _bufferSlier.maximumValue = 1.f;
        _bufferSlier.userInteractionEnabled = NO;
    }
    return _bufferSlier;
}
- (instancetype)init {
    if (self = [super init]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self addSubview:self.timeLabel];
    [self addSubview:self.bufferSlier];
    [self addSubview:self.slider];
    [self addSubview:self.totalTimeLabel];
    //    [self addSubview:self.largeButton];
    //添加约束
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self addConstraintsForSubviews];
}

- (void)deviceOrientationDidChange {
    //添加约束
    [self addConstraintsForSubviews];
}

- (void)addConstraintsForSubviews {
    CGFloat heightTemp = 30;
    CGFloat widthTemp = 50;
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    self.timeLabel.frame =
    CGRectMake(0, (height - heightTemp) / 2., widthTemp, heightTemp);
    
    self.totalTimeLabel.frame =
    CGRectMake(width - widthTemp - padding, (height - heightTemp) / 2.,
               widthTemp, heightTemp);
    self.slider.frame = CGRectMake(widthTemp + padding, 0,
                                   width - (widthTemp * 2 + padding * 3), height);
    self.bufferSlier.frame = CGRectMake(
                                        widthTemp + padding, 0, width - (widthTemp * 2 + padding * 3), height);
}

- (void)hanleLargeBtn:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(controlView:
                                                    withLargeButton:)]) {
        [self.delegate controlView:self withLargeButton:button];
    }
}

- (void)handleSliderPosition:(UISlider *)slider {
    self.bTouchingSlider = YES;
}

- (void)onActionTouchUpOutInside:(UISlider *)sender {
    self.bTouchingSlider = NO;
    if ([self.delegate respondsToSelector:@selector(controlView:draggedPositionWithSlider:)]) {
        [self.delegate controlView:self draggedPositionWithSlider:self.slider];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self.slider];
    CGFloat pointX = point.x;
    CGFloat sliderWidth = self.slider.frame.size.width;
    CGFloat currentValue = pointX / sliderWidth * self.slider.maximumValue;
    if ([self.delegate respondsToSelector:@selector
         (controlView:pointSliderLocationWithCurrentValue:)]) {
        [self.delegate controlView:self pointSliderLocationWithCurrentValue:currentValue];
    }
}

// setter 和 getter方法
- (void)setValue:(CGFloat)value {
    self.slider.value = value;
}
- (CGFloat)value {
    return self.slider.value;
}
- (void)setMinValue:(CGFloat)minValue {
    self.slider.minimumValue = minValue;
}
- (CGFloat)minValue {
    return self.slider.minimumValue;
}
- (void)setMaxValue:(CGFloat)maxValue {
    self.slider.maximumValue = maxValue;
}
- (CGFloat)maxValue {
    return self.slider.maximumValue;
}
- (void)setCurrentTime:(NSString *)currentTime {
    self.timeLabel.text = currentTime;
}
- (NSString *)currentTime {
    return self.timeLabel.text;
}
- (void)setTotalTime:(NSString *)totalTime {
    self.totalTimeLabel.text = totalTime;
}
- (NSString *)totalTime {
    return self.totalTimeLabel.text;
}
- (CGFloat)bufferValue {
    return self.bufferSlier.value;
}
- (void)setBufferValue:(CGFloat)bufferValue {
    self.bufferSlier.value = bufferValue;
}
@end
