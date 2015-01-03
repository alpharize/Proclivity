//
//  ZoomAnimationController.m
//  Notes
//
//  Created by Tope Abayomi on 26/07/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import "ZoomAnimationController.h"

@interface ZoomAnimationController ()

@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;

@end

@implementation ZoomAnimationController

-(id)init{
    self = [super init];
    
    if(self){
        
        self.presentationDuration = 0.65;
        self.dismissalDuration = 0.45;
    }
    
    return self;
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    return self.isPresenting ? self.presentationDuration : self.dismissalDuration;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    
    self.transitionContext = transitionContext;
    if(self.isPresenting){
        [self executePresentationAnimation:transitionContext];
    }
    else{
        
        [self executeDismissalAnimation:transitionContext];
    }
    
}

-(void)executePresentationAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIView* inView = [transitionContext containerView];
    
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIImageView *containerBackgroundIV;
    for (UIView *i in fromViewController.view.subviews){
        if(i.tag==7){
            NSLog(@"Found view with tag 7");
            containerBackgroundIV=(UIImageView *)i;
            [i removeFromSuperview];
        }
    }
    [inView addSubview:containerBackgroundIV];
    [inView sendSubviewToBack:containerBackgroundIV];
    
    CGRect offScreenFrame = inView.frame;
    offScreenFrame.origin.x = inView.frame.size.width+80;
    //toViewController.view.frame = offScreenFrame;
    toViewController.view.layer.transform = [self yetAnotherMethod:toViewController.view];
    toViewController.view.backgroundColor = [UIColor clearColor];
    
    [inView insertSubview:toViewController.view aboveSubview:fromViewController.view];
    
    CFTimeInterval duration = self.presentationDuration;
    
    CATransform3D t2 = [self secondTransformWithView:fromViewController.view];
    
    
    [UIView animateKeyframesWithDuration:duration delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        
        /*[UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:0.05f animations:^{
         fromViewController.view.layer.transform = t1;
         fromViewController.view.alpha = 0.6;
         }];*/
        
        [UIView addKeyframeWithRelativeStartTime:0.00f relativeDuration:1.0f animations:^{
            
            fromViewController.view.layer.transform = t2;
        }];
        
    } completion:^(BOOL finished) {
        
    }];
    [UIView animateWithDuration:duration delay:duration*.5 usingSpringWithDamping:1.0f initialSpringVelocity:6.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        

        //toViewController.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        CATransform3D t = CATransform3DIdentity;
        t.m34 = 1.0/-900;
        t = CATransform3DTranslate(t, 0, 0, 0);
        t = CATransform3DScale(t, 1., 1., 1);
        toViewController.view.layer.transform=t;
        toViewController.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        

    } completion:^(BOOL finished) {
        [self.transitionContext completeTransition:YES];
    }];
    
    
    
}

-(void)executeDismissalAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    /*UIView* inView = [transitionContext containerView];
    
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    toViewController.view.frame = inView.frame;
    CATransform3D scale = CATransform3DIdentity;
    toViewController.view.layer.transform = CATransform3DScale(scale, 0.6, 0.6, 1);
    toViewController.view.alpha = 0.6;
    
    [inView insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    CGRect frameOffScreen = inView.frame;
    frameOffScreen.origin.y = inView.frame.size.height;
    
    NSTimeInterval duration = self.dismissalDuration;
    NSTimeInterval halfDuration = duration/2;
    
    
    [UIView animateKeyframesWithDuration:halfDuration delay:halfDuration - (0.3*halfDuration) options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        
        [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:0.5f animations:^{
            toViewController.view.layer.transform = t1;
            toViewController.view.alpha = 1.0;
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.5f relativeDuration:0.5f animations:^{
            
            toViewController.view.layer.transform = CATransform3DIdentity;
        }];
        
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
    
    
    [UIView animateWithDuration:halfDuration animations:^{
        fromViewController.view.frame = frameOffScreen;
    } completion:^(BOOL finished) {
        
    }];*/
    
    UIView* inView = [transitionContext containerView];
    
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIImageView *containerBackgroundIV;
    for (UIView *i in fromViewController.view.subviews){
        if(i.tag==7){
            NSLog(@"Found view with tag 7");
            containerBackgroundIV=(UIImageView *)i;
            [i removeFromSuperview];
        }
    }
    [inView addSubview:containerBackgroundIV];
    [inView sendSubviewToBack:containerBackgroundIV];
    
    
    toViewController.view.backgroundColor = [UIColor clearColor];
    toViewController.view.layer.transform=[self transformTargetView:toViewController.view];
    
    [inView insertSubview:toViewController.view aboveSubview:fromViewController.view];
    
    CFTimeInterval duration = self.presentationDuration;
    
    [UIView animateKeyframesWithDuration:duration/2 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        
        /*[UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:0.05f animations:^{
         fromViewController.view.layer.transform = t1;
         fromViewController.view.alpha = 0.6;
         }];*/
        
        [UIView addKeyframeWithRelativeStartTime:0.00f relativeDuration:1.0f animations:^{
            
            fromViewController.view.layer.transform = [self yetAnotherMethod:fromViewController.view];
        }];
        
    } completion:^(BOOL finished) {
        
    }];
    [UIView animateWithDuration:duration delay:duration*.5 usingSpringWithDamping:1.0f initialSpringVelocity:6.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        
        CATransform3D t = CATransform3DIdentity;
        t.m34 = 1.0/-900;
        t = CATransform3DTranslate(t, 0, 0, 0);
        t = CATransform3DScale(t, 1., 1., 1);
        toViewController.view.layer.transform=t;
        toViewController.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
    } completion:^(BOOL finished) {
        [self.transitionContext completeTransition:YES];
    }];
    
    

}

-(CATransform3D)transformTargetView:(UIView *)view{
    CATransform3D t2 = CATransform3DIdentity;
    t2.m34 = 1.0/-900;
    t2 = CATransform3DTranslate(t2, 0-view.frame.size.width-100, 0, 0);
    t2 = CATransform3DScale(t2, 0.7, 0.7, 1);
    
    return t2;

    
}

-(CATransform3D)secondTransformWithView:(UIView*)view{
    
    CATransform3D t2 = CATransform3DIdentity;
    t2.m34 = 1.0/-900;
    t2 = CATransform3DTranslate(t2, 0-view.frame.size.width, 0, 0);
    t2 = CATransform3DScale(t2, 0.7, 0.7, 1);
    
    return t2;
}

-(CATransform3D)yetAnotherMethod:(UIView*)view{
    
    CATransform3D t2 = CATransform3DIdentity;
    t2.m34 = 1.0/-900;
    t2 = CATransform3DTranslate(t2, view.frame.size.width+view.frame.size.width, 0, 0);
    t2 = CATransform3DScale(t2, 1.2, 1.2, 1);
    
    return t2;
}

@end
