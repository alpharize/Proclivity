//
//  InstallViewController.h
//  BetterRIP
//
//  Created by David Yu on 22/12/2014.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Package.h"
#import "InstallSession.h"

@interface InstallViewController : UIViewController <UIAlertViewDelegate>

@property BOOL backgroundIsLightStyle;
@property NSInteger installationType;
@property Package* package;
@property (nonatomic, strong) InstallSession* session;

@end
