//
//  ViewController.m
//  BetterRIP
//
//  Created by David Yu on 19/12/2014.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"
#import <sqlite3.h>
#import "PackageManager.h"
#import "BackgroundManager.h"
#import "PackageDetailsViewController.h"
#import "ADVAnimationController.h"
#import "DropAnimationController.h"
#import "ZoomAnimationController.h"
#import "CoolStyledLabel.h"
#import "SettingsViewController.h"
#import "ParseCydiaRepositories.h"
#import "MRProgress.h"

@interface ViewController ()

@property (nonatomic, strong) id<ADVAnimationController> animationController;

@end

@implementation ViewController {
    CGSize keyboardSize;
    UITextField *searchTextField;
    UITableView *searchResults;
    NSTimer *searchResultsTimer;
    
    BOOL noSearchResults;
    
    //sqlite3 *database;
    
    NSArray* searchArray;
    
    BOOL backgroundIsLightStyle;
    BOOL performedFirstSearch;
    
    UIView *backgroundView;
    BackgroundManager *backgroundManager;
    
    MRProgressOverlayView *progressView;
}

@synthesize mainScrollView;


-(void)viewDidAppear:(BOOL)animated {
    // Redraw background if it's not there yet
    [self.view addSubview:backgroundView];
    [self.view sendSubviewToBack:backgroundView];

    
    // Draw rectangle under the status bar
    UIView *myBox  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
    myBox.backgroundColor = backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:1.0 alpha:0.1] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
    myBox.tag=9;
    [self.view addSubview:myBox];
    
}

