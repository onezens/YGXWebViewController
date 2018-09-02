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
#import "YGXSettingCenter.h"
#import "YGXUtils.h"


static NSUInteger const kWKWebView_TimeOut = 60;
static NSUInteger const WebViewBarHeight = 44;

@interface YGXWebViewController()<WKUIDelegate, WKNavigationDelegate, YGXWebViewBarDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, weak) YGXWebViewBar *webBar;
@property (nonatomic, copy) NSString *domain;

@end

@implementation YGXWebViewController

#pragma mark - init

+ (instancetype)webViewVc {
    static YGXWebViewController *webVc;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        webVc = [YGXWebViewController new];
    });
    return webVc;
}

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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
}


- (void)goBack {
    [self.webView stopLoading];
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - webView event
- (void)backBtnClick:(UIButton *)sender {
    [self.webView goBack];
}
- (void)forwardBtnClick:(UIButton *)sender {
    [self.webView goForward];
}
- (void)saveBtnClick:(UIButton *)sender {
    [YGXUtils cancel];
    [self.webView stopLoading];
}
- (void)saveListBtnClick:(UIButton *)sender {
    NSLog(@"%s",__func__);
}
- (void)newBtnClick:(UIButton *)sender{
    [self loadRequestWithUrl:self.url];
}

- (void)refreshBtnClick:(UIButton *)sender {
    [self.webView stopLoading];
    [self.webView reload];
}


#pragma mark - network


#pragma mark - event

- (void)loadRequestWithUrl:(NSString *)url {
    NSURL *uri =[NSURL URLWithString:url];
    NSURLRequest *req = [NSURLRequest requestWithURL:uri cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kWKWebView_TimeOut];
    [self.webView loadRequest:req];
    self.domain = [self getDomainWithUrl:uri.host];
}

- (void)setUrl:(NSString *)url {
    _url = url;
    NSString *cacheUrl = [[NSUserDefaults standardUserDefaults] valueForKey:url];
    [self loadRequestWithUrl:cacheUrl.length>0 ? cacheUrl : url];
}

- (NSString *)getDomainWithUrl:(NSString *)urlStr {
    NSArray *hostArr = [urlStr componentsSeparatedByString:@"."];
    hostArr = [hostArr subarrayWithRange:NSMakeRange(hostArr.count-2, 2)];
    return [hostArr componentsJoinedByString:@"."];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSURLRequest *request = navigationAction.request;
    [[NSUserDefaults standardUserDefaults] setValue:request.URL.absoluteString forKey:self.url];
    NSString *domain = [self getDomainWithUrl:request.URL.host];
    if ([YGXSettingCenter sharedCenter].enableExternalJump && ![domain isEqualToString:self.domain]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
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
    [UIApplication sharedApplication].networkActivityIndicatorVisible = false;
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
        _webView.backgroundColor = [UIColor cyanColor];
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



