//
//  main.c
//  SQLDiff
//
//  Created by David Yu on 25/12/2014.
//  Copyright (c) 2014 Alpharize. All rights reserved.
//

#include <stdio.h>
#include <sqlite3.h>
#include <string.h>
#include <stdlib.h>

int main(int argc, const char * argv[]) {
    // insert code here...
    //printf("Hello, World!\n");
    
    const char *db1=argv[1];
    const char *db2=argv[2];
    
    sqlite3 *database1;
    sqlite3 *database2;
    
    printf("Part 1/2: Check for package changes");
    char *finalOutput = NULL;
    if (sqlite3_open_v2(db1, &database1, SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL) == SQLITE_OK)
    {
        sqlite3_exec(database1, "PRAGMA synchronous = OFF", NULL, NULL, NULL);
        sqlite3_exec(database1, "PRAGMA journal_mode = MEMORY", NULL, NULL, NULL);
        const char *sql_stmt = "SELECT * FROM Packages";
        sqlite3_stmt *statement;
        sqlite3_stmt *statement2;
        if (sqlite3_prepare_v2(database1, sql_stmt, -1, &statement, NULL) == SQLITE_OK) {
            // load second db
            if (sqlite3_open_v2(db2, &database2, SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL) != SQLITE_OK) {
                printf("failed opening database 2: %s",sqlite3_errmsg(database2));
            }
            int count=0;
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                if ((count % 100)==0) {
                    printf("count %d\n",count);
                }
                count++;
                if ((const char *) sqlite3_column_text(statement, 13)) {
                    char sql_stmt2[140];
                    sprintf(sql_stmt2, "SELECT * FROM Packages WHERE package = \"%s\"",(const char *)sqlite3_column_text(statement, 13));
                    if (sqlite3_prepare_v2(database2, sql_stmt2, -1, &statement2, NULL) == SQLITE_OK) {
                        //printf("hi\n");
                        short didReceiveRow=0;
                        while (sqlite3_step(statement2) == SQLITE_ROW)
                        {
                            didReceiveRow=1;
                            short rowsDiffer=0;
                            for (int i=0; i<26; i++) {
                                if ((const char *) sqlite3_column_text(statement, i)) {
                                    if ((const char *) sqlite3_column_text(statement2, i)) {
                                        if (strcmp((const char *) sqlite3_column_text(statement, i), (const char *) sqlite3_column_text(statement2, i)) != 0) {
                                            if (rowsDiffer==0) {
                                                if (!finalOutput) {
                                                    finalOutput=realloc(NULL, 21*sizeof(char));
                                                    strcpy(finalOutput, "UPDATE Packages SET ");
                                                } else {
                                                    finalOutput=(char *)realloc(finalOutput, (strlen(finalOutput)+21)*sizeof(char));
                                                    strcat(finalOutput, "UPDATE Packages SET ");
                                                }
                                                
                                                rowsDiffer=1;
                                            }
                                            
                                            char *newstring=(char *)malloc((strlen(finalOutput)+strlen(sqlite3_column_name(statement2, i))+strlen((const char *) sqlite3_column_text(statement2, i))+8)*sizeof(char));
                                            snprintf(newstring, 8+strlen(sqlite3_column_name(statement2, i))+strlen((const char *) sqlite3_column_text(statement2, i)), "'%s'='%s', ",sqlite3_column_name(statement2, i),(const char *) sqlite3_column_text(statement2, i));
                                            
                                            finalOutput=(char *)realloc(finalOutput, (strlen(finalOutput)+strlen(newstring))*sizeof(char));
                                            strcat(finalOutput, newstring);
                                            free(newstring);
                                        }
                                    } else {
                                        printf("First db column value is set, but second db column value isn't\n");
                                        if (rowsDiffer==0) {
                                            if (!finalOutput) {
                                                finalOutput=realloc(NULL, 21*sizeof(char));
                                                strcpy(finalOutput, "UPDATE Packages SET ");
                                            } else {
                                                finalOutput=(char *)realloc(finalOutput, (strlen(finalOutput)+21)*sizeof(char));
                                                strcat(finalOutput, "UPDATE Packages SET ");
                                            }
                                            rowsDiffer=1;
                                        }
                                        
                                        char *newstring=(char *)malloc((strlen(finalOutput)+strlen(sqlite3_column_name(statement2, i))+8)*sizeof(char));
                                        snprintf(newstring, (8+strlen(sqlite3_column_name(statement2, i)))*sizeof(char), "'%s'='', ",sqlite3_column_name(statement2, i));
                                        
                                        finalOutput=(char *)realloc(finalOutput, (strlen(finalOutput)+strlen(newstring))*sizeof(char));
                                        strcat(finalOutput, newstring);
                                        free(newstring);
                                        
                                    }
                                }
                            }
                            // commit diff
                            if (rowsDiffer==1) {
                                finalOutput[strlen(finalOutput)-2]='\0';
                                char *newstring=(char *)malloc((19+strlen((const char *) sqlite3_column_text(statement2, 13)))*sizeof(char));
                                
                                snprintf(newstring, strlen(finalOutput)+ 19+strlen((const char *) sqlite3_column_text(statement2, 13))+1, " WHERE package='%s'\n",(const char *) sqlite3_column_text(statement2, 13));
                                
                                finalOutput=(char *)realloc(finalOutput, (strlen(finalOutput)+strlen(newstring))*sizeof(char));
                                strcat(finalOutput, newstring);
                                //free(newstring);
                            }
                        }
                        if (didReceiveRow==0) {
                            //printf("error, didn't find package in db2 %s\n",sqlite3_errmsg(database2));
                            // CODE HERE
                            //const char *createRowStatement ="INSERT INTO Packages (package, deleteThis) VALUES ($package, \"YES!\")";
                            if (!finalOutput) {
                                finalOutput=realloc(NULL, 1*sizeof(char));
                                strcpy(finalOutput, "");
                            }
                            char *newstring=(char *)malloc((39+strlen((const char *) sqlite3_column_text(statement, 13)))*sizeof(char));
                            snprintf(newstring, (39+strlen((const char *) sqlite3_column_text(statement, 13)))*sizeof(char), "DELETE FROM Packages WHERE package='%s'\n",(const char *) sqlite3_column_text(statement, 13));
                            
                            finalOutput=(char *)realloc(finalOutput, (strlen(finalOutput)+strlen(newstring))*sizeof(char));
                            strcat(finalOutput, newstring);
                            free(newstring);
                        }
                        sqlite3_reset(statement2);
                        sqlite3_finalize(statement2);
                    } else {
                        
                    }
                }
                
                
            }
            
        } else {
            printf("failed %s\n",sqlite3_errmsg(database1));
        }
        
        sqlite3_finalize(statement);
        printf("Part 2/2: Add new packages");
        char *finalStringTwo=NULL;
        finalStringTwo=(char *)malloc(sizeof(char));
        strcpy(finalStringTwo, "");
        
        // Now we actually add the new packages
        sqlite3_stmt *statement420;
        if (sqlite3_prepare_v2(database2, "SELECT * FROM Packages", -1, &statement420, NULL) == SQLITE_OK) {
            int count=0;
            while (sqlite3_step(statement420) == SQLITE_ROW)
            {
                printf("count %d\n",count);
                count++;
                if ((const char *) sqlite3_column_text(statement420, 13)) {
                    sqlite3_stmt *statement520;
                    
                    char sql_stmt520[160];
                    sprintf(sql_stmt520, "SELECT package FROM Packages WHERE package = \"%s\" LIMIT 1",(const char *)sqlite3_column_text(statement420, 13));
                    //printf("our statement: %s\n",sql_stmt520);
                    if (sqlite3_prepare_v2(database1, sql_stmt520, -1, &statement520, NULL) == SQLITE_OK) {
                        //printf("hi:");
                        short didReceiveRow=0;
                        while (sqlite3_step(statement520) == SQLITE_ROW)
                        {
                            //printf("hello");
                            didReceiveRow=1;
                        }
                        if (didReceiveRow==0) {
                            //printf("helo still here?");
                            // add package to diff db
                            char *part2String=NULL;
                            part2String=realloc(NULL, 23*sizeof(char));
                            strcpy(part2String, "INSERT INTO Packages (");
                            
                            char *valuesForString=(char *)malloc(sizeof(char));
                            strcpy(valuesForString, "");
                            
                            for (int i=0; i<26; i++) {
                                if (sqlite3_column_text(statement420, i)) {
                                    part2String=(char *)realloc(part2String, (5+strlen(part2String)+strlen(sqlite3_column_name(statement420, i)))*sizeof(char));
                                    
                                    snprintf(part2String, (5+strlen(part2String)+strlen(sqlite3_column_name(statement420, i)))*sizeof(char), "%s'%s', ",part2String,sqlite3_column_name(statement420, i));
                                    
                                    //printf("pt2str: %s\n",part2String);
                                    
                                    valuesForString=(char *)realloc(valuesForString, (5+strlen(valuesForString)+strlen((const char *) sqlite3_column_text(statement420, i)))*sizeof(char));
                                    snprintf(valuesForString, (5+strlen(valuesForString)+strlen((const char *) sqlite3_column_text(statement420, i)))*sizeof(char), "%s'%s', ",valuesForString,(const char *) sqlite3_column_text(statement420, i));
                                    
                                    //printf("vfs: %s\n",valuesForString);
                                    
                                }
                            }/*
                              
                              
                              if (strcmp((const char *) sqlite3_column_text(statement, i), (const char *) sqlite3_column_text(statement2, i)) != 0) {
                              if (rowsDiffer==0) {
                              if (!finalOutput) {
                              finalOutput=realloc(NULL, 21*sizeof(char));
                              strcpy(finalOutput, "UPDATE Packages SET ");
                              } else {
                              finalOutput=(char *)realloc(finalOutput, (strlen(finalOutput)+21)*sizeof(char));
                              strcat(finalOutput, "UPDATE Packages SET ");
                              }
                              
                              rowsDiffer=1;
                              }
                              
                              char *newstring=(char *)malloc((strlen(finalOutput)+strlen(sqlite3_column_name(statement2, i))+strlen((const char *) sqlite3_column_text(statement2, i))+8)*sizeof(char));
                              snprintf(newstring, 8+strlen(sqlite3_column_name(statement2, i))+strlen((const char *) sqlite3_column_text(statement2, i)), "'%s'='%s', ",sqlite3_column_name(statement2, i),(const char *) sqlite3_column_text(statement2, i));
                              
                              finalOutput=(char *)realloc(finalOutput, (strlen(finalOutput)+strlen(newstring))*sizeof(char));
                              strcat(finalOutput, newstring);
                              free(newstring);
                              }
                              } else {
                              printf("First db column value is set, but second db column value isn't\n");
                              if (rowsDiffer==0) {
                              if (!finalOutput) {
                              finalOutput=realloc(NULL, 21*sizeof(char));
                              strcpy(finalOutput, "UPDATE Packages SET ");
                              } else {
                              finalOutput=(char *)realloc(finalOutput, (strlen(finalOutput)+21)*sizeof(char));
                              strcat(finalOutput, "UPDATE Packages SET ");
                              }
                              rowsDiffer=1;
                              }
                              
                              char *newstring=(char *)malloc((strlen(finalOutput)+strlen(sqlite3_column_name(statement2, i))+8)*sizeof(char));
                              snprintf(newstring, (8+strlen(sqlite3_column_name(statement2, i)))*sizeof(char), "'%s'='', ",sqlite3_column_name(statement2, i));
                              
                              finalOutput=(char *)realloc(finalOutput, (strlen(finalOutput)+strlen(newstring))*sizeof(char));
                              strcat(finalOutput, newstring);
                              free(newstring);
                              
                              }
                              }*/
                            // commit diff
                            //if (rowsDiffer==1) {
                            
                            part2String[strlen(part2String)-2]='\0';
                            valuesForString[strlen(valuesForString)-2]='\0';
                            //printf("pt2s %s\n",part2String);
                            //printf("v4s %s\n",valuesForString);
                            
                            finalStringTwo=(char *)realloc(finalStringTwo, (strlen(finalStringTwo)+strlen(part2String)+strlen(valuesForString)+13)*sizeof(char));
                            
                            snprintf(finalStringTwo, (strlen(finalStringTwo)+strlen(part2String)+strlen(valuesForString)+13)*sizeof(char), "%s%s) VALUES (%s)\n",finalStringTwo,part2String,valuesForString);
                            
                            //printf("fs2: %s\n",finalStringTwo);
                            
                            //printf("BLAZE\n");
                            
                            //}
                            
                            //CODE HERE
                            /*(if (sqlite3_prepare_v2(database3, createRowStatement, -1, &statement620, NULL) == SQLITE_OK) {
                             for (int i=0; i<26; i++) {
                             //printf("520: %s", (const char *) sqlite3_column_text(statement420, i));
                             
                             sqlite3_bind_text(statement620, i+1, (const char *) sqlite3_column_text(statement420, i), -1, SQLITE_TRANSIENT);
                             }
                             
                             // commit diff
                             //printf("commiting now");
                             if (sqlite3_step(statement620) != SQLITE_OK)
                             {
                             //printf("error: %s",sqlite3_errmsg(database3));
                             } else {
                             //printf("all good");
                             }
                             sqlite3_reset(statement620);
                             sqlite3_finalize(statement620);
                             
                             
                             }*/
                            
                        } else {
                            //printf("there was an error ;_; %s",sqlite3_errmsg(database1));
                            
                        }
                    } else {
                        //printf("error : %s\n",sqlite3_errmsg(database1));
                    }
                    
                }
            }
        } else {
            //printf("there was an error :| %s",sqlite3_errmsg(database2));
        }
        finalOutput=(char *)realloc(finalOutput, (strlen(finalOutput)+strlen(finalStringTwo))*sizeof(char));
        strcat(finalOutput, finalStringTwo);
        FILE *fp = fopen(argv[3], "ab");
        if (fp != NULL)
        {
            fputs(finalOutput, fp);
            fclose(fp);
        }
        
    } else {
        
        //printf("Failed to open database: %s\n",sqlite3_errmsg(database1));
    }
    
    
    
    
    return 0;
}
