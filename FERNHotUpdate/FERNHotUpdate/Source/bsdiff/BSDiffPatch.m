//
//  BSDiffPatch.m
//  CodePull-UI
//
//  Created by FlyElephant on 2018/3/31.
//  Copyright © 2018年 FlyElephant. All rights reserved.
//

#import "BSDiffPatch.h"
#import "bspatch.h"

@implementation BSDiffPatch

+ (BOOL)beginPatch:(NSString *)patch
            origin:(NSString *)origin
     toDestination:(NSString *)destination
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:patch]) {
        return NO;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:origin]) {
        return NO;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:destination]) {
        [[NSFileManager defaultManager] removeItemAtPath:destination error:nil];
    }
    
    int err = beginPatch([origin UTF8String], [destination UTF8String], [patch UTF8String]);
    if (err) {
        return NO;
    }
    return YES;
}

@end
