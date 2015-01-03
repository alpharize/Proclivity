//
//  SettingsTableViewCell.h
//  BetterRIP
//
//  Created by David Yu on 28/12/2014.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewCell : UITableViewCell

@property BOOL backgroundIsLightStyle;
@property NSInteger updateOptionCheckedCellZero;

-(UITableViewCell *)cellForSection:(NSInteger)section row:(NSInteger)row;

@end
