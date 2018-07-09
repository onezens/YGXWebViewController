//
//  YGXUtil.h
//  YGXWebViewController
//
//  Created by wz on 2018/7/6.
//  Copyright © 2018年 wz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGXUtils : NSObject
+ (NSString *)md5ForString:(NSString *)string;
+ (NSData *)convertHexStrToData:(NSString *)str;
+ (NSString *)convertDataToHexStr:(NSData *)data;
@end
