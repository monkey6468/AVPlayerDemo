//
//  Utility.h
//  AVPlayerDemo
//
//  Created by HN on 2021/6/4.
//

#import <Foundation/Foundation.h>

#import "AVPlayerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface Utility : NSObject

+ (NSArray *)getUrls;

/// 获取视频帧图片路径
+ (NSString *)getFrameImagePathWithVideoPath:(NSString *)videoPath
                               showWatermark:(BOOL)isShowWatermark;

+ (void)videoPlayer:(AVPlayerView *)player
       playerStatus:(VideoPlayerStatus)status
              error:(NSError *)error
           tipLabel:(UILabel *)tipLabel;
@end

NS_ASSUME_NONNULL_END
