//
//  ImageCache.h
//  AVPlayerDemo
//
//  Created by HN on 2021/6/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageCache : NSObject


@property (copy, nonatomic) NSString *imageUrl;

- (void)startDownloadTask:(NSURL *)URL isBackground:(BOOL)isBackground;

@end

NS_ASSUME_NONNULL_END
