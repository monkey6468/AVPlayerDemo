//
//  Utility.m
//  AVPlayerDemo
//
//  Created by HN on 2021/6/4.
//

#import "Utility.h"

@implementation Utility

#pragma mark - get data
+ (NSArray *)getUrls {
    NSArray *allUlr = [self getAllUrls];
    NSArray *randomArray = [[NSArray alloc]init];
    randomArray = [allUlr sortedArrayUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
        int seed = arc4random_uniform(2);
        if (seed) {
            return [str1 compare:str2];
        } else {
            return [str2 compare:str1];
        }
    }];
    
    return randomArray;
}

+ (NSArray *)getAllUrls {
//        @"https://xy2.v.netease.com/2020/dhp/qkjoimclekw15.mp4",
//        @"https://aweme.snssdk.com/aweme/v1/playwm/?video_id=v0200ff00000bdkpfpdd2r6fb5kf6m50&line=0.mp4",

    NSArray<NSString *> *urls = @[
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/02/07/875d17111b534655b7b42cbbb97c647b.mp4",// 10 VideoRenderModeFillEdge
        @"https://video.cnhnb.com/video/mp4/miniapp/2021/03/20/8664f5edc73e4d6891caeb4aa14ee337.mp4",// 3.48
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/10/7499e5f4ce864b2c884abf3af6112f56.mp4",// 22.73 VideoRenderModeFillEdge
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/01/da48b9687dd34a3a881347e0fc28fd04.mp4",//  6.52
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/10/d9167b1041cb49a2bb2d897ee7676c3c.mp4",// 7.5
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/0c6e8fb2afe742e1bc67d26f93d7650a.mp4",// 7.1
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/01/23/bf7869316294442eb8ede7fe7e9ac022.mp4",// 8.33
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/09/58a4fc9cb83e4a268411245058f88ab1.mp4",// 5
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/10/281c5a0dd5a049aeba1172909e7f4b5f.mp4",// 10.01
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/04/08/eee7cdbba8cb4d9b8d2ab6d6b2ac9c09.mp4",// VideoRenderModeFillScreen 10.36
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/01/09/d64965c85ab64389b0b4ee7c39b4ae97.mp4",// 27.32
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/10/7499e5f4ce864b2c884abf3af6112f56.mp4",// 22.73 VideoRenderModeFillEdge
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/04/998b644962364ede9a4d8d1af45f77e3.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/04/4bf8820c6a4d4c0482ca0d9dc271f096.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/09/b3ea7bb36ed044f18bff0ab8ac887fa0.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/08/c9f597f0eed347d2ac5fa3d8b7e23a1c.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/08/50946c1619db414cac166cd785102593.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/07/7031b25dfbe54d189140afd45a2adb91.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/02/a23c36a1e7394155ad72b870043ac1cb.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/01/9d8b6aa31f82458ab3f25c4c6f89d7cd.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/01/4ab29480f8574c7d9ac1241ef3aeb46a.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/2e40d10db91249eb8fa1b5c60c47ccde.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/aa8a13c7c54c465684b903c07788d2c7.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/803a7f7582c2413c8f65b5218d629bdc.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/8b31fbe739fc4c06908348825728a86e.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/ae025ed6b9204f979d2ee2e8e529fd21.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/07/24/c0a54c07d3ed4eaca88cb573c9ff4244.mp4",
    
    
        
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/04/998b644962364ede9a4d8d1af45f77e3.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/04/4bf8820c6a4d4c0482ca0d9dc271f096.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/01/da48b9687dd34a3a881347e0fc28fd04.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/02/07/875d17111b534655b7b42cbbb97c647b.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/01/23/bf7869316294442eb8ede7fe7e9ac022.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/01/09/d64965c85ab64389b0b4ee7c39b4ae97.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/10/281c5a0dd5a049aeba1172909e7f4b5f.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/09/58a4fc9cb83e4a268411245058f88ab1.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/09/b3ea7bb36ed044f18bff0ab8ac887fa0.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/08/c9f597f0eed347d2ac5fa3d8b7e23a1c.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/08/50946c1619db414cac166cd785102593.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/07/7031b25dfbe54d189140afd45a2adb91.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/02/a23c36a1e7394155ad72b870043ac1cb.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/01/9d8b6aa31f82458ab3f25c4c6f89d7cd.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/01/4ab29480f8574c7d9ac1241ef3aeb46a.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/2e40d10db91249eb8fa1b5c60c47ccde.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/aa8a13c7c54c465684b903c07788d2c7.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/803a7f7582c2413c8f65b5218d629bdc.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/8b31fbe739fc4c06908348825728a86e.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/ae025ed6b9204f979d2ee2e8e529fd21.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/07/24/c0a54c07d3ed4eaca88cb573c9ff4244.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/04/998b644962364ede9a4d8d1af45f77e3.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/04/4bf8820c6a4d4c0482ca0d9dc271f096.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/01/da48b9687dd34a3a881347e0fc28fd04.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/02/07/875d17111b534655b7b42cbbb97c647b.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/01/23/bf7869316294442eb8ede7fe7e9ac022.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/01/09/d64965c85ab64389b0b4ee7c39b4ae97.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/10/281c5a0dd5a049aeba1172909e7f4b5f.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/09/58a4fc9cb83e4a268411245058f88ab1.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/09/b3ea7bb36ed044f18bff0ab8ac887fa0.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/08/c9f597f0eed347d2ac5fa3d8b7e23a1c.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/08/50946c1619db414cac166cd785102593.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/07/7031b25dfbe54d189140afd45a2adb91.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/02/a23c36a1e7394155ad72b870043ac1cb.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/01/9d8b6aa31f82458ab3f25c4c6f89d7cd.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/01/4ab29480f8574c7d9ac1241ef3aeb46a.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/2e40d10db91249eb8fa1b5c60c47ccde.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/aa8a13c7c54c465684b903c07788d2c7.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/803a7f7582c2413c8f65b5218d629bdc.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/8b31fbe739fc4c06908348825728a86e.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/ae025ed6b9204f979d2ee2e8e529fd21.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/07/24/c0a54c07d3ed4eaca88cb573c9ff4244.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/04/998b644962364ede9a4d8d1af45f77e3.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/04/4bf8820c6a4d4c0482ca0d9dc271f096.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/01/da48b9687dd34a3a881347e0fc28fd04.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/02/07/875d17111b534655b7b42cbbb97c647b.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/01/23/bf7869316294442eb8ede7fe7e9ac022.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/01/09/d64965c85ab64389b0b4ee7c39b4ae97.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/10/281c5a0dd5a049aeba1172909e7f4b5f.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/09/58a4fc9cb83e4a268411245058f88ab1.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/09/b3ea7bb36ed044f18bff0ab8ac887fa0.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/08/c9f597f0eed347d2ac5fa3d8b7e23a1c.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/08/50946c1619db414cac166cd785102593.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/07/7031b25dfbe54d189140afd45a2adb91.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/02/a23c36a1e7394155ad72b870043ac1cb.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/01/9d8b6aa31f82458ab3f25c4c6f89d7cd.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/01/4ab29480f8574c7d9ac1241ef3aeb46a.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/2e40d10db91249eb8fa1b5c60c47ccde.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/aa8a13c7c54c465684b903c07788d2c7.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/803a7f7582c2413c8f65b5218d629bdc.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/8b31fbe739fc4c06908348825728a86e.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/ae025ed6b9204f979d2ee2e8e529fd21.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/07/24/c0a54c07d3ed4eaca88cb573c9ff4244.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/04/998b644962364ede9a4d8d1af45f77e3.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/04/4bf8820c6a4d4c0482ca0d9dc271f096.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/01/da48b9687dd34a3a881347e0fc28fd04.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/02/07/875d17111b534655b7b42cbbb97c647b.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/01/23/bf7869316294442eb8ede7fe7e9ac022.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/01/09/d64965c85ab64389b0b4ee7c39b4ae97.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/10/281c5a0dd5a049aeba1172909e7f4b5f.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/09/58a4fc9cb83e4a268411245058f88ab1.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/09/b3ea7bb36ed044f18bff0ab8ac887fa0.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/08/c9f597f0eed347d2ac5fa3d8b7e23a1c.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/08/50946c1619db414cac166cd785102593.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/07/7031b25dfbe54d189140afd45a2adb91.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/02/a23c36a1e7394155ad72b870043ac1cb.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/01/9d8b6aa31f82458ab3f25c4c6f89d7cd.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/01/4ab29480f8574c7d9ac1241ef3aeb46a.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/2e40d10db91249eb8fa1b5c60c47ccde.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/aa8a13c7c54c465684b903c07788d2c7.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/803a7f7582c2413c8f65b5218d629bdc.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/8b31fbe739fc4c06908348825728a86e.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/ae025ed6b9204f979d2ee2e8e529fd21.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/07/24/c0a54c07d3ed4eaca88cb573c9ff4244.mp4",
    
    ];
    return urls;
}

