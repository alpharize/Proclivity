//
//  KJCStyledLabel.h
//  BetterRIP
//
//  Created by David Yu on 23/12/2014.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoolStyledLabel : NSObject

+(UILabel *)labelWithLightStyle:(BOOL)usesLightStyle labelType:(NSInteger)type frame:(CGRect)frame text:(NSString *)text;

@end
