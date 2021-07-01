//
//  ViewController.m
//  AVPlayerDemo
//
//  Created by HN on 2021/6/30.
//

#import "DYVideoListViewController.h"

#import "DYVideoListCell.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface DYVideoListViewController () <UITableViewDelegate, UITableViewDataSource, DYVideoListCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewConstraintT;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewConstraintH;

@property(strong, nonatomic) NSMutableArray *dataArray;

@property(nonatomic, assign) NSInteger lastOrCurrentPlayIndex;
//记录偏移值,用于判断上滑还是下滑
@property(nonatomic, assign) CGFloat lastScrollViewContentOffsetY;

@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation DYVideoListViewController

#pragma mark - life
- (void)viewDidLoad {
    [super viewDidLoad];

    [self initData];
    [self creatData];
    [self setUI];
    
    //设置初次播放的
    [self setStartPlay];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"currentIndex"];
}

- (void)initData {
    self.lastOrCurrentPlayIndex = 0;
}

- (void)creatData {
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *url in self.urlsArray) {
        VideoInfo *model = [VideoInfo new];
        model.videoUrl = url;
        model.playTime = 0;
        [array addObject:model];
    }
    self.dataArray = array;
}

- (void)setUI {
    self.tableView.tableFooterView = [UIView new];
    self.tableView.tableHeaderView = [UIView new];
    self.tableViewConstraintT.constant = -ScreenHeight;
    self.tableViewConstraintH.constant = ScreenHeight * 3;
    _tableView.contentInset = UIEdgeInsetsMake(ScreenHeight, 0, ScreenHeight * 1, 0);

    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(DYVideoListCell.class) bundle:nil] forCellReuseIdentifier:NSStringFromClass(DYVideoListCell.class)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.data = self.awemes;
        [self.tableView reloadData];
        
        NSIndexPath *curIndexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
        [self.tableView scrollToRowAtIndexPath:curIndexPath atScrollPosition:UITableViewScrollPositionMiddle
                                      animated:NO];
        [self addObserver:self forKeyPath:@"currentIndex" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    });
}

#pragma mark - other
- (IBAction)onActionBack:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setStartPlay {
    DYVideoListCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.lastOrCurrentPlayIndex inSection:0]];
    [cell shouldToPlay];
}

#pragma mark - DYVideoListCellDelegate
- (void)playButtonClick:(UIButton *)sender {
    NSInteger row = sender.tag - 788;
    if (row != self.lastOrCurrentPlayIndex) {
        [self stopVideoWithShouldToStopIndex:self.lastOrCurrentPlayIndex];
        self.lastOrCurrentPlayIndex = row;
        [self playVideoWithShouldToPlayIndex:self.lastOrCurrentPlayIndex];
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DYVideoListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(DYVideoListCell.class)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.row = indexPath.row;
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size.height;
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    //判断滚动方向
//    BOOL isScrollDownward = NO;
//    if (scrollView.contentOffset.y > self.lastScrollViewContentOffsetY) { // Yes-往下滑
//        isScrollDownward = YES;
//    } else { // NO-往上滑
//        isScrollDownward = NO;
//    }
//    self.lastScrollViewContentOffsetY = scrollView.contentOffset.y;
//
//    //停止当前播放的
//    [self stopCurrentPlayingCell];
//
//    //找出适合播放的并播放
//    [self filterShouldPlayCellWithScrollDirection:isScrollDownward];
//}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGPoint translatedPoint = [scrollView.panGestureRecognizer translationInView:scrollView];
        //UITableView禁止响应其他滑动手势
        scrollView.panGestureRecognizer.enabled = NO;
    
        if(translatedPoint.y < -50 && self.currentIndex < (self.dataArray.count - 1)) {
            self.currentIndex ++;   //向下滑动索引递增
        }
        if(translatedPoint.y > 50 && self.currentIndex > 0) {
            self.currentIndex --;   //向上滑动索引递减
        }
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut animations:^{
            //UITableView滑动到指定cell
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        } completion:^(BOOL finished) {
            //UITableView可以响应其他滑动手势
            scrollView.panGestureRecognizer.enabled = YES;
        }];
        
    });
}

