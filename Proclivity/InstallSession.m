//
//  InstallManager.m
//  BetterRIP
//
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import "InstallSession.h"
#import "Dependency.h"
#import "JGDownloadAcceleration.h"
#import "CPDistributedMessangingCenter.h"
#import "NSTask.h"

@implementation InstallSession {
    JGOperationQueue* queue;
    NSArray* sortedDependencies;
    NSMutableArray* downloadedDependencies;
    NSMutableArray* waitingDependencies;
    int highestLevel;
    int currentLevel;
    int levelCount[3000];
    int completedLevelCount[3000];
    BOOL installInProgress;
    NSMutableDictionary* levelsDictionary;
}


-(id)initWithDependencyResult:(DependencyResult* ) res {
    self = [super init];
    
    if (self)
    {
        queue = [JGOperationQueue new];
        downloadedDependencies = [NSMutableArray new];
        queue.handleNetworkActivityIndicator = YES;
        queue.handleBackgroundTask = YES;
        
        //sort dependencies
        sortedDependencies = [[res.dependencies allValues] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            int first = [(Dependency*)a level];
            int second = [(Dependency*) b level];
            if ( first > second ) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if ( first < second ) {
                return (NSComparisonResult)NSOrderedDescending;
            } else {
                return (NSComparisonResult)NSOrderedSame;
            }
        }];
        waitingDependencies = [[NSMutableArray alloc] initWithArray:sortedDependencies];
        highestLevel = [(Dependency*)sortedDependencies[0] level];
        currentLevel = highestLevel;
        levelsDictionary = [NSMutableDictionary new];
        
        //this is stupid
        for (int i = 0; i != highestLevel; i++) {
            levelCount[i] = 0;
            completedLevelCount[i] = 0;
        }
        
        NSLog(@"Sorted dependencies %@", sortedDependencies);
        for (Dependency* d in sortedDependencies) {
            levelCount[d.level] = levelCount[d.level] + 1;
            NSLog(@"sorted %@ %u", d.packageName, d.level);
            if ([d.packageName isEqualToString:@"mobilesubstrate"]) {
                _hasSubstrate = TRUE;
                break;
            }
        }

        NSLog(@"Highest level %u", highestLevel);
    }
    return self;
}

-(void)downloadFiles {
    for (Dependency* d in sortedDependencies) {
        [queue addOperation:[self createDownloadOperationForDependency:d]];
    }
}

-(void)installDependency:(Dependency*) d updateLevel:(BOOL)updateLevel{
    NSLog(@"installing dependency %@", d.getPackage.package);
    if (installInProgress) {
        NSLog(@"another install in progress, aborting");
        return;
    }
    installInProgress = true;
    
    [self runNSTask:@[@"-i", d.downloadLocation] launchPath:@"/usr/bin/dpkg"];
    
    [waitingDependencies removeObject:d];
    
    completedLevelCount[currentLevel] = completedLevelCount[currentLevel] + 1;
    
    installInProgress = false;
    
    if (([waitingDependencies count] == 0) && ([downloadedDependencies count] == [sortedDependencies count])) {
        NSLog(@"wooot! all packages downloaded and installed");
        [self.delegate everythingComplete:_hasSubstrate];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"APRInstallDidCompleteSuccessfully" object:nil];
    }
    else if (updateLevel) {
        [self updateLevel];
    }
    
}

-(void)installEverything {
    if (installInProgress) {
        NSLog(@"another install in progress, aborting");
        while (installInProgress) {
            //wait
            sleep(1);
        }
        NSLog(@"the other install is done!");
    }
    NSMutableArray *args=[[NSMutableArray alloc]initWithObjects:@"-i", nil];
    for (Dependency* d in downloadedDependencies) {
        [args addObject:d.downloadLocation];
        
        //[self installDependency:d updateLevel:NO];
    }
    [self runNSTask:args launchPath:@"/usr/bin/dpkg"];
    installInProgress = false;
    NSLog(@"wooot! all packages downloaded and installed");
    [self.delegate everythingComplete:_hasSubstrate];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"APRInstallDidCompleteSuccessfully" object:nil];
}

