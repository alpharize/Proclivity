//
//  CSSInjector.h
//  Proclivity
//
//  Created by Terence Tan on 1/1/15.
//  Copyright (c) 2015 Kim Jong-Cracks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CSSInjector : NSObject

-(void)injectToWebview:(UIWebView*)view withURL:(NSString*) url lightStyle:(BOOL)lightStyle;
+ (CSSInjector*) sharedInstance;
@end
