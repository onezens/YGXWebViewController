//
//  YGXSettingCenter.h
//  YGXWebViewController
//
//  Created by wz on 2018/8/17.
//  Copyright © 2018 wz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGXSettingCenter : NSObject

+ (instancetype)sharedCenter;

@property (nonatomic, assign) BOOL enableImg;

@property (nonatomic, assign) BOOL enableExternalJump;

@end