/// 获取视频帧图片路径
+ (NSString *)getFrameImagePathWithVideoPath:(NSString *)videoPath
                               showWatermark:(BOOL)isShowWatermark
{
    NSString *frameImagePath = nil;
    if (videoPath.length && [videoPath hasSuffix:@".mp4"]) {
        frameImagePath = [videoPath stringByAppendingString:@"?vframe/jpg/offset/0/"];
    }
    if (!isShowWatermark) {
        frameImagePath = [frameImagePath stringByReplacingOccurrencesOfString:@"transcode/"
                                                                   withString:@""];
    }
    return frameImagePath;
}

+ (void)videoPlayer:(AVPlayerView *)player
       playerStatus:(VideoPlayerStatus)status
              error:(NSError *)error
           tipLabel:(UILabel *)tipLabel
{
//    NSLog(@"%ld %@",(long)status, error.description);
    if (status == VideoPlayerStatusReady) {
        tipLabel.text = @"视频还未播放";
    } else if (status == VideoPlayerStatusReadyToPlay) {
        tipLabel.text = @"视频加载中...";
    } else if (status == VideoPlayerStatusPlaying) {
        tipLabel.text = @"视频播放中...";
    } else if (status == VideoPlayerStatusPaused) {
        tipLabel.text = @"视频已暂停";
    } else if (status == VideoPlayerStatusFinished) {
        tipLabel.text = @"视频已结束";
    } else if (status == VideoPlayerStatusUnknown) {
        tipLabel.text = @"视频未知错误";
    } else if (status == VideoPlayerStatusFailed) {
        tipLabel.text = @"视频播放失败";
    } else if (status == VideoPlayerStatusChangeEsolution) {
//        if (player.height/player.width <= 4/3.0) {
//            player.renderMode = VideoRenderModeFillEdge;
//        } else {
//            player.renderMode = VideoRenderModeFillScreen;
//        }
    }
}
@end
