//
//  PackageDetailsViewController.m
//  BetterRIP
//
//  Created by David Yu on 20/12/2014.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import "PackageDetailsViewController.h"
#import "BackgroundManager.h"
#import "InstallViewController.h"
#import "ADVAnimationController.h"
#import "DropAnimationController.h"
#import "PackageManager.h"
#import "MRProgress.h"
#import "Dependency.h"
#import "CoolStyledLabel.h"
#import "ZoomAnimationController.h"
#import "ClickedDepictionLinkViewController.h"
#import "InstallSession.h"
#import "BuyPackageViewController.h"
#import "CSSInjector.h"

@interface PackageDetailsViewController ()

@property (nonatomic, strong) id<ADVAnimationController> animationController;
@property UIView *installProgressBackgroundView;

@end

#define NAVBAR_HEIGHT 65
#define NAVBAR_MARGIN_TOP 5

@implementation PackageDetailsViewController {
    UIScrollView *mainScrollView;
    NSMutableURLRequest *depictionRequest;
    UIWebView *depictionWebView;
    
    NSInteger count;
    NSTimer *depictionTimer;
    
    UILabel *purchaseStatus;
    
    BOOL installSheetDonePoppedOut;
    UIButton *installButton;
    
    UIView *installationProgressView;
    
    BOOL packageInstalled;
    
    Package* currentPackage;
    UIView *navBox;
    UIButton *cancelButton;
    
    BOOL webViewLoaded;
    
    MRActivityIndicatorView* depictionIndicator;
    
    UIView* installSheetView;
    UIView* installSheetContainer;
    UIView *dependsBackground;
    DependencyResult* r;
    
    UITableView *moreDetails;
    
    NSString *responseString;
    
    UIProgressView *installProgress;
    InstallSession* session;
    
    NSTimer *installationTimer;
    
    BOOL needsRespring;
}

