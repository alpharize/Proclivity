//
//  main.c
//  Packages2SQL
//
//  Created by David Yu on 23/12/2014.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#include <stdio.h>
#include <string.h>
#include <sqlite3.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, const char * argv[]) {
    // insert code here...
    printf("Hello, World!\n");
    
    // Open Packages file
    FILE * fp;
    char * line = NULL;
    size_t len = 0;
    ssize_t read;
    
    fp = fopen(argv[1], "r");
    if (fp == NULL)
        return -1;
    
    // Initialise SQL Database
    const char *dbpath = argv[2];
    sqlite3 *database;
    
    if (sqlite3_open_v2(dbpath, &database, SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL) == SQLITE_OK)
    {
        printf("Opened database\n");
        const char *sql_stmt = "CREATE TABLE Packages (architecture TEXT, author TEXT, conflicts TEXT, depends TEXT, depiction TEXT, description TEXT, filename TEXT, homepage TEXT, icon TEXT, 'installed-size' int, maintainer TEXT, md5sum TEXT, name TEXT, package TEXT, 'pre-depends' TEXT, priority TEXT, repository TEXT, section TEXT, sha1 TEXT, sha256 TEXT, size TEXT, sponsor TEXT, support TEXT, tag TEXT, version TEXT, website TEXT, status TEXT, provides TEXT)";
        
        if (sqlite3_exec(database, sql_stmt, NULL, NULL, NULL) != SQLITE_OK)
        {
            printf("Failed to create table: %s\n",sqlite3_errmsg(database));
        }
    } else {
        printf("Failed to open database: %s\n",sqlite3_errmsg(database));
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
                sqlite3_bind_text(statement, 17, argv[3], -1, SQLITE_TRANSIENT);
            } else {
                printf("error: %s\n",sqlite3_errmsg(database));
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
                // If the key starts with a whitespace we ignore it. Fuck people using newlines in their Packages file
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
                    
                    // Append $ to key because those are the parameter names in the SQL statement
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
    sqlite3_close(database);
    
    fclose(fp);
    if (line)
        free(line);
    
    return 0;
}