-(void)updateLevel {
    //updates the level
    NSLog(@"completed for (%u): %u, total: %u", currentLevel, completedLevelCount[currentLevel], levelCount[currentLevel]);
    if (completedLevelCount[currentLevel] != levelCount[currentLevel]) {
        NSLog(@"not everything is installed, waiting");
        return;
    }
    
    currentLevel = currentLevel - 1;
    
    NSLog(@"no more dependencies waiting for old level! new level: %u", currentLevel);
    
    Dependency* toInstall;

    NSLog(@"downloaded dependencies %@", downloadedDependencies);
    NSLog(@"waiting dependencies %@", waitingDependencies);
    NSLog(@"current level: %u", currentLevel);
    if ([waitingDependencies count] == 0) {
        NSLog(@"no dependencies waiting to be installed uh");
        //check if download is still ongoing
        if ([sortedDependencies count] == [downloadedDependencies count]) {
            NSLog(@"all dependencies are downloaded and installed, yay");
            return;
        }
        else {
            NSLog(@"waiting for downloads to complete");
            return;
        }
    }
    for (Dependency* d in downloadedDependencies) {
        if (d.level == currentLevel) {
            if ([waitingDependencies containsObject:d]) {
                toInstall = d;
                [self installDependency:toInstall updateLevel:YES];
                break;
            }
        }
    }
}
-(void)downloadComplete:(Dependency*) d {
    NSLog(@"download for %@ complete, updating VC", d.packageName);
    [self.delegate downloadComplete:d];
    [downloadedDependencies addObject:d];
    if ([downloadedDependencies count] == [sortedDependencies count]) {
        NSLog(@"All downloads complete!");
        [self installEverything];
        return;
    }
    if (d.level == currentLevel) {
        //other downloads might be ongoing
        [self installDependency:d updateLevel:YES];
    }
}

-(JGDownloadOperation*)createDownloadOperationForDependency:(Dependency*) d {
    NSLog(@"Creating a downloadOperation");
    NSLog(@"Hi: %@",[@"http://"stringByAppendingString:[d.getPackage.repository stringByAppendingPathComponent:d.getPackage.filename]]);
    NSString *file = [NSTemporaryDirectory() stringByAppendingPathComponent: [d.getPackage.filename lastPathComponent]];
    NSString* url = [@"http://"stringByAppendingString:[d.getPackage.repository stringByAppendingPathComponent:d.getPackage.filename]];
    
    NSURL* URL = [[NSURL alloc] initWithString:url];
    NSLog(@"going to download %@", url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
   
    NSLog(@"Request: %@",request);
    
    JGDownloadOperation *operation = [[JGDownloadOperation alloc] initWithRequest:request destinationPath:file allowResume:YES];
    
    [operation setMaximumNumberOfConnections:4];
    [operation setRetryCount:3];
    
    __block CFTimeInterval started;
    
    [operation setCompletionBlockWithSuccess:^(JGDownloadOperation *operation) {
        unsigned long long packageSize = d.getPackage.size;
        if (operation.contentLength != packageSize) {
            NSLog(@"warning: size mismatch: %llu vs %llu",operation.contentLength,packageSize);
        }
#warning todo: implement hash checks
        double kbLength = (double)operation.contentLength/1024.0f;
        CFTimeInterval delta = CFAbsoluteTimeGetCurrent()-started;
        NSLog(@"Success! Downloading %@ %.2f MB took %.1f seconds, average Speed: %.2f kb/s", d.getPackage.package, kbLength/1024.0f, delta, kbLength/delta);
        d.downloadLocation = file;
        [self downloadComplete:d];
    } failure:^(JGDownloadOperation *operation, NSError *error) {
        NSLog(@"Operation Failed: %@", error.localizedDescription);
    }];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, unsigned long long totalBytesReadThisSession, unsigned long long totalBytesWritten, unsigned long long totalBytesExpectedToRead, NSUInteger tag) {
        CFTimeInterval delta = CFAbsoluteTimeGetCurrent()-started;
        NSLog(@"Progress [%@]: %.2f%% Average Speed: %.2f kB/s", d.getPackage.package, ((double)bytesRead/(double)totalBytesExpectedToRead)*100.0f, totalBytesReadThisSession/1024.0f/delta);
        [[NSNotificationCenter defaultCenter]postNotificationName:@"APRDownloadProgressDidChageNotification" object:nil userInfo:@{@"changeInProgress":@((double)bytesRead/(double)totalBytesExpectedToRead)}];
        
        
        
    }];
    
    [operation setOperationStartedBlock:^(NSUInteger tag, unsigned long long totalBytesExpectedToRead) {
        started = CFAbsoluteTimeGetCurrent();
        NSLog(@"Beginning to download %@ to %@", d.getPackage.package, file);
    }];
    
    return operation;
}

