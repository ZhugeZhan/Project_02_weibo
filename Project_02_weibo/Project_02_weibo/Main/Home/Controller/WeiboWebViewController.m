//
//  WeiboWebViewController.m
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/7/5.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import "WeiboWebViewController.h"

@interface WeiboWebViewController()
{
    UIWebView *_webView;
    NSURL *_url;
}
@end



@implementation WeiboWebViewController

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    
    if (self) {
        
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64)];
        _url = url;
        
        self.hidesBottomBarWhenPushed = YES;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //添加WebView
    [self.view addSubview:_webView];
    //设置网络请求
    NSURLRequest *request = [NSURLRequest requestWithURL:_url];
    //使用网络请求对象，加载网页
    [_webView loadRequest:request];
}

@end
