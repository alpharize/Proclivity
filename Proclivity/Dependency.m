//
//  Dependency.m
//  BetterRIP
//
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import "Dependency.h"
#import "PackageManager.h"


@interface NSString (ReplaceExtensions)
-(NSString*)stringByReplacingStringsFromArray:(NSArray*)array;
@end

@implementation NSString (ReplaceExtensions)
-(NSString*)stringByReplacingStringsFromArray:(NSArray*)array
{
    NSMutableString *string = self.mutableCopy;
    for(NSString *key in array)
        [string replaceOccurrencesOfString:key withString:@"" options:0 range:NSMakeRange(0, string.length)];
    return string.copy;
}
@end

@implementation Dependency {
    Package* _package;
}

static dispatch_once_t onceToken = 0;

+ (NSMutableDictionary*)packageCache {
    static NSMutableDictionary *cacheInstance= nil;
    dispatch_once(&onceToken, ^{
        cacheInstance = [NSMutableDictionary new];
    });
    return cacheInstance;
}

+ (NSArray *)stuffToStrip
{
    static NSArray *names;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        names = @[@".", @"-", @"_"];
    });
    
    return names;
}

-(id)init {
    self = [super init];
    
    if (self)
    {
        self.alternatives = [NSMutableArray new];
    }
    return self;
}


-(id)initWithPackage:(NSString*)packageName {
    self = [super init];
    
    if (self)
    {
        self.alternatives = [NSMutableArray new];
        self.packageName = packageName;
    }
    return self;
}
-(id)initWithPackageObject:(Package*)package {
    self = [super init];
    
    if (self)
    {
        self.alternatives = [NSMutableArray new];
        _package = package;
        self.packageName = _package.package;
    }
    return self;
}
-(BOOL)installed {
    return [self getPackage].installed;
}
-(NSString*) installedVersion {
    return [self getPackage].installedVersion;
}
-(Package*) getPackage {
    if (_package != nil) {
        return _package;
    }
    else {
        _package = [[Dependency packageCache] objectForKey:self.packageName];
        if (_package != nil) {
            return _package;
        }
        else {
            _package =  [[PackageManager sharedInstance] findSinglePackageWithPackageName:self.packageName];
            if (_package == nil) {
                NSLog(@"Error: Unable to find unknown package, trying provides %@", self.packageName);
                _package = [[PackageManager sharedInstance] findPackageWhichProvides:self.packageName];
                if (_package == nil) {
                    NSLog(@"Error: Unable to find unknown package or provides %@", self.packageName);
                    //try installed package maybe?
                    _package = [[PackageManager sharedInstance] findSingleInstalledPackageWithPackageName:self.packageName];
                    if (_package == nil) {
                        NSLog(@"unable to find installed package for %@ uh oh", self.packageName);
                        self.missing = TRUE;
                        return nil;
                    }
                    else {
                       _package.installable = false;
                    }
                }
            }
            [[Dependency packageCache] setObject:_package forKey:self.packageName];
            self.packageName = _package.package;

        }
        
    }
    //add the installed parameters
    return _package;
}

-(int)getVersionDouble:(NSString*)string {
    return [[string stringByReplacingStringsFromArray:[Dependency stuffToStrip]] intValue];
}

-(BOOL)versionGreater:(NSString*)v1 than:(NSString*)v2 {
    int one = [self getVersionDouble:v1];
    int two = [self getVersionDouble:v2];
    NSLog(@"comparing %u > %u", one, two);
    if (one > two) {
        return YES;
    }
    return NO;
}



-(BOOL)versionSmaller:(NSString*)v1 than:(NSString*)v2 {
    int one = [self getVersionDouble:v1];
    int two = [self getVersionDouble:v2];
    NSLog(@"comparing %u < %u", one, two);

    if (one < two) {
        return YES;
    }
    return NO;
}

