//
//  PackageManager.h
//  BetterRIP
//
//  Created by Terence Tan on 20/12/14.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Package.h"
#import <sqlite3.h>

@interface PackageManager : NSObject

@property (nonatomic, assign) id searchResultDelegate;

//@property (nonatomic, strong)     NSString *documentsDirectory;
+ (PackageManager*) sharedInstance;
-(id)init;
-(NSArray*) findPackagesWithName:(NSString*) name;
-(void) saveSearchCache;
-(NSArray*)searchPackageCacheWithName: (NSString*) search completeSearch:(BOOL)completeSearch;
-(Package*) findSinglePackageWithPackageName:(NSString*) packageName;
-(Package*) getPackage:(NSString*) packageName;
-(Package*) findPackageWhichProvides:(NSString*)package;
-(NSArray*) prepareDependencies: (Package*) package;
-(Package*) getInstalledPackageCache:(NSString*) packageName;
-(void)updatePackageCache:(Package*)p;
-(void)updateProvidesCache:(Package*)p forPackageName:(NSString*)packageName;

-(void) loadDatabase:(NSString*)file withDB:(sqlite3*)database;

-(NSString*) getStatusForPackage:(NSString*)package;
-(Package*) findSingleInstalledPackageWithPackageName:(NSString*) packageName;
-(NSString*)getVersionForPackageInInstalledCacheLongFunctionsAreCoolTooStopTryingToClassDumpThisNotHelping:(NSString*) package;
-(void)loadInstalledPackageCache;
-(void)loadInstalledPackagesDB;

-(void)refreshPackages;

@end

@protocol SearchResultsDelegate <NSObject>

@required
- (void) insertResultRow:(NSDictionary*) result;

@end

