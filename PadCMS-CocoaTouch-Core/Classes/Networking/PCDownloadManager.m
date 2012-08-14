//
//  PCDownloadManager.m
//  Pad CMS
//
//  Created by Alexey Igoshev on 4/30/12.
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

#import "PCDownloadManager.h"

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "AFNetworking.h"
#import "Helper.h"
#import "PCColumn.h"
#import "PCConfig.h"
#import "PCDownloadOperation.h"
#import "PCHorizontalPage.h"
#import "PCPage.h"
#import "PCPageElement.h"
#import "PCPageElementMiniArticle.h"
#import "PCPageElemetTypes.h"
#import "PCPageTemplate.h"
#import "PCPageTemplatesPool.h"
#import "PCRevision.h"
#import "PCTocItem.h"
//#import "UIImage+Saving.h"
#import "ZipArchive.h"
#import "PCPageElementGallery.h"
#import "PCLocalizationManager.h"


@interface PCDownloadManager()
{
    AFHTTPClient *_httpClient;
}

-(void)launchCoverPageDownloading;
-(void)launchPortraitPagesDownloading;
-(void)launchDownloadingForPage:(PCPage*)page;
-(void)launchTocDownloading;
-(void)launchHelpDownloading;
-(void)launchHorizonalPagesDownload;
-(void)launchHorizontalTocDownload;
-(void)addOperationsForPage:(PCPage*)page;
-(void)addOperationForResourcePath:(NSString*)path element:(PCPageElement*)element inPage:(PCPage*)page isPrimary:(BOOL)isPrimary isThumbnail:(BOOL) isThumbnail resumeOperation:(PCDownloadOperation*)canceledOperation;
-(NSString*)getUrlForResource:(NSString*)resource withType:(ItemType) type withHorizontalOrientation:(BOOL) horizontalOrientation;
-(AFHTTPRequestOperation*)operationWithURL:(NSString*)url
                              successBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                             progressBlock:(void (^)(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)) progressBlock
                              itemLocation:(NSString*)locationPath;
-(void)moveItemWithPath:(NSString*)filePath;
-(NSString*)streamForFilePath:(NSString*)path;

@end

NSString* primaryKey     = @"primaryKey";
NSString* secondaryKey   = @"secondaryKey";

@implementation PCDownloadManager

@synthesize revision=_revision;
@synthesize operationsDic=_operationsDic;
@synthesize portraiteTocOperations=_portraiteTocOperations;
@synthesize isReady=_isReady;
@synthesize helpOperations=_helpOperations;
@synthesize horizontalPageOperations=_horizontalPageOperations;
@synthesize horizontalTocOperations=_horizontalTocOperations;
@synthesize callbackQueue=_callbackQueue;

+ (PCDownloadManager *)sharedManager {
  static PCDownloadManager *_sharedManager = nil;
  static dispatch_once_t oncePredicate;
  dispatch_once(&oncePredicate, ^{
    _sharedManager = [[self alloc] init];
  });
  
  return _sharedManager;
}

-(id)init
{
  self = [super init];
  if (self != nil) {
		
    _isReady = NO;
      
      NSURL *serverURL = [PCConfig serverURL];
      
      if (serverURL != nil) {
          _httpClient = [[AFHTTPClient alloc] initWithBaseURL:serverURL];
          _httpClient.operationQueue.maxConcurrentOperationCount = 1;
          [_httpClient addObserver:self 
                        forKeyPath:@"networkReachabilityStatus" 
                           options:NSKeyValueObservingOptionNew 
                           context:NULL];
      }

  }
  return self;

}

- (void)setRevision:(PCRevision *)revision
{
    @synchronized (self) {
        [_revision release];
        _revision = [revision retain];
        
        if (_httpClient != nil) {
            [_httpClient removeObserver:self forKeyPath:@"networkReachabilityStatus"];
            [_httpClient release];
        }
        _httpClient = [[AFHTTPClient alloc] initWithBaseURL:_revision.backEndURL];
        _httpClient.operationQueue.maxConcurrentOperationCount = 1;
        [_httpClient addObserver:self 
                      forKeyPath:@"networkReachabilityStatus" 
                         options:NSKeyValueObservingOptionNew 
                         context:NULL];
    }
}

- (PCRevision *)revision
{
    PCRevision *result = nil;
    
    @synchronized (self) {
        result = [[_revision retain] autorelease];
    }
    
    return result;
}

-(void) observeValueForKeyPath: (NSString *)keyPath ofObject: (id) object
                        change: (NSDictionary *) change context: (void *) context
{
	if([change objectForKey:NSKeyValueChangeNewKey] != [NSNull null] && [change objectForKey:NSKeyValueChangeOldKey] != [NSNull null]) 
	{
		AFNetworkReachabilityStatus newStatus = [[change objectForKey: NSKeyValueChangeNewKey] intValue];
		AFNetworkReachabilityStatus oldStatus = [[change objectForKey: NSKeyValueChangeOldKey] intValue];
		if (newStatus == AFNetworkReachabilityStatusNotReachable)
		{
			NSString* message = [PCLocalizationManager localizedStringForKey:@"MSG_NO_NETWORK_CONNECTION"
                                                                       value:@"You must be connected to the Internet."];

            NSString    *title = [PCLocalizationManager localizedStringForKey:@"TITLE_WARNING"
                                                                        value:@"Warning!"];

            NSString    *buttonTitle = [PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_OK"
                                                                        value:@"OK"];
            
			dispatch_async(dispatch_get_main_queue(), ^{
				UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                                message:message
                                                               delegate:nil
                                                      cancelButtonTitle:buttonTitle
                                                      otherButtonTitles:nil];
				[alert show];
				[alert release];
			});
		}
		else if ((oldStatus == AFNetworkReachabilityStatusNotReachable) && ((newStatus == AFNetworkReachabilityStatusReachableViaWiFi) || (newStatus == AFNetworkReachabilityStatusReachableViaWWAN)) )
		{
			NSLog(@"Network now available!");
			[self startDownloading];
		}
	}
}

