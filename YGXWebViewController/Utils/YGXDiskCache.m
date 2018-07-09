//
//  YGXDiskCache.m
//  YGXWebViewController
//
//  Created by wz on 2018/7/5.
//  Copyright © 2018年 wz. All rights reserved.
//

#import "YGXDiskCache.h"
#import "YGXUtils.h"

#import <YYCache.h>

@interface YGXDCObject()
@end

#pragma mark -  YGXDCObject

@implementation YGXDCObject

- (NSUInteger)dataLength {
    return _originData.length;
}

+ (instancetype)diskCacheObjWithData:(NSData *)data mimeType:(NSString *)mimeType {
    YGXDCObject *dcObj = [YGXDCObject new];
    dcObj.originData = data;
    dcObj.mimeType = mimeType;
    return dcObj;
}

- (NSData *)cacheData {
    NSDictionary *dict = [self dictionaryWithValuesForKeys:@[@"mimeType"]];
    return [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
}

- (NSString *)originDataCacheKeyWithUrl:(NSString *)url {
    return [NSString stringWithFormat:@"%@-%@",url,self.mimeType];
}

+ (instancetype)diskCacheObjWithCacheData:(NSData *)data {
    if (!data) return nil;
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) return nil;
    YGXDCObject *dco = [[YGXDCObject alloc] init];
    [dco setValuesForKeysWithDictionary:dict];
    return dco;
}

@end


#pragma mark - YGXDiskCache

@interface YGXDiskCache()
@property (nonatomic, strong) YYDiskCache *metaDataCache;
@end

@implementation YGXDiskCache

static YGXDiskCache *_instance;

+ (instancetype)diskCache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [YGXDiskCache new];
        [_instance initCache];
    });
    return _instance;
}

- (void)initCache {
    _metaDataCache = [self createDiskCache];
}

- (NSString *)cacheRootDirectory {
    NSString *cacheDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
    cacheDirectory = [cacheDirectory stringByAppendingFormat:@"/YGXWebCache"];
    return cacheDirectory;
}

- (NSString *)cacheFilePathWithMimeType:(NSString *)mimeType fileName:(NSString *)fileName{
    NSString *localPath = [self cacheRootDirectory];
    NSString *extension = [mimeType componentsSeparatedByString:@"/"].lastObject;
    localPath = [localPath stringByAppendingFormat:@"/%@",mimeType];
    if (![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:localPath withIntermediateDirectories:true attributes:nil error:nil];
    }
    return [localPath stringByAppendingFormat:@"/%@.%@",fileName ,extension];
    
}

//创建cache对象，mimeType为空，则默认的对象json数据的cache
- (YYDiskCache *)createDiskCache {
    NSString *cacheDirectory = [[self cacheRootDirectory] stringByAppendingString:@"/data"];;
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory withIntermediateDirectories:true attributes:nil error:nil];
    }
    YYDiskCache *diskCache = [[YYDiskCache alloc] initWithPath:cacheDirectory];
    diskCache.costLimit = 50 * 1024 * 1024; //50MB
    return diskCache;
}

#pragma mark - private

- (void)cacheData:(NSData *)data withKey:(NSString *)key{
    [_metaDataCache setObject:data forKey:key];
}

- (NSData *)getDataForKey:(NSString *)key{
    
    return (NSData *)[_metaDataCache objectForKey:key];
}

- (void)removeDataForKey:(NSString *)key{
    [_metaDataCache removeObjectForKey:key];
}

- (BOOL)containDataForKey:(NSString *)key {
    return [_metaDataCache containsObjectForKey:key];
}

- (void)saveData:(NSData *)data path:(NSString *)localPath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        [data writeToFile:localPath atomically:true];
    }
}

- (NSData *)getDataWithLocalPath:(NSString *)localPath {
    NSData *data = [NSData dataWithContentsOfFile:localPath];
    return data;
}

- (NSData *)getDataWithMimeType:(NSString *)mimeType fileName:(NSString *)fileName{
    NSString *path = [self cacheFilePathWithMimeType:mimeType fileName:fileName];
    return [self getDataWithLocalPath:path];
}

- (void)saveData:(NSData *)data mimeType:(NSString *)mimeType fileName:(NSString *)fileName {
    NSString *path = [self cacheFilePathWithMimeType:mimeType fileName:fileName];
    [self saveData:data path:path];
}

- (void)saveAppendData:(NSData *)data mimeType:(NSString *)mimeType fileName:(NSString *)fileName {
    NSString *path = [self cacheFilePathWithMimeType:mimeType fileName:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:path];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:data];
        [fileHandle closeFile];
    }else{
        [data writeToFile:path atomically:true];
    }
}

#pragma mark - public

+ (void)cacheData:(YGXDCObject *)dco withKey:(NSString *)key {
    NSData *data = [dco cacheData];
    [[YGXDiskCache diskCache] cacheData:data withKey:key];
    [[YGXDiskCache diskCache] saveData:dco.originData mimeType:dco.mimeType fileName:[YGXUtils md5ForString:key]];
}

+ (void)cacheAppendData:(YGXDCObject *)dco withKey:(NSString *)key {
    NSData *data = [dco cacheData];
    [[YGXDiskCache diskCache] cacheData:data withKey:key];
    [[YGXDiskCache diskCache] saveAppendData:dco.originData mimeType:dco.mimeType fileName:[YGXUtils md5ForString:key]];
}

+ (YGXDCObject *)getDataForKey:(NSString *)key {
    NSData *data = [[YGXDiskCache diskCache] getDataForKey:key];
    YGXDCObject *dco = [YGXDCObject diskCacheObjWithCacheData:data];
    dco.originData = [[YGXDiskCache diskCache] getDataWithMimeType:dco.mimeType fileName:[YGXUtils md5ForString:key]];
    return dco;
}

+ (void)removeDataForKey:(NSString *)key {
    [[YGXDiskCache diskCache] removeDataForKey:key];
}

+ (BOOL)containDataForKey:(NSString *)key {
    return [[YGXDiskCache diskCache] containDataForKey:key];
}


@end
