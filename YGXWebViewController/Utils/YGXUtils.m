//
//  YGXUtil.m
//  YGXWebViewController
//
//  Created by wz on 2018/7/6.
//  Copyright © 2018年 wz. All rights reserved.
//

#import "YGXUtils.h"
#import <CommonCrypto/CommonDigest.h>

@implementation YGXUtils

+ (NSString *)md5ForString:(NSString *)string {
    const char *str = [string UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *md5Result = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                           r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    return md5Result;
}

@end
