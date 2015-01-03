//
//  Dependency.h
//  BetterRIP
//
//  Created by Terence Tan on 21/12/14.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Package.h"
#import "DependencyResult.h"

@class DependencyResult;

@interface Dependency : NSObject

@property (nonatomic, strong) NSString* minumumVersion;
@property (nonatomic, strong) NSString* equalsVersion;
@property (nonatomic, strong) NSString* maximumVersion;
@property (nonatomic, strong) NSString* packageName;
@property (nonatomic) int level;
@property (nonatomic, strong) NSMutableArray* alternatives;

@property (nonatomic) BOOL missing;

@property (nonatomic, strong) NSString* downloadLocation;

-(Dependency*)initWithPackage:(NSString*)packageName;
-(Package*) getPackage;
-(DependencyResult*) getDependencyTree:(int)level;
-(BOOL)requiresInstallation;
-(BOOL)installable;
-(id)initWithPackageObject:(Package*)package;
-(NSString*)description;
@end




