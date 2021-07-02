//
//  VideoCell.h
//  AVPlayerDemo
//
//  Created by HN on 2021/7/1.
//

#import <UIKit/UIKit.h>

// Model
#import "VideoInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoCell : UICollectionViewCell

@property(strong, nonatomic) VideoInfo *model;

@end

NS_ASSUME_NONNULL_END