@synthesize backgroundIsLightStyle;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Make the view blurred
    /*UIImageView *transitionBackground=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    transitionBackground.image=backgroundDuringTransition;
    transitionBackground.tag=7;
    [self.view addSubview:transitionBackground];*/
    count=0;
    // Get package info
    
    currentPackage = [[PackageManager sharedInstance] getPackage:self.packageName];
    
   /* //NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM Packages WHERE \"name\" LIKE \"%%%@%%\" ORDER BY name",searchTextField.text];
    NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM Packages WHERE \"package\" LIKE \"%@\" ORDER BY package",_packageName];
    const char *query_stmt = [querySQL UTF8String];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *currentRowInfo=[[NSMutableDictionary alloc]init];
            
            for (NSInteger i=0; i<22; i++) {
                if ((const char *) sqlite3_column_text(statement, (int)i)) {
                    [currentRowInfo setObject:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, (int)i)] forKey:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_name(statement, (int)i)]];
                }
            }
            [mutableSearchArray addObject:currentRowInfo];
        }
        sqlite3_finalize(statement);
    } else {
        NSLog(@"An error occured while executing the query: '%s'", sqlite3_errmsg(database));
    }
    */
    // Check whether package is installed
    // To do
    packageInstalled = currentPackage.installed;
    // testing
    //packageInstalled=YES;
    
    NSLog(@"Package is installed? %d",packageInstalled);
    NSString *packageAuthor = @"";
    if ((id)currentPackage.author != [NSNull null]) {
        NSArray *array=[currentPackage.author componentsSeparatedByString:@" <"];
        packageAuthor =array[0];
    }
    
    // ScrollView
    mainScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-NAVBAR_HEIGHT)];
    [self.view addSubview:mainScrollView];
    
    // Top Label
    UILabel *aLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 0, [UIScreen mainScreen].bounds.size.width-40, 50)];
    aLabel.text=[NSString stringWithFormat:@"\t%@",currentPackage.name];
    
    aLabel.textColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.05 alpha:1] : [UIColor colorWithHue:0 saturation:0 brightness:.95 alpha:1];
    aLabel.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithWhite:1.0 alpha:0.2] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
    aLabel.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-Bold" size:25];
    aLabel.minimumScaleFactor=0.7;
    aLabel.adjustsFontSizeToFitWidth=YES;
    aLabel.tag=1;
    
    [mainScrollView addSubview:aLabel];
    
    // Sublabel
    UIView *subLabelBackground=[[UIView alloc]initWithFrame:CGRectMake(20, aLabel.frame.origin.y+aLabel.frame.size.height+10, [UIScreen mainScreen].bounds.size.width-40, 85)];
    subLabelBackground.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithWhite:1.0 alpha:0.2] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
    
    /*CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
    [subLabelBackground.backgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    NSLog(@"r:%f, g%f, b%f, a%f", red, green, blue, alpha);
    */
    for (NSInteger i=0; i<3; i++) {
        UILabel *bLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 8+(i*23), [UIScreen mainScreen].bounds.size.width-60, 23)];
        switch (i) {
            case 0:
                bLabel.text=[NSString stringWithFormat:@"by %@",packageAuthor];
                bLabel.minimumScaleFactor=0.85;
                bLabel.adjustsFontSizeToFitWidth=YES;
                break;
            case 1:
                bLabel.text=[NSString stringWithFormat:@"%@",currentPackage.section];
                break;
            case 2:
                bLabel.text=[NSString stringWithFormat:@"%@",currentPackage.version];
                break;
            default:
                break;
        }
        bLabel.textColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.05 alpha:1] : [UIColor colorWithHue:0 saturation:0 brightness:.95 alpha:1];
        //bLabel.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.08] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
        
        bLabel.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-Regular" size:21];
        bLabel.tag=2;
        [subLabelBackground addSubview:bLabel];
    }
    [mainScrollView addSubview:subLabelBackground];
    
    // Fake NavBar (Better Navbar anyone?!)
    //5px padding
    navBox  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, NAVBAR_HEIGHT)];
    navBox.backgroundColor = backgroundIsLightStyle ? [UIColor colorWithWhite:1.0 alpha:0.5] : [UIColor colorWithWhite:0.20 alpha:0.4];
    navBox.tag=9;
    
    navBox.layer.masksToBounds = NO;
    navBox.layer.shadowOffset = CGSizeMake(-3, -3);
    navBox.layer.shadowRadius = 3;
    navBox.layer.shadowOpacity = 0.35;
    CGRect shadowBounds = navBox.layer.bounds;
    shadowBounds.size.height += 6;
    shadowBounds.size.width += 6;
    navBox.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowBounds].CGPath;
    [self.view addSubview:navBox];
    
    // Back Button
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame=CGRectMake(20, 22,120, 40);
    
    [cancelButton setTitle:@"« Back" forState:UIControlStateNormal];
    cancelButton.titleLabel.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-MediumP4" size:21];
    [cancelButton addTarget:self action:@selector(userWantsToGoBack) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton addTarget:self action:@selector(buttonNormal) forControlEvents:UIControlEventTouchUpInside];
    //cancelButton.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.08] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
    [cancelButton setTitleColor:backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.15 alpha:0.9] : [UIColor colorWithHue:0 saturation:0 brightness:.88 alpha:0.95] forState:UIControlStateNormal];
    cancelButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    UISwipeGestureRecognizer *mSwipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userWantsToGoBack)];
    
    [mSwipeUpRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    
    [[self view] addGestureRecognizer:mSwipeUpRecognizer];
    
    [self.view addSubview:cancelButton];
    [self.view bringSubviewToFront:cancelButton];

    // Install button
    installButton=[UIButton buttonWithType:UIButtonTypeCustom];
    installButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-140, 22,120, 40);
    [installButton setTitle:(packageInstalled ? @"Manage" : @"Install") forState:UIControlStateNormal];
    installButton.titleLabel.font = cancelButton.titleLabel.font;
    //installButton.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.08] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
    installButton.backgroundColor=[UIColor clearColor];
    [installButton setTitleColor:backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.15 alpha:0.9] : [UIColor colorWithHue:0 saturation:0 brightness:.88 alpha:0.95] forState:UIControlStateNormal];
    [installButton addTarget:self action:@selector(didClickInstall) forControlEvents:UIControlEventTouchUpInside];
    [installButton addTarget:self action:@selector(buttonNormal) forControlEvents:UIControlEventTouchUpInside];
    
    installButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
    [self.view addSubview:installButton];
    [self.view bringSubviewToFront:installButton];

    // Add this code later
    /*UISwipeGestureRecognizer *iSwipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didClickInstall)];
    
    [iSwipeUpRecognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    
    [[self view] addGestureRecognizer:iSwipeUpRecognizer];*/
    
    
    // Depiction
    
    if ((id)currentPackage.depiction != [NSNull null]) {
        NSURL *depictionURL=[NSURL URLWithString:currentPackage.depiction];
        depictionRequest = [NSMutableURLRequest requestWithURL:depictionURL];
        
        NSString* userAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 8_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12B411 Safari/600.1.4 Cydia/1.1.16 CyF/1141.14";
        
        [depictionRequest setValue:userAgent forHTTPHeaderField:@"User-Agent"];
        depictionWebView=[[UIWebView alloc]initWithFrame:CGRectMake(0, purchaseStatus ? 250 : 200, [UIScreen mainScreen].bounds.size.width, 20)];
        depictionWebView.alpha=0.9;
        [depictionWebView loadRequest:depictionRequest];
        depictionWebView.delegate = self;
        depictionWebView.alpha = 0;
        depictionWebView.scrollView.scrollEnabled = NO;
        depictionWebView.scalesPageToFit = YES;
        [mainScrollView addSubview:depictionWebView];
        
        depictionIndicator = [[MRActivityIndicatorView alloc]initWithFrame:CGRectMake(mainScrollView.frame.size.width/2-25, 220, 50, 50)];
        depictionIndicator.alpha=0.7;
        depictionIndicator.hidden=YES;
        depictionIndicator.tintColor=backgroundIsLightStyle ? [UIColor blackColor] : [UIColor whiteColor];
        [mainScrollView addSubview:depictionIndicator];
    }
    else if ((id)currentPackage.description != [NSNull null]){
        NSLog(@"no depiction");
        UILabel* description = [[UILabel alloc] initWithFrame:CGRectMake(0, purchaseStatus ? 205 : 155, [UIScreen mainScreen].bounds.size.width, 20)];
        
        description.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-Regular" size:21];
        description.textColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.05 alpha:1] : [UIColor colorWithHue:0 saturation:0 brightness:.95 alpha:1];
        description.text = currentPackage.description;
        [description sizeToFit];
        [mainScrollView addSubview:description];
    }
    else {
        NSLog(@"No description/depiction");
    }
}

