//
//  MagThreadQueue.h
//  the_reader
//
//  Created by User on 14.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "MagManager.h"

//#define ColumnLoadNotification @"ColumnLoadNotification"
//3define

@class MagManager;

@interface MagThreadQueue : NSObject
{
	NSArray *columns;
	NSOperationQueue *queue;

	int prevIndex;
	
	BOOL blocked;
}

@property (readonly) int prevIndex;
@property (getter = isBlocked) BOOL blocked;

+ (MagThreadQueue *) sharedInstance;

- (void) addOperationWithPath:(NSString *) path columnIndex:(int) index;
- (void) setCurrentIndex:(int) index;


@end
