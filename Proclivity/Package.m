//
//  Package.m
//  BetterRIP
//
//  Created by jk9357 on 21/12/14.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import "Package.h"
#import "Dependency.h"
#import "PackageManager.h"

@implementation Package {
    NSString* installedVersion;
}

@synthesize description;

-(id)initWithDictionary:(NSDictionary*) dict {
    self = [super init];
    
    if (self)
    {
        
        self.architecture = [dict objectForKey:@"architecture"];
        self.author = [dict objectForKey:@"author"];
        self.conflicts = [dict objectForKey:@"conflicts"];
        self.depends = [dict objectForKey:@"depends"];
        self.depiction = [dict objectForKey:@"depiction"];
        self.description = [dict objectForKey:@"description"];
        self.filename = [dict objectForKey:@"filename"];
        self.homepage = [dict objectForKey:@"homepage"];
        self.icon = [dict objectForKey:@"icon"];
        self.installed_size = [dict objectForKey:@"installed-size"];
        self.maintainer = [dict objectForKey:@"maintainer"];
        self.md5sum = [dict objectForKey:@"md5sum"];
        self.name = [dict objectForKey:@"name"];
        self.package = [dict objectForKey:@"package"];
        self.pre_depends = [dict objectForKey:@"pre-depends"];
        self.repository = [dict objectForKey:@"repository"];
        self.section = [dict objectForKey:@"section"];
        self.sponsor = [dict objectForKey:@"sponsor"];
        self.support = [dict objectForKey:@"support"];
        self.tag = [dict objectForKey:@"tag"];
        self.version = [dict objectForKey:@"version"];
        self.website = [dict objectForKey:@"website"];
        self.provides = [dict objectForKey:@"provides"];
        
        self.installable = true;
        
        self.status = [dict objectForKey:@"status"];
        
        if (![[dict objectForKey:@"size"] isKindOfClass:[NSNull class]]) {
            self.size=[dict[@"Size"]unsignedLongLongValue];
        }
        
        NSString* cachedVersion = [[PackageManager sharedInstance] getVersionForPackageInInstalledCacheLongFunctionsAreCoolTooStopTryingToClassDumpThisNotHelping:self.package];
        
        if (cachedVersion != nil) {
            NSLog(@"package appears installed parsing details");
            
            if ((id)self.status!= [NSNull null]) {
                //seems ok
                //no status, fetch installed package
               
            }
            else {
                self.status = [[PackageManager sharedInstance] getStatusForPackage:self.package];
            }
            
            NSArray* statusArray = [self.status componentsSeparatedByString:@" "];
            BOOL foundOk = false, foundInstalled = false;
            for (NSString* status in statusArray) {
                if ([status isEqualToString:@"ok"]) {
                    NSLog(@"found ok for package %@", self.package);
                    foundOk = true;
                }
                else if ([status isEqualToString:@"installed"]) {
                    NSLog(@"found installed for package %@", self.package);
                    foundInstalled = true;
                }
                if (foundOk && foundInstalled) {
                    self.installed = true;
                    self.installedVersion = cachedVersion;
                    return self;
                }
            }
           
        }
        NSLog(@"couldn't find ok & installed for package %@", self.package);
        self.installed = false;
    }
    return self;
}

-(NSArray*) getDependencies:(int)level {
    if (!level) {
        NSLog(@"Uh oh level isn't set. Returning nil");
        return nil;
    }
#warning Sometimes the app crashes here. Please fix this so it doesnt crash anymore. this is a remporary workaround. THE WORKAROUND DOESNT WORK. Test with package ayecon (iOS 7+), it crashes.
    NSLog(@"parsing dependencies: level %u", level);
    NSMutableArray* dependencies = [NSMutableArray new];
    NSCharacterSet* set = [NSCharacterSet characterSetWithCharactersInString:@"()"];
    NSMutableArray* arr = [NSMutableArray new];
    if ((id)self.depends != [NSNull null]) {
         [arr addObjectsFromArray:[[self.depends stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","]];
    }
    if ((id)self.pre_depends != [NSNull null]) {
        [arr addObjectsFromArray:[[self.pre_depends stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","]];
    }
        /* coreutils-bin,firmware(=5.0)|firmware(=5.0.1),cy+model.iphone(=2.1)|cy+model.iphone(=3.1)
         [0] coreutils-bin
         [1] firmware(=5.0)|firmware(=5.0.1)
         [2] cy+model.iphone(=2.1)|cy+model.iphone(=3.1)
         */
    for (NSString* object in arr) {
        NSLog(@"splittin comma sawg %@", object);
        NSString* packages = (NSString*) object;
        NSArray* alternativesArray = [packages componentsSeparatedByString:@"|"];
        
        /*
         [0] coreutils-bin
         [1]
         [0] firmware(=5.0)
         [1] firmware(=5.0.1)
         [2]
         [0] cy+model.iphone(=2.1)
         [1] cy+model.iphone(=3.1)
         */
        __block Dependency* main_d = nil;
        
        int alternativesIndex = 0;
        
        for (NSString* alternative in alternativesArray) {
            NSArray* versionArray = [alternative componentsSeparatedByCharactersInSet:set];
            
            /*
             [0] coreutils-bin
             [1]
             [0]
             [0] firmware
             [1] =5.0
             [1]
             [0] firmware
             [1] =5.0.1
             [2]
             [0]
             [0] cy+model.iphone
             [1] =2.1
             [1]
             [0] cy+model.iphone
             [1] =3.1
             */
            
            NSString* packageName = versionArray[0];
            if (packageName == nil) {
                NSLog(@"wtf package name is nil?");
                continue;
            }
            Dependency * d;
            d = [[Dependency alloc] initWithPackage:packageName];
            d.level = level;
            
            if ([versionArray count] > 1) {
                NSString* version = versionArray[1];
                if ([version hasPrefix:@"<<"]) {
                    d.maximumVersion = [version substringFromIndex:2];
                }
                else if ([version hasPrefix:@"<="]) {
                    d.maximumVersion = [version substringFromIndex:2];
                    d.equalsVersion = [version substringFromIndex:2];
                    
                }
                else if ([version hasPrefix:@">="]) {
                    d.minumumVersion = [version substringFromIndex:2];
                    d.equalsVersion = [version substringFromIndex:2];
                }
                else if ([version hasPrefix:@">>"]) {
                    d.minumumVersion = [version substringFromIndex:2];
                }
                else if ([version hasPrefix:@"="]) {
                    d.equalsVersion = [version substringFromIndex:1];
                }
                else {
                    NSLog(@"Error: unable to get parse unknown version string %@", version);
                    //return nil;
                }
                
            }
            
            //find package
          
            if (alternativesIndex == 0) {
                main_d = d;
                NSLog(@"found main package %@", d.packageName);
            }
            else {
                NSLog(@"adding alternative %@", d.packageName);
                [main_d.alternatives addObject:d];
            }
            alternativesIndex++;
        }
        
        /*
         main_d
         firmware
         alternatives
         tomkeywang.killkbcache
         */
        if (main_d != nil) {
            NSLog(@"Main dependency added %@", main_d.packageName);
            [dependencies addObject:main_d];
        }
        else {
            NSLog(@"error: could not find suitable dependency");
            //shouldn't ever happen
            return nil;
        }
        
    }
    
    return dependencies;
}
-(NSString*)getUsableName {
    if ((id)self.name != [NSNull null]) {
        return self.name;
    }
    else if ((id)self.package != [NSNull null]) {
        return self.package;
    }
    else {
        return @"No Name Package";
    }
}


@end

