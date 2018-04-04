//
//  CodePullDownloader.m
//  FERNHotUpdate
//
//  Created by FlyElephant on 2018/4/2.
//  Copyright © 2018年 FlyElephant. All rights reserved.
//

#import "CodePullDownloader.h"
#import "CodePullUtil.h"

@interface CodePullDownloader()<NSURLSessionDownloadDelegate>

@end

@implementation CodePullDownloader

#pragma mark - Public

- (void)fetchVersionInfo:(void (^)(NSError *error, CodePullModel *model))complete {
    NSURL *url = [NSURL URLWithString:@"http://api.test.we.com/n2/home/rn/checkUpdate/?appKey=10f87932-bef4-4331-a8fb-5faeee5f&nativeVersion=50501&rnVersion=1"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (dic.count) {
            CodePullModel *model = [self convertToModel:dic[@"data"]];
            complete(nil, model);
        } else {
            complete(error, nil);
        }
    }];
    [dataTask resume];
}

- (void)download:(NSString *)url {
    self.downloadUrl = url;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSession *session = [self backgroundURLSession];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];
    [downloadTask resume];
}

#pragma mark - Private

- (CodePullModel *)convertToModel:(NSDictionary *)dict {
    CodePullModel *model = [[CodePullModel alloc] init];
    model.needUpdate = dict[@"needUpdate"];
    model.patchMd5 = dict[@"patchMd5"];
    model.patchUrl = dict[@"patchUrl"];
    model.updateRNVersion = dict[@"updateRNVersion"];
    model.fullPackageMd5 = dict[@"fullPackageMd5"];
    model.fullPackageUrl = dict[@"fullPackageUrl"];
    return model;
}

- (NSURLSession *)backgroundURLSession {
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *identifier = @"com.reactnative.download.backgroundSession";
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                delegate:self
                                           delegateQueue:[NSOperationQueue mainQueue]];
    });
    return session;
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
     NSLog(@"fileOffset:%lld expectedTotalBytes:%lld",fileOffset,expectedTotalBytes);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"downloadTask:%lu percent:%.2f%%",(unsigned long)downloadTask.taskIdentifier,(float)totalBytesWritten / totalBytesExpectedToWrite * 100);
}

- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
    NSString *file = [[CodePullUtil getApplicationSupportDirectory] stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    NSLog(@"新的文件路径:%@",file);
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:file] error:nil];
}

@end
