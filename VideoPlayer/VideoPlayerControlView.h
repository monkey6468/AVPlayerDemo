//
//  VideoPlayerControlView.h
//  VideoPlayer
//
//  Created by HN on 2021/6/30.
//

#import <UIKit/UIKit.h>

@class VideoPlayerControlView;
@protocol VideoPlayerControlViewDelegate <NSObject>
@required
/**
 点击UISlider获取点击点
 
 @param controlView 控制视图
 @param value 当前点击点
 */
- (void)controlView:(VideoPlayerControlView *)controlView pointSliderLocationWithCurrentValue:(CGFloat)value;

/**
 拖拽UISlider的knob的时间响应代理方法
 
 @param controlView 控制视图
 @param slider UISlider
 */
- (void)controlView:(VideoPlayerControlView *)controlView draggedPositionWithSlider:(UISlider *)slider;

/**
 点击放大按钮的响应事件
 
 @param controlView 控制视图
 @param button 全屏按钮
 */
- (void)controlView:(VideoPlayerControlView *)controlView withLargeButton:(UIButton *)button;
@end

@interface VideoPlayerControlView : UIView

//全屏按钮
//@property (nonatomic,strong) UIButton *largeButton;
//进度条当前值
@property(nonatomic, assign) CGFloat value;
@property (assign, nonatomic, getter=isTouchingSlider) BOOL bTouchingSlider; // 进度条
//最小值
@property(nonatomic, assign) CGFloat minValue;
//最大值
@property(nonatomic, assign) CGFloat maxValue;
//当前时间
@property(nonatomic, copy) NSString *currentTime;
//总时间
@property(nonatomic, copy) NSString *totalTime;
//缓存条当前值
@property(nonatomic, assign) CGFloat bufferValue;
// UISlider手势
@property(nonatomic, strong) UITapGestureRecognizer *tapGesture;
//代理方法
@property(nonatomic, weak) id<VideoPlayerControlViewDelegate> delegate;

@end
