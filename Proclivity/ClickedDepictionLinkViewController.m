//
//  ClickedDepictionLinkViewController.m
//  BetterRIP
//
//  Created by David Yu on 28/12/2014.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import "ClickedDepictionLinkViewController.h"
#import "TUSafariActivity.h"

@interface ClickedDepictionLinkViewController ()

@end

@implementation ClickedDepictionLinkViewController

@synthesize backgroundIsLightStyle;
@synthesize urlRequest;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Fake NavBar (Better Navbar anyone?!)
    //5px padding
    UIView *navBox  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 65)];
    navBox.backgroundColor = backgroundIsLightStyle ? [UIColor colorWithWhite:1.0 alpha:0.5] : [UIColor colorWithWhite:0.20 alpha:0.4];
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
    [installButton setTitle:@"Share" forState:UIControlStateNormal];
    installButton.titleLabel.font = cancelButton.titleLabel.font;
    //installButton.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.08] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
    installButton.backgroundColor=[UIColor clearColor];
    [installButton setTitleColor:backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.15 alpha:0.9] : [UIColor colorWithHue:0 saturation:0 brightness:.88 alpha:0.95] forState:UIControlStateNormal];
    [installButton addTarget:self action:@selector(showShareSheet) forControlEvents:UIControlEventTouchUpInside];
    
    installButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
    [self.view addSubview:installButton];
    [self.view bringSubviewToFront:installButton];

    
    //Depiction
    
    UIWebView *depictionWebView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 65, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-65)];
    depictionWebView.alpha=0.9;
    NSLog(@"Request: %@",urlRequest);
    [depictionWebView loadRequest:urlRequest];
    depictionWebView.delegate = self;
    //depictionWebView.scalesPageToFit = YES;
    [self.view addSubview:depictionWebView];

    
}

-(void)userWantsToGoBack {
    
    for (UIView *i in self.view.subviews){
        if(i.tag==9){
            UIView *newLbl = (UIView *)i;
            [newLbl removeFromSuperview];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showShareSheet {
    NSLog(@"Trying to show share sheet. URL: %@",urlRequest.URL);
    TUSafariActivity *activity = [[TUSafariActivity alloc] init];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[urlRequest.URL] applicationActivities:@[activity]];
    [self presentViewController:activityViewController
                                       animated:YES
                                     completion:^{
                                         // ...
                                     }];
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
