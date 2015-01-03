//
//  RepoManager.m
//  Proclivity


#import "RepoManager.h"
#import "JGDownloadOperation.h"
#import "PackageManager.h"


@implementation Repo {
    NSString* _repoURL;
    NSString* _rootDomain;
    NSString* _releaseURL;
    NSString* _packagesURL;
    FMDatabase* _db;

}
-(FMDatabase*) getDB {
    if (_db != nil) {
        return _db;
    }
    _db = [[FMDatabase alloc] initWithPath:[@"/var/lib/Proclivity/" stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", [self rootDomain]]]];
    return _db;
}

-(NSString*)getPackagesURL {
    if (_packagesURL != nil) {
        return _packagesURL;
    }
    _packagesURL = [NSString stringWithFormat:@"%@/%@", self.url, self.packagesLocation];
    return _packagesURL;
}

-(NSString*)getRepoURL {
    if (_repoURL != nil) {
        return _repoURL;
    }
    if (self.dist == nil) {
        return self.url;
    }
    _repoURL = [NSString stringWithFormat:@"%@/dists/%@/", self.url, self.dist];
    return _repoURL;
}

-(NSString*)getReleaseURL {
    if (_releaseURL != nil) {
        return _releaseURL;
    }
    _releaseURL = [NSString stringWithFormat:@"%@/%@", self.url, self.releaseFile];
    return _releaseURL;
}

-(NSString*)rootDomain {
    if (_rootDomain != nil) {
        return _rootDomain;
    }
    
    // Convert the string to an NSURL to take advantage of NSURL's parsing abilities.
    NSURL * url = [NSURL URLWithString:self.url];
    
    // Get the host, e.g. "secure.twitter.com"
    NSString * host = [url host];
    
    // Separate the host into its constituent components, e.g. [@"secure", @"twitter", @"com"]
    NSArray * hostComponents = [host componentsSeparatedByString:@"."];
    if ([hostComponents count] >=2) {
        // Create a string out of the last two components in the host name, e.g. @"twitter" and @"com"
        _rootDomain = [NSString stringWithFormat:@"%@.%@", [hostComponents objectAtIndex:([hostComponents count] - 2)], [hostComponents objectAtIndex:([hostComponents count] - 1)]];
    }
    return _rootDomain;
}

@end

@implementation RepoManager {
    NSMutableArray* repos;
}

static dispatch_once_t repoManager_dispatch = 0;

+ (RepoManager*) sharedInstance
{
    static RepoManager *sharedRepoManager = nil;
    dispatch_once(&repoManager_dispatch, ^{
        sharedRepoManager = [[RepoManager alloc] init];
    });
    
    return sharedRepoManager;
}

-(id)init {
    self = [super init];
    
    if (self)
    {
        NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/etc/apt/sources.list.d" error:nil];
        repos = [NSMutableArray new];
        for (NSString* file in directoryContents) {
            NSLog(@"file %@", file);
            if ([file hasPrefix:@".list"]) {
                [self parseSources:file];
            }
        }
        
        for (Repo* r in repos) {
            NSLog(@"url %@", [r getRepoURL]);
            [self fetchRepo:r];
        }
        
        
    }
    return self;
}

-(void)fetchRepo:(Repo*) repo {
    
}


-(void)releaseDownloadComplete:(Repo*) repo{
    FILE *fp = fopen([repo.releaseFile UTF8String], "r");
    char * _line = NULL;
    size_t len = 0;
    ssize_t read;
    while ((read = getline(&_line, &len, fp)) != -1) {
        NSString* line = [[NSString stringWithUTF8String:_line] lowercaseString];
        if ([line hasPrefix:@"Packages"]) {
            NSArray* arr = [line componentsSeparatedByString:@" "];
            NSString* packagesFile = [arr lastObject];
            repo.packagesLocation = packagesFile;
            
            break;
        }
    }
}

-(void)packagesDownloadComplete:(Repo*) repo{
    [[PackageManager sharedInstance] loadDatabase:repo.packagesFile withDB:(__bridge sqlite3 *)([repo getDB])];
}


-(JGDownloadOperation*)createDownloadPackagesOperation:(Repo*) repo {
    NSString *file = [NSTemporaryDirectory() stringByAppendingPathComponent:[repo rootDomain]];
    
    NSString* url = [repo getReleaseURL];
    
    NSURL* URL = [[NSURL alloc] initWithString:url];
    NSLog(@"going to download packages %@", url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    JGDownloadOperation *operation = [[JGDownloadOperation alloc] initWithRequest:request destinationPath:file allowResume:YES];
    
    [operation setMaximumNumberOfConnections:4];
    [operation setRetryCount:3];
    
    __block CFTimeInterval started;
    
    [operation setCompletionBlockWithSuccess:^(JGDownloadOperation *operation) {
        /*unsigned long long packageSize = d.getPackage.size;
         if (operation.contentLength != packageSize) {
         NSLog(@"warning: size mismatch");
         }*/
        
        double kbLength = (double)operation.contentLength/1024.0f;
        CFTimeInterval delta = CFAbsoluteTimeGetCurrent()-started;
        NSLog(@"Success! Downloading %@ %.2f MB took %.1f seconds, average Speed: %.2f kb/s", [repo rootDomain], kbLength/1024.0f, delta, kbLength/delta);
        
    } failure:^(JGDownloadOperation *operation, NSError *error) {
        NSLog(@"Operation Failed: %@", error.localizedDescription);
    }];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, unsigned long long totalBytesReadThisSession, unsigned long long totalBytesWritten, unsigned long long totalBytesExpectedToRead, NSUInteger tag) {
        CFTimeInterval delta = CFAbsoluteTimeGetCurrent()-started;
        //NSLog(@"Progress [%@]: %.2f%% Average Speed: %.2f kB/s", d.getPackage.package, ((double)totalBytesWritten/(double)totalBytesExpectedToRead)*100.0f, totalBytesReadThisSession/1024.0f/delta);
    }];
    
    [operation setOperationStartedBlock:^(NSUInteger tag, unsigned long long totalBytesExpectedToRead) {
        started = CFAbsoluteTimeGetCurrent();
        NSLog(@"Beginning to download %@ to %@", [repo rootDomain], file);
    }];
    
    return operation;
}



-(JGDownloadOperation*)createDownloadReleaseOperation:(Repo*) repo {
    NSString *file = [NSTemporaryDirectory() stringByAppendingPathComponent:[repo rootDomain]];
    
    NSString* url = [repo getRepoURL];
    
    NSURL* URL = [[NSURL alloc] initWithString:url];
    NSLog(@"going to download %@", url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    JGDownloadOperation *operation = [[JGDownloadOperation alloc] initWithRequest:request destinationPath:file allowResume:YES];
    
    [operation setMaximumNumberOfConnections:4];
    [operation setRetryCount:3];
    
    __block CFTimeInterval started;
    
    [operation setCompletionBlockWithSuccess:^(JGDownloadOperation *operation) {
        /*unsigned long long packageSize = d.getPackage.size;
        if (operation.contentLength != packageSize) {
            NSLog(@"warning: size mismatch");
        }*/
#warning todo: implement hash checks
        double kbLength = (double)operation.contentLength/1024.0f;
        CFTimeInterval delta = CFAbsoluteTimeGetCurrent()-started;
        NSLog(@"Success! Downloading %@ %.2f MB took %.1f seconds, average Speed: %.2f kb/s", [repo rootDomain], kbLength/1024.0f, delta, kbLength/delta);
        
        repo.releaseFile = file;
        
        [self releaseDownloadComplete:repo];
        
    } failure:^(JGDownloadOperation *operation, NSError *error) {
        NSLog(@"Operation Failed: %@", error.localizedDescription);
    }];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, unsigned long long totalBytesReadThisSession, unsigned long long totalBytesWritten, unsigned long long totalBytesExpectedToRead, NSUInteger tag) {
        CFTimeInterval delta = CFAbsoluteTimeGetCurrent()-started;
        //NSLog(@"Progress [%@]: %.2f%% Average Speed: %.2f kB/s", d.getPackage.package, ((double)totalBytesWritten/(double)totalBytesExpectedToRead)*100.0f, totalBytesReadThisSession/1024.0f/delta);
    }];
    
    [operation setOperationStartedBlock:^(NSUInteger tag, unsigned long long totalBytesExpectedToRead) {
        started = CFAbsoluteTimeGetCurrent();
        NSLog(@"Beginning to download %@ to %@", [repo rootDomain], file);
    }];
    
    return operation;
}

-(void)parseSources:(NSString*) file {
    FILE *fp = fopen([[[NSBundle mainBundle] pathForResource:@"dpkg" ofType:@"status"] UTF8String], "r");
    char * _line = NULL;
    size_t len = 0;
    ssize_t read;
    while ((read = getline(&_line, &len, fp)) != -1) {
        NSString* line = [[NSString stringWithUTF8String:_line] lowercaseString];
        if (![line hasPrefix:@"deb"]) {
            continue;
        }
        NSArray* arr = [line componentsSeparatedByString:@" "];
        if (arr.count < 3) {
            NSLog(@"error: malformed repo string %@", line);
            continue;
        }
        //deb http://apt.saurik.com/dists/ios/1141.14 main
        Repo* repo = [Repo new];
        repo.url = arr[1];
        repo.dist = arr[2];
        if ([repo.dist isEqualToString:@"./"]) {
            repo.dist = nil;
        }
        [repos addObject:repo];
    }
}
@end
