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

+ (NSString *)hashFileName:(NSURL *)url;

+ (NSString *)computeHashForFile:(NSURL *)fileURL;
+ (NSString *)computeHashForData:(NSData *)inputData;
+ (NSString *)computeHashForString:(NSString *)string;

+ (NSString *)createDir:(NSString *)dirName;
+ (NSString *)createSubDir:(NSString *)path subDir:(NSString *)subDir;

+ (NSMutableArray *)allSubDirsInFolder:(NSString *)sourceFolder error:(NSError **)error;
+ (NSMutableDictionary *)subDirDateInfo:(NSString *)sourceFolder error:(NSError **)error;

+ (NSString *)modifiedDateStringOfFileAtURL:(NSString *)fileURL;
+ (BOOL)copyEntriesInFolder:(NSString *)sourceFolder
                 destFolder:(NSString *)destFolder
                      error:(NSError **)error;



@end
