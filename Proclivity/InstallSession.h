//
//  InstallManager.h
//  BetterRIP
//
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Package.h"
#import "DependencyResult.h"


@protocol InstallSessionDelegate<NSObject>

@optional
- (void)downloadComplete:(Dependency*) d;
-(void)log:(NSString*)message;

@required
-(void)downloadFailed:(Dependency*) d withError:(NSString*) err;
- (void)installationComplete:(Dependency*) d;
- (void)everythingComplete:(BOOL)hasSubstrate;

- (void)installFailed:(Dependency*) d withMessage:(NSString*)err;

@end

@interface InstallSession : NSObject

@property (nonatomic) BOOL hasSubstrate;
@property (nonatomic, assign) id<InstallSessionDelegate> delegate;
-(id)initWithDependencyResult:(DependencyResult* ) res;
-(void)downloadFiles;
-(void)loadDylib;
@end


