//
//  VideoPlayer.h
//  AVPlayerDemo
//
//  Created by HN on 2021/6/1.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoPlayer : NSObject

- (instancetype)initWithUrl:(NSString *)url;
- (void)showInView:(UIView *)playView;

@end

NS_ASSUME_NONNULL_END
