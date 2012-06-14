//
//  PCSearchTask.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 02.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCSearchResult.h"
#import "PCSearchTaskDelegate.h"
#import "PCApplication.h"

@class PCRevision;
/**
 @class PCSearchTask
 @brief This class implements searching in magazines
 */
@interface PCSearchTask : NSObject
{
    PCRevision *revision;   ///< current revision if the search was initiated from magazine viewing mode, or nil else
}

/**
 @brief The key phrase for search
 */ 
@property (nonatomic, retain) NSString *keyphrase;

/**
 @brief The regular expression for search, created from the key phrase
 */ 
@property (nonatomic, retain) NSString *keyphraseRegexp;

/**
 @brief Searching result
 */ 
@property (atomic, retain) PCSearchResult *result;

/**
 @brief Background thread that perform search
 */ 
@property (atomic, assign) NSThread *searchingThread;

/**
 @brief object that receiving notifications from searching thread (performed in main-thread)
 */ 
@property (atomic, assign) id<PCSearchTaskDelegate> delegate;

/**
 @brief main application object
 */ 
@property (atomic, assign) PCApplication *application;

/**
 @brief Returns new initialized instance of the PCSearchTask class
 @param smagazine - current magazine if the search was initiated from magazine viewing mode, or nil else
 @param skeyphrase - searching keyphrase entered by user
 @param sdelegate - object that receiving notifications from search task
 */ 
- (id)initWithRevision:(PCRevision *)srevision
             keyPhrase:(NSString *)skeyphrase 
              delegate:(id<PCSearchTaskDelegate>)sdelegate
           application:(PCApplication*) application;

/**
 @brief Starts searching process
 */ 
-(void) startSearch;

/**
 @brief Cancel searching process
 */ 
-(void) cancelSearch;

@end
