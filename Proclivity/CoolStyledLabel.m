//
//  KJCStyledLabel.m
//  BetterRIP
//
//  Created by David Yu on 23/12/2014.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import "CoolStyledLabel.h"

@implementation CoolStyledLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+(UILabel *)labelWithLightStyle:(BOOL)usesLightStyle labelType:(NSInteger)type frame:(CGRect)frame text:(NSString *)text {
    UILabel *aLabel=[[UILabel alloc]initWithFrame:frame];
    aLabel.text=[@"\t"stringByAppendingString:text];
    aLabel.backgroundColor=usesLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:1.0 alpha:0.2] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];

    //aLabel.backgroundColor=usesLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.1] : [UIColor colorWithHue:0 saturation:0 brightness:.25 alpha:0.25];
    if (type==0) {
        aLabel.textColor=usesLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.05 alpha:1] : [UIColor colorWithHue:0 saturation:0 brightness:.95 alpha:1];
        aLabel.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-Bold" size:24.5];
        return aLabel;
    }
    if (type==1) {
        aLabel.textColor=usesLightStyle ? [UIColor colorWithHue:0 saturation:0 brightness:.05 alpha:1] : [UIColor colorWithHue:0 saturation:0 brightness:.95 alpha:1];
        aLabel.font=[UIFont fontWithName:@".HelveticaNeueDeskInterface-Regular" size:22.5];
        return aLabel;
    }
    
    return nil;
}

@end
