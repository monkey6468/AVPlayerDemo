//
//  AVPlayerManager.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "AVPlayerManager.h"

@interface AVPlayerManager()

@end

@implementation AVPlayerManager

+ (AVPlayerManager *)shareManager {
    static dispatch_once_t once;
    static AVPlayerManager *manager;
    dispatch_once(&once, ^{
        manager = [AVPlayerManager new];
    });
    return manager;
}

+ (void)setAudioMode {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (instancetype)init {
    if (self = [super init]) {
        self.playerArray = [NSMutableArray array];
    }
    return self;
}

- (void)play:(AVPlayer *)player {
    [self.playerArray enumerateObjectsUsingBlock:^(AVPlayer * obj, NSUInteger idx, BOOL *stop) {
        [obj pause];
    }];
    if(![self.playerArray containsObject:player]) {
        [self.playerArray addObject:player];
    }
    [player play];
}

- (void)pause:(AVPlayer *)player {
    if([self.playerArray containsObject:player]) {
        [player pause];
    }
}

- (void)pauseAll {
    [self.playerArray enumerateObjectsUsingBlock:^(AVPlayer * obj, NSUInteger idx, BOOL *stop) {
        [obj pause];
    }];
}

- (void)replay:(AVPlayer *)player {
    [self.playerArray enumerateObjectsUsingBlock:^(AVPlayer * obj, NSUInteger idx, BOOL *stop) {
        [obj pause];
    }];
    if([self.playerArray containsObject:player]) {
        [player seekToTime:kCMTimeZero];
        [self play:player];
    }else {
        [self.playerArray addObject:player];
        [self play:player];
    }
}

- (void)removeAllPlayers {
    [self.playerArray removeAllObjects];
}

@end
