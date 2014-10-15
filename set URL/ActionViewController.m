//
//  ActionViewController.m
//  set URL
//
//  Created by 石田 勝嗣 on 2014/08/18.
//  Copyright (c) 2014年 Solstice Mobile. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ActionViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textView;
@property (nonatomic) NSURL *url;
@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 共有するコンテンツを取り出す
    NSExtensionItem *inputItem = self.extensionContext.inputItems.firstObject;
    NSItemProvider *urlItemProvider = inputItem.attachments.firstObject;
    
    // URLを取り出す
    if ([urlItemProvider hasItemConformingToTypeIdentifier:(__bridge NSString *)kUTTypeURL]) {
        [urlItemProvider loadItemForTypeIdentifier:(__bridge NSString *)kUTTypeURL
                                           options:nil
                                 completionHandler:^(NSURL *url, NSError *error) {
                                     // kUTTypeURLの場合itemはNSURLクラスで渡される
                                     if (!error) {
                                         
                                         // ここでなんらかのサービスに投稿する処理をする
                                         self.url = url;
                                         [self.textView setText:([url absoluteString])];
                                         NSLog(@"url retrived: %@", url);
                                    }
                                 }
         ];}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done {
    NSLog(@"set: %@", self.url);
    // Save to sharedDefaults
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.jp.neoscorp.rand.beacongroup"];
    [sharedDefaults setObject:[self.url absoluteString] forKey:@"MyURL"];
    [sharedDefaults synchronize];
    
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

@end
