//
//  PackageManager.m
//  BetterRIP
//
//
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#import "PackageManager.h"
#import "Dependency.h"
#import "package.h"
#import "FMDB.h"
#include <stdio.h>
#include <string.h>
#include <sqlite3.h>
#include <stdlib.h>
#include <unistd.h>
#include <libkern/OSAtomic.h>
#include <bzlib.h>
#import "JGDownloadAcceleration.h"
#import "NSTask.h"
#import "BZipCompression.h"

#define CASE(str)                       if ([__s__ isEqualToString:(str)])
#define SWITCH(s)                       for (NSString *__s__ = (s); ; )
#define DEFAULT


@implementation PackageManager {
    NSString* dbPath;
    FMDatabase *db;
    FMDatabase *installedDb;
    FMDatabase *mergedDBTemp;
    NSArray* searchCache;
    NSMutableDictionary* searchResultsCache;
    NSArray* installedPackages;
    
    NSString* mergedDB;
    
    NSInteger amountOfDownloads;
    NSInteger completedDownloadCount;
    NSMutableArray *downloadedFiles;
    
    NSMutableDictionary* installedCache;
}

static dispatch_once_t packageManager_dispatch = 0;

NSString *readLineAsNSString(FILE *file)
{
    char buffer[4096];
    
    // tune this capacity to your liking -- larger buffer sizes will be faster, but
    // use more memory
    NSMutableString *result = [NSMutableString stringWithCapacity:4096];
    
    // Read up to 4095 non-newline characters, then read and discard the newline
    int charsRead;
    do
    {
        if(fscanf(file, "%4095[^\n]%n%*c", buffer, &charsRead) == 1)
            [result appendFormat:@"%s", buffer];
        else
            break;
    } while(charsRead == 4095);
    
    return result;
}

+ (PackageManager*) sharedInstance
{
    static PackageManager *shared = nil;
    dispatch_once(&packageManager_dispatch, ^{
        shared = [[PackageManager alloc] init];
    });
    
    return shared;
}

-(Package*) findSingleInstalledPackageWithPackageName:(NSString*) packageName {
    FMResultSet *s = [installedDb executeQuery:@"SELECT * FROM Packages WHERE package = ?", [NSString stringWithFormat:@"%@", packageName]];
    Package* p;
    while ([s next]) {
        NSLog(@"result dict %@", [s resultDictionary]);
        p = [[Package alloc] initWithDictionary:[s resultDictionary]];
        return p;
        break;
    }
    return p;
}


-(id)init {
    self = [super init];
    
    if (self)
    {
        NSLog(@"Initialising PackageManager");
        
        /*if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/Proclivity/database.db" isDirectory:nil]) {
            NSLog(@"database does not exist");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"InitLoadingPackages" object:self];
            NSLog(@"refreshing packages");
            [self refreshPackages];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"InitLoadingPackagesComplete" object:self];
            
        }*/
        
        [[NSFileManager defaultManager] removeItemAtPath:@"/var/lib/Proclivity/database.db" error:nil];
        
        NSArray *dbsToMerge=@[@"/var/lib/Proclivity/packages/BigBoss.db",@"/var/lib/Proclivity/packages/ModMyi.db",@"/var/lib/Proclivity/packages/ZodTTD.db",@"/var/lib/Proclivity/packages/Saurik.db"];
        [self mergeDatabase:dbsToMerge];
        db = [FMDatabase databaseWithPath:@"/var/lib/Proclivity/database.db"];
        [db open];
        
        sqlite3_exec(db->_db, "PRAGMA busy_timeout=0;", NULL, NULL, NULL);
        //sqlite3_exec(db->_db, "PRAGMA cache_size=8192", NULL, NULL, NULL);
        sqlite3_exec(db->_db, "PRAGMA encoding='UTF-8'", NULL, NULL, NULL);
        sqlite3_exec(db->_db, "PRAGMA foreign_keys=ON", NULL, NULL, NULL);
        //sqlite3_exec(db->_db, "PRAGMA journal_mode=WAL", NULL, NULL, NULL);
        sqlite3_exec(db->_db, "PRAGMA journal_mode=MEMORY", NULL, NULL, NULL); // for right now why not its fast

        //sqlite3_exec(db->_db, "PRAGMA legacy_file_format=OFF", NULL, NULL, NULL);
        //sqlite3_exec(db->_db, "PRAGMA synchronous=NORMAL", NULL, NULL, NULL);
        sqlite3_exec(db->_db, "PRAGMA synchronous=NO", NULL, NULL, NULL); //speed

        
        //sqlite3_exec(db->_db, "PRAGMA temp_store=MEMORY", NULL, NULL, NULL);
    
        
        [[NSFileManager defaultManager] removeItemAtPath:@"/var/lib/Proclivity/installed.db" error:nil];
        
        installedDb = [FMDatabase databaseWithPath:@"/var/lib/Proclivity/installed.db"];
        [installedDb open];
        
        
        searchResultsCache = [NSMutableDictionary new];
    }
    
    return self;
}