-(BOOL)runNSTask:(NSArray*)args launchPath:(NSString*) launchPath {
    NSTask* task = [[NSTask alloc] init];
    task.currentDirectoryPath = @"/var/root";
    
    task.launchPath = launchPath;
    task.arguments = args;
    
    NSPipe *pipe = [NSPipe pipe];
    NSPipe *errorPipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task setStandardError:errorPipe];
    
    [task launch];
    
    NSFileHandle *outFile = [pipe fileHandleForReading];
    NSFileHandle *errFile = [errorPipe fileHandleForReading];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(terminated:)
                                                 name:NSTaskDidTerminateNotification
                                               object:task];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(outData:)
                                                 name:NSFileHandleDataAvailableNotification
                                               object:outFile];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(outData:)
                                                 name:NSFileHandleDataAvailableNotification
                                               object:errFile];
    
    
    [outFile waitForDataInBackgroundAndNotify];
    [errFile waitForDataInBackgroundAndNotify];
    
    [task waitUntilExit];
    
    if ([task terminationStatus] != 0) { // check termination status
        NSLog(@"something happened while running NSTask uh oh");
        return false;
    }
    else {
        return true;
    }
}


-(void) outData: (NSNotification *) notification
{
    NSFileHandle *fh = (NSFileHandle*) [notification object];
    NSData *data = [fh availableData];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"outdata %@",str);
    [fh waitForDataInBackgroundAndNotify];
    
}


- (void) terminated: (NSNotification *)notification
{
    NSLog(@"NSTask terminated");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)loadDylib {
    system("killall Preferences");
    NSString *file = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp_dpkg_amazing"];
    [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    for (Dependency* d in sortedDependencies) {
         [self runNSTask:@[@"-L", d.packageName, @">>", file] launchPath:@"/usr/bin/dpkg"];
    }
    FILE *fp = fopen([file UTF8String], "r");
    char * _line = NULL;
    size_t len = 0;
    ssize_t read;
    NSMutableArray* dylibs = [NSMutableArray new];
    while ((read = getline(&_line, &len, fp)) != -1) {
        NSString* line = [NSString stringWithUTF8String:_line];
        if ([line hasPrefix:@"/System/Library/MobileSubstrate/DynamicLibraries"]) {
            if ([line hasSuffix:@"dylib"]) {
                NSLog(@"found this dylib, %@", line);
#warning todo: support system wide loading
                
                [dylibs addObject:line];
            }
        }
    }
    CPDistributedMessagingCenter* center = [CPDistributedMessagingCenter centerNamed:@"com.alpharize.proclivity"];
    for (NSString* dylib in dylibs) {
        NSDictionary *userInfo = @{@"bundle": @"com.apple.springboard",
                                   @"dylib": dylib };
        [center sendMessageAndReceiveReplyName:@"reload" userInfo:userInfo];
    }
}

@end