-(void)initLoadingPackages {
    NSLog(@"init loading packages");
    progressView = [MRProgressOverlayView new];
    progressView.mode = MRProgressOverlayViewModeIndeterminate;
    progressView.titleLabelText = @"Downloading Packages..";
    [self.view addSubview:progressView];
    [progressView show:YES];
}

     
-(void)initLoadingPackagesComplete {
     NSLog(@"init loading packages complete");
    [progressView dismiss:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // initialize defaults
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    if (![defaults valueForKey:@"standardRepos"]) {
        [defaults setValue:@[@"BigBoss",@"ModMyi",@"ZodTTD",@"Saurik"] forKey:@"standardRepos"];
        [defaults synchronize];
    }
    
    if (![[NSFileManager defaultManager]fileExistsAtPath:@"/var/lib/Proclivity/packages" isDirectory:nil]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:@"/var/lib/Proclivity/packages" withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initLoadingPackages) name:@"InitLoadingPackages" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initLoadingPackagesComplete) name:@"InitLoadingPackagesComplete" object:nil];
    
    mainScrollView.scrollEnabled = NO;
    BackgroundManager *navigationVC=[[BackgroundManager alloc]init];
    backgroundView=[navigationVC getBackgroundView];
    backgroundView.tag=7;
   
    //[self.view addSubview:backgroundView];
    backgroundIsLightStyle=navigationVC.backgroundIsLightStyle;
    
    // Status bar
    [[UIApplication sharedApplication] setStatusBarStyle:backgroundIsLightStyle ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent];
    
    UILabel *topLabel=[CoolStyledLabel labelWithLightStyle:backgroundIsLightStyle labelType:0 frame:CGRectMake(20, 40, [UIScreen mainScreen].bounds.size.width-40, 60) text:@"Proclivity"];
    topLabel.tag=1;
    
    [self.mainScrollView addSubview:topLabel];
    
    UILabel *subLabel=[CoolStyledLabel labelWithLightStyle:backgroundIsLightStyle labelType:1 frame:CGRectMake(20, topLabel.frame.origin.y+topLabel.frame.size.height+20, [UIScreen mainScreen].bounds.size.width-40, 60) text:@"Made with love in California"];
    subLabel.tag=2;\
    
    [self.mainScrollView addSubview:subLabel];
    
    /* The fonts we have available are:
     2014-12-19 16:12:02.617 BetterRIP[12228:1030107] San Francisco Display
     2014-12-19 16:12:02.617 BetterRIP[12228:1030107]   .HelveticaNeueDeskInterface-MediumP4
     2014-12-19 16:12:02.618 BetterRIP[12228:1030107]   .HelveticaNeueDeskInterface-UltraLightP2
     2014-12-19 16:12:02.618 BetterRIP[12228:1030107]   .HelveticaNeueDeskInterface-Regular
     2014-12-19 16:12:02.618 BetterRIP[12228:1030107]   .HelveticaNeueDeskInterface-Thin
     2014-12-19 16:12:02.618 BetterRIP[12228:1030107]   .HelveticaNeueDeskInterface-Bold
    */
    
    // Increase scrollView size
    mainScrollView.contentSize=CGSizeMake(400, 1500);
    
    // Bring ScrollView to front so we can see it
    [self.view bringSubviewToFront:mainScrollView];
    
    // Draw rectangle under the status bar
    UIView *myBox  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
    myBox.backgroundColor = backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:1.0 alpha:0.1] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
    myBox.tag=9;
    [self.view addSubview:myBox];
    
    // Search bar
    
    UIView *searchBarBackground  = [[UIView alloc] initWithFrame:CGRectMake(20, [UIScreen mainScreen].bounds.size.height-80, [UIScreen mainScreen].bounds.size.width-40, 60)];
    searchBarBackground.backgroundColor = backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:1.0 alpha:0.2] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
    [mainScrollView addSubview:searchBarBackground];
    searchBarBackground.tag=4;
    searchTextField=[[UITextField alloc]initWithFrame:CGRectMake(60, 0, searchBarBackground.frame.size.width-80, 60)];
    
    searchTextField.backgroundColor=[UIColor clearColor];
    
    NSDictionary *placeholderTextAttributes =@{NSFontAttributeName:[UIFont fontWithName:@".HelveticaNeueDeskInterface-Regular" size:20],
                                               NSForegroundColorAttributeName:backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.15 alpha:1] : [UIColor colorWithHue:0 saturation:0 brightness:.9 alpha:1]
                                               };
    searchTextField.placeholder=@"Package Search";
    
    searchTextField.attributedPlaceholder=[[NSAttributedString alloc] initWithString:@"Package Search" attributes:placeholderTextAttributes];
    searchTextField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    [searchTextField addTarget:self action:@selector(shouldInitiateSearch) forControlEvents:UIControlEventEditingDidBegin];
    [searchTextField addTarget:self action:@selector(searchQueryDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    searchTextField.keyboardAppearance=backgroundIsLightStyle ? UIKeyboardAppearanceLight : UIKeyboardAppearanceDark;
    searchTextField.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-Regular" size:20];
    searchTextField.textColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.12 alpha:1] : [UIColor colorWithHue:0 saturation:0 brightness:.95 alpha:1];
    searchTextField.autocorrectionType=UITextAutocorrectionTypeNo;
    searchTextField.userInteractionEnabled = NO;
    searchTextField.returnKeyType=UIReturnKeySearch;
    searchTextField.delegate=self;
    searchTextField.clearButtonMode=UITextFieldViewModeAlways;
    
    [searchBarBackground addSubview:searchTextField];
    
    // Search icon
    UIImageView *searchIconImageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 0, 40, 60)];
    searchIconImageView.image=backgroundIsLightStyle ? [UIImage imageNamed:@"SearchIconLightStyle"] : [UIImage imageNamed:@"SearchIconDarkStyle"];
    [searchBarBackground addSubview:searchIconImageView];
    
    searchTextField.userInteractionEnabled = NO;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [[PackageManager sharedInstance] saveSearchCache];
        [[PackageManager sharedInstance] loadInstalledPackagesDB];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            searchTextField.userInteractionEnabled = YES;
        });
    });

    //Settings
    UILabel *settingsLabel=[CoolStyledLabel labelWithLightStyle:backgroundIsLightStyle labelType:1 frame:CGRectMake(20, searchBarBackground.frame.origin.y-100, [UIScreen mainScreen].bounds.size.width-40, 60) text:@"Settings"];
    settingsLabel.userInteractionEnabled=YES;
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentSettings)];
    [settingsLabel addGestureRecognizer:tapGesture];
    
    [self.mainScrollView addSubview:settingsLabel];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)searchQueryDidChange :(id)sender {
    [self updateSearchResults];
}

-(void)presentSettings {

    NSLog(@"Presenting settings");
    SettingsViewController *SettingsVC=[[SettingsViewController alloc]init];
    
    self.animationController = [[DropAnimationController alloc] init];
    
    SettingsVC.transitioningDelegate  = self;
    
   
    SettingsVC.backgroundIsLightStyle=backgroundIsLightStyle;
    for (UIView *i in self.view.subviews){
        if(i.tag==9){
            UIView *newLbl = (UIView *)i;
            [newLbl removeFromSuperview];
        }
    }
    
    [self presentViewController:SettingsVC animated:YES completion:nil];
}

