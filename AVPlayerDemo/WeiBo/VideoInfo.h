//
//  VideoInfo.h
//  AVPlayerDemo
//
//  Created by HN on 2021/7/1.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoInfo : NSObject
/// 视频地址
@property (copy, nonatomic) NSString *videoUrl;
/// 视频播放时间
@property (assign, nonatomic) CGFloat playTime;
@end

NS_ASSUME_NONNULL_END
