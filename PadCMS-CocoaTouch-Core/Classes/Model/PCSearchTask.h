//
//  PCSearchTask.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 02.03.12.
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
