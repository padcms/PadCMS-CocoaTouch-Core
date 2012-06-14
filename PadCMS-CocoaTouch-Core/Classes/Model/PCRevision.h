//
//  PCRevision.h
//  Pad CMS
//
//  Created by Maxim Pervushin on 4/26/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

PADCMS_EXTERN NSString * const PCHelpItemDidDownloadNotification;
PADCMS_EXTERN NSString * const PCHorizontalPageDidDownloadNotification;
PADCMS_EXTERN NSString * const PCHorizontalTocDidDownloadNotification;

typedef void (^PCRevisionDownloadSuccessBlock)();
typedef void (^PCRevisionDownloadFailedBlock)(NSError *error);
typedef void (^PCRevisionDownloadCanceledBlock)();
typedef void (^PCRevisionDownloadProgressBlock)(float progress);

@class PCPage;
@class PCIssue;

@protocol PCDownloadProgressProtocol;


typedef enum
{
    PCRevisionStateUnknown = 0, ///< Unknown state. This state set by default with PCMagazine initialization. After magazine data is loaded the state changes either to PCMagazinePublishedState or PCMagazineWorkInProgressState. This state means that magazine data wasn't initialized or it was initialized with errors.
    PCRevisionStateWorkInProgress = 1, ///< Work on magazine is in progress and it's not published yet. Such magazines can be viewed by super users only.
    PCRevisionStatePublished = 2, ///< Magazine is published 
    PCRevisionStateArchived = 3, ///< Magazine is archived. Currently isn't used by reader.
    PCRevisionStateForReview = 4 ///< Magazine is on review. Currently isn't used by reader.
} PCRevisionState; ///< The enumeration of magazine state

@interface PCRevision : NSObject

@property (readonly) NSString *contentDirectory;
@property (nonatomic, assign) PCIssue *issue;
@property (nonatomic, assign) NSInteger identifier;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) UIColor *color;
@property (nonatomic, retain) NSDate *createDate;
@property (nonatomic, retain) NSDate *updateDate;
@property (nonatomic, assign) PCRevisionState state; 
@property (nonatomic, retain) NSURL *coverImageListURL;
@property (nonatomic, retain) NSMutableArray *toc;
@property (nonatomic, retain) NSMutableArray *pages;
@property (nonatomic, assign) BOOL horizontalMode;
@property (nonatomic, assign) BOOL horizontalOrientation;
@property (nonatomic, retain) NSMutableDictionary *horizontalPages;
@property (nonatomic, retain) NSMutableDictionary* horisontalTocItems;
@property (nonatomic,retain) NSMutableDictionary* horisontalPagesObjects;
@property (nonatomic, retain) NSDictionary *helpPages;
@property (nonatomic, retain) NSMutableArray *columns;
@property (nonatomic, retain) NSString *startVideo;
@property (nonatomic, assign) float horizontalHelpProgress;
@property (nonatomic, assign) float verticalHelpProgress;
@property (assign) BOOL isHorizontalHelpComplete;
@property (assign) BOOL isVerticalHelpComplete;
@property (nonatomic, assign) id<PCDownloadProgressProtocol> progressDelegate;
@property (nonatomic, retain) AFHTTPRequestOperation *downloadOperation;
@property (nonatomic, retain) AFHTTPRequestOperation *downloadStartVideoOperation;

/**
 @brief Designated initializer.
 @param Dictionary with parameters to initialize instance
 @param Root directory for content
 */ 
- (id)initWithParameters:(NSDictionary *)parameters rootDirectory:(NSString *)rootDirectory;

- (UIImage *)coverImage;

- (void)deleteContent;

/**
 @brief Build or update columns from pages. Those should be define before this method calling.
 */ 
- (void)updateColumns;

/**
 @brief Return a page by specific identifier.
 
 @param aIdentifier - page identifier.
 */ 
- (PCPage *)pageWithId:(NSInteger)identifier;

/**
 @brief Return a page by specific Link. Link can be recieved from linkForConnector: method of PCPage class. 
 
 @param link - page link.
 */ 
- (PCPage *)pageForLink:(id)link;

/**
 @brief Return a page by specific name. 
 
 @param machineName - specific page name.
 */ 
- (PCPage *)pageWithMachineName:(NSString *)machineName;

/**
 @brief Return revision cover page  
 */ 
- (PCPage *)coverPage;

/**
 @brief Return TRUE if revision database file exists
 */ 
- (BOOL)isDownloaded;

/**
 @brief Download and load database if success
 */ 
- (void)download:(PCRevisionDownloadSuccessBlock)successCallback failed:(PCRevisionDownloadFailedBlock) failedCallback canceled:(PCRevisionDownloadCanceledBlock) canceledCallback progress:(PCRevisionDownloadProgressBlock) progressCallback;

/**
 @brief Cancel download process
 */ 
- (void)cancelDownloading;

@end
