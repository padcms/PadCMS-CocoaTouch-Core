//
//  PCPathHelper.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 16.02.12.
//  Copyright (c) PadCMS (http://www.padcms.net)
//
//
//  This software is governed by the CeCILL-C  license under French law and
//  abiding by the rules of distribution of free software.  You can  use,
//  modify and/ or redistribute the software under the terms of the CeCILL-C
//  license as circulated by CEA, CNRS and INRIA at the following URL
//  "http://www.cecill.info".
//  
//  As a counterpart to the access to the source code and  rights to copy,
//  modify and redistribute granted by the license, users are provided only
//  with a limited warranty  and the software's author,  the holder of the
//  economic rights,  and the successive licensors  have only  limited
//  liability.
//  
//  In this respect, the user's attention is drawn to the risks associated
//  with loading,  using,  modifying and/or developing or reproducing the
//  software by the user in light of its specific status of free software,
//  that may mean  that it is complicated to manipulate,  and  that  also
//  therefore means  that it is reserved for developers  and  experienced
//  professionals having in-depth computer knowledge. Users are therefore
//  encouraged to load and test the software's suitability as regards their
//  requirements in conditions enabling the security of their systems and/or
//  data to be ensured and,  more generally, to use and operate it in the
//  same conditions as regards security.
//  
//  The fact that you are presently reading this means that you have had
//  knowledge of the CeCILL-C license and that you accept its terms.
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
