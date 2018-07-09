//
//  YGXWebViewBar.h
//  YGXWebViewController
//
//  Created by wz on 2018/7/9.
//  Copyright © 2018年 wz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YGXWebViewBarDelegate<NSObject>

- (void)backBtnClick:(UIButton *)sender;
- (void)forwardBtnClick:(UIButton *)sender;
- (void)saveBtnClick:(UIButton *)sender;
- (void)saveListBtnClick:(UIButton *)sender ;
- (void)newBtnClick:(UIButton *)sender;
- (void)refreshBtnClick:(UIButton *)sender;

@end

@interface YGXWebViewBar : UIView
@property (weak, nonatomic) IBOutlet UIButton *gobackBtn;
@property (weak, nonatomic) IBOutlet UIButton *goForwardBtn;

+ (instancetype)webViewBar;

@property (nonatomic, weak) id <YGXWebViewBarDelegate> delegate;

@end
