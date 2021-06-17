//
//  AwemeListCell.h
//  AVPlayerDemo
//
//  Created by HN on 2021/6/17.
//

#import <UIKit/UIKit.h>

typedef void (^OnPlayerReady)(void);

@class AVPlayerView;

@interface AwemeListCell : UITableViewCell

@property (copy, nonatomic) NSString *aweme;

@property (nonatomic, strong) AVPlayerView     *playerView;


@property (nonatomic, strong) OnPlayerReady    onPlayerReady;
@property (nonatomic, assign) BOOL             isPlayerReady;

- (void)play;
- (void)pause;
- (void)replay;
- (void)startDownloadBackgroundTask;
- (void)startDownloadHighPriorityTask;

@end