-(void)startDownloading
{
    if (!self.revision) return;
    if (_httpClient.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) 
    {
        NSString* message = [PCLocalizationManager localizedStringForKey:@"MSG_NO_NETWORK_CONNECTION"
                                                                   value:@"You must be connected to the Internet."];
        
        NSString    *title = [PCLocalizationManager localizedStringForKey:@"TITLE_WARNING"
                                                                    value:@"Warning!"];

        NSString    *buttonTitle = [PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_OK"
                                                                          value:@"OK"];
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:buttonTitle
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
        
    }
    [self clearData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boost:) name:PCBoostPageNotification object:nil];
    self.operationsDic = [NSMutableDictionary dictionary];
	self.callbackQueue = dispatch_queue_create("com.adyax.mag.success", NULL);
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ((orientation == UIInterfaceOrientationPortrait) || (orientation == UIInterfaceOrientationPortraitUpsideDown))
    {
        [self launchCoverPageDownloading];
        [self launchTocDownloading];
        [self launchHelpDownloading];
        [self launchPortraitPagesDownloading];
        [self launchHorizontalTocDownload];
        [self launchHorizonalPagesDownload];
        
    }
    else {
        [self launchHorizontalTocDownload];
        [self launchHorizonalPagesDownload];
        [self launchCoverPageDownloading];
        [self launchTocDownloading];
        [self launchHelpDownloading];
        [self launchPortraitPagesDownloading];
        
    }
    self.isReady = YES;
}

-(void)launchCoverPageDownloading
{
  //Cover Page
  PCPage* cover = [self.revision coverPage];
  [self launchDownloadingForPage:cover];
}

-(void)launchPortraitPagesDownloading
{
    for (PCPage* page in self.revision.pages) {
        if (page == [self.revision coverPage]) {
            continue;   
        }
        [self launchDownloadingForPage:page];    
    }
}

-(void)launchDownloadingForPage:(PCPage*)page
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[page startRepeatingTimer];
	});
 
  [self addOperationsForPage:page];
  NSNumber* pageIdentifier = [NSNumber numberWithInteger:page.identifier];
  NSArray* primaryPageElements = [[self.operationsDic objectForKey:pageIdentifier] objectForKey:primaryKey];
  if ([primaryPageElements lastObject]) page.isComplete = NO;
    
  for (AFHTTPRequestOperation* operation in primaryPageElements) {
    [_httpClient enqueueHTTPRequestOperation:operation];
  }
 /* [[PCDownloadApiClient sharedClient] enqueueBatchOfHTTPRequestOperations:primaryPageElements progressBlock:^(NSUInteger numberOfCompletedOperations, NSUInteger totalNumberOfOperations) {
    
  } completionBlock:^(NSArray *operations) {
//    dispatch_async(dispatch_get_main_queue(), ^{
   //   [[NSNotificationCenter defaultCenter] postNotificationName:endOfDownloadingPageNotification object:page];
//      [page stopRepeatingTimer];
  //    page.isComplete = YES;
//    });
    
    
  }];*/
  
  [[[self.operationsDic objectForKey:pageIdentifier] objectForKey:secondaryKey] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
   
    AFHTTPRequestOperation* elementOperation = obj;
    [elementOperation setQueuePriority:NSOperationQueuePriorityLow];
    [_httpClient enqueueHTTPRequestOperation:elementOperation];
    
  }];

}

-(void)launchTocDownloading
{
  self.portraiteTocOperations = nil;
  _portraiteTocOperations = [[NSMutableArray alloc] init];
  for (PCTocItem* item in self.revision.toc)
  {
    NSString* stripeURLString = [self getUrlForResource:item.thumbStripe withType:VERTICAL_TOC withHorizontalOrientation:NO];
    AFHTTPRequestOperation* stripeOperation = [self operationWithURL:stripeURLString successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
      NSLog(@"Vertical toc item loaded");
      [self moveItemWithPath:[self.revision.contentDirectory stringByAppendingPathComponent:item.thumbStripe ]];
      [self.portraiteTocOperations removeObject:operation];
      if (![self.portraiteTocOperations lastObject]) {
        self.portraiteTocOperations = nil;
        NSLog(@"Vertical TOC loaded");
        dispatch_async(dispatch_get_main_queue(), ^{
          [[NSNotificationCenter defaultCenter] postNotificationName:endOfDownloadingTocNotification object:nil userInfo:nil];
          
        });
      }
    } progressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
      
    } itemLocation:item.thumbStripe];
    [stripeOperation setQueuePriority:NSOperationQueuePriorityVeryHigh];
    if (stripeOperation) [self.portraiteTocOperations addObject:stripeOperation];
    NSString* summaryURLString = [self getUrlForResource:item.thumbSummary withType:VERTICAL_TOC withHorizontalOrientation:NO];
    AFHTTPRequestOperation* summaryOperation = [self operationWithURL:summaryURLString successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
      [self moveItemWithPath:[self.revision.contentDirectory stringByAppendingPathComponent:item.thumbSummary ]];
      [self.portraiteTocOperations removeObject:operation];
      if (![self.portraiteTocOperations lastObject]) {
        self.portraiteTocOperations = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
          [[NSNotificationCenter defaultCenter] postNotificationName:endOfDownloadingTocNotification object:nil userInfo:nil];
        });
      }
      
    } progressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
      
    } itemLocation:item.thumbSummary];
    [summaryOperation setQueuePriority:NSOperationQueuePriorityVeryHigh];
    if (summaryOperation) [self.portraiteTocOperations addObject:summaryOperation]; 
	  
	  UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	  if ((orientation == UIInterfaceOrientationPortrait) || (orientation == UIInterfaceOrientationPortraitUpsideDown))
	  {
		  [stripeOperation setQueuePriority:NSOperationQueuePriorityHigh];
		  [summaryOperation setQueuePriority:NSOperationQueuePriorityHigh];
	  }
	  else {
		  [stripeOperation setQueuePriority:NSOperationQueuePriorityHigh];
		  [summaryOperation setQueuePriority:NSOperationQueuePriorityHigh];
	  }
  }
	

  for (AFHTTPRequestOperation* operation in self.portraiteTocOperations) {
    [_httpClient enqueueHTTPRequestOperation:operation];
  }
  
  
 /* [[PCDownloadApiClient sharedClient] enqueueBatchOfHTTPRequestOperations:self.portraiteTocOperations progressBlock:^(NSUInteger numberOfCompletedOperations, NSUInteger totalNumberOfOperations) {
    
  } completionBlock:^(NSArray *operations) {
 //   dispatch_async(dispatch_get_main_queue(), ^{
 //     [[NSNotificationCenter defaultCenter] postNotificationName:endOfDownloadingTocNotification object:nil userInfo:nil];
  //    self.portraiteTocOperations = nil;
 //   });
    
  }];*/
 
  
}

