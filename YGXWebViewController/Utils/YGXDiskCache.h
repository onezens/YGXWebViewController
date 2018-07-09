//
//  YGXDiskCache.h
//  YGXWebViewController
//
//  Created by wz on 2018/7/5.
//  Copyright © 2018年 wz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGXDCObject: NSObject

@property (nonatomic, strong) NSData *originData;

@property (nonatomic, copy) NSString *mimeType;

@property (nonatomic, assign, readonly) NSUInteger dataLength;

+ (instancetype)diskCacheObjWithData:(NSData *)data mimeType:(NSString *)mimeType;


@end

@interface YGXDiskCache : NSObject

+ (YGXDCObject *)getDataForKey:(NSString *)key;

+ (void)cacheData:(YGXDCObject *)dco withKey:(NSString *)key;

+ (void)cacheAppendData:(YGXDCObject *)dco withKey:(NSString *)key;

+ (void)removeDataForKey:(NSString *)key;

+ (BOOL)containDataForKey:(NSString *)key ;

@end
