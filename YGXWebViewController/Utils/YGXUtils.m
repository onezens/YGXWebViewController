//
//  YGXUtil.m
//  YGXWebViewController
//
//  Created by wz on 2018/7/6.
//  Copyright © 2018年 wz. All rights reserved.
//

#import "YGXUtils.h"
#import <CommonCrypto/CommonDigest.h>

@interface YGXUtils()

@end

@implementation YGXUtils
NSUInteger _oldTime;
dispatch_queue_t _queue;
NSMutableArray *_tasks;

+ (NSMutableArray *)tasks {

    if(!_tasks){
        _tasks = [NSMutableArray array];
    }
    return _tasks;
}

+ (dispatch_queue_t)queue {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _queue = dispatch_queue_create("UTILS QUEUE", DISPATCH_QUEUE_CONCURRENT);
    });
    return _queue;
}
+ (void)timeBegin {
    _oldTime = [self msec_timestamp];
    
}
+ (NSUInteger)timeEnd {
    return [self msec_timestamp] - _oldTime;
}

+ (NSUInteger)msec_timestamp {
    return (NSUInteger)[NSDate date].timeIntervalSince1970;
}

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


+ (NSString *)base64encode:(NSString *)string {
    //先将string转换成data
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *base64Data = [data base64EncodedDataWithOptions:0];
    NSString *baseString = [[NSString alloc]initWithData:base64Data encoding:NSUTF8StringEncoding];
    return baseString;
}
+ (NSString *)base64decode:(NSString *)base64String {

    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    return string;
}



+ (NSData *)convertHexStrToData:(NSString *)str {
    
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}


+ (NSString *)convertDataToHexStr:(NSData *)data {
    
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}

+ (void)cancel {
    NSLog(@"[cancen Tasks] count: %zd", [self tasks].count);
    [[self tasks].copy enumerateObjectsUsingBlock:^(NSURLSessionDownloadTask * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj cancel];
    }];
}
+ (void)resHeadersWithUrl:(NSString *)urlStr completion:(void (^)(NSDictionary *resHeaders))completion {
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //只获取响应头 大概100ms就能返回
    [request setHTTPMethod:@"HEAD"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 3;
    config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:[NSOperationQueue currentQueue]];
    NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [[self tasks] removeObject:task];
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
        NSDictionary *allHeaderFields = res.allHeaderFields;
        completion ? completion(allHeaderFields) : false;
        if (error){
            NSLog(@"[Head Error] URL: %@ \nError: %@", urlStr, error);
        }
    }];
    [[self tasks] addObject:task];
    [task resume];
}

+ (NSDictionary *)resHeadersWithUrl:(NSString *)urlStr {
    __block NSDictionary *headers = nil;
    dispatch_sync([self queue], ^{
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [self resHeadersWithUrl:urlStr completion:^(NSDictionary *resHeaders) {
            headers = resHeaders;
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    });
    return headers;
}




@end