-(void)launchHelpDownloading 
{
	self.helpOperations = nil;
	_helpOperations = [[NSMutableDictionary alloc] init];
	if (self.revision.helpPages&&[self.revision.helpPages count]>0) {
        NSArray     *keys = [self.revision.helpPages allKeys];        
        for (int i = 0; i<[keys count]; i++)
        {
            NSString* key = [keys objectAtIndex:i];
            NSString* resource  = [self.revision.helpPages objectForKey:key];
            
            NSString* filePath = [self.revision.contentDirectory stringByAppendingPathComponent:resource];
          //NSLog(@"Help filePath - %@", filePath);
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
            {
                continue;
            }
            
            NSString* pathExtension = [[resource pathExtension] lowercaseString];
			NSString* urlStr = nil;
			if ([pathExtension isEqualToString:@"png"] || [pathExtension isEqualToString:@"jpg"]
				||[pathExtension isEqualToString:@"jpeg"])
			{
				if ([key isEqualToString:@"horizontal"])
				{
          if ([Helper currentDeviceResolution] == RETINA)
          {
            urlStr = [NSString stringWithFormat:@"/resources/2048-1536%@", resource];
            // urlStr = [NSString stringWithFormat:@"/resources/1024-768%@", resource];
          }
          else {
            urlStr = [NSString stringWithFormat:@"/resources/1024-768%@", resource];
          }
					
				}
				else
				{
          if ([Helper currentDeviceResolution] == RETINA)
          {
            urlStr = [NSString stringWithFormat:@"/resources/1536-2048%@", resource];
           //  urlStr = [NSString stringWithFormat:@"/resources/768-1024%@", resource];
          }else {
            urlStr = [NSString stringWithFormat:@"/resources/768-1024%@", resource];
          }
					
				}
			} 
			else 
			{
				urlStr = resource;
			}
          NSLog(@"Help url - %@", urlStr);
			AFHTTPRequestOperation* helpOperation = [self operationWithURL:urlStr successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
				[self moveItemWithPath:filePath];
				[self.helpOperations removeObjectForKey:key];
				if (![[self.helpOperations allValues] lastObject]) self.helpOperations = nil;
				NSLog(@"help download finished");
				if ([key isEqualToString:@"horizontal"]) self.revision.isHorizontalHelpComplete = YES;
				else self.revision.isVerticalHelpComplete = YES;
				
				dispatch_async(dispatch_get_main_queue(), ^{
					[[NSNotificationCenter defaultCenter] postNotificationName:PCHelpItemDidDownloadNotification object:nil userInfo:[NSDictionary dictionaryWithObject:key forKey:@"orientation"]];
				});
								
				
			} progressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
				 float progress = (float)totalBytesRead/(float)totalBytesExpectedToRead;
			if ([key isEqualToString:@"horizontal"])self.revision.horizontalHelpProgress = progress;
				else self.revision.verticalHelpProgress = progress;
			
			} itemLocation:resource];
			if (!helpOperation) continue;
			if ([key isEqualToString:@"horizontal"]) self.revision.isHorizontalHelpComplete = NO;
			else self.revision.isVerticalHelpComplete = NO;
			[helpOperation setQueuePriority:NSOperationQueuePriorityVeryLow];
			if (helpOperation) [self.helpOperations setObject:helpOperation forKey:key];
			[_httpClient enqueueHTTPRequestOperation:helpOperation];

            
            
        }
    }
}


-(void)launchHorizonalPagesDownload
{
	self.horizontalPageOperations = nil;
	_horizontalPageOperations = [[NSMutableDictionary alloc] init];
	if (self.revision.horizontalPages && [self.revision.horizontalPages count]>0) {
        NSArray     *keys = [self.revision.horizontalPages allKeys];        
        for (int i = 0; i<[keys count]; i++)
        {
            NSNumber* key = [keys objectAtIndex:i];
          [self addHorizontalOperationWithKey:key resumeOperation:nil];
                        
        }
    }
}

-(void)addHorizontalOperationWithKey:(NSNumber*)key resumeOperation:(PCDownloadOperation*)resumeOperation
{
  NSString* resource  = [self.revision.horizontalPages objectForKey:key];
  NSString* filePath = [self.revision.contentDirectory stringByAppendingPathComponent:resource];
  PCHorizontalPage* horizontalPage = [self.revision.horisontalPagesObjects objectForKey:key];
  
  
  if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
  {
    return;
  }
  
  NSString* pathExtension = [[resource pathExtension] lowercaseString];
  NSString* urlStr = nil;
  if ([pathExtension isEqualToString:@"png"] || [pathExtension isEqualToString:@"jpg"]
      ||[pathExtension isEqualToString:@"jpeg"])
  {
      // For horizontal pages always use retina images
      
    if ([Helper currentDeviceResolution] == RETINA)
   {
      urlStr = [NSString stringWithFormat:@"/resources/2048-1536%@", resource];
    }else {
      urlStr = [NSString stringWithFormat:@"/resources/1024-768%@", resource];
    }
    
  } else {
    urlStr = [NSString stringWithFormat:resource];
  }
  
	
  AFHTTPRequestOperation* horizontalOperation = [self operationWithURL:urlStr successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
    [self moveItemWithPath:filePath];
    [self.horizontalPageOperations removeObjectForKey:key];
    if (![[self.horizontalPageOperations allValues] lastObject]) self.horizontalPageOperations = nil;
    NSLog(@"Horizantal page downloaded - %@", key);
    horizontalPage.isComplete = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
      [[NSNotificationCenter defaultCenter] postNotificationName:PCHorizontalPageDidDownloadNotification object:self userInfo:[NSDictionary dictionaryWithObject:key forKey:@"id"]];
    });
    
    
  } progressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
    float progress = (float)totalBytesRead/(float)totalBytesExpectedToRead;
    dispatch_queue_t progressQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(progressQueue, ^{
      horizontalPage.downloadProgress = progress;
    });
    
    
    
  } itemLocation:resource];
  
  if(!horizontalOperation)return;
  horizontalPage.isComplete = NO;
  UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
  if ((orientation == UIInterfaceOrientationPortrait) || (orientation == UIInterfaceOrientationPortraitUpsideDown))
  {
    [horizontalOperation setQueuePriority:NSOperationQueuePriorityVeryLow];
  }
  else {
    [horizontalOperation setQueuePriority:NSOperationQueuePriorityHigh];
  }
  ((PCDownloadOperation*)horizontalOperation).horizontalPageKey = key;
  if (horizontalOperation) [self.horizontalPageOperations setObject:horizontalOperation forKey:key];
  [_httpClient enqueueHTTPRequestOperation:horizontalOperation];

}

