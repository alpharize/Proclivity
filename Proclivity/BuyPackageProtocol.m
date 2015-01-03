//
//  BuyPackageProtocol.m
//  Proclivity
//
//  Created by David Yu on 30/12/2014.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import "BuyPackageProtocol.h"

@implementation BuyPackageProtocol



+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ([NSURLProtocol propertyForKey:@"UserAgentSet" inRequest:request] != nil)
        return NO;
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (void)startLoading
{
    
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    
   
    
    if ([[[self.request allHTTPHeaderFields]allKeys]containsObject:@"shouldNotOverride"]) {
        NSLog(@"Not overriding %@",self.request);
        [newRequest setValue:nil forHTTPHeaderField:@"shouldNotOverride"];
        self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
        return;
    }
    
    // Here we set the User Agent
    NSLog(@"Trying to override request %@",newRequest);
    
    [newRequest setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 8_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12B411 Safari/600.1.4 Cydia/1.1.16 CyF/1141.14" forHTTPHeaderField:@"User-Agent"];
    [newRequest setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 8_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12B411 Safari/600.1.4 Cydia/1.1.16 CyF/1141.14" forHTTPHeaderField:@"UserAgent"];

    [newRequest addValue:@"1141.16" forHTTPHeaderField:@"X-Cydia-Cf"];
    [newRequest addValue:@"iPhone7,2" forHTTPHeaderField:@"X-Machine"];
    extern CFStringRef MGCopyAnswer(CFStringRef key) WEAK_IMPORT_ATTRIBUTE;
    CFStringRef uniqueIdentifier = MGCopyAnswer(CFSTR("UniqueDeviceID"));
    NSLog(@"UDID: %@ Length: %lu",uniqueIdentifier,(unsigned long)[(__bridge NSString *)uniqueIdentifier length]);
    [newRequest addValue:(__bridge id)(uniqueIdentifier) forHTTPHeaderField:@"X-Cydia-Id"];
    [newRequest addValue:(__bridge id)(uniqueIdentifier) forHTTPHeaderField:@"X-Unique-ID"];
    
    
    [NSURLProtocol setProperty:@YES forKey:@"UserAgentSet" inRequest:newRequest];
    
    self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
}

- (void)stopLoading
{
    [self.connection cancel];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.client URLProtocol:self didFailWithError:error];
    self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.client URLProtocolDidFinishLoading:self];
    self.connection = nil;
}


@end