-(NSString*)getVersionForPackageInInstalledCacheLongFunctionsAreCoolTooStopTryingToClassDumpThisNotHelping:(NSString*) package {
    return [installedCache objectForKey:package];
}

-(void)loadInstalledPackageCache {
    installedCache = [NSMutableDictionary new];
    FMResultSet *s = [installedDb executeQuery:@"SELECT package, version FROM Packages ORDER BY name"];
    while ([s next]) {
        NSString* package = [s stringForColumn:@"package"];
        NSString* version = [s stringForColumn:@"version"];
        if ((package == nil) || (version == nil)) {
            continue;
        }
        NSLog(@"Installed Package: %@ %@", package, version);
        [installedCache setObject:version forKey:package];
    }
    NSLog(@"done saving installed package cache");
}

-(void) loadDatabase:(NSString*)file withDB:(sqlite3*)database {
    
    // insert code here...
    printf("Hello, World!\n");
    
    // Open Packages file
    FILE *fp = fopen([file UTF8String], "r");
    char * line = NULL;
    size_t len = 0;
    ssize_t read;
    
    printf("Opened database\n");
    const char *sql_stmt =
    "CREATE TABLE Packages (architecture TEXT, author TEXT, conflicts TEXT, depends TEXT, depiction TEXT, description TEXT, filename TEXT, homepage TEXT, icon TEXT, 'installed-size' int, maintainer TEXT, md5sum TEXT, name TEXT, package TEXT, 'pre-depends' TEXT, priority TEXT, repository TEXT, section TEXT, sha1 TEXT, sha256 TEXT, size TEXT, sponsor TEXT, support TEXT, tag TEXT, version TEXT, website TEXT, status TEXT, provides TEXT)";
    
    if (sqlite3_exec(database, sql_stmt, NULL, NULL, NULL) != SQLITE_OK)
    {
        printf("Failed to create table: %s\n",sqlite3_errmsg(database));
    }


    sqlite3_stmt *statement = NULL;
    
    long currentRow=0;
    short currentLine=0;
    
    // Apparently these options improve the speed
    sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, NULL);
    sqlite3_exec(database, "PRAGMA synchronous = OFF", NULL, NULL, NULL);
    sqlite3_exec(database, "PRAGMA journal_mode = MEMORY", NULL, NULL, NULL);
    
    while ((read = getline(&line, &len, fp)) != -1) {
        //Start reading the file line by line.
        
        // If the line is a newline, we perform the SQL query
        if (line[0]=='\n') {
            if (sqlite3_step(statement) != SQLITE_ROW)
            {
                //printf("error: %s",sqlite3_errmsg(database));
            }
            
            //sqlite3_step(statement);
            sqlite3_reset(statement);
            sqlite3_finalize(statement);
            
            //printf("error: %s",sqlite3_errmsg(database));
            currentLine=0;
            currentRow++;
            continue;
        }
        
        // If the line is the first line of a package, we initialise the SQL query
        if (currentLine==0) {
            const char *createRowStatement ="INSERT INTO Packages (architecture, author, conflicts, depends, depiction, description, filename, homepage, icon, 'installed-size', maintainer, md5sum, name, package, 'pre-depends', priority, repository, section, sha1, sha256, size, sponsor, support, tag, version, website, status, provides) VALUES ($Architecture, $Author, $Conflicts, $Depends, $Depiction, $Description, $Filename, $Homepage, $Icon, $InstalledzSize, $Maintainer, $MD5sum, $Name, $Package, $PrezDepends, $Priority, $Repository, $Section, $SHA1, $SHA256, $Size, $Sponsor, $Support, $Tag, $Version, $Website, $Status, $Provides)";
            
            if (sqlite3_prepare_v2(database, createRowStatement, -1, &statement, NULL) == SQLITE_OK) {
                int index=sqlite3_bind_parameter_index(statement, "$Pre-Depends");
                
                sqlite3_bind_int64(statement, index, currentRow);
            } else {
                printf("error: %s",sqlite3_errmsg(database));
            }
            currentLine=1;
        }
        
        // Create chars that hold the key and key value
        char lineKey[20]={};
        char valueForKey[420]={};
        short passedkey=0;
        
        // Iterate over every character
        for (int i = 0; i < 421; i++){
            
            // Continue in case there is no character at the beginning
            // Not sure why we need this check, but apparently it crashes sometimes without it
            if (!line[i]) {
                continue;
            }
            
            char currentCharacter=line[i];
            
            // Passed key is a bool that determines if we are currently reading the key or the key value
            if (passedkey==0) {
                if (currentCharacter==' '||currentCharacter=='\t') {
                    passedkey=1;
                    continue;
                }
                
                if (currentCharacter=='-') {
                    lineKey[i]='z';
                    continue;
                }
                
                // If there is a colon we are done reading the key and begin reading the key value
                if (currentCharacter==':') {
                    passedkey=1;
                    i++;
                    continue;
                }
                lineKey[i]=line[i];
            }
            if (passedkey==1) {
                // If there's a newline we're done reading the line and bind the text to the SQL statement
                if (currentCharacter=='\n') {
                    char parameter[30];
                    
                    // Prepend $ to key because those are the parameter names in the SQL statement
                    sprintf(parameter, "$%s",lineKey);
                    
                    // Get index of parameter
                    int index=sqlite3_bind_parameter_index(statement, parameter);
                    
                    sqlite3_bind_text(statement, index, valueForKey, -1, SQLITE_TRANSIENT);
                    continue;
                }
                valueForKey[i-2-strlen(lineKey)]=line[i];
            }
        }
    }
    
    sqlite3_exec(database, "END TRANSACTION", NULL, NULL, NULL);
    
    fclose(fp);
    if (line)
        free(line);
    //[self patchRepo:@"apt.thebigboss.org/repofiles/cydia" withSQLDiff:[[NSBundle mainBundle] pathForResource:@"bbsqldiff" ofType:@"db"]];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [documentPaths objectAtIndex:0];
    
    //sqlPatch([[documentsDirectory stringByAppendingPathComponent:@"zero.db"]UTF8String], [[[NSBundle mainBundle] pathForResource:@"bbsqldiff" ofType:@"db"]UTF8String]);

    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Start Patching");
        //[self patchDatabase:[NSURL URLWithString:[documentsDirectory stringByAppendingPathComponent:@"bb0.db"]] withPatch:[NSURL URLWithString:[documentsDirectory stringByAppendingPathComponent:@"bb0.patch"]]];
        NSLog(@"Done patching");
    });
}

