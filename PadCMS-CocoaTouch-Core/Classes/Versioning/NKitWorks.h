//
//  NSKitWorks.h
//  the_reader
//
//  Created by User on 17.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NewsstandKit/NewsstandKit.h>

@class NKitCustomDeletage;

@interface NKitWorks : NSObject
{
@private
    NSMutableDictionary *extendedDownloads;
}

@property (nonatomic, retain) NSMutableDictionary *extendedDownloads;

+ (void) addIssueWithName:(NSString *) name date:(NSDate *) date;
+ (NKIssue *) issueWithName:(NSString *) name;

+ (void) updateExtendedDownloads;
+ (NKitCustomDeletage *) getDelegateForIssue:(NSString*) issueName;

@end

@interface NKitCustomDeletage : NSObject <NSURLConnectionDownloadDelegate>
{
@private
    id<NSURLConnectionDownloadDelegate> delegate;
}

@property (nonatomic, retain) id<NSURLConnectionDownloadDelegate> delegate;

@end