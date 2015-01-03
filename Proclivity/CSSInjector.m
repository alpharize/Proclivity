//
//  CSSInjector.m
//  Proclivity
//
//  Created by Terence Tan on 1/1/15.
//  Copyright (c) 2015 Kim Jong-Cracks. All rights reserved.
//

#import "CSSInjector.h"
#import <UIKit/UIKit.h>

@implementation CSSInjector {
    NSDictionary* dict;
}


static dispatch_once_t cssinjector_dispatch = 0;


+ (CSSInjector*) sharedInstance
{
    static CSSInjector *shared = nil;
    dispatch_once(&cssinjector_dispatch, ^{
        shared = [[CSSInjector alloc] init];
    });
    
    return shared;
}

-(id)init {
    self = [super init];
    
    if (self)
    {
        NSLog(@"Initialising CSS injectors");
        dict = [[NSDictionary alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"css" ofType:@"plist"]];
    }
    
    return self;
        
}

-(NSString*)rootDomain:(NSString*)_url {
    // Convert the string to an NSURL to take advantage of NSURL's parsing abilities.
    NSURL * url = [NSURL URLWithString:_url];
    
    // Get the host, e.g. "secure.twitter.com"
    NSString * host = [url host];
    NSString* _rootDomain;
    // Separate the host into its constituent components, e.g. [@"secure", @"twitter", @"com"]
    NSArray * hostComponents = [host componentsSeparatedByString:@"."];
    if ([hostComponents count] >=2) {
        // Create a string out of the last two components in the host name, e.g. @"twitter" and @"com"
        _rootDomain = [NSString stringWithFormat:@"%@.%@", [hostComponents objectAtIndex:([hostComponents count] - 2)], [hostComponents objectAtIndex:([hostComponents count] - 1)]];
    }
    return _rootDomain;
}


-(void)injectToWebview:(UIWebView*)view withURL:(NSString*) url lightStyle:(BOOL)lightStyle {
    NSLog(@"root domain %@", [self rootDomain:url]);
    for (NSString* domain in dict) {
        if ([url rangeOfString:domain].location!=NSNotFound) {
            NSLog(@"found suitable css");
            NSString* css;
            if (lightStyle) {
                css = [dict objectForKey:domain][0];
            }
            else {
                css = [dict objectForKey:domain][1];
            }
            NSString *js = [NSString stringWithFormat:@"var styleNode = document.createElement('style');"
                            "styleNode.type = 'text/css';"
                            "styleNode.innerHTML = ' %@ ';", css];
            js = [NSString stringWithFormat:@"%@document.getElementsByTagName('head')[0].appendChild(styleNode);", js];
            [view stringByEvaluatingJavaScriptFromString:js];
            NSLog(@"cool js");
            return;
            break;
        }
    }
    NSLog(@"could not find suitable css uh oh");
}


@end