-(void)mergeDatabase:(NSArray *)dbsToMerge {
    
    NSLog(@"start merging");
    sqlite3 *ourDatabase;
    const char *path=[@"/var/lib/Proclivity/database.db" UTF8String];
    sqlite3_open(path, &ourDatabase);
    sqlite3_exec(ourDatabase, "CREATE TABLE Packages (architecture TEXT, author TEXT, conflicts TEXT, depends TEXT, depiction TEXT, description TEXT, filename TEXT, homepage TEXT, icon TEXT, 'installed-size' int, maintainer TEXT, md5sum TEXT, name TEXT, package TEXT, 'pre-depends' TEXT, priority TEXT, repository TEXT, section TEXT, sha1 TEXT, sha256 TEXT, size TEXT, sponsor TEXT, support TEXT, tag TEXT, version TEXT, website TEXT, status TEXT, provides TEXT)", NULL, NULL, NULL); // if there was an error too bad we'll never know
    sqlite3_exec(ourDatabase, "PRAGMA synchronous = OFF", NULL, NULL, NULL);
    sqlite3_exec(ourDatabase, "PRAGMA journal_mode = OFF", NULL, NULL, NULL);
    //sqlite3_exec(ourDatabase, "BEGIN TRANSACTION", NULL, NULL, NULL);
    for (NSString* database in dbsToMerge) {
        NSLog(@"Database:%@",database);
        //sqlite3_exec(ourDatabase, "BEGIN TRANSACTION", NULL, NULL, NULL);
        sqlite3_exec(ourDatabase, [[NSString stringWithFormat:@"ATTACH DATABASE '%s' AS TOMERGE;",[database UTF8String]] UTF8String], NULL, NULL, NULL);
        sqlite3_exec(ourDatabase, "INSERT INTO Packages SELECT * FROM TOMERGE.Packages;", NULL, NULL, NULL);
        sqlite3_exec(ourDatabase, "DETACH TOMERGE", NULL, NULL, NULL);
        //sqlite3_exec(ourDatabase, "END TRANSACTION", NULL, NULL, NULL); // i have no clue why this needs to be in the loop, but it doesnt work if its not
    }

    sqlite3_close(ourDatabase);
    
    NSLog(@"done merging");
    
    
    //});
    
    //that was easy
    // NOT
    // lol
}


