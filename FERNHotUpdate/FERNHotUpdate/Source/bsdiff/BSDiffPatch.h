//
//  BSDiffPatch.h
//  CodePull-UI
//
//  Created by FlyElephant on 2018/3/31.
//  Copyright © 2018年 rrd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BSDiffPatch : NSObject

+ (BOOL)beginPatch:(NSString *)patch
            origin:(NSString *)origin
     toDestination:(NSString *)destination;

@end
