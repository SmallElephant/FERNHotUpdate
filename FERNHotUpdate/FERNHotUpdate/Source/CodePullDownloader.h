//
//  CodePullDownloader.h
//  FERNHotUpdate
//
//  Created by FlyElephant on 2018/4/2.
//  Copyright © 2018年 FlyElephant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CodePullDownloader : NSObject

@property (copy, nonatomic) NSString *downloadUrl;

- (void)download:(NSString *)url;

@end
