//
//  PCSearchProvider.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 01.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PCSearchTaskDelegate.h"
#import "PCApplication.h"

@class PCRevision;
@class PCSearchTask;

/**
 @class PCSearchProvider
 @brief Singletone that provides search functionality entry-point
 */
@interface PCSearchProvider : NSObject

/**
 @brief Returns initialized PCSearchTask task instance
 @param keyphrase - searching keyphrase entered by user
 @param magazine - current magazine if the search was initiated from magazine viewing mode, or nil else
 @param delegate - object that receiving notifications from search task
 */
+ (PCSearchTask *)searchWithKeyphrase:(NSString *)keyphrase
                             revision:(PCRevision *)revision 
                             delegate:(id<PCSearchTaskDelegate>)delegate
                          application:(PCApplication*) application;

@end