#pragma KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    //观察currentIndex变化
    if ([keyPath isEqualToString:@"currentIndex"]) {
        //设置用于标记当前视频是否播放的BOOL值为NO
//        _isCurPlayerPause = NO;
//        //获取当前显示的cell
//
//        AwemeListCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
//        [cell startDownloadHighPriorityTask];
//        __weak typeof (cell) wcell = cell;
//        __weak typeof (self) wself = self;
//        //判断当前cell的视频源是否已经准备播放
//        if(cell.isPlayerReady) {
//            //播放视频
//            [cell replay];
//        }else {
//            [[AVPlayerManager shareManager] pauseAll];
//            //当前cell的视频源还未准备好播放，则实现cell的OnPlayerReady Block 用于等待视频准备好后通知播放
//            cell.onPlayerReady = ^{
//                NSIndexPath *indexPath = [wself.tableView indexPathForCell:wcell];
//                if(!wself.isCurPlayerPause && indexPath && indexPath.row == wself.currentIndex) {
//                    [wcell play];
//                }
//            };
//        }
//    } else {
//        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - 播放暂停
- (void)filterShouldPlayCellWithScrollDirection:(BOOL)isScrollDownward {
    //顶部
    if (self.tableView.contentOffset.y <= 0) {
        //其他的已经暂停播放
        if (self.lastOrCurrentPlayIndex == -1) {
            [self playVideoWithShouldToPlayIndex:0];
        } else {
            //第一个正在播放
            if (self.lastOrCurrentPlayIndex == 0) {
                return;
            }
            //其他的没有暂停播放,先暂停其他的再播放第一个
            [self stopVideoWithShouldToStopIndex:self.lastOrCurrentPlayIndex];
            [self playVideoWithShouldToPlayIndex:0];
        }
        return;
    }
    
    //底部
    if (self.tableView.contentOffset.y + self.tableView.frame.size.height >= self.tableView.contentSize.height) {
        //其他的已经暂停播放
        if (self.lastOrCurrentPlayIndex == -1) {
            [self playVideoWithShouldToPlayIndex:self.dataArray.count - 1];
        } else {
            //最后一个正在播放
            if (self.lastOrCurrentPlayIndex == self.dataArray.count - 1) {
                return;
            }
            //其他的没有暂停播放,先暂停其他的再播放最后一个
            [self stopVideoWithShouldToStopIndex:self.lastOrCurrentPlayIndex];
            [self playVideoWithShouldToPlayIndex:self.dataArray.count - 1];
        }
        return;
    }
    
    //中部(找出可见cell中最合适的一个进行播放)
    NSArray *cellsArray = [self.tableView visibleCells];
    NSArray *newArray = nil;
    if (!isScrollDownward) {
        newArray = [cellsArray reverseObjectEnumerator].allObjects;
    } else {
        newArray = cellsArray;
    }
    [newArray enumerateObjectsUsingBlock:^(DYVideoListCell *cell, NSUInteger idx, BOOL *_Nonnull stop) {
        CGRect rect = [cell.videoBackView convertRect:cell.videoBackView.bounds toView:self.view];
        CGFloat topSpacing = rect.origin.y;
        CGFloat bottomSpacing = self.tableView.frame.size.height - rect.origin.y - rect.size.height;
        if (topSpacing >= -rect.size.height / 3. && bottomSpacing >= -rect.size.height / 3.) {
            if (self.lastOrCurrentPlayIndex == -1) {
                if (self.lastOrCurrentPlayIndex != cell.row) {
                    [cell shouldToPlay];
                    self.lastOrCurrentPlayIndex = cell.row;
                }
            }
            *stop = YES;
        }
    }];
}

- (void)stopCurrentPlayingCell {
    //避免第一次播放的时候被暂停
    if (self.tableView.contentOffset.y <= 0) {
        return;
    }
    
    if (self.lastOrCurrentPlayIndex != -1) {
        DYVideoListCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.lastOrCurrentPlayIndex inSection:0]];
        CGRect rect = [cell.videoBackView convertRect:cell.videoBackView.bounds toView:self.view];
        CGFloat topSpacing = rect.origin.y;
        CGFloat bottomSpacing = self.tableView.frame.size.height - rect.origin.y - rect.size.height;
        //当视频播放部分移除可见区域1/3的时候暂停
        if (topSpacing < -rect.size.height / 3. || bottomSpacing < -rect.size.height / 3.) {
            cell.model.playTime = cell.player.currentTime;
            [cell.player stop];
            cell.player = nil;
            self.lastOrCurrentPlayIndex = -1;
        }
    }
}

- (void)playVideoWithShouldToPlayIndex:(NSInteger)shouldToPlayIndex {
    DYVideoListCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:shouldToPlayIndex inSection:0]];
    [cell shouldToPlay];
    self.lastOrCurrentPlayIndex = cell.row;
}

- (void)stopVideoWithShouldToStopIndex:(NSInteger)shouldToStopIndex {
    DYVideoListCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:shouldToStopIndex inSection:0]];
    cell.model.playTime = cell.player.currentTime;
    [cell.player stop];
    cell.player = nil;
}

@end
