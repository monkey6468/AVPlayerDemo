//
//  AwemeListCell.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^OnPlayerReady)(void);

@class Aweme;
@class AVPlayerView;

@interface AwemeListCell : UITableViewCell

@property (nonatomic, strong) Aweme            *aweme;

@property (nonatomic, strong) AVPlayerView     *playerView;


@property (nonatomic, strong) OnPlayerReady    onPlayerReady;
@property (nonatomic, assign) BOOL             isPlayerReady;

- (void)initData:(Aweme *)aweme;
- (void)play;
- (void)pause;
- (void)replay;
- (void)startDownloadBackgroundTask;
- (void)startDownloadHighPriorityTask;

@end
