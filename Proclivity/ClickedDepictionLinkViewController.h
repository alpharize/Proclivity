//
//  ClickedDepictionLinkViewController.h
//  BetterRIP
//
//  Created by David Yu on 28/12/2014.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClickedDepictionLinkViewController : UIViewController <UIWebViewDelegate>

@property NSURLRequest *urlRequest;
@property BOOL backgroundIsLightStyle;

@end
