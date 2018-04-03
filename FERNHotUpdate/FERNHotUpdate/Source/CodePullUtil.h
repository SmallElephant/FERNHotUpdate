//
//  CodePullUtil.h
//  FERNHotUpdate
//
//  Created by FlyElephant on 2018/4/2.
//  Copyright © 2018年 FlyElephant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CodePullUtil : NSObject

+ (NSString *)getApplicationSupportDirectory;

+ (NSString *)computeHashForFile:(NSURL *)fileURL;
+ (NSString *)computeHashForData:(NSData *)inputData;

+ (BOOL)copyEntriesInFolder:(NSString *)sourceFolder
                 destFolder:(NSString *)destFolder
                      error:(NSError **)error;

@end
