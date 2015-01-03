//
//  BuyPackageProtocol.h
//  Proclivity
//
//  Created by David Yu on 30/12/2014.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BuyPackageProtocol : NSURLProtocol
@property (nonatomic, strong) NSURLConnection *connection;
+(BOOL) contains:(NSString*) string inArray:(NSArray*) array;
@end
