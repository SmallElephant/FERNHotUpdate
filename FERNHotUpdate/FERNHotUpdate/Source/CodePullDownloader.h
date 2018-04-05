//
//  CodePullDownloader.h
//  FERNHotUpdate
//
//  Created by FlyElephant on 2018/4/2.
//  Copyright © 2018年 FlyElephant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CodePullModel.h"

@interface CodePullDownloader : NSObject

@property (copy, nonatomic) NSString *downloadUrl;

@property (copy, nonatomic) void (^doneCallBack)(NSError *error, NSURL *fileUrl);

- (void)fetchVersionInfo:(void (^)(NSError *err, CodePullModel *model))completeCallback;

- (void)download:(NSArray *)files doneCallBack:(void(^)(NSError *error, NSURL *fileUrl))doneCallBack;

@end
