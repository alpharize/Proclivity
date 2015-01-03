//
//  ManageReposViewController.m
//  Proclivity
//
//  Created by David Yu on 30/12/2014.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import "ManageReposViewController.h"

@interface ManageReposViewController ()

@end

@implementation ManageReposViewController {
    UITableView *reposTableView;
    NSArray *standardRepos;
}

@synthesize  backgroundIsLightStyle;

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
    
    
    reposTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 65, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-65) style:UITableViewStyleGrouped];
    [reposTableView setDataSource:self];
    [reposTableView setDelegate:self];
    reposTableView.backgroundView=nil;
    [reposTableView setSeparatorInset:UIEdgeInsetsMake(0, 50, 0, 0)];
    reposTableView.backgroundColor=[UIColor clearColor];
    reposTableView.separatorColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.1 alpha:0.9] : [UIColor colorWithHue:0 saturation:0 brightness:.94 alpha:0.95];
    
    [self.view addSubview:reposTableView];
    
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
    
    //get repos
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    standardRepos=[defaults valueForKey:@"standardRepos"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissSelf {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
// number of section(s), now I assume there is only 1 section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 2;
}

// number of row in the section, I assume there is only 1 row
- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 4;
            break;
        case 1:
            return 2;
            break;
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"Official Package Sources";
            break;
        case 1:
            sectionName = @"Custom Package Sources";
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"";
            break;
        case 1:
            sectionName = @"Installing packages from unofficial sources might cause damage to your device. Use this option only with sources that are trustworthy";
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

// the cell will be returned to the tableView
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SettingsCell";
    
    // Similar to UITableViewCell, but
    UITableViewCell *cell = [reposTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    // Just want to test, so I hardcode the data
    cell.textLabel.text=@"http://here.is.a.repo/";
    cell.contentView.backgroundColor=[UIColor clearColor];
    cell.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:1.0 alpha:0.2] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
    
    
    cell.textLabel.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-Bold" size:24.5];
    cell.textLabel.textColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.05 alpha:1] : [UIColor colorWithHue:0 saturation:0 brightness:.95 alpha:1];

    
    if (indexPath.section==0) {
        cell.textLabel.text=standardRepos[indexPath.row];
    }
    
    return cell;
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