-(void)buttonNormal {
    [installButton setTitleColor:backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.15 alpha:0.9] : [UIColor colorWithHue:0 saturation:0 brightness:.88 alpha:0.95] forState:UIControlStateNormal];
    [cancelButton setTitleColor:backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.15 alpha:0.9] : [UIColor colorWithHue:0 saturation:0 brightness:.88 alpha:0.95] forState:UIControlStateNormal];
    
}

-(void)wantsToBuyPackage {
    
    NSNumber *packageNumber;
    if ([responseString rangeOfString:@"<input type=\"hidden\" name=\"product\" value=\""].location!=NSNotFound) {
        NSLog(@"Found package id");
        NSArray *array=[responseString componentsSeparatedByString:@"<input type=\"hidden\" name=\"product\" value=\""];
        NSArray *array2=[array[1]componentsSeparatedByString:@"\""];
        packageNumber=[NSNumber numberWithInteger:[array2[0]integerValue]];
        NSLog(@"package number: %@",packageNumber);
    }
    
    NSURL *purchaseURL=[NSURL URLWithString:[NSString stringWithFormat:@"http://cydia.saurik.com/api/purchase?product=%@",packageNumber]];
    
    
    BuyPackageViewController *BPVC=[[BuyPackageViewController alloc]init];
    
    self.animationController = [[ZoomAnimationController alloc] init];
    
    BPVC.transitioningDelegate  = self;
    BPVC.purchasePackageURL=purchaseURL;
    BPVC.backgroundIsLightStyle=backgroundIsLightStyle;
    
    [self presentViewController:BPVC animated:YES completion:nil];

}

