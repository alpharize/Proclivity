//
//  FeedbackViewController.m
//  Proclivity
//
//  Created by David Yu on 2/01/2015.
//  Copyright (c) 2015 Kim Jong-Cracks. All rights reserved.
//

#import "FeedbackViewController.h"

@interface FeedbackViewController ()

@end

@implementation FeedbackViewController {
    UITableView *reposTableView;
}

@synthesize backgroundIsLightStyle;

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
            return 5;
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
            sectionName = @"";
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
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text=@"Report a problem";
            break;
        case 1:
            cell.textLabel.text=@"Recommend a feature";
            break;
        case 2:
            cell.textLabel.text=@"Recommend a UI change";
            break;
        case 3:
            cell.textLabel.text=@"General enquiry";
            break;
        case 4:
            cell.textLabel.text=@"Give other feedback";
            break;
        default:
            break;
    }
    cell.contentView.backgroundColor=[UIColor clearColor];
    cell.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:1.0 alpha:0.2] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
    
    
    cell.textLabel.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-Bold" size:24.5];
    cell.textLabel.textColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.05 alpha:1] : [UIColor colorWithHue:0 saturation:0 brightness:.95 alpha:1];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showEmail:indexPath];
}

- (void)showEmail:(NSIndexPath *)indexPath {
    NSLog(@"Wants to email");
    NSString *supportEmail = @"team@alpharize.com";
    // Email Subject
    NSString *emailTitle = [NSString stringWithFormat:@"Proclivity Feedback"];
    // Email Content
    NSString *messageBody;
    switch (indexPath.row) {
        case 0:
            messageBody=@"On which device(s) and/or firmware(s) does the problem occur?\n\n\nIn which view does the problem occur?\n\n\nSteps to reproduce the problem?\n1.\n2.\n...\n\nSuggestions to fix the problem:\n\n\nAny other relevant information (e.g. crash logs)\n";
            break;
        case 1:
            messageBody=@"Enter any revelant details below:\n";
            break;
        case 2:
            messageBody=@"Which devices does the UI change apply to?\n\n\nIn which view should the UI change be introduced?\n\n\nEnter any other relevant details below:\n";
            break;
        case 3:
            messageBody=@"Enter any revelant details below:\n";
            break;
        case 4:
            messageBody=@"Feedback:\n";
            break;
        default:
            break;
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
