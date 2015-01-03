//
//  PackageDetailsViewController.h
//  BetterRIP
//
//  Created by David Yu on 20/12/2014.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import <MessageUI/MessageUI.h>

@interface PackageDetailsViewController : UIViewController <NSURLConnectionDelegate,UIViewControllerTransitioningDelegate, UIWebViewDelegate, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>

@property BOOL backgroundIsLightStyle;
@property NSString *packageName;

@end
