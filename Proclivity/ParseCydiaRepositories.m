//
//  ParseCydiaRepositories.m
//  Proclivity
//
//  Created by jk9357 on 31/12/2014.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import "ParseCydiaRepositories.h"

@implementation ParseCydiaRepositories

-(id)init {
    self = [super init];
    
    if (self)
    {
        // initialization code goes here
    }
    return self;
}

+(NSArray *)parseStandardCydiaSources {
    NSLog(@"Parsing Cydia Sources");
    NSString *sourcesString=[NSString stringWithContentsOfFile:@"/etc/apt/sources.list.d/cydia.list" encoding:NSUTF8StringEncoding error:nil];
    // For now use a test one
    sourcesString=[NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"cydia" ofType:@"list"] encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *sourcesArray=[sourcesString componentsSeparatedByString:@"\n"];
    NSMutableArray *results=[[NSMutableArray alloc]init];
    for (int i=0; i<[sourcesArray count]; i++) {
        if ([sourcesArray[i]length]==0) {
            continue;
        }
        
        NSMutableDictionary *sourceDictionary=[[NSMutableDictionary alloc]init];
        NSArray *currentSourceComponents=[sourcesArray[i]componentsSeparatedByString:@" "];
        NSString *baseURL=currentSourceComponents[1];
        [sourceDictionary setObject:baseURL forKey:@"baseURL"];
        if ([currentSourceComponents[2]isEqualToString:@"./"]) {
            [sourceDictionary setObject:baseURL forKey:@"releaseFilePrefix"];
            [sourceDictionary setObject:baseURL forKey:@"packagesFilePrefix"];
            [results addObject:sourceDictionary];
            continue;
        }
        
        baseURL=[baseURL stringByAppendingString:[NSString stringWithFormat:@"dists/%@/",currentSourceComponents[2]]];
        [sourceDictionary setObject:baseURL forKey:@"releaseFilePrefix"];
        
        
        NSString *packagesFilePrefix=[baseURL stringByAppendingString:[NSString stringWithFormat:@"%@/binary-iphoneos-arm/",currentSourceComponents[3]]];
        [sourceDictionary setObject:packagesFilePrefix forKey:@"packagesFilePrefix"];
        [results addObject:sourceDictionary];
    }
    //NSLog(@"Array: %@",results);
    return results;
}

@end
