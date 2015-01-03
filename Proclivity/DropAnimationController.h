//
//  DropAnimationController.h
//  Notes
//
//  Created by Tope Abayomi on 25/07/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADVAnimationController.h"
#import <UIKit/UIKit.h>

@interface DropAnimationController : NSObject <ADVAnimationController>

@property (nonatomic, assign) NSTimeInterval presentationDuration;

@property (nonatomic, assign) NSTimeInterval dismissalDuration;

@property (nonatomic, assign) BOOL isPresenting;

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext;

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext;

@end