-(void)loadInstalledPackagesDB {
    [self loadDatabase:@"/var/lib/dpkg/status" withDB:installedDb->_db];
    [self loadInstalledPackageCache];
}

// test

-(BOOL)patchDatabase:(NSURL *)databaseToPatch withPatch:(NSURL *)patchURL {
    // Open Packages file
    FILE *fp = fopen([[patchURL path] UTF8String], "r");
    char * line = NULL;
    size_t len = 0;
    ssize_t read;
    
    // Initialise SQL Database
    const char *dbpath = [[databaseToPatch path]UTF8String];
    
    sqlite3 *database;
    
    if (sqlite3_open_v2(dbpath, &database, SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL) == SQLITE_OK)
    {
        sqlite3_exec(database, "PRAGMA synchronous = OFF", NULL, NULL, NULL);
        sqlite3_exec(database, "PRAGMA journal_mode = MEMORY", NULL, NULL, NULL);
        sqlite3_exec(database, "PRAGMA temp_store=MEMORY", NULL, NULL, NULL);
        sqlite3_exec(database, "PRAGMA count_changes=OFF", NULL, NULL, NULL);
        sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, NULL);
    }
    
    BOOL returnValue=YES;;

    while ((read = getline(&line, &len, fp)) != -1) {
        
        sqlite3_exec(database, line, NULL, NULL, NULL);
        
    }
    sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, NULL);
    return returnValue; // add more checks later and return no if it failed
    
}

// end test

-(void)refreshPackages {
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSArray *reposToRefresh=[defaults objectForKey:@"standardRepos"]; // change this later to add custom repos as well
    
    [[NSFileManager defaultManager]createDirectoryAtPath:@"/var/lib/Proclivity/Downloads" withIntermediateDirectories:YES attributes:nil error:nil];
    downloadedFiles=[[NSMutableArray alloc]init];
    amountOfDownloads=reposToRefresh.count;
    for (int i=0; i<reposToRefresh.count; i++) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://alpharize.com:3000/sources/%@/latest",reposToRefresh[i]]]
                                                                 completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error) {
                                          if (data) {
                                              NSLog(@"Download Done %@!",reposToRefresh[i]);
                                              NSLog(@"Decompressing");
                                              [[NSFileManager defaultManager]removeItemAtPath:[@"/var/lib/Proclivity/" stringByAppendingPathComponent:[NSString stringWithFormat:@"packages/%@.db",reposToRefresh[i]]] error:nil];
                                              // trying this now
                                              NSError *extractionError;
                                              [[BZipCompression decompressedDataWithData:data error:&extractionError]writeToFile:[NSString stringWithFormat:@"/var/lib/Proclivity/packages/%@.db",reposToRefresh[i]] atomically:NO];
                                              if (extractionError) {
                                                  NSLog(@"WARNING: DECOMPRESSION FAILED! %@",[extractionError userInfo]);
                                                  return;
                                              }
                                              
                                              NSLog(@"Done decompressing");
                                              [downloadedFiles addObject:[@"/var/lib/Proclivity/" stringByAppendingPathComponent:[NSString stringWithFormat:@"packages/%@.db",reposToRefresh[i]]]];
                                              completedDownloadCount++;
                                              NSLog(@"download count %ld amount %ld", (long)completedDownloadCount, (long)amountOfDownloads);
                                              if (completedDownloadCount==amountOfDownloads) {
                                                  NSLog(@"Downloaded files: %@",downloadedFiles);
                                                  [[NSFileManager defaultManager] removeItemAtPath:[@"/var/lib/Proclivity/" stringByAppendingPathComponent:@"database.db"] error:nil];
                                                  [self mergeDatabase:downloadedFiles];
                                                  [db close];
                                                  db = [FMDatabase databaseWithPath:[@"/var/lib/Proclivity/" stringByAppendingPathComponent:@"database.db"]];
                                                  [db open];
                                                  [self saveSearchCache];
                                                  NSLog(@"All done");
                                                  [[NSFileManager defaultManager]removeItemAtPath:[@"/var/lib/Proclivity/" stringByAppendingPathComponent:@"Downloads"] error:nil];
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"APRRefreshDidCompleteNotification" object:nil];
                                                  [self saveSearchCache];
                                              }
                                          } else {
                                              NSLog(@"Failed to fetch %@: %@",response.URL,error);
                                          }
                                      }];
            [task resume];
        });
        
        
        // Use this code once the server properly sends content length
        
        //JGDownloadOperation *operation=[self createDownloadPackagesOperation:[NSURL URLWithString:[NSString stringWithFormat:@"http://alpharize.com/sources/%@/latest",reposToRefresh[i]]]];
        //[operation start];
    }
}

