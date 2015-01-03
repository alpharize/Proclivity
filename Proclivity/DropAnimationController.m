//
//  DropAnimationController.m
//  Notes
//
//  Created by Tope Abayomi on 25/07/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import "DropAnimationController.h"

@implementation DropAnimationController

-(id)init{
    self = [super init];
    
    if(self){
        
        self.presentationDuration = 0.85;
        self.dismissalDuration = 0.65;
    }
    
    return self;
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    return self.isPresenting ? self.presentationDuration : self.dismissalDuration;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
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
    toViewController.view.backgroundColor=[UIColor clearColor];
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
    //toViewController.view.backgroundColor=[UIColor greenColor];
    
    //[inView addSubview:toViewController.view];
    [inView insertSubview:toViewController.view aboveSubview:fromViewController.view];
    
    //centerOffScreen.y = (-1)*inView.frame.size.height;
    //toViewController.view.center = centerOffScreen;

    CATransform3D t = CATransform3DIdentity;
    t.m34 = 1.0/-900;
    //t = CATransform3DTranslate(t, 0-toViewController.view.frame.size.width, 0, 0);
    t = CATransform3DScale(t, 0.7, 0.7, 1);
    t=CATransform3DRotate(t,-12.0f*M_PI/180.0f, 1, 0, 0);
    t=CATransform3DTranslate(t,0, 0-[UIScreen mainScreen].bounds.size.height-200, 0);
    toViewController.view.layer.transform=t;

    
    [UIView animateKeyframesWithDuration:self.presentationDuration delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        
        [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:0.25f animations:^{
            CATransform3D t = CATransform3DIdentity;
            t.m34 = 1.0/-900;
            //t = CATransform3DTranslate(t, 0-toViewController.view.frame.size.width, 0, 0);
            t = CATransform3DScale(t, 0.7, 0.7, 1);
            //t=CATransform3DRotate(t, 15.0f*M_PI/180.0f, 1, 0,0);
            
            t = CATransform3DTranslate(t, 0, 0-fromViewController.view.frame.size.height-550, 0);
            //t=CATransform3DTranslate(t, 0, 0, 0);
            fromViewController.view.layer.transform=t;
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.1f relativeDuration:0.9f animations:^{
            CATransform3D t = CATransform3DIdentity;
            t.m34 = 1.0/-900;
            //t = CATransform3DTranslate(t, 0-toViewController.view.frame.size.width, 0, 0);
            t = CATransform3DScale(t, 1.0, 1, 1/1);
            t=CATransform3DRotate(t,0.0, 0, 0.0f, .0);
            t=CATransform3DTranslate(t, 0, 0, 0);
            toViewController.view.layer.transform=t;
            toViewController.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);

        }];
        
        
    }completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
    
    //
    /*[UIView animateWithDuration:self.presentationDuration delay:0.0f usingSpringWithDamping:0.4f initialSpringVelocity:6.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        toViewController.view.center = inView.center;
        fromViewController.view.alpha = 0.6;
        
    } completion:^(BOOL finished) {
        
        [transitionContext completeTransition:YES];
    }];*/
}

-(void)executeDismissalAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    /*UIView* inView = [transitionContext containerView];
    
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
    
    [inView insertSubview:toViewController.view aboveSubview:fromViewController.view];
    
    CGPoint centerOffScreen = fromViewController.view.center;
    centerOffScreen.y = (-1)*fromViewController.view.frame.size.height;
    
    [UIView animateKeyframesWithDuration:self.dismissalDuration delay:0.0f options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
            
            CGPoint center = fromViewController.view.center;
            center.y =[UIScreen mainScreen].bounds.size.height/2;
            fromViewController.view.center = center;
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            
            fromViewController.view.center = centerOffScreen;
            toViewController.view.alpha = 1.0;
            
        }];

        
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];*/
    
    
    // copy and pasted this from the other one until we have a better transition
    
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
    
    [UIView animateKeyframesWithDuration:duration*.6 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        
        /*[UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:0.05f animations:^{
         fromViewController.view.layer.transform = t1;
         fromViewController.view.alpha = 0.6;
         }];*/
        
        [UIView addKeyframeWithRelativeStartTime:0.00f relativeDuration:1.0f animations:^{
            
            fromViewController.view.layer.transform = [self yetAnotherMethod:fromViewController.view];
        }];
        
    } completion:^(BOOL finished) {
        
    }];
    //[UIView animateWithDuration:duration delay:duration*.2 usingSpringWithDamping:1.0f initialSpringVelocity:6.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        //[UIView animateWithDuration:duration*.2 animations:^{
    [UIView animateWithDuration:duration*.7 delay:duration*.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        
        CATransform3D t = CATransform3DIdentity;
        t.m34 = 1.0/-900;
        t = CATransform3DTranslate(t, 0, 0, 0);
        t = CATransform3DScale(t, 1., 1., 1);
        toViewController.view.layer.transform=t;
        toViewController.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-20);
        
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
    
    
    

}


-(CATransform3D)transformTargetView:(UIView *)view{
    CATransform3D t2 = CATransform3DIdentity;
    t2.m34 = 1.0/-900;
    t2 = CATransform3DTranslate(t2, 0, 0-view.frame.size.height-200, 0);
    t2 = CATransform3DScale(t2, 0.7, 0.7, 1);
    
    return t2;
    
    
}

-(CATransform3D)yetAnotherMethod:(UIView*)view{
    
    CATransform3D t2 = CATransform3DIdentity;
    t2.m34 = 1.0/-900;
    t2 = CATransform3DTranslate(t2, 0, view.frame.size.height*2, 0);
    t2 = CATransform3DScale(t2, 1.2, 1.2, 1);
    
    return t2;
}


@end
