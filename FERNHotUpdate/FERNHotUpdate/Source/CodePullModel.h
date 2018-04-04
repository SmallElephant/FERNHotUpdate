//
//  CodePullModel.h
//  FERNHotUpdate
//
//  Created by FlyElephant on 2018/4/4.
//  Copyright © 2018年 FlyElephant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CodePullModel : NSObject

@property (copy, nonatomic) NSString *needUpdate;
@property (copy, nonatomic) NSString *updateRNVersion;
@property (copy, nonatomic) NSString *fullPackageMd5;
@property (copy, nonatomic) NSString *fullPackageUrl;
@property (copy, nonatomic) NSString *patchMd5;
@property (copy, nonatomic) NSString *patchUrl;

@end
