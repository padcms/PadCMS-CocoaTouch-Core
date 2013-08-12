//
//  VersionManager.h
//  temp
//
//  Created by mark on 1/31/11.
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
#import "Reachability.h"
#import "PadCMSCoder.h"

@interface VersionManager : NSObject <PadCMSCodeDelegate>
{
	BOOL kioskTapped;
}

+ (VersionManager*)sharedManager;

@property (nonatomic, retain) NSMutableArray* items;
@property (nonatomic, retain) Reachability* reachability;
//@property (nonatomic, retain) PadCMSCoder* coder;


//- (void) navigatorShouldAppear;
- (void) extractRevisionsFromServer;
- (void) mergeAdminItems;

- (int) revision:(int)index;


- (void)updateTotal_bytes:		(int)value			index:(int)index;
- (void)updateServer_filename:	(NSString*)value	index:(int)index;
- (void)updateReadyState:		(BOOL)value			index:(int) index;
- (void)updateResize_done:		(int)value			index:(int)index;
- (void)updateResize_total:		(int)value			index:(int)index;
- (void) updateNewsstandIcon:(int) index;
- (NSString *) price:			(int)index;

- (NSString*)cover:(int)index;
- (NSString*)caption:(int)index;
- (NSString*)revision_caption:(int)index;
- (NSString*)server_filename:(int)index;
- (int)total_bytes:(int)index;
- (BOOL) readyState:(int) index;
- (BOOL) didPayed:(int)index;
- (int) issue_id:(int)index;
- (NSString *) productId: (int) index;

- (void) store;
- (void) removeFromMemory;

- (void) reloadAllData;
- (void) loadProductPrices;

- (void) appLoaded;
- (void) kioskTap;

@end