-(void)launchHorizontalTocDownload
{
	self.horizontalTocOperations = nil;
	_horizontalTocOperations = [[NSMutableArray alloc] init];
	for (NSString* resource in [self.revision.horisontalTocItems allValues]) {
		
		NSString* urlString = [NSString stringWithFormat:@"/resources/204-153%@", resource];
		NSString* filePath = [[self.revision.contentDirectory stringByAppendingPathComponent:@"horisontal_toc_items"] stringByAppendingPathComponent:resource];
		
		AFHTTPRequestOperation* horizontalTocOperation = [self operationWithURL:urlString successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
      NSLog(@"Horizontal toc item downloaded");
			[self moveItemWithPath:filePath];
			[self.horizontalTocOperations removeObject:operation];
			if (![self.horizontalTocOperations lastObject])
      {
        self.horizontalTocOperations = nil;
        NSLog(@"horizontal toc download FINISHED");
        dispatch_async(dispatch_get_main_queue(), ^{
          [[NSNotificationCenter defaultCenter] postNotificationName:PCHorizontalTocDidDownloadNotification object:nil userInfo:nil];
        });
      }
      
			
			
		} progressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
			
			
			
		} itemLocation:[@"/horisontal_toc_items" stringByAppendingPathComponent:resource]];
		
		if (!horizontalTocOperation) continue;
		UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
		if ((orientation == UIInterfaceOrientationPortrait) || (orientation == UIInterfaceOrientationPortraitUpsideDown))
		{
			[horizontalTocOperation setQueuePriority:NSOperationQueuePriorityHigh];
		}
		else {
			[horizontalTocOperation setQueuePriority:NSOperationQueuePriorityHigh];
		}
		
		if (horizontalTocOperation) [self.horizontalTocOperations addObject:horizontalTocOperation];
		[_httpClient enqueueHTTPRequestOperation:horizontalTocOperation];
		
	}
	
}

-(void)addOperationsForPage:(PCPage*)page
{
   NSNumber* pageIdentifier = [NSNumber numberWithInteger:page.identifier];
   NSMutableDictionary* pageDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSMutableArray array], primaryKey,[NSMutableDictionary dictionary] ,secondaryKey, nil];
   [self.operationsDic setObject:pageDictionary forKey:pageIdentifier];
   BOOL isMiniArticleMet = NO;
   for (PCPageElement* element in page.primaryElements) 
   {
       if ([element isKindOfClass:[PCPageElementMiniArticle class]])
       {
           if (!isMiniArticleMet) 
           {
               [self addOperationForResourcePath:element.resource element:element inPage:page isPrimary:YES isThumbnail:NO resumeOperation:nil];
           }
           isMiniArticleMet = YES;
           PCPageElementMiniArticle* miniArticle = (PCPageElementMiniArticle*)element;
           [self addOperationForResourcePath:miniArticle.thumbnail element:miniArticle inPage:page isPrimary:YES isThumbnail:YES resumeOperation:nil];
           [self addOperationForResourcePath:miniArticle.thumbnailSelected element:miniArticle inPage:page isPrimary:YES isThumbnail:YES resumeOperation:nil];
       }
       else {
           [self addOperationForResourcePath:element.resource element:element inPage:page isPrimary:YES isThumbnail:NO resumeOperation:nil];
       }
   }
  
   for (PCPageElement* element in page.secondaryElements)
   {
      [self addOperationForResourcePath:element.resource element:element inPage:page isPrimary:NO isThumbnail:NO resumeOperation:nil];
   }
}


