//
//  DependencyResult.m
//  BetterRIP
//
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import "DependencyResult.h"

@implementation DependencyResult

-(id)init {
    self = [super init];
    
    if (self)
    {
        self.dependencies = [NSMutableDictionary new];
    }
    return self;
}

@end