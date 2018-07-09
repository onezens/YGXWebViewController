//
//  YGXWebViewBar.m
//  YGXWebViewController
//
//  Created by wz on 2018/7/9.
//  Copyright © 2018年 wz. All rights reserved.
//

#import "YGXWebViewBar.h"

@implementation YGXWebViewBar

+ (instancetype)webViewBar {
    YGXWebViewBar *webBar = [[NSBundle mainBundle] loadNibNamed:@"YGXWebBarView" owner:self options:nil].firstObject;
    return webBar;
}

- (IBAction)back:(UIButton *)sender {

    if ([self.delegate respondsToSelector:@selector(backBtnClick:)]) {
        [self.delegate backBtnClick:sender];
    }
}
- (IBAction)forward:(id)sender {
    if ([self.delegate respondsToSelector:@selector(forwardBtnClick:)]) {
        [self.delegate forwardBtnClick:sender];
    }
}
- (IBAction)save:(id)sender {
    if ([self.delegate respondsToSelector:@selector(saveBtnClick:)]) {
        [self.delegate saveBtnClick:sender];
    }
}
- (IBAction)saveList:(id)sender {
    if ([self.delegate respondsToSelector:@selector(saveListBtnClick:)]) {
        [self.delegate saveListBtnClick:sender];
    }
}
- (IBAction)new:(id)sender {
    if ([self.delegate respondsToSelector:@selector(newBtnClick:)]) {
        [self.delegate newBtnClick:sender];
    }
}
- (IBAction)refresh:(id)sender {
    if ([self.delegate respondsToSelector:@selector(refreshBtnClick:)]) {
        [self.delegate refreshBtnClick:sender];
    }
}

@end
