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
 @brief Class that provides and manage searching
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
 @brief Searching result (array)
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
 @brief
 */ 
-(id) initWithKeyPhrase:(NSString*) keyPhrase;

/**
 @brief
 */ 
-(NSString*) searchingRegexpFromKeyPhrase:(NSString*) keyphrase;

/**
 @brief
 */ 
-(BOOL) isStringContainsRegexp:(NSString*) string;

/**
 @brief
 */ 
-(void) searchInRevision:(PCRevision*) revision;

/**
 @brief
 */ 
-(void) cancelSearch;

/**
 @brief
 */ 

- (void) searchThread:(id)someObject;
/**
 @brief
 */ 

- (void) callDelegateTaskStarted;
/**
 @brief
 */ 

- (void) callDelegateTaskFinished;
/**
 @brief
 */ 

- (void) callDelegateTaskCanceled;
/**
 @brief
 */ 

- (void) callDelegateTaskUpdated;

/**
 @brief
 */ 
- (void) search;

@end
