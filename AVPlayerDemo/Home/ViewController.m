//
//  ViewController.m
//  AVPlayerDemo
//
//  Created by HN on 2021/6/1.
//

// Controller
#import "ViewController.h"
#import "VideoListViewController.h"
#import "DYVideoListViewController.h"

// View
#import "VideoCell.h"

// Tools
#import "Utility.h"
#import "CacheHelpler.h"
#import "SDImageCache.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property(copy, nonatomic) NSArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self settingUI];

    [self onActionRefresh:nil];
}

#pragma mark - UI
- (void)settingUI
{
    self.navigationItem.title = @"AVPlayerDemo";
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(VideoCell.class) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass(VideoCell.class)];

    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.minimumLineSpacing = 10;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 12, 10, 12);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView.collectionViewLayout = flowLayout;
    self.collectionView.showsVerticalScrollIndicator = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

#pragma mark - other
- (IBAction)onActionClearCache:(UIBarButtonItem *)sender {
    //获取缓存图片的大小(字节)
    NSUInteger bytesCache = [[SDImageCache sharedImageCache] totalDiskSize];
    
    //换算成 MB (注意iOS中的字节之间的换算是1000不是1024)
    float MBCache = bytesCache/1000./1000.;
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        NSLog(@"异步清除图片缓存: %lf MB",MBCache);
    }];
}

- (IBAction)onActionRefresh:(UIBarButtonItem *)sender {
    self.dataArray = [Utility getUrls];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellW = (ScreenWidth-12*2-8)/2.;
    CGFloat cellH = cellW*264/171.5;
    return CGSizeMake(cellW, cellH);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(VideoCell.class) forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.item];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择跳转"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *weiBoAction = [UIAlertAction actionWithTitle:@"微博(无定位)"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
        
        VideoListViewController *vc = [[VideoListViewController alloc]init];
        vc.urlsArray = self.dataArray;
        [self.navigationController pushViewController:vc animated:YES];
    }];

    UIAlertAction *douyinAction = [UIAlertAction actionWithTitle:@"抖音"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
        DYVideoListViewController *vc = [[DYVideoListViewController alloc]init];
        vc.urlsArray = self.dataArray;
        vc.currentIndex = indexPath.row;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [alertController addAction:weiBoAction];
    [alertController addAction:douyinAction];
    [alertController addAction:cancelAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

@end
