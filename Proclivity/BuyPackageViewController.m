//
//  BuyPackageViewController.m
//  Proclivity
//
//  Created by David Yu on 30/12/2014.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import "BuyPackageViewController.h"

@interface BuyPackageViewController ()

@end

@implementation BuyPackageViewController {
    NSMutableData *webdata;
    UIWebView *depictionWebView;
}

@synthesize backgroundIsLightStyle;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Fake NavBar (Better Navbar anyone?!)
    //5px padding
    UIView *navBox  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 65)];
    navBox.backgroundColor = backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.08] : [UIColor colorWithWhite:0.20 alpha:0.4];
    navBox.tag=9;
    
    navBox.layer.masksToBounds = NO;
    navBox.layer.shadowOffset = CGSizeMake(-3, -3);
    navBox.layer.shadowRadius = 3;
    navBox.layer.shadowOpacity = 0.35;
    CGRect shadowBounds = navBox.layer.bounds;
    shadowBounds.size.height += 6;
    shadowBounds.size.width += 6;
    navBox.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowBounds].CGPath;
    [self.view addSubview:navBox];
    
    // Buttons
    // Back Button
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame=CGRectMake(20, 22,120, 40);
    
    [cancelButton setTitle:@"« Back" forState:UIControlStateNormal];
    cancelButton.titleLabel.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-MediumP4" size:21];
    [cancelButton addTarget:self action:@selector(userWantsToGoBack) forControlEvents:UIControlEventTouchUpInside];
    //cancelButton.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.08] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
    [cancelButton setTitleColor:backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.15 alpha:0.9] : [UIColor colorWithHue:0 saturation:0 brightness:.88 alpha:0.95] forState:UIControlStateNormal];
    cancelButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    UISwipeGestureRecognizer *mSwipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userWantsToGoBack)];
    
    [mSwipeUpRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    
    [[self view] addGestureRecognizer:mSwipeUpRecognizer];
    
    [self.view addSubview:cancelButton];
    [self.view bringSubviewToFront:cancelButton];
    
    // Install button
    UIButton *installButton=[UIButton buttonWithType:UIButtonTypeCustom];
    installButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-140, 22,120, 40);
    [installButton setTitle:@"Open in Safari" forState:UIControlStateNormal];
    installButton.titleLabel.font = cancelButton.titleLabel.font;
    //installButton.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.08] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
    installButton.backgroundColor=[UIColor clearColor];
    [installButton setTitleColor:backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.15 alpha:0.9] : [UIColor colorWithHue:0 saturation:0 brightness:.88 alpha:0.95] forState:UIControlStateNormal];
    [installButton addTarget:self action:@selector(didClickInstall) forControlEvents:UIControlEventTouchUpInside];
    
    installButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
    [self.view addSubview:installButton];
    [self.view bringSubviewToFront:installButton];
    
    
    //Depiction
    
    depictionWebView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 65, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-65)];
    depictionWebView.alpha=1.0;
    NSMutableURLRequest *purchaseRequest=[[NSMutableURLRequest alloc]initWithURL:_purchasePackageURL];
    [purchaseRequest setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    
    [depictionWebView loadRequest:purchaseRequest];

    
    [self.view addSubview:depictionWebView];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    /*if (webdata == nil) {
        webdata = [[NSMutableData alloc] init];
    }
    [webdata appendData:data];
    [depictionWebView loadData:webdata MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:nil];
    NSLog(@"Web data: %@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"Request: %@",request);
    
    NSDictionary *allHeaders=[request allHTTPHeaderFields];
    NSLog(@"All headers: %@",allHeaders);

    return YES;
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    NSMutableDictionary *mutableUserInfo = [[cachedResponse userInfo] mutableCopy];
    NSMutableData *mutableData = [[cachedResponse data] mutableCopy];
    NSURLCacheStoragePolicy storagePolicy = NSURLCacheStorageAllowed;
    NSLog(@"user info:: %@",mutableUserInfo);
    // ...
    
    return [[NSCachedURLResponse alloc] initWithResponse:[cachedResponse response]
                                                    data:mutableData
                                                userInfo:mutableUserInfo
                                           storagePolicy:storagePolicy];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"Did finish: %@",webView.request);
    NSDictionary *allHeaders=[webView.request allHTTPHeaderFields];
    NSLog(@"All headers: %@",allHeaders);

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
