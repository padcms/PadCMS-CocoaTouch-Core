//
//  PadCMSCoder.h
//  temp
//
//  Created by mark on 1/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


#define reloadCellNotification @"reloadCellNotification"


@protocol PadCMSCodeDelegate <NSObject>
//- (void) reloadAllData;
	-(void)restartApplication;
@end

@interface PadCMSCoder : NSObject
{
	id <PadCMSCodeDelegate> padDelegate;
}

@property  BOOL validUDID;
@property  BOOL isAdminUDID;
//@property (retain) NSMutableArray* filter;

- (id) initWithDelegate:(id <PadCMSCodeDelegate>) padDelegate;
//- (BOOL) syncServerPlistDownloadToDirectory:(NSString *)directory;
- (BOOL) syncServerPlistDownload;
//- (void) reloadFilter;

@end