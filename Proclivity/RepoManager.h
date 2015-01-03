//
//  RepoManager.h
//  Proclivity

//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface RepoManager : NSObject

@end

@interface Repo : NSObject

@property(nonatomic, strong) NSString* url;
@property(nonatomic, strong) NSString* dist;
@property(nonatomic, strong) NSString* releaseFile;
@property(nonatomic, strong) NSString* packagesLocation;
@property(nonatomic, strong) NSString* packagesFile;

@end
