//
//  PCDownloadManager.h
//  Pad CMS
//
//  Created by Alexey Petrosyan on 4/30/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>


PADCMS_EXTERN NSString* primaryKey;
PADCMS_EXTERN NSString* secondaryKey;


typedef enum _ItemType {
  PAGE = 0,
  VERTICAL_TOC  = 1,
  VERTICAL_HELP= 2,
  HORIZONTAL_HELP = 3,
  HORIZONTAL_TOC = 4,
  THUMBNAIL = 5,
	HORIZONTAL_SCROLLING_PANE = 6
} ItemType;

@class PCRevision;

@interface PCDownloadManager : NSObject

@property(retain) PCRevision* revision;
@property(retain) NSMutableDictionary* operationsDic;
@property(retain) NSMutableArray* portraiteTocOperations;
@property(retain) NSMutableDictionary* helpOperations;
@property(retain) NSMutableDictionary* horizontalPageOperations;
@property(retain) NSMutableArray* horizontalTocOperations;
@property BOOL isReady;

+ (PCDownloadManager *)sharedManager;

-(void)startDownloading;

-(void)cancelAllOperations;

@end
