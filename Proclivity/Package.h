//
//  Package.h
//  BetterRIP
//
//  Created by jk9357 on 21/12/14.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Package : NSObject

//SQL
@property (nonatomic, strong) NSString* status;
@property (nonatomic, strong) NSString* architecture;
@property (nonatomic, strong) NSString* author;
@property (nonatomic, strong) NSString* conflicts;
@property (nonatomic, strong) NSString* depends;
@property (nonatomic, strong) NSString* depiction;
@property (nonatomic, strong) NSString* description;
@property (nonatomic, strong) NSString* filename;
@property (nonatomic, strong) NSString* homepage;
@property (nonatomic, strong) NSString* icon;
@property (nonatomic, strong) NSNumber* installed_size;
@property (nonatomic, strong) NSString* maintainer;
@property (nonatomic, strong) NSString* md5sum;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* package;
@property (nonatomic, strong) NSString* pre_depends;
@property (nonatomic, strong) NSString* provides;
@property (nonatomic, strong) NSString* repository;
@property (nonatomic, strong) NSString* section;
@property unsigned long long size;
@property (nonatomic, strong) NSString* sponsor;
@property (nonatomic, strong) NSString* support;
@property (nonatomic, strong) NSString* tag;
@property (nonatomic, strong) NSString* version;
@property (nonatomic, strong) NSString* website;
@property (nonatomic, strong) NSString* installedVersion;

@property (nonatomic) BOOL installed;
@property (nonatomic) BOOL installable;
//dpkg -l



-(id)initWithDictionary:(NSDictionary*) dict;
-(BOOL)packageInstallable;
-(NSString*)getUsableName;
-(NSArray*) getDependencies:(int)level;

@end



