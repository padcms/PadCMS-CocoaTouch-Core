//
//  VersionManager.h
//  temp
//
//  Created by mark on 1/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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