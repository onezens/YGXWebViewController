//
//  YGXWebViewController.m
//  YGXWebViewController
//
//  Created by wz on 2017/11/18.
//  Copyright © 2017年 wz. All rights reserved.
//

#import "YGXWebViewController.h"
#import <WebKit/WebKit.h>

#define WKWebView_TimeOut 60

@interface YGXWebViewController()<WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation YGXWebViewController

#pragma mark - init


#pragma mark - ui

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI {
    self.title = @"YGXWebViewController";
}


#pragma mark - network



#pragma mark - event

- (void)setUrl:(NSString *)url {
    _url = url;
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:WKWebView_TimeOut];
    [self.webView loadRequest:req];
}

#pragma mark - WKUIDelegate

/*! @abstract Creates a new web view.
 @param webView The web view invoking the delegate method.
 @param configuration The configuration to use when creating the new web
 view.
 @param navigationAction The navigation action causing the new web view to
 be created.
 @param windowFeatures Window features requested by the webpage.
 @result A new web view or nil.
 @discussion The web view returned must be created with the specified configuration. WebKit will load the request in the returned web view.
 
 If you do not implement this method, the web view will cancel the navigation.
 */
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    
    NSLog(@"%s", __FUNCTION__);
    return [[WKWebView alloc] initWithFrame:self.view.bounds];
}

/*! @abstract Notifies your app that the DOM window object's close() method completed successfully.
 @param webView The web view invoking the delegate method.
 @discussion Your app should remove the web view from the view hierarchy and update
 the UI as needed, such as by closing the containing browser tab or window.
 */
- (void)webViewDidClose:(WKWebView *)webView {
    
    NSLog(@"%s", __FUNCTION__);
}

/*! @abstract Displays a JavaScript alert panel.
 @param webView The web view invoking the delegate method.
 @param message The message to display.
 @param frame Information about the frame whose JavaScript initiated this
 call.
 @param completionHandler The completion handler to call after the alert
 panel has been dismissed.
 @discussion For user security, your app should call attention to the fact
 that a specific website controls the content in this panel. A simple forumla
 for identifying the controlling website is frame.request.URL.host.
 The panel should have a single OK button.
 
 If you do not implement this method, the web view will behave as if the user selected the OK button.
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    NSLog(@"%s", __FUNCTION__);
}

/*! @abstract Displays a JavaScript confirm panel.
 @param webView The web view invoking the delegate method.
 @param message The message to display.
 @param frame Information about the frame whose JavaScript initiated this call.
 @param completionHandler The completion handler to call after the confirm
 panel has been dismissed. Pass YES if the user chose OK, NO if the user
 chose Cancel.
 @discussion For user security, your app should call attention to the fact
 that a specific website controls the content in this panel. A simple forumla
 for identifying the controlling website is frame.request.URL.host.
 The panel should have two buttons, such as OK and Cancel.
 
 If you do not implement this method, the web view will behave as if the user selected the Cancel button.
 */
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    NSLog(@"%s", __FUNCTION__);
}

/*! @abstract Displays a JavaScript text input panel.
 @param webView The web view invoking the delegate method.
 @param prompt The message to display.
 @param defaultText The initial text to display in the text entry field.
 @param frame Information about the frame whose JavaScript initiated this call.
 @param completionHandler The completion handler to call after the text
 input panel has been dismissed. Pass the entered text if the user chose
 OK, otherwise nil.
 @discussion For user security, your app should call attention to the fact
 that a specific website controls the content in this panel. A simple forumla
 for identifying the controlling website is frame.request.URL.host.
 The panel should have two buttons, such as OK and Cancel, and a field in
 which to enter text.
 
 If you do not implement this method, the web view will behave as if the user selected the Cancel button.
 */
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler{
    
    NSLog(@"%s", __FUNCTION__);
}

/*! @abstract Allows your app to determine whether or not the given element should show a preview.
 @param webView The web view invoking the delegate method.
 @param elementInfo The elementInfo for the element the user has started touching.
 @discussion To disable previews entirely for the given element, return NO. Returning NO will prevent
 webView:previewingViewControllerForElement:defaultActions: and webView:commitPreviewingViewController:
 from being invoked.
 
 This method will only be invoked for elements that have default preview in WebKit, which is
 limited to links. In the future, it could be invoked for additional elements.
 */
- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo{
    NSLog(@"%s", __FUNCTION__);
    return true;
}

/*! @abstract Allows your app to provide a custom view controller to show when the given element is peeked.
 @param webView The web view invoking the delegate method.
 @param elementInfo The elementInfo for the element the user is peeking.
 @param defaultActions An array of the actions that WebKit would use as previewActionItems for this element by
 default. These actions would be used if allowsLinkPreview is YES but these delegate methods have not been
 implemented, or if this delegate method returns nil.
 @discussion Returning a view controller will result in that view controller being displayed as a peek preview.
 To use the defaultActions, your app is responsible for returning whichever of those actions it wants in your
 view controller's implementation of -previewActionItems.
 
 Returning nil will result in WebKit's default preview behavior. webView:commitPreviewingViewController: will only be invoked
 if a non-nil view controller was returned.
 */
- (nullable UIViewController *)webView:(WKWebView *)webView previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo defaultActions:(NSArray<id <WKPreviewActionItem>> *)previewActions {
    
    NSLog(@"%s", __FUNCTION__);
    
    UIViewController *vc = [[UIViewController alloc] init];
    vc.title = @"test";
    
    return vc;
}

/*! @abstract Allows your app to pop to the view controller it created.
 @param webView The web view invoking the delegate method.
 @param previewingViewController The view controller that is being popped.
 */
- (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController {
    NSLog(@"%s", __FUNCTION__);
}



/*! @abstract Displays a file upload panel.
 @param webView The web view invoking the delegate method.
 @param parameters Parameters describing the file upload control.
 @param frame Information about the frame whose file upload control initiated this call.
 @param completionHandler The completion handler to call after open panel has been dismissed. Pass the selected URLs if the user chose OK, otherwise nil.
 
 If you do not implement this method, the web view will behave as if the user selected the Cancel button.
 */
- (void)webView:(WKWebView *)webView runOpenPanelWithParameters:(WKOpenPanelParameters *)parameters initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSArray<NSURL *> * _Nullable URLs))completionHandler{
    NSLog(@"%s", __FUNCTION__);
}


#pragma mark - lazy loading

- (WKWebView *)webView {
    
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        _webView.backgroundColor = [UIColor orangeColor];
        _webView.UIDelegate = self;
        [self.view addSubview:_webView];
    }
    return _webView;
}

@end