-(void)updateSearchResults {
    NSLog(@"Query changed to: %@",searchTextField.text);
    
    if (searchTextField.text.length < 3) {
        if ([searchTextField.text hasPrefix:@" "]) {
            NSLog(@"empty");
            return;
        }
    }
    
    searchArray = [[PackageManager sharedInstance] searchPackageCacheWithName:searchTextField.text completeSearch:NO];
    
    [searchResults reloadData];
    
}

-(void)shouldInitiateSearch {
    NSLog(@"Initiating search");
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardDidShow:)
                   name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide:)
                   name:UIKeyboardWillHideNotification object:nil];
    
    [UIView animateWithDuration:0.48
                          delay:0.2
         usingSpringWithDamping:0.7
          initialSpringVelocity: 0.2
                        options:(NSInteger)UIViewAnimationCurveEaseInOut animations:^{
        for (UIView *i in mainScrollView.subviews){
            if([i isKindOfClass:[UILabel class]]){
                UILabel *newLbl = (UILabel *)i;
                newLbl.alpha=0;
            }
        }
        for (UIView *i in mainScrollView.subviews){
            if([i isKindOfClass:[UIView class]]){
                UIView *newView = (UIView *)i;
                if (newView.tag==4) {
                    newView.frame=CGRectMake(20, 40, [UIScreen mainScreen].bounds.size.width-120, 60);
                }
            }
        }
        
    } completion:^(BOOL finished){
        searchTextField.frame=CGRectMake(searchTextField.frame.origin.x, searchTextField.frame.origin.y, [UIScreen mainScreen].bounds.size.width-180, searchTextField.frame.size.height);
        searchTextField.text=@"";
        UIButton *cancelButton=[UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame=CGRectMake(searchTextField.frame.origin.x+searchTextField.frame.size.width+20, 40, [UIScreen mainScreen].bounds.size.width-(searchTextField.frame.origin.x+searchTextField.frame.size.width+10)-20, 60);
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        cancelButton.titleLabel.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-Bold" size:21];
        [cancelButton addTarget:self action:@selector(didAbortSearch) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setTitleColor:backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.15 alpha:0.9] : [UIColor colorWithHue:0 saturation:0 brightness:.88 alpha:0.95] forState:UIControlStateNormal];
        cancelButton.tag=10;
        [mainScrollView addSubview:cancelButton];
        searchTextField.clearButtonMode=UITextFieldViewModeAlways;
        searchTextField.clearsOnBeginEditing=NO;
    }];
    
}

-(void)didAbortSearch {
    NSLog(@"Aborting Search");
    searchTextField.clearButtonMode=UITextFieldViewModeNever;
    [searchResults removeFromSuperview];
    [searchTextField resignFirstResponder];
    searchResults=nil;
    performedFirstSearch=NO;
    for (UIView *i in mainScrollView.subviews){
        if(i.tag==10){
            [i removeFromSuperview];
        }
    }
    
    [UIView animateWithDuration:0.48
                          delay:0.2
         usingSpringWithDamping:0.7
          initialSpringVelocity: 0.2
                        options:(NSInteger)UIViewAnimationCurveEaseInOut animations:^{
        [UIView animateWithDuration:0.5 delay:0.27 options:UIViewAnimationOptionCurveEaseIn animations:^{
            for (UIView *i in mainScrollView.subviews){
                if([i isKindOfClass:[UILabel class]]){
                    UILabel *newLbl = (UILabel *)i;
                    newLbl.alpha=1.0;
                }
            }
        } completion:^(BOOL finished){
            
        }];
        searchTextField.frame=CGRectMake(60, 0, [UIScreen mainScreen].bounds.size.width-120, 60);
        
        for (UIView *i in mainScrollView.subviews){
            if([i isKindOfClass:[UIView class]]){
                UIView *newView = (UIView *)i;
                if (newView.tag==4) {
                    newView.frame=CGRectMake(20, [UIScreen mainScreen].bounds.size.height-80, [UIScreen mainScreen].bounds.size.width-40, 60);
                }
            }
        }
    } completion:^(BOOL finished){
        
    }];
}


- (void)keyboardDidShow:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSLog(@"size %@",NSStringFromCGSize(kbSize));
    keyboardSize=kbSize;
    [self initSearchResultsTableView];
}