-(void)didClickInstall {
    NSLog(@"Did click install");
   
    //installButton.enabled=NO;
    if (installSheetDonePoppedOut) {
        installSheetDonePoppedOut=NO;
        //installSheetContainer=[self.view viewWithTag:15];
        UIView *installSheet=[installSheetContainer viewWithTag:11];
        NSLog(@"Install sheet: %@",installSheet);
        [UIView animateWithDuration:0.4 animations:^{
            
            installSheet.frame=CGRectMake(installSheet.frame.origin.x, installSheet.frame.origin.y-installSheet.frame.size.height, installSheet.frame.size.width, installSheet.frame.size.height);
            installSheetContainer.alpha = 0;
            mainScrollView.frame=CGRectMake(0, NAVBAR_HEIGHT+10, [UIScreen mainScreen].bounds.size.width, mainScrollView.frame.size.height+installSheet.frame.size.height);
        }completion:^(BOOL finished) {
            [installSheetContainer removeFromSuperview];
            
            [UIView animateWithDuration:0.4 animations:^{
            }completion:^(BOOL finished){
                [installButton setTitle:(packageInstalled ? @"Manage" : @"Install") forState:UIControlStateNormal];
                installButton.enabled=YES;
            }];
            
        }];
        return;
    }
    
    if (installSheetContainer == nil) {
        
        BOOL dependenciesUnmet = FALSE;
        
        NSLog(@"getting dependencies");
        Dependency* d = [[Dependency alloc] initWithPackageObject:currentPackage];
        r = [d getDependencyTree:0];
        
        
        NSMutableDictionary* packageDependencies = r.dependencies;
        //NSLog(@"%@", packageDependencies);
        NSMutableArray* dependencies = [NSMutableArray new];
        if (r.code == dependencies_cannot_be_installed) {
            NSLog(@"warning not success uhh");
            dependenciesUnmet = TRUE;
            [dependencies addObject:r.dependency_cannot_be_installed.packageName];
        }
        else {
            for (id key in packageDependencies) {
                Dependency* d = [packageDependencies objectForKey:key];
                NSLog(@"wow %@:%u", d.packageName, d.level);
                if ([d.packageName isEqualToString:@"mobilesubstrate"]) {
                    needsRespring=YES;
                }
                if (![d.getPackage.package isEqualToString:currentPackage.package]) {
                    [dependencies addObject:[d.getPackage getUsableName]];
                }
            }
        }
        
        [dependencies addObject:currentPackage.package];
        
        
        installSheetView =[[UIView alloc]initWithFrame:CGRectMake(20, 0, [UIScreen mainScreen].bounds.size.width-40, 200)];
        installSheetView.clipsToBounds=YES;
        installSheetView.tag=11;
        
        installSheetView.frame=CGRectMake(installSheetView.frame.origin.x, installSheetView.frame.origin.y, installSheetView.frame.size.width, 65+(45*(packageInstalled ? 2 : 1)));
        
        // Uninstall/install button
        
        /*UILabel *bLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 45, [UIScreen mainScreen].bounds.size.width-80, 45)];
         bLabel.textColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.15 alpha:0.9] : [UIColor colorWithHue:0 saturation:0 brightness:.88 alpha:0.95];
         //bLabel.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.4] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.7];
         bLabel.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-Bold" size:21];
         bLabel.textAlignment=NSTextAlignmentRight;
         bLabel.userInteractionEnabled = YES;
         
         //underline
         NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
         if (packageInstalled) {
         bLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Remove" attributes:underlineAttribute];
         }  else {
         bLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Install" attributes:underlineAttribute];
         }
         
         UITapGestureRecognizer *labelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapInstallSheetLabel:)];
         [bLabel addGestureRecognizer:labelTapGesture];
         NSLog(@"blabel frame: %@",NSStringFromCGRect(bLabel.frame));
         [installSheetView addSubview:bLabel];*/
        
        // Button
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),NSForegroundColorAttributeName:[UIColor colorWithHue:0 saturation:0 brightness:.9 alpha:1]};
        
        UIButton *installButton2=[UIButton buttonWithType:UIButtonTypeCustom];
        installButton2.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-230, 15,150, 40);
        //[installButton2 setTitle:(packageInstalled ? @"Remove" : @"Install Now") forState:UIControlStateNormal];
        [installButton2 setAttributedTitle:[[NSAttributedString alloc] initWithString:(packageInstalled ? @"Remove" : @"Install Now") attributes:underlineAttribute] forState:UIControlStateNormal];
        
        installButton2.titleLabel.font = cancelButton.titleLabel.font;
        //installButton.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.08] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
        installButton2.backgroundColor=[UIColor clearColor];
        [installButton2 addTarget:self action:@selector(didTapInstallSheetLabel:) forControlEvents:UIControlEventTouchUpInside];
        installButton2.tag=17;
        installButton2.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
        [installSheetView addSubview:installButton2];
        
        if (packageInstalled) {
            UIButton *reinstallButton=[UIButton buttonWithType:UIButtonTypeCustom];
            reinstallButton.frame = CGRectMake(20, 15,150, 40);
            reinstallButton.titleLabel.font = cancelButton.titleLabel.font;
            //installButton.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.08] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
            reinstallButton.backgroundColor=[UIColor clearColor];
            [reinstallButton addTarget:self action:@selector(didTapInstallSheetLabel:) forControlEvents:UIControlEventTouchUpInside];
            [reinstallButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Reinstall" attributes:underlineAttribute] forState:UIControlStateNormal];
            
            reinstallButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
            [installSheetView addSubview:reinstallButton];
        }
        //UITextView *dependencyLabal=[KJCStyledLabel labelWithLightStyle:backgroundIsLightStyle labelType:1 frame:CGRectMake(20, (45*(packageInstalled ? 2 : 1)) + (10*(packageInstalled ? 2 : 1)), [UIScreen mainScreen].bounds.size.width-40, <#CGFloat height#>) text:<#(NSString *)#>];
        
        //UITextView *dependencyTextView=[[UITextView alloc]initWithFrame:CGRectMake(20, (45*(packageInstalled ? 2 : 1)) + (10*(packageInstalled ? 2 : 1)), [UIScreen mainScreen].bounds.size.width-40, <#CGFloat height#>)
        
        // Go Go Dependencies
        
        // Sublabel
        dependsBackground=[[UIView alloc]initWithFrame:CGRectMake(0, 40+10+(45*(packageInstalled ? 2 : 1))+((packageInstalled ? 2 : 1)*10), [UIScreen mainScreen].bounds.size.width-60, 40)];
        //dependsBackground.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.4] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.7];
        
        for (NSInteger i=0; i<dependencies.count+1; i++) {
            UILabel *bLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, ((i-1)*22)+70, [UIScreen mainScreen].bounds.size.width-100, 20)];
            if (i==0) {
                if (!packageInstalled) {
                    if (dependenciesUnmet) {
                        bLabel.text=[NSString stringWithFormat:@"Installation failed. The following packages could not be found, try reloading packages"];
                        installButton.userInteractionEnabled = NO;
                        installButton.alpha = 0.3;
                    }
                    else {
                        bLabel.text=[NSString stringWithFormat:@"Installing %@ will also install these packages:",currentPackage.name];
                        
                    }
                    bLabel.numberOfLines=2;
                    bLabel.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-Regular" size:21];
                    bLabel.adjustsFontSizeToFitWidth=YES;
                    bLabel.minimumScaleFactor=0.5;
                    CGRect aFrame=bLabel.frame;
                    aFrame.origin.y=0;
                    aFrame.size.height=70;
                    bLabel.frame=aFrame;
                }
            } else {
                bLabel.text=dependencies[i-1];
                bLabel.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-Thin" size:19];
            }
            bLabel.textAlignment=NSTextAlignmentLeft;
            bLabel.textColor=[UIColor colorWithHue:0 saturation:0 brightness:.95 alpha:1];
            [dependsBackground addSubview:bLabel];
        }
        dependsBackground.frame=CGRectMake(0, 60, [UIScreen mainScreen].bounds.size.width-60, 23*(dependencies.count+1)+20);
        dependsBackground.tag=13;
        
        [installSheetView addSubview:dependsBackground];
        //installSheetView.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.08] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
        //installSheetView.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.08] : [UIColor colorWithWhite:0.20 alpha:0.4];
        
        
        
        installSheetView.frame=CGRectMake(installSheetView.frame.origin.x, 0, installSheetView.frame.size.width, 60+52+((22*dependencies.count) + 32));
        installSheetView.frame=CGRectMake(installSheetView.frame.origin.x, installSheetView.frame.origin.y-installSheetView.frame.size.height, installSheetView.frame.size.width, installSheetView.frame.size.height);
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [blurEffectView setFrame:installSheetView.bounds];
        blurEffectView.alpha=backgroundIsLightStyle ? 0.8 : 1.0 ;
        [installSheetView addSubview:blurEffectView];
        [installSheetView sendSubviewToBack:blurEffectView];
        
        // Container for install sheet view
        installSheetContainer=[[UIView alloc]initWithFrame:CGRectMake(20, 65, [UIScreen mainScreen].bounds.size.width-40, installSheetView.frame.size.height)];
        installSheetContainer.clipsToBounds=YES;
        installSheetContainer.tag=15;
        [installSheetContainer addSubview:installSheetView];
    }
    [self.view addSubview:installSheetContainer];
    installSheetContainer.alpha = 0;
    
    [UIView animateWithDuration:0.4 animations:^{
        mainScrollView.frame=CGRectMake(0, NAVBAR_HEIGHT+10+installSheetContainer.frame.size.height, [UIScreen mainScreen].bounds.size.width, mainScrollView.frame.size.height-installSheetContainer.frame.size.height);
         installSheetView.frame=CGRectMake(installSheetView.frame.origin.x, installSheetView.frame.origin.y+installSheetView.frame.size.height, installSheetView.frame.size.width, installSheetView.frame.size.height);
        installSheetContainer.alpha = 1;
        [installButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.95] forState:UIControlStateNormal];
    }completion:^(BOOL finished){
        
        //[installButton setTitle:(packageInstalled ? @"Manage ↓" : @"Install ↓") forState:UIControlStateNormal];
        
        
        
    }];
    installSheetDonePoppedOut=YES;
    NSLog(@"Done Presenting Install Sheet");
}

