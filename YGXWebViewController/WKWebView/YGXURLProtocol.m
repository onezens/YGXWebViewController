//
//  YGXURLProtocol.m
//  YGXWebViewController
//
//  Created by wz on 2018/7/4.
//  Copyright © 2018年 wz. All rights reserved.
//

#import "YGXURLProtocol.h"
#import "YGXDiskCache.h"

static NSString * const KYGXURLProtocol = @"KYGXURLProtocol";

@interface YGXURLProtocol()<NSURLSessionDelegate>
@property (nonnull,strong) NSURLSessionDataTask *task;
@end

@implementation YGXURLProtocol

//是否需要处理request请求
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSLog(@"request URL: %@",request.URL.absoluteString);
    NSString *scheme = [[request URL] scheme];
    if (([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame || [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame )) {
        //看看是否已经处理过了，防止无限循环
        if ([NSURLProtocol propertyForKey:KYGXURLProtocol inRequest:request])
            return NO;
        return YES;
    }
    return NO;
}

//处理request请求
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request{
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    return mutableReqeust;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading {
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    //给我们处理过的请求设置一个标识符, 防止无限循环,
    [NSURLProtocol setProperty:@YES forKey:KYGXURLProtocol inRequest:mutableReqeust];
    if ([YGXDiskCache containDataForKey:mutableReqeust.URL.absoluteString]) {
        YGXDCObject *dco = [YGXDiskCache getDataForKey:mutableReqeust.URL.absoluteString];
        NSData* data = dco.originData;
        NSURLResponse* response = [[NSURLResponse alloc] initWithURL:self.request.URL MIMEType:dco.mimeType expectedContentLength:data.length textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];
    }else{
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
        self.task = [session dataTaskWithRequest:self.request];
        [self.task resume];
    }
    
}
- (void)stopLoading
{
    if (self.task != nil) {
        [self.task cancel];
    }
}

#pragma mark - NSURLSession delegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [[self client] URLProtocol:self didLoadData:data];
    NSURLResponse *res = dataTask.response;
    NSString *url = dataTask.originalRequest.URL.absoluteString;
    YGXDCObject *dco = [YGXDCObject diskCacheObjWithData:data mimeType:res.MIMEType];
    [YGXDiskCache cacheData:dco withKey:url];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    [self.client URLProtocolDidFinishLoading:self];
}

@end