-(NSComparisonResult) compareVersions:(NSString*) v1 and:(NSString*)v2 {
    /*The format is: [epoch:]upstream_version[-debian_revision]
    
     epoch
     This is a single (generally small) unsigned integer. It may be omitted, in which case zero is assumed. If it is omitted then the upstream_version may not contain any colons.
     
     It is provided to allow mistakes in the version numbers of older versions of a package, and also a package's previous version numbering schemes, to be left behind.
     
     upstream_version
     This is the main part of the version number. It is usually the version number of the original ("upstream") package from which the .deb file has been made, if this is applicable. Usually this will be in the same format as that specified by the upstream author(s); however, it may need to be reformatted to fit into the package management system's format and comparison scheme.
     
     The comparison behavior of the package management system with respect to the upstream_version is described below. The upstream_version portion of the version number is mandatory.
     

    */
    NSArray* arr1 = [v1 componentsSeparatedByString:@" "];
    NSArray* arr2 = [v2 componentsSeparatedByString:@" "];
    if (([arr1 count] > 1) && ([arr2 count] > 1)) {
        int epoch1 = [(NSString*)arr1[0] intValue];
         int epoch2 = [(NSString*)arr2[0] intValue];
        if (epoch1 > epoch2) {
            return (NSComparisonResult) NSOrderedAscending;
        }
        else if (epoch1 < epoch2) {
           return (NSComparisonResult) NSOrderedDescending;
        }
        else {
            v1 = arr1[1];
            v2 = arr2[1];
            NSLog(@"epoch is equal, continuing with other stuff");
        }
    }
    NSCharacterSet* set = [NSCharacterSet characterSetWithCharactersInString:@".+-:~"];
    arr1 = [v1 componentsSeparatedByString:@"-"];
    arr2 = [v2 componentsSeparatedByString:@"-"];
    NSString* upstream1 = arr1[0];
    NSString* upstream2 = arr2[0];
    int upstream_version1 = [[[upstream1 componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""] intValue];
    int upstream_version2 = [[[upstream2 componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""] intValue];
    NSLog(@"upstream 1 %u, upstream 2 %u", upstream_version1, upstream_version2);
    
    if (upstream_version1 > upstream_version2) {
        return (NSComparisonResult) NSOrderedAscending;
    }
    else if (upstream_version1 < upstream_version2) {
        return (NSComparisonResult) NSOrderedDescending;
    }
    else {
        //equal wtf
        NSLog(@"upstream is equal, continuing with other stuff");
    }
    
    if (([arr1 count] > 1) && ([arr2 count] > 1)) {
        //has debian-revision
        int revision1 = [arr1[1] intValue];
        int revision2 = [arr2[1] intValue];
        if (revision1> revision2) {
            return (NSComparisonResult) NSOrderedAscending;
        }
        else if (revision1 < revision2) {
            return (NSComparisonResult) NSOrderedDescending;
        }
        else {
            //equal wtf
            NSLog(@"revision is equal, so it's equal");
        }
    }
    else {
        NSLog(@"no debian revision, should be equal");
    }
    return (NSComparisonResult) NSOrderedSame;
}

-(BOOL)installable {
    /*if (self.getPackage.installable == false) {
        NSLog(@"package %@ is not installable, probably doesn't exist", self.packageName);
        return false;
    }*/
    if (self.maximumVersion != nil) {
        NSLog(@"installed version %@, max version %@", [self installedVersion], self.maximumVersion);
        
        NSComparisonResult res = [self compareVersions:[self installedVersion] and:self.maximumVersion];
        if (res == NSOrderedDescending) {
            NSLog(@"installed version greater than max version");
            return false;
        }
    }
#warning todo: implement checks on packages that cannot be modified: eg firmware
    return true;
}

-(BOOL)requiresInstallation {
    if ([self installed]) {
        NSLog(@"### PACKAGE %@ is installed, no install needed", self.packageName);
        //check version requirements
        NSLog(@"equals version %@ %@", self.equalsVersion, [self installedVersion]);
        if ([self.equalsVersion isEqualToString:[self installedVersion]]) {
            return false;
        }
        
        else if (self.minumumVersion != nil) {
            NSLog(@"installed version %@, min version %@", [self installedVersion], self.minumumVersion);
            
            NSComparisonResult res = [self compareVersions:[self installedVersion] and:self.minumumVersion];
            if (res == NSOrderedAscending) {
                NSLog(@"installed version greater than min version");
                return false;
            }
        }
        else {
            return false;
        }
    }
    return true;
}

-(DependencyResult*)getDependencyTree:(int)level {
    
    NSMutableArray *uniquePackagesName = [NSMutableArray new];
    DependencyResult* res = [[DependencyResult alloc] init];
    if ([self.packageName isEqualToString:@"firmware"]) {
        NSLog(@"um");
        res.code = success_already_installed;
        res.dependencies = nil;
        return res;
    }
    if ([self installed]) {
        res.code = success_already_installed;
        res.dependencies = nil;
        return res;
    }
    else if ([self getPackage] == nil) {
        NSLog(@"couldn't find package %@ anywhere", self.packageName);
        res.code = missing_packages;
        res.missing_dependency = self;
    }
    NSArray* primaryDependencies = [[self getPackage] getDependencies:(level+1)];
    if (primaryDependencies == nil) {
        NSLog(@"error fetching primary dependencies");
    }
    NSMutableDictionary* dependencies = [[NSMutableDictionary alloc] init];
    [dependencies setObject:self forKey:self.packageName]; //duh
    [uniquePackagesName addObject:self.packageName];
    for (Dependency* d in primaryDependencies) {
        Dependency* chosen_d;
        if (![d installable]) {
            BOOL foundAlternative = NO;
            for (Dependency* d_alt in d.alternatives) {
                if ([d_alt installable] ) {
                    [dependencies setObject:d_alt forKey:d_alt.packageName];
                    foundAlternative = YES;
                    chosen_d = d_alt;
                    break;
                }
            }
            if (!foundAlternative) {
                res.dependency_cannot_be_installed = d;
                res.code = dependencies_cannot_be_installed;
                return res;
            }
        }
        else if ([d requiresInstallation]) {
            //try find alternative
            BOOL foundAlternative = NO;
            for (Dependency* d_alt in d.alternatives) {
                NSLog(@"alternative %@", d_alt.packageName);
                if ((![d_alt requiresInstallation]) || (d.missing))  {
                    [dependencies setObject:d_alt forKey:d_alt.packageName];
                    foundAlternative = YES;
                    chosen_d = d_alt;
                    break;
                }
            }
            if (!foundAlternative) {
                NSLog(@"Could not find alternative for %@, sticking with this", [d getPackage].package);
                [dependencies setObject:d forKey:d.packageName];
                chosen_d = d;
            }
        }
        else {
            NSLog(@"dependency %@ is already installed, skipping", [d getPackage].package);
            continue;
        }
        
        
        //grab the dependency tree as well for the secondary dependencies
        NSLog(@"fetching secondary dependencies for %@ %u", [chosen_d getPackage].package, level+1);
        
        DependencyResult* secondaryDependencies = [chosen_d getDependencyTree:(level+2)];
        if (secondaryDependencies.code == success_already_installed) {
            NSLog(@"Secondary dependencies already installed, cool!");
        }
        else if (secondaryDependencies.code != success) {
            NSLog(@"error not success uh oh");
            return secondaryDependencies; //stop finding others
        }
        else {
            for (id key in secondaryDependencies.dependencies) {
                Dependency* d = [secondaryDependencies.dependencies objectForKey:key];
                if ([[dependencies allKeys] containsObject:key]) {
                    Dependency* existing_d = [dependencies objectForKey:key];
                    NSLog(@"d.level %u existing %u", d.level, existing_d.level);
                    if (d.level > existing_d.level) {
                        [dependencies setObject:d forKey:key];
                    }
                }
            }
        }
    }
    res.code = success;
    res.dependencies = dependencies;
    for (NSString* key in dependencies) {
        Dependency* d = [dependencies objectForKey:key];
        NSLog(@"wow such dependency %@ %u", d.packageName, d.level);
    }
    return res;
}

-(NSString*) description {
    return self.packageName;
}

@end
