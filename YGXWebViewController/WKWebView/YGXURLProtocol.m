//
//  YGXURLProtocol.m
//  YGXWebViewController
//
//  Created by wz on 2018/7/4.
//  Copyright © 2018年 wz. All rights reserved.
//

#import "YGXURLProtocol.h"
#import "YGXDiskCache.h"
#import "YGXUtils.h"

static NSString * const KYGXURLProtocol = @"KYGXURLProtocol";

@interface YGXURLProtocol()<NSURLSessionDelegate>
@property (nonatomic,strong) NSURLSessionDataTask *task;
@property (nonatomic, assign) BOOL isIgnoreReq;
@end

@implementation YGXURLProtocol

//是否需要处理request请求
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSString *scheme = [[request URL] scheme];
    if (([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame || [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame )) {
        NSString *urlStr = request.URL.absoluteString;
        //看看是否已经处理过了，防止无限循环
        if ([NSURLProtocol propertyForKey:KYGXURLProtocol inRequest:request])
            return false;
        return true;
//        [YGXUtils timeBegin];
//        NSDictionary *headers = [YGXUtils resHeadersWithUrl:urlStr];
//        NSLog(@"[Timer End] %ld", [YGXUtils timeEnd]);
//        NSString *contentType = [headers valueForKey:@"content-type"];
//        BOOL isControlRequest = [contentType containsString:@"image"];
//        if (isControlRequest) {
//            NSLog(@"[URL] %@", urlStr);
//            [YGXDiskCache addIgnoreUrl:urlStr];
//        }
//        return  isControlRequest;
    }
    return false;
}

//处理request请求
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request{
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading {
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    //给我们处理过的请求设置一个标识符, 防止无限循环,
    [NSURLProtocol setProperty:@YES forKey:KYGXURLProtocol inRequest:mutableReqeust];
    NSString *url = mutableReqeust.URL.absoluteString;
    NSString *range = [self.request.allHTTPHeaderFields valueForKey:@"Range"];
    YGXDCObject *dco = [YGXDiskCache getDataForKey:mutableReqeust.URL.absoluteString];
    BOOL isNoCache = range && [range isEqualToString:@"bytes=0-1"];
    isNoCache = isNoCache || ![YGXDiskCache containDataForKey:url];
    isNoCache = isNoCache || [dco.mimeType containsString:@"json"];
    isNoCache = isNoCache || [dco.mimeType containsString:@"html"];
    if (!isNoCache) {
        NSData *data = data = dco.originData;
        NSURLResponse* response = [[NSURLResponse alloc] initWithURL:self.request.URL MIMEType:dco.mimeType expectedContentLength:data.length textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];
    }else{
        [self startNewDownload:mutableReqeust];
    }
    
    
}

- (void)startNewDownload:(NSURLRequest *)request {
    if ([YGXDiskCache ignoreUrl:request.URL.absoluteString]) {
        [self.client URLProtocol:self didLoadData:nil];
        return;
    }
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    self.task = [session dataTaskWithRequest:request];
    [self.task resume];
}

+ (BOOL)isMediaSrc:(NSString *)url {
    NSString *srcUrl = [url lowercaseString];
    if ([srcUrl containsString:@"png"] || [srcUrl containsString:@"gif"] || [srcUrl containsString:@"jpeg"] || [srcUrl containsString:@"webp"] ) {
        return true;
    }
    if ([srcUrl containsString:@"mp4"] || [srcUrl containsString:@"avi"] || [srcUrl containsString:@"mov"]) {
        return true;
    }
    
    return false;
}
- (void)stopLoading
{
    NSLog(@"[stopLoading] stop: %@", self);
    if (self.task.state == NSURLSessionTaskStateRunning) {
        [self.task cancel];
    }
    self.task = nil;
}

#pragma mark - NSURLSession delegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    if ([dataTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)dataTask.response;
        NSString *mimeType = res.MIMEType;
        NSString *url = dataTask.originalRequest.URL.absoluteString;
        if (![mimeType containsString:@"image"]) {
            [self.client URLProtocol:self didLoadData:data];
        }else{
            [self.client URLProtocol:self didLoadData:nil];
            [YGXDiskCache ignoreUrl:url];
        }
        if (res.statusCode == 200) {
            YGXDCObject *dco = [YGXDCObject diskCacheObjWithData:data mimeType:mimeType];
            [YGXDiskCache cacheData:dco withKey:url];
            return;
        }else if (res.statusCode == 206){
            if (data.length != 2) {
                YGXDCObject *dco = [YGXDCObject diskCacheObjWithData:data mimeType:mimeType];
                [YGXDiskCache cacheAppendData:dco withKey:url];
            }
            return;
           
        }
        NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"[didReceiveData Error] statusCode: %zd  data: %@", res.statusCode, dataStr);
    }else{
        [self.client URLProtocol:self didLoadData:data];
    }
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    if (error) {
        NSLog(@"[didCompleteWithError]: %@", error);
    }
    [self.client URLProtocolDidFinishLoading:self];
}

@end
