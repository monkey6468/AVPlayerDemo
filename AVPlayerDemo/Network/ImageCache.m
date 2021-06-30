//
//  ImageCache.m
//  AVPlayerDemo
//
//  Created by HN on 2021/6/21.
//

#import "ImageCache.h"
#import "CacheHelpler.h"
#import "SDWebImageDownloader.h"

@interface ImageCache ()

@property (copy, nonatomic) NSString *cacheFileKey; //缓存文件key值

@property (strong, nonatomic) CombineOperation *combineOperation;
@property (strong, nonatomic) NSOperation *queryCacheOperation;    // 查找本地缓存数据的NSOperation

@property (copy, nonatomic) NSString *imageUrl;
@property (strong, nonatomic) NSURL *sourceURL; // 图片路径
@property (strong, nonatomic) SDWebImageDownloadToken *downlaodToken;
@end

@implementation ImageCache

- (void)cancelLoading {
    if (self.combineOperation) {
        [self.combineOperation cancel];
        self.combineOperation = nil;
    }
}

- (void)downloadImageUrl:(NSString *)imageUrl completion:(void(^)(void))completionBlock {
    SDWebImageDownloader *manager = [SDWebImageDownloader sharedDownloader];
    self.downlaodToken = [manager downloadImageWithURL:[NSURL URLWithString:imageUrl]
                                               options:SDWebImageDownloaderUseNSURLCache|SDWebImageDownloaderScaleDownLargeImages
                                              progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        if(finished){
            if(completionBlock){
                completionBlock();
            }
        }
    }];
}

+ (NSArray *)createDownloadResultArray:(NSDictionary *)dict count:(NSInteger)count {
    NSMutableArray *resultArray = [NSMutableArray new];
    for(int i=0;i<count;i++) {
        NSObject *obj = [dict objectForKey:@(i)];
        [resultArray addObject:obj];
    }
    return resultArray;
}


- (void)setImageUrl:(NSString *)imageUrl needCache:(BOOL)bNeedCache {
    self.cacheFileKey = imageUrl;
    
    __weak __typeof(self) wself = self;
    //查找本地缓存数据
    self.queryCacheOperation = [[CacheHelpler sharedWebCache] queryURLFromDiskMemory:self.cacheFileKey cacheQueryCompletedBlock:^(id data, BOOL hasCache) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //hasCache是否有缓存，data为本地缓存路径
            if (hasCache) {
                wself.sourceURL = [NSURL fileURLWithPath:data];
            } else {
                if (bNeedCache) {
                    // 预加载
                    [self startDownloadTask:[NSURL URLWithString:imageUrl] isBackground:YES];
                    
                } else {
                    // 硬核下载
                    [self downloadImageUrl:imageUrl completion:^{
                        //下载完毕，将缓存数据保存到本地
                        [[CacheHelpler sharedWebCache] storeDataToDiskCache:data key:self.cacheFileKey extension:@"jpg"];
                    }];
                }
            }
        });
    } extension:@"jpg"];
}

- (void)startDownloadTask:(NSURL *)URL isBackground:(BOOL)isBackground {
    if (self.downlaodToken) {
        return;
    }

    __weak __typeof(self) wself = self;
    self.queryCacheOperation = [[CacheHelpler sharedWebCache] queryURLFromDiskMemory:self.cacheFileKey cacheQueryCompletedBlock:^(id data, BOOL hasCache) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (hasCache) {
                return;
            }
            
            if (wself.combineOperation != nil) {
                [wself.combineOperation cancel];
            }
            
            SDWebImageDownloader *manager = [SDWebImageDownloader sharedDownloader];
            wself.downlaodToken = [manager downloadImageWithURL:URL
                                   options:SDWebImageDownloaderUseNSURLCache|SDWebImageDownloaderScaleDownLargeImages
                                  progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                 
             } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                 if (finished) {
                     //下载完毕，将缓存数据保存到本地
                     [[CacheHelpler sharedWebCache] storeDataToDiskCache:data key:URL.absoluteString extension:@"jpg"];
                 }
             }];
        });
    }];

}

@end
