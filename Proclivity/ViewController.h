//
//  ViewController.h
//  BetterRIP
//
//  Created by David Yu on 19/12/2014.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,UIViewControllerTransitioningDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@end