-(void)didTapInstallSheetLabel:(UIGestureRecognizer *)sender {
    
    NSLog(@"beginning installation");
    NSLog(@"background: %@",dependsBackground);
    [dependsBackground removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateProgressBarByAbsolute:)
                                                 name:@"APRDownloadProgressDidChageNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(installationDidCompleteSuccessfully)
                                                 name:@"APRInstallDidCompleteSuccessfully" object:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self beginInstallation];
    });
    
    installButton.enabled=NO;
    [UIView animateWithDuration:0.1 animations:^{
        dependsBackground.alpha=0;
    }];
    
    UIButton *installNowButton;
    for (UIView *i in installSheetView.subviews){
        if(i.tag==17){
            NSLog(@"Found install button");
            installNowButton=(UIButton *)i;
        }
    }
    
    //[installNowButton setTitle:@"Installing" forState:UIControlStateNormal];
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),NSForegroundColorAttributeName:[UIColor colorWithHue:0 saturation:0 brightness:.9 alpha:1]};
    
    [installNowButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Installing..." attributes:underlineAttribute] forState:UIControlStateNormal];

    [UIView animateWithDuration:.4 animations:^{
        installSheetView.frame=CGRectMake(installSheetView.frame.origin.x, installSheetView.frame.origin.y, installSheetView.frame.size.width, installSheetView.frame.size.height-dependsBackground.frame.size.height-30);
        mainScrollView.frame=CGRectMake(0, 150, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-125);
    }completion:^(BOOL finished){
        NSLog(@"FRAMES: %@ %@",NSStringFromCGRect(installSheetView.frame),NSStringFromCGRect(installSheetContainer.frame));
        installProgress=[[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
        installProgress.frame=CGRectMake(40, 134, installSheetView.frame.size.width, 5);
        installProgress.tintColor=[UIColor blackColor];
        NSLog(@"Other frame: %@",NSStringFromCGRect(installProgress.frame));
        installProgress.progress=0.05;
        [self.view addSubview:installProgress];
    }];
    
    MRActivityIndicatorView *activityIndicatorView = [[MRActivityIndicatorView alloc]initWithFrame:CGRectMake(installButton.frame.origin.x-50, 87, 30, 30)];
    activityIndicatorView.tintColor=backgroundIsLightStyle ? [UIColor whiteColor] : [UIColor whiteColor];
    [activityIndicatorView startAnimating];
    activityIndicatorView.tag=19;
    [self.view addSubview:activityIndicatorView];
    
    
    //NSLog(@"Sender tag: %ld",(long)sender.view.tag);
    
    NSLog(@"hello");
    return;
    
    /*self.installProgressBackgroundView=[[UIView alloc]initWithFrame:CGRectMake(20, 90+((45*(sender.view.tag-12))+((sender.view.tag-12)*10)), [UIScreen mainScreen].bounds.size.width-40, 45)];
    self.installProgressBackgroundView.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.08] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
    self.installProgressBackgroundView.alpha=0;
    [self.view addSubview:self.installProgressBackgroundView];
    
    installationProgressView=[[UIView alloc]initWithFrame:CGRectMake(20, 90+((45*(sender.view.tag-12))+((sender.view.tag-12)*10)), [UIScreen mainScreen].bounds.size.width-40, 45)];
    installationProgressView.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.08] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
    installationProgressView.alpha=0;
    [self.view addSubview:installationProgressView];
    
    for (UIView *i in self.view.subviews){
        if(i.tag==11){
            UIView *installSheetView=(UIView *)i;
            for (UIView *n in installSheetView.subviews) {
                if (n.tag==sender.view.tag) {
                    //n.alpha=0;
                    UILabel *m=(UILabel *)n;
                    //m.text=[@"\t"stringByAppendingString:m.text]; - Do we really need to add a tab at the beginning?
                    m.text=@"\t10 seconds remaining"; // Let's try a space

                    m.backgroundColor=[UIColor clearColor];
                    //n.frame=CGRectMake(55, n.frame.origin.y, n.frame.size.width-40, n.frame.size.height);
                }
            }
        }

    }
    
   
    activityIndicatorView.alpha=0;
    [UIView animateWithDuration:0.5 animations:^{
        for (UIView *i in self.view.subviews){
            if(i.tag==11){
                UIView *installSheetView=(UIView *)i;
                for (UIView *n in installSheetView.subviews) {
                    if (n.tag!=sender.view.tag) {
                        n.alpha=0;
                    }
                }
            }
            self.installProgressBackgroundView.alpha=1.0;
            installationProgressView.alpha=1.0;
            activityIndicatorView.alpha=1.0;
        }
    }completion:^(BOOL finished){
    }];*/
}

/*-(void)updateProgressBarByIncrease:(float)percentIncrease {
    float currentPercentDone=1-(installationProgressView.frame.size.width/([UIScreen mainScreen].bounds.size.width-40));
    float finalPercentDone=currentPercentDone+percentIncrease;
    NSLog(@"Percent done: %f",finalPercentDone);
    if (finalPercentDone>0.999) {
        UIView *activityIndicator;
        for (UIView *i in self.view.subviews){
            if([i isKindOfClass:[MRActivityIndicatorView class]]){
                activityIndicator=i;
            }
            self.installProgressBackgroundView.alpha=1.0;
        }
        [UIView animateWithDuration:0.2 animations:^{
            installationProgressView.frame=CGRectMake([UIScreen mainScreen].bounds.size.width-20, installationProgressView.frame.origin.y, 0, installationProgressView.frame.size.height);
            activityIndicator.alpha=0;
            
        }completion:^(BOOL finished){
            [installationProgressView removeFromSuperview];
            // perform additional UI changes
            [activityIndicator removeFromSuperview];
            [self installationActionDidComplete];
        }];

        return;
    }
    [UIView animateWithDuration:0.2 animations:^{
        
        float progressBarWidth=([UIScreen mainScreen].bounds.size.width-40)-(([UIScreen mainScreen].bounds.size.width-40)*finalPercentDone);
        installationProgressView.frame=CGRectMake(([UIScreen mainScreen].bounds.size.width-20)-progressBarWidth, installationProgressView.frame.origin.y, progressBarWidth, installationProgressView.frame.size.height);
        
    }completion:^(BOOL finished){
        
    }];
}*/

-(void)beginInstallation {
    session = [[InstallSession alloc] initWithDependencyResult:r];
    [session downloadFiles];
}

-(void)updateProgressBarByAbsolute:(NSNotification *)notification {
    //todo!
    if (installProgress.progress>.69) {
                installationTimer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateInstallProgressBar) userInfo:nil repeats:YES];
        NSLog(@"Did start installing");
        return;
    }
    
    NSDictionary *userInfo=[notification userInfo];
    NSInteger numberOfDependencies = r.dependencies.count;

    NSLog(@"User info: %@",userInfo);
    CGFloat progress=installProgress.progress+([userInfo[@"changeInProgress"]floatValue] /numberOfDependencies)*.7;
    installProgress.progress=progress;
    
    NSLog(@"Progress: %f",progress);
    
    if (installProgress.progress>.69) {
        installationTimer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateInstallProgressBar) userInfo:nil repeats:YES];
    }
}

