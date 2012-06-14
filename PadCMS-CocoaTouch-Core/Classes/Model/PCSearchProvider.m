//
//  PCSearchProvider.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 01.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCSearchProvider.h"
#import "PCSearchTask.h"

@interface PCSearchProvider (Private)
+ (PCSearchProvider*)GetInstance;
- (PCSearchTask *)searchWithKeyphrase:(NSString *)keyphrase
                             revision:(PCRevision *)revision 
                             delegate:(id<PCSearchTaskDelegate>)delegate
                          application:(PCApplication*) application;
@end

@implementation PCSearchProvider

static PCSearchProvider *instance = nil;

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

+ (PCSearchTask *)searchWithKeyphrase:(NSString *)keyphrase
                             revision:(PCRevision *)revision 
                             delegate:(id<PCSearchTaskDelegate>)delegate
                          application:(PCApplication*) application
{
    return [[PCSearchProvider GetInstance] searchWithKeyphrase:keyphrase
                                                      revision:revision
                                                      delegate:delegate
                                                   application:application];
}

#pragma mark --- Private ---

+ (PCSearchProvider*)GetInstance
{
    if (instance == nil)
    {
        instance = [[PCSearchProvider alloc] init];
    }
    
    return instance;
}

- (PCSearchTask *)searchWithKeyphrase:(NSString *)keyphrase
                             revision:(PCRevision *)revision 
                             delegate:(id<PCSearchTaskDelegate>)delegate
                          application:(PCApplication*) application
{
    PCSearchTask *searchTask = [[PCSearchTask alloc] initWithRevision:revision 
                                                            keyPhrase:keyphrase 
                                                             delegate:delegate
                                                          application:application];
    
    return [searchTask autorelease];
}

@end