-(JGDownloadOperation*)createDownloadPackagesOperation:(NSURL *)downloadURL {
    NSString *file = [NSTemporaryDirectory() stringByAppendingPathComponent:[downloadURL host]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:downloadURL];
    JGDownloadOperation *operation = [[JGDownloadOperation alloc] initWithRequest:request destinationPath:file allowResume:YES];
    
    [operation setMaximumNumberOfConnections:4];
    [operation setRetryCount:3];
    
    __block CFTimeInterval started;
    
    [operation setCompletionBlockWithSuccess:^(JGDownloadOperation *operation) {
        double kbLength = (double)operation.contentLength/1024.0f;
        CFTimeInterval delta = CFAbsoluteTimeGetCurrent()-started;
        NSLog(@"Success! Downloading %@ %.2f MB took %.1f seconds, average Speed: %.2f kb/s", [downloadURL host], kbLength/1024.0f, delta, kbLength/delta);
        /*[self decompressBzip2ToPath:[@"/var/lib/Proclivity/" stringByAppendingPathComponent:[NSString stringWithFormat:@"Downloads/%@.db",[downloadURL host]]] withData:[NSData dataWithContentsOfFile:file]];
        [[NSFileManager defaultManager]removeItemAtPath:[NSString stringWithFormat:@"Downloads/%@.db",[downloadURL host]] error:nil];
        [downloadedFiles addObject:[NSString stringWithFormat:@"Downloads/%@.db",[downloadURL host]]];
        completedDownloadCount++;
        if (completedDownloadCount==amountOfDownloads) {
            NSLog(@"Downloaded files: %@",downloadedFiles);
            [[NSFileManager defaultManager] removeItemAtPath:[@"/var/lib/Proclivity/" stringByAppendingPathComponent:@"database.db"] error:nil];
            [self mergeDatabase:downloadedFiles];
            db = [FMDatabase databaseWithPath:[@"/var/lib/Proclivity/" stringByAppendingPathComponent:@"database.db"]];
            [db open];
            [self saveSearchCache];
            [[NSFileManager defaultManager]removeItemAtPath:[@"/var/lib/Proclivity/" stringByAppendingPathComponent:@"Downloads"] error:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"APRRefreshDidCompleteNotification" object:nil];
        }*/
        
    } failure:^(JGDownloadOperation *operation, NSError *error) {
        NSLog(@"Operation Failed: %@", error.localizedDescription);
    }];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, unsigned long long totalBytesReadThisSession, unsigned long long totalBytesWritten, unsigned long long totalBytesExpectedToRead, NSUInteger tag) {
        CFTimeInterval delta = CFAbsoluteTimeGetCurrent()-started;
    }];
    
    [operation setOperationStartedBlock:^(NSUInteger tag, unsigned long long totalBytesExpectedToRead) {
        started = CFAbsoluteTimeGetCurrent();
        NSLog(@"Beginning to download %@ to %@", [downloadURL host], file);
    }];
    
    return operation;
}

-(NSArray*)getVersionsOfPackage:(NSString*)packageName {
    FMResultSet *s = [db executeQuery:@"SELECT version, installed_version FROM Packages WHERE package = ?", [NSString stringWithFormat:@"%@", packageName]];
    while ([s next]) {
        NSString* installed_version = [s stringForColumn:@"installed_version"];
        NSString* version = [s stringForColumn:@"version"];
        return @[installed_version, version];
    }
    return nil;
}

