//
//  PCPathHelper.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 16.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCPathHelper : NSObject

+ (void)createDirectoryIfNotExists:(NSString *)path;

+ (NSString *)pathForPrivateDocuments;
+ (NSString *)pathForApplicationWithId:(NSUInteger)applicationId;
+ (NSString *)pathForIssueWithId:(NSUInteger)issueId applicationId:(NSUInteger)applicationId;
+ (NSString *)pathForRevisionWithId:(NSUInteger)revisionId issueId:(NSUInteger)issueId 
                      applicationId:(NSUInteger)applicationId;
+ (NSString *)databaseFileNameForRevisionWithId:(NSUInteger)revisionId issueId:(NSUInteger)issueId 
                                  applicationId:(NSUInteger)applicationId;

@end
