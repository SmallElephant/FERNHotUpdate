//
//  CodePullUtil.m
//  FERNHotUpdate
//
//  Created by FlyElephant on 2018/4/2.
//  Copyright © 2018年 FlyElephant. All rights reserved.
//

#import "CodePullUtil.h"
#include <CommonCrypto/CommonDigest.h>

@implementation CodePullUtil

+ (NSString *)getApplicationSupportDirectory {
    NSString *applicationSupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    if (![[NSFileManager defaultManager] fileExistsAtPath:applicationSupportDirectory]) {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"%@", error.localizedDescription);
        }
    }
    return applicationSupportDirectory;
}

+ (NSString *)hashFileName:(NSURL *)url {
    NSString *fileName = [url lastPathComponent];
    NSString *extension = [url pathExtension];
    NSString *newName = [NSString stringWithFormat:@"%@.%@",[CodePullUtil computeHashForString:fileName],extension];
    return newName;
}

+ (NSString *)computeHashForFile:(NSURL *)fileURL {
    NSString *fileContentsHash;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) {
        NSData *fileContents = [NSData dataWithContentsOfURL:fileURL];
        fileContentsHash = [self computeHashForData:fileContents];
    }
    return fileContentsHash;
}

+ (NSString *)computeHashForData:(NSData *)inputData {
    uint8_t digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(inputData.bytes, (CC_LONG)inputData.length, digest);
    NSMutableString *inputHash = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [inputHash appendFormat:@"%02x", digest[i]];
    }
    return inputHash;
}

+ (NSString *)computeHashForString:(NSString *)string {
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    NSMutableString *hash = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x", digest[i]];
    }
    return hash;
}

+ (BOOL)copyEntriesInFolder:(NSString *)sourceFolder
                 destFolder:(NSString *)destFolder
                      error:(NSError **)error {
    NSArray *files = [[NSFileManager defaultManager]
                      contentsOfDirectoryAtPath:sourceFolder
                      error:error];
    if (!files) {
        return NO;
    }
    
    for (NSString *fileName in files) {
        NSString * fullFilePath = [sourceFolder stringByAppendingPathComponent:fileName];
        BOOL isDir = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullFilePath
                                                 isDirectory:&isDir] && isDir) {
            NSString *nestedDestFolder = [destFolder stringByAppendingPathComponent:fileName];
            BOOL result = [self copyEntriesInFolder:fullFilePath
                                         destFolder:nestedDestFolder
                                              error:error];
            
            if (!result) {
                return NO;
            }
            
        } else {
            NSString *destFileName = [destFolder stringByAppendingPathComponent:fileName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:destFileName]) {
                BOOL result = [[NSFileManager defaultManager] removeItemAtPath:destFileName error:error];
                if (!result) {
                    return NO;
                }
            }
            if (![[NSFileManager defaultManager] fileExistsAtPath:destFolder]) {
                BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:destFolder
                                                        withIntermediateDirectories:YES
                                                                         attributes:nil
                                                                              error:error];
                if (!result) {
                    return NO;
                }
            }
            
            BOOL result = [[NSFileManager defaultManager] copyItemAtPath:fullFilePath toPath:destFileName error:error];
            if (!result) {
                return NO;
            }
        }
    }
    return YES;
}
@end