-(NSString*) getStatusForPackage:(NSString*)package {
    FMResultSet *s = [installedDb executeQuery:@"SELECT status FROM Packages WHERE package = ?", [NSString stringWithFormat:@"%@", package]];
    NSString* status = @"";
    while ([s next]) {
        status = [s stringForColumn:@"status"];
        return status;
        break;
    }
    return status;
}

-(Package*) findSinglePackageWithPackageName:(NSString*) packageName {
    NSLog(@"finding package with package name %@", packageName);

    FMResultSet *s = [db executeQuery:@"SELECT * FROM Packages WHERE package = ?", [NSString stringWithFormat:@"%@", packageName]];
    Package* p;
    while ([s next]) {
        NSLog(@"result dict %@", [s resultDictionary]);
        p = [[Package alloc] initWithDictionary:[s resultDictionary]];
        NSLog(@"hey");
        return p;
        break;
    }
    
    return p;
}

-(Package*) getPackage:(NSString*) packageName {
    return [self findSinglePackageWithPackageName:packageName];
}
-(Package*) findPackageWhichProvides:(NSString*)package {
    return [self findPackageWhichProvides:package fromDB:db];
}


-(Package*) findPackageWhichProvides:(NSString*)package fromDB:(FMDatabase*) _db {
    Package* p;
    FMResultSet *s = [_db executeQuery:@"SELECT * FROM Packages WHERE provides LIKE ?", [NSString stringWithFormat:@"%%%@%%", package]];
    while ([s next]) {
        NSLog(@"result dict 2 %@", [s resultDictionary]);
        p = [[Package alloc] initWithDictionary:[s resultDictionary]];
        NSArray* providesArray = [[p.provides stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","];
        if ([providesArray containsObject:package]) {
            NSLog(@"found providing package %@", p.package);
            return p;
        }
        break;
    }
    NSLog(@"Error: Could not find suitable package to provide for %@", package);
    return nil;
}




-(void) saveSearchCache {
    NSMutableArray* array = [NSMutableArray new];
    FMResultSet *s = [db executeQuery:@"SELECT name, package, description FROM Packages ORDER BY name"];
    while ([s next]) {
        [array addObject:[s resultDictionary]];
    }
    searchCache = array;
    NSLog(@"done saving search cach");
}



-(NSArray*)searchPackageCacheWithName: (NSString*) search completeSearch:(BOOL)completeSearch {
    
    __block int count = 0;
    __block int count1 = 0;
    __block int count2 = 0;
    NSLog(@"searching woot %@", search);
    NSString* _search = [search lowercaseString];
    NSArray* result = [searchResultsCache objectForKey:_search];
    if (result != nil) {
        return result;
    }

    __block volatile OSSpinLock spinLock = OS_SPINLOCK_INIT;

    __block NSMutableArray* filteredArray = [NSMutableArray new];
    __block NSMutableArray* filteredArrayPackage = [NSMutableArray new];
    
    
    
    [searchCache enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //NSRange matchedRange = [obj rangeOfString:@"this"];
        @try {
            NSString* _package = obj[@"package"];
            if (((id)_package != [NSNull null]) && (count1 < 5)) {
                if ([[_package lowercaseString] hasPrefix:_search]) {
                    OSSpinLockLock((volatile OSSpinLock * volatile)&spinLock);
                    [filteredArrayPackage addObject:obj];
                    count1++;
                    count++;
                    OSSpinLockUnlock((volatile OSSpinLock * volatile)&spinLock);
                }
            }
            
            NSString* _name = obj[@"name"];
            if (((id)_name != [NSNull null]) && (count2 < 6)) {
                if ([[_name lowercaseString]hasPrefix:_search]) {
                    OSSpinLockLock((volatile OSSpinLock * volatile)&spinLock);
                    [filteredArray addObject:obj];
                    count++;
                    count2++;
                    OSSpinLockUnlock((volatile OSSpinLock * volatile)&spinLock);
                }
            }
            
            if (count > 15) {
                *stop = TRUE;
            }
            
        }
        @catch (NSException * e) {
            NSLog(@"package %@", search);
        }
        @finally {
        }
        
    }];
    
    [filteredArray addObjectsFromArray:filteredArrayPackage];
    [searchResultsCache setObject:filteredArray forKey:_search];
    return filteredArray;
}

-(NSArray*) parseResultSet:(FMResultSet*) s {
    NSMutableArray* array = [NSMutableArray new];
    while ([s next]) {
        Package* p = [[Package alloc] initWithDictionary:[s resultDictionary]];
        [array addObject:p];
    }
    return array;
}

@end
