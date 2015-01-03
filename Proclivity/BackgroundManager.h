//
//  NavigationViewController.h
//  BetterRIP
//
//  Created by Terence Tan on 21/12/14.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BackgroundManager : UIViewController

@property (nonatomic) BOOL backgroundIsLightStyle;

-(UIView *)getBackgroundView;

@end
