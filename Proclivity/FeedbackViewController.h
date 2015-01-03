//
//  FeedbackViewController.h
//  Proclivity
//
//  Created by David Yu on 2/01/2015.
//  Copyright (c) 2015 Kim Jong-Cracks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface FeedbackViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>

@property BOOL backgroundIsLightStyle;

@end
