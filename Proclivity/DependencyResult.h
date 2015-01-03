//
//  DependencyResult.h
//  BetterRIP
//
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import "Dependency.h"

@class Dependency;

@interface DependencyResult : NSObject

typedef enum {
    success,
    success_already_installed,
    missing_packages,
    dependencies_cannot_be_installed,
} DependencyResultCode;


@property (nonatomic) DependencyResultCode code;
@property (nonatomic, strong) NSMutableDictionary* dependencies;
@property (nonatomic, strong) Dependency* dependency_cannot_be_installed;
@property (nonatomic, strong) Dependency* missing_dependency;

@end
