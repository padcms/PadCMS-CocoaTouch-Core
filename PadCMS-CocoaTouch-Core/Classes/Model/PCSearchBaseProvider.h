//
//  PCSearchBaseProvider.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Oleg Zhitnik on 31.07.12.
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
#import "PCRevision.h"
#import "PCSearchProviderDelegate.h"
#import "PCSearchResult.h"

/**
 @class PCSearchBaseProvider
 @brief Base class that provides and manage searching. For using search in PadCMS, subclass it
 */
@interface PCSearchBaseProvider : NSObject

/**
 @brief Object that receiving notifications from searching thread (performed in main-thread)
 */ 
@property (atomic, assign) id<PCSearchProviderDelegate> delegate;

/**
 @brief Searching regexp string
 */ 

@property (nonatomic, retain) NSString *keyPhraseRegexp;

/**
 @brief Searching in progress flag
 */ 
@property (nonatomic, assign) BOOL searchInPorgress;

/**
 @brief Searching result
 */ 
@property (atomic, retain) PCSearchResult *result;

/**
 @brief Searching thread
 */ 
@property (nonatomic, assign) NSThread *searchingThread;

/**
 @brief Revision for searching
 */ 
@property (nonatomic, assign) PCRevision *targetRevision;



/**
 @brief Returns new instance of PCSearchBaseProvider class
 @param keyPhrase - searching keyphrase entered by user
 */ 
-(id) initWithKeyPhrase:(NSString*) keyPhrase;

/**
 @brief Returns searching regexp string generated from users keyphrase
 @param keyphrase - searching keyphrase entered by user
 */ 
-(NSString*) searchingRegexpFromKeyPhrase:(NSString*) keyphrase;

/**
 @brief Returns TRUE if string contains searching regexp
 @param string - string inside which will we search
 */ 
-(BOOL) isStringContainsRegexp:(NSString*) string;

/**
 @brief Start searching process in specified revision
 @param revision - revision inside which will we search, if nil - search in all revisions
 */ 
-(void) searchInRevision:(PCRevision*) revision;

/**
 @brief Cancel searching process
 */ 
-(void) cancelSearch;

/**
 @brief Searching thread
 */ 
- (void) searchThread:(id)someObject;

/**
 @brief Tell to delegate that the search process is started
 */ 
- (void) callDelegateTaskStarted;

/**
 @brief Tell to delegate that the search process is finished
 */ 
- (void) callDelegateTaskFinished;

/**
 @brief Tell to delegate that the search process is canceled
 */ 
- (void) callDelegateTaskCanceled;

/**
 @brief Tell to delegate that the search process updated result with new element
 */ 
- (void) callDelegateTaskUpdated;

/**
 @brief Search stub method, must be overrided in subclasses
 */ 
- (void) search;

@end
