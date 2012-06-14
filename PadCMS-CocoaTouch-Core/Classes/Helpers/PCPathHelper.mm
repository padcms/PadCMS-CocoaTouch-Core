//
//  PCPathHelper.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 16.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPathHelper.h"
#include <sys/xattr.h>

#define ApplicationsFolderName @"Applications"
#define PrivateDocumentsFolderName @"PrivateDocuments"
#define DatabaseFileName @"sqlite.db"

@interface PCPathHelper ()

+ (void)createDirectoryIfNotExists:(NSString *)path;

@end

@implementation PCPathHelper

+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)path
{
    const char* filePath = [path fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

/*
+ (NSString*) issuesFolder
{
	
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    if ([paths count] < 1)
        return nil;
	NSString* docDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:PrivateDocumentsFolderName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:docDirectory])
    {
        BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:docDirectory withIntermediateDirectories:NO attributes:nil error:nil];
        if(result)
        {
            [self addSkipBackupAttributeToItemAtPath:docDirectory];
        }
    }
    
	return docDirectory;
}


+(NSString*)folderForePathForRevisionID:(NSInteger)issueID
{
    return [[self issuesFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",issueID]];
}

+(NSString*)sqliteBasePathForRevisionID:(NSInteger)issueID
{
    return [[self folderForePathForRevisionID:issueID] stringByAppendingPathComponent:DatabaseFileName];
}*/

#pragma mark - multi application version 

+ (NSString *)pathForPrivateDocuments
{
    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *libraryPath = [libraryPaths objectAtIndex:0];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@", libraryPath, PrivateDocumentsFolderName];

    return path;
}

+ (void)createDirectoryIfNotExists:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:path])
    {    
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES 
                                attributes:nil error:nil];
    }
}

+ (NSString *)pathForApplicationWithId:(NSUInteger)applicationId
{
    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *libraryPath = [libraryPaths objectAtIndex:0];

    NSString *path = [NSString stringWithFormat:@"%@/%@/%d", libraryPath, PrivateDocumentsFolderName, 
                      applicationId];
    
    [PCPathHelper createDirectoryIfNotExists:path];
    
    return path;
}

+ (NSString *)pathForIssueWithId:(NSUInteger)issueId applicationId:(NSUInteger)applicationId
{
    NSString *path = [NSString stringWithFormat:@"%@/%d", 
                      [PCPathHelper pathForApplicationWithId:applicationId], issueId];
    
    [PCPathHelper createDirectoryIfNotExists:path];
    
    return path;
}

+ (NSString *)pathForRevisionWithId:(NSUInteger)revisionId issueId:(NSUInteger)issueId 
                      applicationId:(NSUInteger)applicationId
{
    NSString *path = [NSString stringWithFormat:@"%@/%d", 
                      [PCPathHelper pathForIssueWithId:issueId applicationId:applicationId], 
                      revisionId];
    
    [PCPathHelper createDirectoryIfNotExists:path];
    
    return path;
}

+ (NSString *)databaseFileNameForRevisionWithId:(NSUInteger)revisionId issueId:(NSUInteger)issueId 
                                  applicationId:(NSUInteger)applicationId
{
    return [NSString stringWithFormat:@"%@/%@", 
            [PCPathHelper pathForRevisionWithId:revisionId issueId:issueId
                                  applicationId:applicationId], 
            DatabaseFileName];
}

@end