-(void)keyboardWillHide:(NSNotification *)aNotification {
    keyboardSize=CGSizeMake(0, 0);
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [UIView animateWithDuration:0.48 animations:^{
        searchResults.frame=CGRectMake(20, 120, [UIScreen mainScreen].bounds.size.width-40, [UIScreen mainScreen].bounds.size.height-140);
    } completion:^(BOOL finished){
       
    }];
    
    return YES;
}


-(void)initSearchResultsTableView {
    if (performedFirstSearch) {
        searchResults.frame=CGRectMake(20, 120, [UIScreen mainScreen].bounds.size.width-40, [UIScreen mainScreen].bounds.size.height-120-keyboardSize.height);
        [self updateSearchResults];
        
        return;
    } else {
        performedFirstSearch=YES;
    }
    if (!searchResults) {
        NSLog(@"Keyboard frame: %@",NSStringFromCGSize(keyboardSize));
        if (keyboardSize.width==0) {
            NSLog(@"Couldn't get keyboard size. Aborting.");
            return;
        }
        searchResults=[[UITableView alloc]initWithFrame:CGRectMake(20, 120, [UIScreen mainScreen].bounds.size.width-40, [UIScreen mainScreen].bounds.size.height-120-keyboardSize.height) style:UITableViewStylePlain];
        [searchResults setDataSource:self];
        [searchResults setDelegate:self];
        searchResults.backgroundView=nil;
        [searchResults setSeparatorInset:UIEdgeInsetsMake(0, 70, 0, 0)];
        searchResults.backgroundColor=[UIColor clearColor];
        searchResults.separatorColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.1 alpha:0.9] : [UIColor colorWithHue:0 saturation:0 brightness:.94 alpha:0.95];
        
        [self.view addSubview:searchResults];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([searchArray count]>0) {
        searchResults.hidden=NO;
    } else {
        searchResults.hidden=YES;
    }
    return searchArray.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];

    cell.backgroundView=nil;
    
    cell.contentView.backgroundColor=[UIColor clearColor];

    UILabel *nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(70, 0, cell.frame.size.width-65, 32)];
    nameLabel.textColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.05 alpha:1] : [UIColor colorWithHue:0 saturation:0 brightness:.95 alpha:1];
    
    nameLabel.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-Regular" size:23];
    nameLabel.tag=5;
    
    if (noSearchResults) {
        nameLabel.text=@"";
        [cell addSubview:nameLabel];
        cell.backgroundColor=[UIColor clearColor];
        return cell;
    }
    cell.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:1.0 alpha:0.2] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];

    
    [cell addSubview:nameLabel];
    
    UILabel *descLabel=[[UILabel alloc]initWithFrame:CGRectMake(70, 32, cell.frame.size.width-65, 28)];

    descLabel.textColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.05 alpha:1] : [UIColor colorWithHue:0 saturation:0 brightness:.95 alpha:1];
    descLabel.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-Thin" size:17.5];
    descLabel.tag=6;
    [cell addSubview:descLabel];
    
    UIImage *categoryIcon=[UIImage imageNamed:@"PlaceholderCategoryIcon"];
    UIImageView *categoryImageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 50, 50)];
    categoryImageView.image=categoryIcon;
    categoryImageView.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.08] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
    [cell addSubview:categoryImageView];
    
    NSString* name = searchArray[indexPath.row][@"name"];
    NSString* package = searchArray[indexPath.row][@"package"];
    NSString* description = searchArray[indexPath.row][@"description"];
    if ((id)name != [NSNull null]) {
        nameLabel.text = name;
    }
    else if ((id)package != [NSNull null]) {
        nameLabel.text = package;
    }
    if ((id)description != [NSNull null]) {
        descLabel.text = description;
    }

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (keyboardSize.height>0)
        [self textFieldShouldReturn:searchTextField];
    

    
    PackageDetailsViewController *PDVC=[[PackageDetailsViewController alloc]init];
    
    self.animationController = [[ZoomAnimationController alloc] init];
    
    PDVC.transitioningDelegate  = self;
    
    PDVC.packageName = searchArray[indexPath.row][@"package"];
    PDVC.backgroundIsLightStyle=backgroundIsLightStyle;
    for (UIView *i in self.view.subviews){
        if(i.tag==9){
            UIView *newLbl = (UIView *)i;
            [newLbl removeFromSuperview];
        }
    }

    [self presentViewController:PDVC animated:YES completion:nil];
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


@end
