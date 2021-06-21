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

@property (copy, nonatomic) NSString *videoUrl;
@property (assign, nonatomic) NSInteger index;

@property (strong, nonatomic) AVPlayerView *playerView;
@property (strong, nonatomic) OnPlayerReady onPlayerReady;
@property (assign, nonatomic) BOOL isPlayerReady;

- (void)play;
- (void)pause;
- (void)replay;
- (void)startDownloadHighPriorityTask;

@end
