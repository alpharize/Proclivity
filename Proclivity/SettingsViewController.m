//
//  SettingsViewController.m
//  BetterRIP
//
//  Created by David Yu on 28/12/2014.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsTableViewCell.h"
#import "ManageReposViewController.h"
#import "ZoomAnimationController.h"
#import "PackageManager.h"
#import "FeedbackViewController.h"

@interface SettingsViewController ()

@property (nonatomic, strong) id<ADVAnimationController> animationController;
@property UIRefreshControl *refreshControl;
@property UILabel *refreshLabel;

@property UITableView *settingsTV;

@end

@implementation SettingsViewController

@synthesize backgroundIsLightStyle;
@synthesize settingsTV;
@synthesize refreshLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Fake NavBar (Better Navbar anyone?!)
    //5px padding
    UIView *navBox  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 65)];
    navBox.backgroundColor = backgroundIsLightStyle ? [UIColor colorWithWhite:1.0 alpha:0.2] : [UIColor colorWithWhite:0.20 alpha:0.4];
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

    
    settingsTV=[[UITableView alloc]initWithFrame:CGRectMake(0, 65, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-65) style:UITableViewStyleGrouped];
    [settingsTV setDataSource:self];
    [settingsTV setDelegate:self];
    settingsTV.backgroundView=nil;
    [settingsTV setSeparatorInset:UIEdgeInsetsMake(0, 50, 0, 0)];
    settingsTV.backgroundColor=[UIColor clearColor];
    settingsTV.separatorColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.1 alpha:0.9] : [UIColor colorWithHue:0 saturation:0 brightness:.94 alpha:0.95];
    
    [self.view addSubview:settingsTV];
    
    
    // Install button
    UIButton *installButton=[UIButton buttonWithType:UIButtonTypeCustom];
    installButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-140, 22,120, 40);
    [installButton setTitle:@"Done" forState:UIControlStateNormal];
    installButton.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueDeskInterface-MediumP4" size:21];
    //installButton.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.08] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
    installButton.backgroundColor=[UIColor clearColor];
    [installButton setTitleColor:backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.15 alpha:0.9] : [UIColor colorWithHue:0 saturation:0 brightness:.88 alpha:0.95] forState:UIControlStateNormal];
    [installButton addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    installButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
    [self.view addSubview:installButton];
    [self.view bringSubviewToFront:installButton];
    
    // Pull 2 Refresh
    
    NSDictionary *refreshControlTextAttributes =@{NSFontAttributeName:[UIFont fontWithName:@".HelveticaNeueDeskInterface-Regular" size:20],
                                               NSForegroundColorAttributeName:backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.1 alpha:.9] : [UIColor colorWithHue:0 saturation:0 brightness:.9 alpha:.9]
                                               };
    
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    
    //self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = backgroundIsLightStyle ? [UIColor blackColor] : [UIColor whiteColor];
    self.refreshControl.attributedTitle=[[NSAttributedString alloc]initWithString:@"Keep pulling to refresh" attributes:refreshControlTextAttributes];
    [self.refreshControl addTarget:self
                            action:@selector(refreshPackages)
                  forControlEvents:UIControlEventValueChanged];

    
    [settingsTV addSubview:self.refreshControl];
    
    // Pull 2 Refresh Label
    refreshLabel=[[UILabel alloc]initWithFrame:CGRectMake(0,75,settingsTV.bounds.size.width,20)];
    refreshLabel.backgroundColor=[UIColor clearColor];
    refreshLabel.textColor = backgroundIsLightStyle ? [UIColor colorWithWhite:0.15 alpha:0.9] : [UIColor colorWithWhite:0.9 alpha:0.8];
    refreshLabel.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-Regular" size:14];
    refreshLabel.text=@"↓ Pull To Refresh Packages Manually ↓";
    refreshLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:refreshLabel];
    [self.view bringSubviewToFront:refreshLabel];
}



-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    
    if(translation.y > 0)
    {
        refreshLabel.hidden=YES;
    } else
    {
        refreshLabel.hidden=YES;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float scrollOffset = scrollView.contentOffset.y;
    NSLog(@"offest: %f",scrollOffset);
    if (!self.refreshControl.refreshing) {
        refreshLabel.hidden=NO;
    }
    if (scrollOffset == 0)
    {
        refreshLabel.hidden=NO;
    }
}

-(void)refreshPackages {
    
    NSLog(@"User wants to refresh packages manually");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(packagesRefreshDidComplete)
                                                 name:@"APRRefreshDidCompleteNotification" object:nil];
    
    NSDictionary *refreshControlTextAttributes =@{NSFontAttributeName:[UIFont fontWithName:@".HelveticaNeueDeskInterface-Regular" size:20],
                                                  NSForegroundColorAttributeName:backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.1 alpha:.9] : [UIColor colorWithHue:0 saturation:0 brightness:.9 alpha:.9]
                                                  };
    

    self.refreshControl.attributedTitle=[[NSAttributedString alloc]initWithString:@"Downloading new package information" attributes:refreshControlTextAttributes];

    
    [[PackageManager sharedInstance]refreshPackages];
}

-(void)packagesRefreshDidComplete {
    NSLog(@"We're complete");
    [[PackageManager sharedInstance] saveSearchCache];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        refreshLabel.hidden=NO;
    });
    [self.refreshControl endRefreshing];
}

-(void)dismissSelf {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
// number of section(s), now I assume there is only 1 section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 5;
}