-(void)updateInstallProgressBar {
    NSLog(@"Updating progress bar");
    if (installProgress.progress<.95) {
        if (installProgress.progress+.05<.95) {
            installProgress.progress=installProgress.progress+.05;
        } else {
            installProgress.progress=.95;
        }
    } else {
        installProgress.progress=.95;
        [installationTimer invalidate];
    }
}

-(void)installationDidCompleteSuccessfully {
    [[PackageManager sharedInstance] loadInstalledPackagesDB];
    BOOL shouldRespring=NO;
    if ([currentPackage.depends rangeOfString:@"mobilesubstrate"].location!=NSNotFound) {
        shouldRespring=YES;
    }
    dispatch_async(dispatch_get_main_queue(), ^(void){
        installProgress.progress=1.0;
        [installProgress removeFromSuperview];
        for (UIView *i in self.view.subviews){
            if(i.tag==19){
                UIView *newLbl = (UIView *)i;
                [newLbl removeFromSuperview];
            }
        }
        installButton.enabled=YES;
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),NSForegroundColorAttributeName:[UIColor colorWithHue:0 saturation:0 brightness:.9 alpha:1]};
        
        [installButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Manage" attributes:underlineAttribute] forState:UIControlStateNormal];
        packageInstalled=YES;
        if (shouldRespring) {
            [self showInstallViewController];
            
        } else {
            [self didClickInstall];
        }

    });
    

   
}

