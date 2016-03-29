//
//  PandPViewController.m
//  SnapShotSale
//
//  Created by Manish on 09/12/15.
//  Copyright © 2015 E2M. All rights reserved.
//

#import "PandPViewController.h"
#import "MBProgressHUD.h"
#import "TKAlertCenter.h"
#import "Common.h"

@interface PandPViewController ()<UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *myWebView;

@end

@implementation PandPViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *websiteUrl = [NSURL URLWithString:@"http://software.snapshotsale.com/webservices/legal/privacy.html"];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
    _myWebView.delegate = self;
    [_myWebView loadRequest:urlRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Button Click Event

- (IBAction)btnBackTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - WebView Delegate Method

-(void)webViewDidStartLoad:(UIWebView *)webView{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[TKAlertCenter defaultCenter] postAlertWithMessage:error.description image:kErrorImage];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

@end
