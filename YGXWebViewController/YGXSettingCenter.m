//
//  YGXSettingCenter.m
//  YGXWebViewController
//
//  Created by wz on 2018/8/17.
//  Copyright © 2018 wz. All rights reserved.
//

#import "YGXSettingCenter.h"

static NSString *const kEnableImg = @"kEnableImg";
static NSString *const kEnableExternalJump = @"kEnableExternalJump";

@implementation YGXSettingCenter

+ (instancetype)sharedCenter {
    static dispatch_once_t onceToken;
    static YGXSettingCenter *center = nil;
    dispatch_once(&onceToken, ^{
        center = [YGXSettingCenter new];
    });
    return center;
}

- (void)setEnableImg:(BOOL)enableImg {
    [[NSUserDefaults standardUserDefaults] setBool:enableImg forKey:kEnableImg];
}

- (BOOL)enableImg {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kEnableImg];
}

- (void)setEnableExternalJump:(BOOL)enableExternalJump {
    [[NSUserDefaults standardUserDefaults] setBool:enableExternalJump forKey:kEnableExternalJump];
}

- (BOOL)enableExternalJump {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kEnableExternalJump];
}

@end