-(void)showInstallViewController {
    InstallViewController *instVC=[[InstallViewController alloc]init];
    instVC.package = currentPackage;
    instVC.session = session;
    
    self.animationController = [[DropAnimationController alloc] init];
    
    instVC.transitioningDelegate  = self;
    
    instVC.backgroundIsLightStyle=backgroundIsLightStyle;
    [self presentViewController:instVC animated:YES completion:nil];

}

-(void)userWantsToGoBack {
    
    for (UIView *i in self.view.subviews){
        if(i.tag==9){
            UIView *newLbl = (UIView *)i;
            [newLbl removeFromSuperview];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    
    [depictionIndicator startAnimating];
    depictionIndicator.hidden=NO;
    // Draw rectangle under the status bar
    dispatch_async(dispatch_get_main_queue(), ^(void){
       // draw rectangle under status bar code used to be here but got moved
    });
    
    
    // Check whether user purchased the package
    NSLog(@"hey");
    if ([currentPackage.tag isKindOfClass:[NSNull class]]) {
        return;
    }
    if ([currentPackage.tag rangeOfString:@"cydia::commercial"].location==NSNotFound) {
        return;
    }
    purchaseStatus=[[UILabel alloc]initWithFrame:CGRectMake(20, 155, [UIScreen mainScreen].bounds.size.width-40, 40)];
    
    purchaseStatus.textColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.05 alpha:1] : [UIColor colorWithHue:0 saturation:0 brightness:.95 alpha:1];
    purchaseStatus.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithWhite:1.0 alpha:0.2] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];

    purchaseStatus.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-Regular" size:20];
    purchaseStatus.textAlignment=NSTextAlignmentCenter;
    purchaseStatus.userInteractionEnabled=YES;
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wantsToBuyPackage)];
    [purchaseStatus addGestureRecognizer:tapGesture];
    
    NSMutableURLRequest *checkPurchaseStatus=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://cydia.saurik.com/api/commercial?package=%@",currentPackage.package]]];

    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:checkPurchaseStatus
                                          returningResponse:&response
                                                      error:&error];
    NSLog(@"Looks like the Request is done");
    
    if (!error)
    {
        NSString *purchaseResponseString=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        responseString=purchaseResponseString;
        NSLog(@"Response string: %@",purchaseResponseString);
        if ([purchaseResponseString rangeOfString:@"style=\"background-color:#eefff0\""].location!=NSNotFound) {
            purchaseStatus.text=@"✓ You've Purchased this Package";
            [mainScrollView addSubview:purchaseStatus];
        } else if ([purchaseResponseString rangeOfString:@"style=\"background-color:#ffc040\""].location!=NSNotFound||[purchaseResponseString rangeOfString:@"style=\"background-color:#f0efaf\""].location!=NSNotFound) {
            purchaseStatus.text=@"\t× Not Purchased";
            purchaseStatus.textAlignment=NSTextAlignmentLeft;
            installButton.hidden=YES;
            [mainScrollView addSubview:purchaseStatus];
        } else {
            purchaseStatus=nil;
        }
    } else {
        purchaseStatus=nil;
        NSLog(@"Error: %@",[error userInfo]);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
       //depictionTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateWebViewSize) userInfo:nil repeats:YES];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"web view loading complete");
    if (webView.isLoading) {
        return;
    }
    [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none';"]; // disable ios action sheet
    
    
    NSLog(@"really loading complete");
    CGFloat contentHeight = [[webView stringByEvaluatingJavaScriptFromString:
                              @"document.documentElement.scrollHeight"] floatValue];
    
    depictionWebView.frame = CGRectMake(webView.frame.origin.x, webView.frame.origin.y,
                                        webView.frame.size.width, contentHeight + 50);
    
    [depictionWebView setBackgroundColor:[UIColor clearColor]];
    [depictionWebView setOpaque:NO];
    mainScrollView.contentSize=CGSizeMake([UIScreen mainScreen].bounds.size.width, contentHeight + 220);
    
    [[CSSInjector sharedInstance] injectToWebview:depictionWebView withURL:currentPackage.depiction lightStyle:backgroundIsLightStyle];
    
    [UIView animateWithDuration:0.3 animations:^{
        depictionIndicator.alpha = 0;
        [depictionIndicator removeFromSuperview];
        depictionWebView.alpha = 1;
    }];
    
    if (!moreDetails) {
        moreDetails=[[UITableView alloc]initWithFrame:CGRectMake(20, depictionWebView.frame.origin.y+depictionWebView.frame.size.height+20, [UIScreen mainScreen].bounds.size.width-40, 180) style:UITableViewStylePlain];
        [moreDetails setDataSource:self];
        [moreDetails setDelegate:self];
        moreDetails.backgroundView=nil;
        [moreDetails setSeparatorInset:UIEdgeInsetsMake(0, 45, 0, 0)];
        moreDetails.backgroundColor=[UIColor clearColor];
        moreDetails.separatorColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.1 alpha:0.9] : [UIColor colorWithHue:0 saturation:0 brightness:.94 alpha:0.95];
        [mainScrollView addSubview:moreDetails];
        moreDetails.userInteractionEnabled=NO;
        mainScrollView.contentSize=CGSizeMake([UIScreen mainScreen].bounds.size.width, mainScrollView.contentSize.height+255);
    }

}