// number of row in the section, I assume there is only 1 row
- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 1;
            break;
        case 4:
            return 2;
            break;
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0) {
        return 60;
    }
    return 45;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"";
            break;
        case 1:
            sectionName = NSLocalizedString(@"Downloading Updates",@"DOWNLOAD_UPDATES_SECTION_HEADER");
            break;
        case 2:
            sectionName = NSLocalizedString(@"Package Information",@"PACKAGE_INFORMATION_SECTION_HEADER");
            break;
        case 3:
            sectionName = NSLocalizedString(@"Filter Packages",@"FILTER_PACKAGES_SECTION_HEADER");
            break;
        case 4:
            sectionName = NSLocalizedString(@"Obtaining Packages",@"FILTER_PACKAGES_SECTION_HEADER");
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, settingsTV.bounds.size.width, 35)];
    //[headerView setBackgroundColor:[UIColor redColor]];
    
    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(settingsTV.separatorInset.left,0,settingsTV.bounds.size.width-70,35)];
    tempLabel.backgroundColor=[UIColor clearColor];
    tempLabel.textColor = backgroundIsLightStyle ? [UIColor colorWithWhite:0.15 alpha:0.9] : [UIColor colorWithWhite:0.9 alpha:0.8];
    tempLabel.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-Regular" size:15];
    
    NSString *key = nil;
    if ([tableView isEqual:settingsTV])
    {
        key = [self tableView:settingsTV titleForHeaderInSection:section];
    }
    else{
        NSLog(@"Uh oh, not the right tableview");
    }
    
    tempLabel.text=[key uppercaseString];
    [headerView addSubview:tempLabel];
    
    //headerView.backgroundColor=[UIColor purpleColor];
    NSLog(@"Header view frame for section: %@ %ld",NSStringFromCGRect(headerView.frame),(long)section);
    
    return headerView;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"";
            break;
        case 1:
            sectionName = NSLocalizedString(@"If you have a fast internet connection, choose \"Download All Packages\". This option requires downloading more data, but uses less time to process the downloaded data. If you have a slow internet connection, choose \"Download New Packages\". This option requires more loading time on the device, but initiates a smaller download.",@"DOWNLOAD_UPDATES_SECTION_HEADER");
            break;
        case 2:
            sectionName = NSLocalizedString(@"Optimizing the package description attempts to change the style of package descriptions to be in accord with Proclivity Design Language.",@"PACKAGE_INFORMATION_SECTION_HEADER");
            break;
        case 3:
            sectionName = NSLocalizedString(@"You may choose which packages appear. Advanced and Developer packages might damage your device when used improperly.",@"FILTER_PACKAGES_SECTION_HEADER");
            break;
        case 4:
            sectionName = NSLocalizedString(@"Configure where Proclivity downloads packages from",@"FILTER_PACKAGES_SECTION_HEADER");
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 35;
            break;
        case 1:
            return 110;
            break;
        case 2:
            return 65;
            break;
        case 3:
            return 65;
            break;
        case 4:
            return 40;
            break;
            
        default:
            return 35;
            break;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, settingsTV.bounds.size.width, [self tableView:settingsTV heightForFooterInSection:section])];
    //[headerView setBackgroundColor:[UIColor redColor]];
    
    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(settingsTV.separatorInset.left,0,settingsTV.bounds.size.width-70,[self tableView:settingsTV heightForFooterInSection:section])];
    tempLabel.backgroundColor=[UIColor clearColor];
    tempLabel.textColor = backgroundIsLightStyle ? [UIColor colorWithWhite:0.15 alpha:0.9] : [UIColor colorWithWhite:0.65 alpha:0.8];
    tempLabel.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-Regular" size:12.5];
    NSString *key = nil;
    if ([tableView isEqual:settingsTV])
    {
        key = [self tableView:settingsTV titleForFooterInSection:section];
    }
    else{
        NSLog(@"Uh oh, not the right tableview");
    }
    
    tempLabel.text=key;
    tempLabel.numberOfLines=10;
    
    [footerView addSubview:tempLabel];
    
    //headerView.backgroundColor=[UIColor purpleColor];
    NSLog(@"Footer view frame for section: %@ %ld",NSStringFromCGRect(footerView.frame),(long)section);
    
    return footerView;

}

// the cell will be returned to the tableView
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SettingsCell";
    
    // Similar to UITableViewCell, but
    UITableViewCell *cell = [settingsTV dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    // Just want to test, so I hardcode the data
    
    SettingsTableViewCell *settingsCell=[[SettingsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    settingsCell.backgroundIsLightStyle=backgroundIsLightStyle;
    if (indexPath.section==1) {
        settingsCell.updateOptionCheckedCellZero=YES; // change this to use userdefaults
    }
    
    return [settingsCell cellForSection:indexPath.section row:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [settingsTV deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section!=4) {
        return;
    }
    
    ManageReposViewController *MRVC=[[ManageReposViewController alloc]init];
    self.animationController = [[ZoomAnimationController alloc] init];
    
    MRVC.transitioningDelegate  = self;
    
    MRVC.backgroundIsLightStyle=backgroundIsLightStyle;
    for (UIView *i in self.view.subviews){
        if(i.tag==9){
            UIView *newLbl = (UIView *)i;
            [newLbl removeFromSuperview];
        }
    }
    
    if (indexPath.row==0) {
        [self presentViewController:MRVC animated:YES completion:nil];
    } else {
        FeedbackViewController *fbvc=[[FeedbackViewController alloc]init];
        fbvc.backgroundIsLightStyle=backgroundIsLightStyle;
        fbvc.transitioningDelegate=self;
        [self presentViewController:fbvc animated:YES completion:nil];
    }
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