-(void)addOperationForResourcePath:(NSString*)path element:(PCPageElement*)element inPage:(PCPage*)page isPrimary:(BOOL)isPrimary isThumbnail:(BOOL) isThumbnail resumeOperation:(PCDownloadOperation*)canceledOperation
{
    NSNumber* pageIdentifier = [NSNumber numberWithInteger:page.identifier];
    NSNumber* elementIdentifier = [NSNumber numberWithInteger:element.identifier];
    ItemType type = isThumbnail? THUMBNAIL : PAGE;
	if (element.isCropped && !isThumbnail) 
	{
		type = TILED;
	}
    if ((element.page.pageTemplate.identifier == PCHorizontalScrollingPageTemplate) && ([element.fieldTypeName isEqualToString:PCPageElementTypeScrollingPane])) type = HORIZONTAL_SCROLLING_PANE;
    
    NSString* url = [self getUrlForResource:path withType:type withHorizontalOrientation:page.revision.horizontalOrientation];
	
   
    AFHTTPRequestOperation* elementOperation = [self operationWithURL:url successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSLog(@"Element %d downloaded:isPrimary %@, isThumb %@, page - %@ ", element.identifier, isPrimary?@"YES":@"NO", isThumbnail?@"YES":@"NO", pageIdentifier);
		NSLog(@"%@",[self.revision.contentDirectory stringByAppendingPathComponent:path] );
    [self moveItemWithPath:[self.revision.contentDirectory stringByAppendingPathComponent:path]];
		
	if (type == TILED || type == HORIZONTAL_SCROLLING_PANE) 
	{
		NSString *archivePath = [[page.revision contentDirectory] stringByAppendingPathComponent:path];
		
		ZipArchive *zipArchive = [[ZipArchive alloc] init];
		BOOL openFileResult = [zipArchive UnzipOpenFile:archivePath];
		NSString *outputDirectory = [archivePath stringByDeletingLastPathComponent];
		
		if (openFileResult)
		{
			
			
			[zipArchive UnzipFileTo:outputDirectory overWrite:YES];
			
			[zipArchive UnzipCloseFile];
		}
		
		[zipArchive release];
		[self archiveCroppedImageSizeToDirectory:outputDirectory];
	//	[element calculateSize];
		
	/*	NSString* resourceFullPath = [self.revision.contentDirectory stringByAppendingPathComponent:path];
		UIImage* basicArticleBodyImage = [UIImage imageWithContentsOfFile:resourceFullPath];
		NSLog(@"SCALE - %f", basicArticleBodyImage.scale);
		if (basicArticleBodyImage)
		{
			element.elementContentSize = basicArticleBodyImage.size;
			[self saveTilesOfSize:CGSizeMake(256.0, 256.0) forImage:basicArticleBodyImage toDirectory:[resourceFullPath stringByDeletingLastPathComponent]  usingPrefix:[[resourceFullPath stringByDeletingPathExtension] lastPathComponent]];
		}
	 */
	}
		
    if (!isThumbnail) element.isComplete = YES;
    
    if (isPrimary)
    {
      [[[self.operationsDic objectForKey:pageIdentifier] objectForKey:primaryKey] removeObject:operation];
    }
    else {
      [[[self.operationsDic objectForKey:pageIdentifier] objectForKey:secondaryKey]  removeObjectForKey:elementIdentifier];
    }
    
    if (![[[self.operationsDic objectForKey:pageIdentifier] objectForKey:primaryKey] lastObject] && isPrimary) {
      NSLog(@"VERTICAL PAGE DOWNLOADED - %@ - %@", pageIdentifier, path);
      dispatch_async(dispatch_get_main_queue(), ^{
        [page stopRepeatingTimer];
        page.isComplete = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:endOfDownloadingPageNotification object:page];
        
      });
      
    }
    
    if ([element.fieldTypeName isEqualToString:PCPageElementTypeGallery])
    {
      dispatch_async(dispatch_get_main_queue(), ^{
		  NSDictionary* dic = [NSDictionary dictionaryWithObject:element forKey:@"element"];
        [[NSNotificationCenter defaultCenter] postNotificationName:PCGalleryElementDidDownloadNotification object:page userInfo:dic];
      });
      
    }
    if (!isPrimary && ( [element.fieldTypeName isEqualToString:PCPageElementTypeMiniArticle] ||  [element.fieldTypeName isEqualToString:PCPageElementTypeSlide]))
    {
      dispatch_async(dispatch_get_main_queue(), ^{
		NSDictionary* dic = [NSDictionary dictionaryWithObject:element forKey:@"element"];
        [[NSNotificationCenter defaultCenter] postNotificationName:PCMiniArticleElementDidDownloadNotification object:page userInfo:dic];
      });
      
    }
    
  } progressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
    dispatch_queue_t progressQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(progressQueue, ^{
      float progress = (float)totalBytesRead/(float)totalBytesExpectedToRead;
      if ([element isKindOfClass:[PCPageElementMiniArticle class]])
      {
        if (isThumbnail)
        {
          PCPageElementMiniArticle* miniArticle = (PCPageElementMiniArticle*)element;
          if ([miniArticle.thumbnail isEqualToString:path]) miniArticle.thumbnailProgress = progress;
          else if ([miniArticle.thumbnailSelected isEqualToString:path])  miniArticle.thumbnailSelectedProgress = progress;
          else abort();
        }
        else {
          element.downloadProgress = progress;
        }
      } else
          if([element isKindOfClass:[PCPageElementGallery class]])
          {
              element.downloadProgress = progress;
          }
          else {
              element.downloadProgress = progress;
          }
    });
 
  } itemLocation:path];
  if (!elementOperation) return;
  element.isComplete = NO;
  
  ((PCDownloadOperation*)elementOperation).page =page;
  ((PCDownloadOperation*)elementOperation).element =element;
  ((PCDownloadOperation*)elementOperation).resource = path;
  ((PCDownloadOperation*)elementOperation).isPrimary =isPrimary;
  ((PCDownloadOperation*)elementOperation).isThumbnail =isThumbnail;
   
  if (isPrimary)
  {
    [[[self.operationsDic objectForKey:pageIdentifier] objectForKey:primaryKey] addObject:elementOperation];
  }
  else {
    [[[self.operationsDic objectForKey:pageIdentifier] objectForKey:secondaryKey] setObject:elementOperation forKey:elementIdentifier];
  }
  
  if (canceledOperation) {
    [elementOperation setQueuePriority:NSOperationQueuePriorityHigh];
  /*  unsigned long long offset =  [[[NSFileManager defaultManager] attributesOfItemAtPath:canceledOperation.responseFilePath error:NULL] fileSize];    
   NSLog(@"OFFSET - %qi", offset);
    NSMutableURLRequest *mutableURLRequest = [[canceledOperation.request mutableCopy] autorelease];
    if ([[canceledOperation.response allHeaderFields] valueForKey:@"ETag"]) {
      [mutableURLRequest setValue:[[canceledOperation.response allHeaderFields] valueForKey:@"ETag"] forHTTPHeaderField:@"If-Range"];
    }
    [mutableURLRequest setValue:[NSString stringWithFormat:@"bytes=%llu-", offset] forHTTPHeaderField:@"Range"];
    elementOperation.request = mutableURLRequest;
       elementOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:canceledOperation.responseFilePath append:YES];
    elementOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:elementOperation.responseFilePath append:YES];*/
    [_httpClient enqueueHTTPRequestOperation:elementOperation];
  }
}


