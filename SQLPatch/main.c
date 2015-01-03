//
//  main.c
//  SQLPatch
//
//  Created by David Yu on 26/12/2014.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#include <stdio.h>
#include <sqlite3.h>
#include <string.h>

int main(int argc, const char * argv[]) {
    // insert code here...
    printf("Hello, World!\n");
    
    // Initialise SQL Database
    const char *dbpath = argv[2];
    const char *dbpath2 = argv[1];

    sqlite3 *database;
    sqlite3 *database2;

    if (sqlite3_open_v2(dbpath, &database, SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL) == SQLITE_OK)
    {
        sqlite3_exec(database, "PRAGMA synchronous = OFF", NULL, NULL, NULL);
        sqlite3_exec(database, "PRAGMA journal_mode = MEMORY", NULL, NULL, NULL);
        
        // Open database to patch
        if (sqlite3_open_v2(dbpath2, &database2, SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL) != SQLITE_OK) {

            printf("couldnt open database 2: %s",sqlite3_errmsg(database2));
            return -1;
        } else {
            sqlite3_exec(database2, "BEGIN TRANSACTION", NULL, NULL, NULL);
            sqlite3_exec(database2, "PRAGMA synchronous = OFF", NULL, NULL, NULL);
            sqlite3_exec(database2, "PRAGMA journal_mode = MEMORY", NULL, NULL, NULL);
        }
        
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, "SELECT * FROM Packages", -1, &statement, NULL) == SQLITE_OK) {
            short weAtPt2=0;
            printf("Patching (1/2)\n");
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                
                if ((const char *) sqlite3_column_text(statement, 26)) {
                    if (strcmp("YES!",(const char *) sqlite3_column_text(statement, 26))==0) {
                        printf("YES!\n");
                        
                        sqlite3_stmt *statement2;
                        char deleteRowStatement[160];
                        sprintf(deleteRowStatement,"DELETE FROM Packages WHERE package = \"%s\"",(const char *) sqlite3_column_text(statement, 13));
                        if (sqlite3_prepare_v2(database2, deleteRowStatement, -1, &statement2, NULL) == SQLITE_OK) {
                            if (sqlite3_step(statement2)!=SQLITE_DONE) {
                                printf("couldn't step %s\n",sqlite3_errmsg(database2));
                            }
                        }

                        continue;
                    }
                }
                
                if ((const char *) sqlite3_column_text(statement, 26)) {
                    if (strcmp("NO",(const char *) sqlite3_column_text(statement, 26))==0) {
                        printf("Patching (2/2)\n");
                        weAtPt2=1;
                        continue;
                    }
                }
                
                if (weAtPt2==1) {
                    sqlite3_stmt *statement2;
                    char createRowStatement[666];
                    sprintf(createRowStatement,"INSERT INTO Packages (architecture, author, conflicts, depends, depiction, description, filename, homepage, icon, 'installed-size', maintainer, md5sum, name, package, 'pre-depends', priority, repository, section, sha1, sha256, size, sponsor, support, tag, version, website) VALUES ($Architecture, $Author, $Conflicts, $Depends, $Depiction, $Description, $Filename, $Homepage, $Icon, :InstalledSize, $Maintainer, $MD5sum, $Name, $Package, :PreDepends, $Priority, $Repository, $Section, $SHA1, $SHA256, $Size, $Sponsor, $Support, $Tag, $Version, $Website) WHERE package = \"%s\"",(const char *) sqlite3_column_text(statement, 13));
                    if (sqlite3_prepare_v2(database2, createRowStatement, -1, &statement2, NULL) == SQLITE_OK) {
                        for (int i=0; i<sqlite3_column_count(statement)-1&&i!=13; i++) {
                            if ((const char *) sqlite3_column_text(statement, i)) {
                                if (sqlite3_bind_text(statement2, i+1, (const char *) sqlite3_column_text(statement, i), -1, SQLITE_TRANSIENT)!=SQLITE_OK) {
                                    printf("not ok :\\ %s\n",sqlite3_errmsg(database2));
                                }
                            }
                        }
                        
                        if (sqlite3_step(statement2)!=SQLITE_DONE) {
                            printf("couldn't step %s\n",sqlite3_errmsg(database2));
                        }
                        continue;
                    }
                }

                sqlite3_stmt *statement2;
                char createRowStatement[666];
                sprintf(createRowStatement,"UPDATE Packages SET architecture=?, author=?, conflicts=?, depends=?, depiction=?, description=?, filename=?, homepage=?, icon=?, 'installed-size'=?, maintainer=?, md5sum=?, name=?, package=?, 'pre-depends'=?, priority=?, repository=?, section=?, sha1=?, sha256=?, size=?, sponsor=?, support=?, tag=?, version=?, website=? WHERE package = \"%s\"",(const char *) sqlite3_column_text(statement, 13));
                if (sqlite3_prepare_v2(database2, createRowStatement, -1, &statement2, NULL) != SQLITE_OK) {
                    //if (sqlite3_bind_text(statement3, 14, (const char *) sqlite3_column_text(statement, 13), -1, SQLITE_TRANSIENT)!=SQLITE_OK) {
                    //}
                    printf("fail %s\n",sqlite3_errmsg(database2));
                }

                
                for (int i=0; i<sqlite3_column_count(statement)-1&&i!=13; i++) {
                    if ((const char *) sqlite3_column_text(statement, i)) {
                        if (sqlite3_bind_text(statement2, i+1, (const char *) sqlite3_column_text(statement, i), -1, SQLITE_TRANSIENT)!=SQLITE_OK) {
                            printf("not ok :\\ %s\n",sqlite3_errmsg(database2));

                            
                        }
                    }
                }
                
                if (sqlite3_step(statement2)!=SQLITE_DONE) {
                    printf("couldn't step! %s\n",sqlite3_errmsg(database2));
                }
                continue;
            }
        }
    } else {
        printf("couldnt open database 1: %s",sqlite3_errmsg(database2));
    }
    sqlite3_exec(database2, "END TRANSACTION", NULL, NULL, NULL);
    printf("Done\n");
    return 0;
    
}
