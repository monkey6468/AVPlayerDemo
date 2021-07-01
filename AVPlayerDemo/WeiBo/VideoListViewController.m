//
//  ViewController.m
//  ScrollPlayVideo
//
//  Created by 郑旭 on 2017/10/20.
//  Copyright © 2017年 郑旭. All rights reserved.
//

#import "VideoListViewController.h"

#import "VideoListCell.h"

@interface VideoListViewController () <
UITableViewDelegate, UITableViewDataSource, VideoListCellDelegate>
@property(nonatomic, strong) UITableView *tableView;
@property(strong, nonatomic) NSMutableArray *dataArray;

@property(nonatomic, assign) NSInteger lastOrCurrentPlayIndex;
//记录偏移值,用于判断上滑还是下滑
@property(nonatomic, assign) CGFloat lastScrollViewContentOffsetY;

@end

@implementation VideoListViewController

#pragma mark - life
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self creatData];
    [self setUI];
    
    //设置初次播放的
    [self setStartPlay];
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
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(VideoListCell.class) bundle:nil] forCellReuseIdentifier:NSStringFromClass(VideoListCell.class)];
}

- (void)setStartPlay {
    VideoListCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.lastOrCurrentPlayIndex inSection:0]];
    [cell shouldToPlay];
}

#pragma mark - VideoListCellDelegate
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
    VideoListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(VideoListCell.class)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.row = indexPath.row;
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 250;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //判断滚动方向
    BOOL isScrollDownward = NO;
    if (scrollView.contentOffset.y > self.lastScrollViewContentOffsetY) { // Yes-往下滑
        isScrollDownward = YES;
    } else { // NO-往上滑
        isScrollDownward = NO;
    }
    self.lastScrollViewContentOffsetY = scrollView.contentOffset.y;
    
    //停止当前播放的
    [self stopCurrentPlayingCell];
    
    //找出适合播放的并播放
    [self filterShouldPlayCellWithScrollDirection:isScrollDownward];
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
    [newArray enumerateObjectsUsingBlock:^(VideoListCell *cell, NSUInteger idx, BOOL *_Nonnull stop) {
        NSLog(@"%ld", (long)cell.row);
        
        CGRect rect = [cell.videoBackView convertRect:cell.videoBackView.bounds toView:self.view];
        CGFloat topSpacing = rect.origin.y;
        CGFloat bottomSpacing = self.view.frame.size.height - rect.origin.y - rect.size.height;
        if (topSpacing >= -rect.size.height / 3 &&
            bottomSpacing >= -rect.size.height / 3) {
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
        VideoListCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.lastOrCurrentPlayIndex inSection:0]];
        CGRect rect = [cell.videoBackView convertRect:cell.videoBackView.bounds toView:self.view];
        CGFloat topSpacing = rect.origin.y;
        CGFloat bottomSpacing = self.view.frame.size.height - rect.origin.y - rect.size.height;
        //当视频播放部分移除可见区域1/3的时候暂停
        if (topSpacing < -rect.size.height / 3 || bottomSpacing < -rect.size.height / 3) {
            cell.model.playTime = cell.player.currentTime;
            [cell.player stop];
            cell.player = nil;
            self.lastOrCurrentPlayIndex = -1;
        }
    }
}

- (void)playVideoWithShouldToPlayIndex:(NSInteger)shouldToPlayIndex {
    VideoListCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:shouldToPlayIndex inSection:0]];
    [cell shouldToPlay];
    self.lastOrCurrentPlayIndex = cell.row;
}

- (void)stopVideoWithShouldToStopIndex:(NSInteger)shouldToStopIndex {
    VideoListCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:shouldToStopIndex inSection:0]];
    [cell.player stop];
    cell.player = nil;
}

#pragma mark - Getters & Setters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.sectionFooterHeight = 1;
        _tableView.tableFooterView = [UIView new];
        _tableView.tableHeaderView = [UIView new];
        [self.view addSubview:self.tableView];
    }
    return _tableView;
}

@end