-(AFHTTPRequestOperation*)operationWithURL:(NSString*)url
                              successBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                             progressBlock:(void (^)(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)) progressBlock
                              itemLocation:(NSString*)locationPath
{
  if ([[NSFileManager defaultManager] fileExistsAtPath:[self.revision.contentDirectory stringByAppendingPathComponent:locationPath]]) return nil;
  NSURLRequest* request = [_httpClient requestWithMethod:@"GET" path:url parameters:nil];
  AFHTTPRequestOperation* operation = [[[PCDownloadOperation alloc] initWithRequest:request] autorelease];
  //operation.successCallbackQueue = dispatch_queue_create("com.adyax.mag.success", NULL);
	operation.successCallbackQueue = _callbackQueue;
  [operation setCompletionBlockWithSuccess:success failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"operation failed! %@", operation);
	   NSLog(@"Error description - %@", error.description);
  }];
  [operation setDownloadProgressBlock:progressBlock];
  operation.responseFilePath = [self streamForFilePath:[self.revision.contentDirectory stringByAppendingPathComponent:locationPath]];
  return operation;

}


//Helpers

-(NSString*)getUrlForResource:(NSString*)resource withType:(ItemType) type withHorizontalOrientation:(BOOL) horizontalOrientation

{
   NSString* pathExtension = [[resource pathExtension] lowercaseString];
	BOOL isImageExtension = ([pathExtension isEqualToString:@"png"]||[pathExtension isEqualToString:@"jpg"]||[pathExtension isEqualToString:@"jpeg"]);
  
  switch (type) {
    case PAGE:
    {
       if (isImageExtension)
       {
          if ([Helper currentDeviceResolution] == RETINA)
          {
              return horizontalOrientation ? [NSString stringWithFormat:@"/resources/2048-1536%@",resource] : [NSString stringWithFormat:@"/resources/1536-2048%@",resource];
         //   return [NSString stringWithFormat:@"/resources/768-1024%@",resource];
          }else {
              return horizontalOrientation ? [NSString stringWithFormat:@"/resources/1024-768%@",resource] : [NSString stringWithFormat:@"/resources/768-1024%@",resource];
          }
       }
       else return [@"/resources/none/" stringByAppendingPathComponent:resource];
       break;
    }
    case THUMBNAIL:
    {
      if (isImageExtension)
      {
        if ([Helper currentDeviceResolution] == RETINA)
        {
            return horizontalOrientation ? [NSString stringWithFormat:@"/resources/none%@?2048-1536",resource] : [NSString stringWithFormat:@"/resources/none%@?1536-2048",resource];
         //  return [NSString stringWithFormat:@"/resources/none%@?768-1024",resource];
        }else {
            return horizontalOrientation ? [NSString stringWithFormat:@"/resources/none%@?1024-768",resource] : [NSString stringWithFormat:@"/resources/none%@?768-1024",resource];
        }
      }
      else  return resource; 
      break;
    }
    case HORIZONTAL_TOC:
    {
      break;
    }
    case VERTICAL_TOC:
    {
      if (isImageExtension) return [ @"resources/192-256/" stringByAppendingPathComponent:resource];
      else  return resource; 
      break;
    }
    case HORIZONTAL_HELP:
    {
      break;
    }
      
    case VERTICAL_HELP:
    {
      break;
    }
		  
	case HORIZONTAL_SCROLLING_PANE:
	{
		if ([Helper currentDeviceResolution] == RETINA)
		{
			return horizontalOrientation ? [NSString stringWithFormat:@"/resources/2048-1536-h%@",resource] : [NSString stringWithFormat:@"/resources/1536-2048-h%@",resource];
			
		}else {
			return horizontalOrientation ? [NSString stringWithFormat:@"/resources/1024-768-h%@",resource] : [NSString stringWithFormat:@"/resources/768-1024-h%@",resource];
		}
		break;  
	}
	case TILED:
	{
		if ([Helper currentDeviceResolution] == RETINA)
		{
			return horizontalOrientation ? [NSString stringWithFormat:@"/resources/2048-1536%@",resource] : [NSString stringWithFormat:@"/resources/1536-2048%@",resource];
			//   return [NSString stringWithFormat:@"/resources/768-1024%@",resource];
		}else {
			return horizontalOrientation ? [NSString stringWithFormat:@"/resources/1024-768%@",resource] : [NSString stringWithFormat:@"/resources/768-1024%@",resource];
		}
		break;
	}
        
    default:
      break;
  }
  return nil;
  
  
}


- ( NSString*)streamForFilePath:(NSString*)path
{
  NSString* directoryPath = [path stringByDeletingLastPathComponent];
  BOOL isDir = NO;        
  NSError* directoryCreateError = nil;
  if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDir]) {
    if (!isDir) {            
      [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                withIntermediateDirectories:YES attributes:nil error:&directoryCreateError];             
    }
  }
  
  if (!directoryCreateError) { 
    return [path stringByAppendingString:@".temp"];
  //  return [[[NSOutputStream alloc] initToFileAtPath:[path stringByAppendingString:@".temp"] append:NO]autorelease];
  }
  
  return nil;
}

-(void)moveItemWithPath:(NSString*)filePath
{
  NSString* tempFile = [filePath stringByAppendingString:@".temp"];
  if ([[NSFileManager defaultManager] fileExistsAtPath:tempFile]) 
    [[NSFileManager defaultManager] moveItemAtPath:tempFile toPath:filePath error:nil];
}



//Boost

