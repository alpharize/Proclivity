//
//  SettingsTableViewCell.m
//  BetterRIP
//
//  Created by David Yu on 28/12/2014.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import "SettingsTableViewCell.h"
#import "CoolStyledLabel.h"

@implementation SettingsTableViewCell

@synthesize backgroundIsLightStyle;

- (void)awakeFromNib {
    // Initialization code
    NSLog(@"Frame: %@",NSStringFromCGRect(self.frame));
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(UITableViewCell *)returnProclivityLogoCell {
    UILabel *topLabel=[CoolStyledLabel labelWithLightStyle:backgroundIsLightStyle labelType:0 frame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60) text:@"\tProclivity Preview 1"];
    [self addSubview:topLabel];
    return self;
}

-(UITableViewCell *)returnDownloadingUpdatesCell:(NSString *)label :(BOOL)checked {
    UILabel *topLabel=[CoolStyledLabel labelWithLightStyle:backgroundIsLightStyle labelType:1 frame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 45) text:label];
    [self addSubview:topLabel];
    self.accessoryType=checked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return self;
}

-(UITableViewCell *)returnOptimizeDepictionCell {
    UILabel *topLabel=[CoolStyledLabel labelWithLightStyle:backgroundIsLightStyle labelType:1 frame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 45) text:@"Optimize Package Description"];
    [self addSubview:topLabel];
    
    UISwitch *aSwitch=[[UISwitch alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-60, 0, 60, 45)];
    aSwitch.tintColor=[UIColor blackColor];
    aSwitch.on=YES;
    [self addSubview:aSwitch];
    return self;
}

-(UITableViewCell *)returnManageSourcesCell {
    UILabel *topLabel=[CoolStyledLabel labelWithLightStyle:backgroundIsLightStyle labelType:1 frame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 45) text:@"Manage Package Sources"];
    [self addSubview:topLabel];
    self.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    return self;
}

-(UITableViewCell *)returnFilterCell {
    self.backgroundColor=backgroundIsLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:1.0 alpha:0.2] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
    UISegmentedControl *segmentedControl=[[UISegmentedControl alloc]initWithItems:@[@"User",@"Advanced",@"Developer"]];
    
    segmentedControl.frame=CGRectMake(50, 10, [UIScreen mainScreen].bounds.size.width-80, 25);
    segmentedControl.tintColor=[UIColor blackColor];
    segmentedControl.selectedSegmentIndex=2;
    [self addSubview:segmentedControl];
    return self;
}

-(UITableViewCell *)returnFeedbackCell {
    UILabel *topLabel=[CoolStyledLabel labelWithLightStyle:backgroundIsLightStyle labelType:1 frame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 45) text:@"Send Feedback"];
    [self addSubview:topLabel];
    self.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    return self;
}

-(UITableViewCell *)cellForSection:(NSInteger)section row:(NSInteger)row {
    self.contentView.backgroundColor=[UIColor clearColor];
    self.backgroundColor=[UIColor clearColor];
    NSLog(@"Returning a cell");
    switch (section) {
        case 0:
            switch (row) {
                case 0:
                    return [self returnProclivityLogoCell];
                    break;
                default:
                    return self;
                    break;
            }
            break;
        case 1:
            switch (row) {
                case 0:
                    return [self returnDownloadingUpdatesCell:@"Download All Packages": _updateOptionCheckedCellZero ? YES : NO ];
                    break;
                case 1:
                    return [self returnDownloadingUpdatesCell:@"Download Newest Packages": _updateOptionCheckedCellZero ? NO : YES ];
                    break;
                default:
                    return self;
                    break;
            }
            break;
        case 2:
            return [self returnOptimizeDepictionCell];
            break;
        case 3:
            return [self returnFilterCell];
            break;
        case 4:
            switch (row) {
                case 0:
                    return [self returnManageSourcesCell];
                    break;
                case 1:
                    return [self returnFeedbackCell];
                    break;
                    
                default:
                    return nil;
                    break;
            }
            break;
        default:
            return self;
            break;
    }
}

@end
