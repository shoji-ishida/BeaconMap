//
//  ViewController.m
//  BeaconMap
//
//  Created by Pablo Bartolome on 10/10/13.
//  Copyright (c) 2013 Solstice Mobile. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@property (weak, nonatomic) UIWebView* webView;
@end

@implementation ViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // UIWebViewのインスタンス化
    CGRect rect = self.view.frame;
    UIWebView *webView = [[UIWebView alloc]initWithFrame:rect];
    
    // Webページの大きさを自動的に画面にフィットさせる
    webView.scalesPageToFit = YES;
    
    // デリゲートを指定
    webView.delegate = self;
    // URLを指定
    NSURL *url;
    if (!self.url) {
        url = [NSURL URLWithString:@"http://sp.ekitan.com"];
    } else {
        url = self.url;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // リクエストを投げる
    [webView loadRequest:request];
    
    // UIWebViewのインスタンスをビューに追加
    [self.view addSubview:webView];
    self.webView = webView;
}

/**
 * Webページのロード時にインジケータを動かす
 */
- (void)webViewDidStartLoad:(UIWebView*)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


/**
 * Webページのロード完了時にインジケータを非表示にする
 */
- (void)webViewDidFinishLoad:(UIWebView*)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)reload {
    // URLを指定
    NSURL *url;
    if (!self.url) {
        url = [NSURL URLWithString:@"http://sp.ekitan.com"];
    } else {
        url = self.url;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSLog(@"Reload %@", url.absoluteString);
    // リクエストを投げる
    [_webView loadRequest:request];
}
@end