-(void)boostDownloadForPortaraitPage:(PCPage*)page
{
  
  if (!self.revision) return;
  if (!self.isReady) return;
	if(!self.operationsDic) return;
	
  if (![_httpClient.operationQueue.operations lastObject]) return;
  
   NSNumber* pageIdentifier = [NSNumber numberWithInteger:page.identifier];
  NSLog(@"Attempting boost page - %@", pageIdentifier);
  NSMutableArray* executingApps = [[NSMutableArray alloc] init];
  for (PCDownloadOperation* operation in _httpClient.operationQueue.operations) {
    [operation setQueuePriority:NSOperationQueuePriorityLow];
    if(operation.isExecuting && ((operation.page && operation.isThumbnail==NO) || operation.horizontalPageKey) ) [executingApps addObject:operation];
    
  }
  NSArray* toBoost = [[self.operationsDic objectForKey:pageIdentifier] objectForKey:primaryKey];
  for (AFHTTPRequestOperation* operation in toBoost) {
    if ([executingApps containsObject:operation]) [executingApps removeObject:operation]; 
    [operation setQueuePriority:NSOperationQueuePriorityVeryHigh];
  }
  
  for (AFHTTPRequestOperation* operation in [[[self.operationsDic objectForKey:pageIdentifier] objectForKey:secondaryKey] allValues]) {
    [operation setQueuePriority:NSOperationQueuePriorityHigh];
  }
  
  if (self.portraiteTocOperations) {
    for (AFHTTPRequestOperation* operation in self.portraiteTocOperations) {
      [operation setQueuePriority:NSOperationQueuePriorityHigh];
    }

  }
  if (self.horizontalTocOperations)
	{
		for (AFHTTPRequestOperation* operation in self.horizontalTocOperations) {
			[operation setQueuePriority:NSOperationQueuePriorityHigh];
		}
	}
  
  for (PCPage* columnPage in page.column.pages) {
    NSNumber* columnPageIdentifier = [NSNumber numberWithInteger:columnPage.identifier];
    for (AFHTTPRequestOperation* operation in [[self.operationsDic objectForKey:columnPageIdentifier] objectForKey:primaryKey]) {
      [operation setQueuePriority:NSOperationQueuePriorityVeryHigh];
    }
  }
  
  PCPage* leftPage = [self.revision pageForLink:[page linkForConnector:PCTemplateLeftConnector]];
  if (leftPage) {
    NSNumber* leftPageIdentifier = [NSNumber numberWithInteger:leftPage.identifier];
    for (AFHTTPRequestOperation* operation in [[self.operationsDic objectForKey:leftPageIdentifier] objectForKey:primaryKey]) {
      [operation setQueuePriority:NSOperationQueuePriorityNormal];
    }
  }
  
  PCPage* rightPage = [self.revision pageForLink:[page linkForConnector:PCTemplateRightConnector]];
  if (rightPage) {
    NSNumber* rightPageIdentifier = [NSNumber numberWithInteger:rightPage.identifier];
    for (AFHTTPRequestOperation* operation in [[self.operationsDic objectForKey:rightPageIdentifier] objectForKey:primaryKey]) {
      [operation setQueuePriority:NSOperationQueuePriorityNormal];
    }
  }
   NSLog(@"Page %@ Boosted", pageIdentifier);
  if (!toBoost)
  {
    NSLog(@"no op to boost");
	[executingApps release];  
    return;
  }
	if (page.isComplete) return;
  [self relaunchOperationsInArray:executingApps operationsToBoost:toBoost];
	[executingApps release];
    
    
 
}

-(void)boostHelpDownload
{
	if (!self.revision) return;
	if (!self.isReady) return;
	if (!self.helpOperations) return;
	if (![_httpClient.operationQueue.operations lastObject]) return;
  NSLog(@"Attempting to boost help");
   NSMutableArray* executingApps = [[NSMutableArray alloc] init];
	for (PCDownloadOperation* operation in _httpClient.operationQueue.operations) {
    
		if (operation.queuePriority == NSOperationQueuePriorityVeryHigh)
			[operation setQueuePriority:NSOperationQueuePriorityHigh];
		 if(operation.isExecuting && ((operation.page && operation.isThumbnail==NO) || operation.horizontalPageKey) ) [executingApps addObject:operation];
	}
	
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if ((orientation == UIInterfaceOrientationPortrait) || (orientation == UIInterfaceOrientationPortraitUpsideDown))
	{
		[[self.helpOperations objectForKey:@"vertical"] setQueuePriority:NSOperationQueuePriorityVeryHigh];
		[[self.helpOperations objectForKey:@"horizontal"] setQueuePriority:NSOperationQueuePriorityHigh];
	}
	else {
		[[self.helpOperations objectForKey:@"vertical"] setQueuePriority:NSOperationQueuePriorityHigh];
		[[self.helpOperations objectForKey:@"horizontal"] setQueuePriority:NSOperationQueuePriorityVeryHigh];
	}
   [self relaunchOperationsInArray:executingApps operationsToBoost:[NSArray array]];
	NSLog(@"Help boosted");
	[executingApps release];

}

-(void)boostHorizontalPageDownloadWithIdentifier:(NSNumber*)identifier
{
	if (!self.revision) return;
	if (!self.isReady) return;
	if (!self.horizontalPageOperations) return;
	if (![_httpClient.operationQueue.operations lastObject]) return;
  NSLog(@"Attempling to boost horizontal page - %@", identifier);
  NSMutableArray* executingApps = [[NSMutableArray alloc] init];
	for (PCDownloadOperation* operation in _httpClient.operationQueue.operations) {
		[operation setQueuePriority:NSOperationQueuePriorityLow];
     if(operation.isExecuting && ((operation.page && operation.isThumbnail==NO) || operation.horizontalPageKey) ) [executingApps addObject:operation];
	}
	for (AFHTTPRequestOperation* operation in [self.horizontalPageOperations allValues])
	{
		[operation setQueuePriority:NSOperationQueuePriorityNormal];
	}
	
	if (self.horizontalTocOperations)
	{
		for (AFHTTPRequestOperation* operation in self.horizontalTocOperations) {
			[operation setQueuePriority:NSOperationQueuePriorityHigh];
		}
	}
  
  if (self.portraiteTocOperations) {
    for (AFHTTPRequestOperation* operation in self.portraiteTocOperations) {
      [operation setQueuePriority:NSOperationQueuePriorityHigh];
    }
    
  }
	
	AFHTTPRequestOperation* operation = [self.horizontalPageOperations objectForKey:identifier];
	[operation setQueuePriority:NSOperationQueuePriorityVeryHigh];
  NSLog(@"Horizontal page boosted");
  if (!operation)
  {
    NSLog(@"no op to boost");
    return;
  }
   [self relaunchOperationsInArray:executingApps operationsToBoost:[NSArray arrayWithObject:operation]];
 [executingApps release];

}

