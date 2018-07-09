//
//  YGXWebViewController.m
//  YGXWebViewController
//
//  Created by wz on 2017/11/18.
//  Copyright © 2017年 wz. All rights reserved.
//

#import "YGXWebViewController.h"
#import <WebKit/WebKit.h>
#import "YGXURLProtocol.h"
#import "YGXWebViewBar.h"

static NSUInteger const kWKWebView_TimeOut = 60;
static NSUInteger const WebViewBarHeight = 44;

@interface YGXWebViewController()<WKUIDelegate, WKNavigationDelegate, YGXWebViewBarDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, weak) YGXWebViewBar *webBar;

@end

@implementation YGXWebViewController

#pragma mark - init

#pragma mark - ui

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI {
    self.title = @"YGXWebVC";
    self.view.backgroundColor = [UIColor whiteColor];
    YGXWebViewBar *bar = [YGXWebViewBar webViewBar];
    bar.frame = CGRectMake(0, self.view.bounds.size.height - WebViewBarHeight, self.view.bounds.size.width, WebViewBarHeight);
    bar.delegate = self;
    _webBar = bar;
    [self.view addSubview:bar];
}

#pragma mark - webView event
- (void)backBtnClick:(UIButton *)sender {
    [self.webView goBack];
}
- (void)forwardBtnClick:(UIButton *)sender {
    [self.webView goForward];
}
- (void)saveBtnClick:(UIButton *)sender {
    
}
- (void)saveListBtnClick:(UIButton *)sender {
    
}
- (void)newBtnClick:(UIButton *)sender{
    
}


#pragma mark - network


#pragma mark - event

- (void)setUrl:(NSString *)url {
    _url = url;
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kWKWebView_TimeOut];
    [self.webView loadRequest:req];
}


#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
//    NSURLRequest *request = navigationAction.request;
    if(decisionHandler){
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSURLResponse *response = navigationResponse.response;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
//        NSHTTPURLResponse *httpRes = (NSHTTPURLResponse *)response;
    }else{
        NSLog(@"response: %@", [response class]);
    }
    
    if (decisionHandler) {
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = true;
}


- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s", __FUNCTION__);
    self.webBar.gobackBtn.enabled = webView.canGoBack;
    self.webBar.goForwardBtn.enabled = webView.canGoForward;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = false;
    [webView evaluateJavaScript:@"document.title" completionHandler:^(NSString * result, NSError * _Nullable error) {
        if (result.length>15) {
            result = [result substringWithRange:NSMakeRange(0, 15)];
        }
        self.title = result;
    }];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = false;
}

#pragma mark - WKUIDelegate

- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    
    NSLog(@"%s", __FUNCTION__);
    return [[WKWebView alloc] initWithFrame:self.webView.bounds];
}

- (void)webViewDidClose:(WKWebView *)webView {
    
    NSLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    NSLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    NSLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler{
    
    NSLog(@"%s", __FUNCTION__);
}


- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo API_AVAILABLE(ios(10.0)){
    NSLog(@"%s", __FUNCTION__);
    return true;
}

- (nullable UIViewController *)webView:(WKWebView *)webView previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo defaultActions:(NSArray<id <WKPreviewActionItem>> *)previewActions  API_AVAILABLE(ios(10.0)){
    
    NSLog(@"%s", __FUNCTION__);
    
    UIViewController *vc = [[UIViewController alloc] init];
    vc.title = @"test";
    
    return vc;
}

- (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController {
    NSLog(@"%s", __FUNCTION__);
}


- (void)webView:(WKWebView *)webView runOpenPanelWithParameters:(WKOpenPanelParameters *)parameters initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSArray<NSURL *> * _Nullable URLs))completionHandler{
    NSLog(@"%s", __FUNCTION__);
}


#pragma mark - lazy loading

- (WKWebView *)webView {
    
    if (!_webView) {
        _webView = [[WKWebView alloc] init];
        _webView.backgroundColor = [UIColor orangeColor];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        _webView.frame = CGRectMake(0, 64.0f, self.view.bounds.size.width, self.view.bounds.size.height - 64.0f - WebViewBarHeight);
        [self.view addSubview:_webView];
    }
    return _webView;
}

#pragma mark - others

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end