static dispatch_once_t protocol_onceToken = 0;


+ (NSArray*) blacklist {
    static NSArray *cacheInstance= nil;
    dispatch_once(&protocol_onceToken, ^{
        cacheInstance = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"blacklist" ofType:@"plist"]];
    });
    return cacheInstance;
}

+(BOOL) contains:(NSString*) _string {
    for (NSString* string in [self blacklist]) {
        if ([_string rangeOfString:string].location != NSNotFound) {
            NSLog(@"yea it contains");
            return true;
        }
    }
    return false;
}


- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"Request: %@",request);
    
    if ([PackageDetailsViewController contains:[request.URL absoluteString]]) {
     NSLog(@"HA! url %@ is blacklisted", [request.URL absoluteString]);
        return NO;
     }
    
    if(navigationType == UIWebViewNavigationTypeLinkClicked) {
        [self presentMoreDepictionVC:request];
        return NO;
    }
    return YES;
}

-(void)presentMoreDepictionVC :(NSURLRequest *)request {
    
    ClickedDepictionLinkViewController *CDLVC=[[ClickedDepictionLinkViewController alloc]init];
    
    self.animationController = [[ZoomAnimationController alloc] init];
    
    CDLVC.transitioningDelegate  = self;
    CDLVC.urlRequest=request;
    
    [self presentViewController:CDLVC animated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    self.animationController.isPresenting = YES;
    return self.animationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.animationController.isPresenting = NO;
    
    return self.animationController;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

// the cell will be returned to the tableView
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SettingsCell";
    
    // Similar to UITableViewCell, but
    UITableViewCell *cell = [moreDetails dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-Regular" size:21];
    cell.contentView.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithWhite:1.0 alpha:0.2] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
    cell.backgroundColor=[UIColor clearColor];
    cell.textLabel.minimumScaleFactor=0.6;
    cell.textLabel.adjustsFontSizeToFitWidth=YES;
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showEmail:)];

    switch (indexPath.row) {
        case 0:
            cell.textLabel.text=currentPackage.package;
            break;
        case 1:
            cell.textLabel.text=@"Package is provided by <Repo Name>";
            break;
        case 2:
            if (![currentPackage.installed_size isKindOfClass:[NSNull class]]) {
                cell.textLabel.text=[NSString stringWithFormat:@"Installing %@ will use %.2f MB",currentPackage.name,[currentPackage.installed_size floatValue]/1000];
            }
            break;
        case 3:
            cell.textLabel.text=@"Tap to get support";
            cell.textLabel.userInteractionEnabled=YES;
            [cell.textLabel addGestureRecognizer:tapGesture];
            break;
        default:
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Clicked a cell");
    
    if (indexPath.row==3) {
        NSLog(@"Index path is 3");
        [self showEmail:nil];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (IBAction)showEmail:(id)sender {
    NSLog(@"Wants to email");
    NSString *supportEmail = @"";
    if ((id)currentPackage.author != [NSNull null]) {
        NSArray *array=[currentPackage.author componentsSeparatedByString:@" <"];
        supportEmail =array[1];
    }
    
    // Email Subject
    NSString *emailTitle = [NSString stringWithFormat:@"%@ Support Request",currentPackage.name];
    // Email Content
    NSString *messageBody = @"";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:supportEmail];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}




- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    
    
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