-(void)boostDownloadForElement:(PCPageElement*)element
{
	if (!self.revision) return;
	if (!self.isReady) return;
	
 	if(!self.operationsDic) return;
	if (![_httpClient.operationQueue.operations lastObject]) return;
  NSLog(@"Attempting to boost element - %d, from page - %d", element.identifier, element.page.identifier);
   NSMutableArray* executingApps = [[NSMutableArray alloc] init];
  for (PCDownloadOperation* operation in _httpClient.operationQueue.operations) {
		if(operation.isExecuting && ((operation.page && operation.isThumbnail==NO) || operation.horizontalPageKey) ) [executingApps addObject:operation];
	}
	 NSNumber* pageIdentifier = [NSNumber numberWithInteger:element.page.identifier];
	 NSNumber* elementIdentifier = [NSNumber numberWithInteger:element.identifier];
	AFHTTPRequestOperation* operation = [[[self.operationsDic objectForKey:pageIdentifier] objectForKey:secondaryKey] objectForKey:elementIdentifier];
	[operation setQueuePriority:NSOperationQueuePriorityVeryHigh];
  NSLog(@"Element boosted");
  if (!operation)
  {
    	NSLog(@"no op to boost");
	  [executingApps release];
      return;
  }
	if (element.isComplete) return;
   [self relaunchOperationsInArray:executingApps operationsToBoost:[NSArray arrayWithObject:operation]];
	[executingApps release];

}


-(void)boost:(NSNotification*)notif
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		if (!self.isReady) return;
		if ([notif.object isKindOfClass:[PCPage class]])
		{
			[self boostDownloadForPortaraitPage:notif.object];
		}
		else if ([notif.object isKindOfClass:[NSString class]]) {
			[self boostHelpDownload];
		}
		else if ([notif.object isKindOfClass:[NSNumber class]]) {
			[self boostHorizontalPageDownloadWithIdentifier:notif.object];
		}
		else if ([notif.object isKindOfClass:[PCPageElement class]]) {
			[self boostDownloadForElement:notif.object];
		}

	});
  
}


-(void)relaunchOperationsInArray:(NSArray*)array operationsToBoost:(NSArray*)boostedOperations
{
  for (PCDownloadOperation* operation in array) {
    if(operation.isExecuting && operation.element.downloadProgress < 0.8 && ![boostedOperations containsObject:operation]){
      [operation cancel];
      operation.page.primaryProgress-=operation.element.downloadProgress;
      operation.element.downloadProgress = 0.0f;
      if (operation.page)
      {
        NSNumber* pageIdentifier = [NSNumber numberWithInteger:operation.page.identifier];
        NSNumber* elementIdentifier = [NSNumber numberWithInteger:operation.element.identifier];
        if (operation.isPrimary)
        {
          [[[self.operationsDic objectForKey:pageIdentifier] objectForKey:primaryKey] removeObject:operation];
        }
        else {
          [[[self.operationsDic objectForKey:pageIdentifier] objectForKey:secondaryKey]  removeObjectForKey:elementIdentifier];
        }
        [self addOperationForResourcePath:operation.resource element:operation.element inPage:operation.page isPrimary:operation.isPrimary isThumbnail:operation.isThumbnail resumeOperation:operation];
		   NSLog(@"restarted for element - %d",operation.element.identifier);
      }
      else if (operation.horizontalPageKey) {
        [self.horizontalPageOperations removeObjectForKey:operation.horizontalPageKey];
        [self addHorizontalOperationWithKey:operation.horizontalPageKey resumeOperation:operation];
		   NSLog(@"restarted for element - %@",operation.horizontalPageKey);
      }
      
      
     
    } 
    
  }

}

-(void)cancelAllOperations
{
  [self clearData];
  self.revision = nil;
  
  
}

-(void)clearData
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:PCBoostPageNotification object:nil];
  self.isReady = NO;
  [_httpClient.operationQueue cancelAllOperations];
  self.operationsDic = nil;
  self.portraiteTocOperations = nil;
  self.helpOperations = nil;
  self.horizontalTocOperations = nil;
  self.horizontalTocOperations = nil;
	if (_callbackQueue) { 
        dispatch_release(_callbackQueue);
        _callbackQueue = NULL;
    }

}


- (void)setCallbackQueue:(dispatch_queue_t)successCallbackQueue {
    if (successCallbackQueue != _callbackQueue) {
        if (_callbackQueue) {
            dispatch_release(_callbackQueue);
            _callbackQueue = NULL;
        }
		
        if (successCallbackQueue) {
            dispatch_retain(successCallbackQueue);
            _callbackQueue = successCallbackQueue;
        }
    }    
}

-(void)archiveCroppedImageSizeToDirectory:(NSString*)directoryPath
{
	NSArray* fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:nil];
	NSMutableArray* rowNumbers = [NSMutableArray array];
	NSMutableArray* columnNumbers = [NSMutableArray array];
	for (NSString* filename in fileNames) {
		NSArray* stringComponents = [filename componentsSeparatedByString:@"_"];
		if ([stringComponents count] != 3) continue;// 3 components : name, row, column
		NSNumber* number = [NSNumber numberWithInt:[[stringComponents objectAtIndex:1] intValue]];
		NSNumber* number2 = [NSNumber numberWithInt:[[stringComponents objectAtIndex:2] intValue]];
		[rowNumbers addObject:number];
		[columnNumbers addObject:number2];
		
	}
	[rowNumbers sortUsingSelector:@selector(compare:)];
	[columnNumbers sortUsingSelector:@selector(compare:)];
	NSString* lastRowNumber = [NSString stringWithFormat:@"%@",[rowNumbers lastObject]];
	NSString* lastColumnNumber = [NSString stringWithFormat:@"%@",[columnNumbers lastObject]];
	NSString* lastRowPNGname = [NSString stringWithFormat:@"resource_%@_%@.png",lastRowNumber,lastColumnNumber];

	UIImage* image = [UIImage imageWithContentsOfFile:[directoryPath stringByAppendingPathComponent:lastRowPNGname]];
	float height = kDefaultTileSize * ([lastRowNumber intValue] - 1) + image.size.height/[UIScreen mainScreen].scale;
	float width = kDefaultTileSize * ([lastColumnNumber intValue] - 1) + image.size.width/[UIScreen mainScreen].scale;
	NSDictionary* information = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:height],@"height", [NSNumber numberWithFloat:width],@"width",nil];
	[information writeToFile:[directoryPath stringByAppendingPathComponent:@"information.plist"] atomically:YES];
	

}

@end
