//
//  VideoPageViewController.m
//  AVPlayerDemo
//
//  Created by HN on 2021/6/4.
//

#import "VideoPageViewController.h"
#import "PlayerContentViewController.h"

@interface VideoPageViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, strong) UIPageViewController *pageViewController;

@property (copy, nonatomic) NSArray *urlsArray;

@end

@implementation VideoPageViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.urlsArray = [self getUrls];

    // 设置UIPageViewController的配置项
//    NSDictionary *options = @{UIPageViewControllerOptionInterPageSpacingKey : @(20)};
    NSDictionary *options = @{UIPageViewControllerOptionSpineLocationKey : @(UIPageViewControllerSpineLocationNone)};

    // 根据给定的属性实例化UIPageViewController
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationVertical
                                                                        options:options];
    // 设置UIPageViewController代理和数据源
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    
    // 设置UIPageViewController初始化数据, 将数据放在NSArray里面
    // 如果 options 设置了 UIPageViewControllerSpineLocationMid,注意viewControllers至少包含两个数据,且 doubleSided = YES
    
    PlayerContentViewController *initialViewController = [self viewControllerAtIndex:0];// 得到第一页
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageViewController setViewControllers:viewControllers
                              direction:UIPageViewControllerNavigationDirectionReverse
                               animated:NO
                             completion:nil];

    // 设置UIPageViewController 尺寸
    self.pageViewController.view.frame = self.view.bounds;

    // 在页面上，显示UIPageViewController对象的View
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];

}

#pragma mark - UIPageViewControllerDataSource And UIPageViewControllerDelegate

#pragma mark 返回上一个ViewController对象

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [self indexOfViewController:(PlayerContentViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    // 返回的ViewController，将被添加到相应的UIPageViewController对象上。
    // UIPageViewController对象会根据UIPageViewControllerDataSource协议方法,自动来维护次序
    // 不用我们去操心每个ViewController的顺序问题
    return [self viewControllerAtIndex:index];
    
    
}

#pragma mark 返回下一个ViewController对象

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(PlayerContentViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if (index == self.urlsArray.count) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
    
    
}

#pragma mark - 根据index得到对应的UIViewController

- (PlayerContentViewController *)viewControllerAtIndex:(NSUInteger)index {
    if ((self.urlsArray.count == 0) || (index >= self.urlsArray.count)) {
        return nil;
    }
    // 创建一个新的控制器类，并且分配给相应的数据
    PlayerContentViewController *contentVC = [[PlayerContentViewController alloc] init];
    contentVC.index = index;
    contentVC.url = self.urlsArray[contentVC.index];
    return contentVC;
}

#pragma mark - 数组元素值，得到下标值

- (NSUInteger)indexOfViewController:(PlayerContentViewController *)viewController {
//    return [self.pageContentArray indexOfObject:@(viewController.index)];
    return viewController.index;
}



- (NSArray *)getUrls {
    NSArray<NSString *> *urls = @[
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/11/30/0c6e8fb2afe742e1bc67d26f93d7650a.mp4",
        @"https://xy2.v.netease.com/2020/dhp/qkjoimclekw15.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/12/10/7499e5f4ce864b2c884abf3af6112f56.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/04/08/eee7cdbba8cb4d9b8d2ab6d6b2ac9c09.mp4",
        @"https://video.cnhnb.com/video/mp4/miniapp/2021/03/20/8664f5edc73e4d6891caeb4aa14ee337.mp4",
        @"https://video.cnhnb.com/video/mp4/douhuo/2021/03/10/d9167b1041cb49a2bb2d897ee7676c3c.mp4",
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
        @"https://video.cnhnb.com/video/mp4/douhuo/2020/07/24/c0a54c07d3ed4eaca88cb573c9ff4244.mp4"];
    return urls;
}

@end
