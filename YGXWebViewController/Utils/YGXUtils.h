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
+ (void)resHeadersWithUrl:(NSString *)urlStr completion:(void (^)(NSDictionary *resHeaders))completion;
+ (NSDictionary *)resHeadersWithUrl:(NSString *)urlStr;
+ (void)timeBegin;
+ (NSUInteger)timeEnd;
+ (void)cancel;
@end
