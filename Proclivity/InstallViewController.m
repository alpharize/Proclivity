//
//  InstallViewController.m
//  BetterRIP
//
//  Created by David Yu on 22/12/2014.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import "InstallViewController.h"
#import "BackgroundManager.h"
#import "PackageManager.h"

@interface InstallViewController ()


@end


@implementation InstallViewController {
    UILabel *timerLabel;
    NSTimer *deathTimer;
}

@synthesize backgroundIsLightStyle;
@synthesize package;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    // Top Label
    UILabel *aLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, ([UIScreen mainScreen].bounds.size.height/2)-30, [UIScreen mainScreen].bounds.size.width-40, 60)];
    aLabel.text=[NSString stringWithFormat:@"Restarting SpringBoard in"];
    
    aLabel.textColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.05 alpha:1] : [UIColor colorWithHue:0 saturation:0 brightness:.95 alpha:1];
    aLabel.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.08] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
    aLabel.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-Bold" size:24];
    aLabel.tag=1;
    aLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:aLabel];

    
    timerLabel=[[UILabel alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width/2)-50, ([UIScreen mainScreen].bounds.size.height/2)+60, 100, 140)];
    timerLabel.text=[NSString stringWithFormat:@"5"];
    
    timerLabel.textColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.05 alpha:1] : [UIColor colorWithHue:0 saturation:0 brightness:.95 alpha:1];
    timerLabel.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-Bold" size:70];
    timerLabel.tag=1;
    timerLabel.textAlignment=NSTextAlignmentCenter;
    
    [self.view addSubview:timerLabel];

    // Back Button
    UIButton *cancelButton=[UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame=CGRectMake(20, aLabel.frame.origin.y-80,120, 60);
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelButton.titleLabel.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-Bold" size:21];
    [cancelButton addTarget:self action:@selector(userWantsToGoBack) forControlEvents:UIControlEventTouchUpInside];
    //cancelButton.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.08] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
    [cancelButton setTitleColor:backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.15 alpha:0.9] : [UIColor colorWithHue:0 saturation:0 brightness:.88 alpha:0.95] forState:UIControlStateNormal];
    
    [self.view addSubview:cancelButton];
    
    // Install button
    UIButton *installButton=[UIButton buttonWithType:UIButtonTypeCustom];
    installButton.frame=CGRectMake([UIScreen mainScreen].bounds.size.width-140, aLabel.frame.origin.y-80,120, 60);
    [installButton setTitle:@"Restart Now" forState:UIControlStateNormal];
    installButton.titleLabel.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-Bold" size:19.5];
    //installButton.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.08] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
    [installButton setTitleColor:backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.15 alpha:0.9] : [UIColor colorWithHue:0 saturation:0 brightness:.88 alpha:0.95] forState:UIControlStateNormal];
    [installButton addTarget:self action:@selector(die) forControlEvents:UIControlEventTouchUpInside];
    installButton.opaque=YES;
    [self.view addSubview:installButton];
    
    // P-Load button
    UIButton *loadButton=[UIButton buttonWithType:UIButtonTypeCustom];
    loadButton.frame=CGRectMake([UIScreen mainScreen].bounds.size.width/2-150, aLabel.frame.origin.y+80,300, 60);
    [loadButton setTitle:@"Dynamic Reload (Experimental)" forState:UIControlStateNormal];
    loadButton.titleLabel.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-Bold" size:17];
    [loadButton setTitleColor:backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:.1 brightness:.15 alpha:0.9] : [UIColor colorWithHue:0 saturation:.1 brightness:.88 alpha:0.95] forState:UIControlStateNormal];
    [loadButton addTarget:self action:@selector(showReloadAView) forControlEvents:UIControlEventTouchUpInside];
    loadButton.opaque=YES;
    [self.view addSubview:loadButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidAppear:(BOOL)animated {
    /*NSLog(@"Re-adding parallax");
    NavigationViewController *navigationVC=[[NavigationViewController alloc]init];
    UIView *backgroundView=[navigationVC getBackgroundView];
    backgroundView.tag=7;
    [self.view addSubview:backgroundView];
    [self.view sendSubviewToBack:backgroundView];
    */
    // Draw rectangle under the status bar
    dispatch_async(dispatch_get_main_queue(), ^(void){
        UIView *myBox  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
        myBox.backgroundColor = backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.08] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
        myBox.tag=9;
        [self.view addSubview:myBox];
    });
    
    deathTimer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button Index =%ld",(long)buttonIndex);
    if (buttonIndex == 0)
    {
        timerLabel.text=@"5";
        deathTimer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats:YES];

    }
    else if(buttonIndex == 1)
    {
        [self flyflyswoosh];
    }
}

-(void)updateCountdown {
    timerLabel.text=[NSString stringWithFormat:@"%d",[timerLabel.text integerValue]-1];
    if ([timerLabel.text integerValue]==0) {
        NSLog(@"Dying");
        [self die];
    }
}

-(void)die {
    system("killall backboardd");
}

-(void)showReloadAView {
    [deathTimer invalidate];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Try Dynamic Reload?" message:@"Dynamic Reload is an experimental feature that tries to start Cydia Substrate tweaks without restarting SpringBoard. Using Dynamic Reload will close Proclivity." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Reload", nil];
    [alert show];
}

//can't think of a better name to load dylib, perhaps loaddylib would be better, but whatever
-(void)flyflyswoosh {
    [deathTimer invalidate];
    NSLog(@"Fly fly swoosh");
    [_session loadDylib];
    NSLog(@"Done");
    [self dismissViewControllerAnimated:YES completion:nil];
}
    

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
