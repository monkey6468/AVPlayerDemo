//
//  ViewController.m
//  AVPlayerDemo
//
//  Created by HN on 2021/6/1.
//

#import "ViewController.h"

#import "VideoPlayer.h"

@interface ViewController ()

@property (nonatomic, strong) UIImageView *videoPlayImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithCustomView:button];
//    self.navigationItem.leftBarButtonItem = backBtn;
    
    [[VideoPlayer shareInstance] showInView:self.view];
}









//- (UIImage *)getFirstImageofvideo {
//    AVAsset *asset = nil;
//    AVAssetImageGenerator *imageGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
//    if (imageGen) {
//        imageGen.appliesPreferredTrackTransform = YES;
//        CMTime actualTime;
//        CGImageRef cgImage = [imageGen copyCGImageAtTime:CMTimeMakeWithSeconds(0, 30) actualTime:&actualTime error:nil];
//        if (cgImage) {
//            UIImage *image = [UIImage imageWithCGImage:cgImage];
//            CGImageRelease(cgImage);
//            return image;
//        }
//    }
//    return nil;
//}



- (UIImageView *)videoPlayImageView {
    if (!_videoPlayImageView) {
        _videoPlayImageView = [UIImageView new];
        _videoPlayImageView.layer.shadowColor = [UIColor grayColor].CGColor;
        _videoPlayImageView.layer.shadowOffset = CGSizeMake(1, 1);
        _videoPlayImageView.layer.shadowOpacity = 1;
    }
    return _videoPlayImageView;
}


@end


/*
 NSArray<NSString *> *urls = @[
     @"https://video.cnhnb.com/video/mp4/douhuo/2021/04/08/eee7cdbba8cb4d9b8d2ab6d6b2ac9c09.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/24/59fa99dc757a4d44b3a09e5fdcd9d6e3.mp4",
     @"https://video.cnhnb.com/video/mp4/miniapp/2021/03/20/8664f5edc73e4d6891caeb4aa14ee337.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/10/d9167b1041cb49a2bb2d897ee7676c3c.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/04/15e1e854bf6b4b98ba2cb9b5528fb976.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/04/998b644962364ede9a4d8d1af45f77e3.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/04/4bf8820c6a4d4c0482ca0d9dc271f096.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/03/a6f9789ec7ba42a4b67fa7b29647bd1a.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/03/1cc646c8b5ad4e34b75a89292cc1a792.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/03/7459674e847d49e7ab8337fe56d53d55.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/03/86f1d849dca44bc3bcb3bdd4e158f9e9.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/01/da48b9687dd34a3a881347e0fc28fd04.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2021/02/07/875d17111b534655b7b42cbbb97c647b.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2021/01/23/bf7869316294442eb8ede7fe7e9ac022.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2021/01/09/d64965c85ab64389b0b4ee7c39b4ae97.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/10/7499e5f4ce864b2c884abf3af6112f56.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/10/281c5a0dd5a049aeba1172909e7f4b5f.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/09/be22d76796b240f1b31b54d9f0088f23.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/09/58a4fc9cb83e4a268411245058f88ab1.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/09/b3ea7bb36ed044f18bff0ab8ac887fa0.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/08/c9f597f0eed347d2ac5fa3d8b7e23a1c.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/08/50946c1619db414cac166cd785102593.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/07/7031b25dfbe54d189140afd45a2adb91.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/07/4d03585b5b084934922434fd1f2b2ad2.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/03/2fbf4adeabbd4e08b1e91c22947922ab.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/03/a199d9bf2d044dad9f28825ad1a8a646.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/03/e3d14bb89a25458288279f984acd0c08.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/05/24/05b961c7053e4de0b891da0261b4a9c3.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/05/24/05b961c7053e4de0b891da0261b4a9c3.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/02/a23c36a1e7394155ad72b870043ac1cb.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/02/33cd3487bff44a4eb5eb758d84016a0c.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/02/0cd41b6ed8644034a2381170951ef374.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/01/9d8b6aa31f82458ab3f25c4c6f89d7cd.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/01/4ab29480f8574c7d9ac1241ef3aeb46a.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/01/c976d53a98474ad992c995bfcc04964a.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/01/ac932e96d1b143dc8bf1ca9b3743c9e9.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/01/91a42a30a930442295439f12dd3945f5.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/01/765eb88274144fb1a7785fabfd88b56e.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/6f43df7ab5bd43778aae14a1770259e7.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/2e40d10db91249eb8fa1b5c60c47ccde.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/fcd0485552c94e4a9410787f8d8e6475.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/0c6e8fb2afe742e1bc67d26f93d7650a.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/aa8a13c7c54c465684b903c07788d2c7.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/803a7f7582c2413c8f65b5218d629bdc.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/8b31fbe739fc4c06908348825728a86e.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/ae025ed6b9204f979d2ee2e8e529fd21.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/28/c413d199e5c04b3fbc33a98c08131145.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/28/6fbb69ee2f3442f4a3484acaae567c14.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/07/24/c0a54c07d3ed4eaca88cb573c9ff4244.mp4",
     @"https://video.cnhnb.com/video/mp4/douhuo/2020/07/24/e8a94fc443494c11b4db57be9949f9e7.mp4"];
 */
