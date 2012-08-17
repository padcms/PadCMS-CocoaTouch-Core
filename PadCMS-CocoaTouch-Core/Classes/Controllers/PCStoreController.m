//
//  StoreController.m
//  Pad CMS
//
//  Created by Alexey Igoshev on 6/20/12.
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


#import "PCStoreController.h"
#import "PCConfig.h"
#import "JSON.h"
#import "AFJSONRequestOperation.h"
#import "Helper.h"
#import "PCApplication.h"
#import "PCPathHelper.h"
#import "PCStoreControllerDelegate.h"
#import "PCRevision.h"
#import "PCIssue.h"
#import "PCDownloadManager.h"
#import "PCResourceCache.h"
#import "PCDownloadApiClient.h"
#import "PCRevisionViewController.h"
#import "InAppPurchases.h"
#import "PCRemouteNotificationCenter.h"
#import "PCGoogleAnalytics.h"
#import "PCLocalizationManager.h"
#import "PCVideoManager.h"

NSString* PCNetworkServiceJSONRPCPath = @"/api/v1/jsonrpc.php";


@interface PCStoreController()
{
	BOOL _previewMode;
}

@property (nonatomic, readwrite, retain) PCApplication* application;
@property (nonatomic, retain) PCRevisionViewController* revisionViewController;

@end

@implementation PCStoreController
@synthesize rootViewController=_rootViewController;
//@synthesize navigationController=_navigationController;
@synthesize application=_application;
@synthesize revisionViewController=_revisionViewController;

- (id)initWithStoreRootViewController:(UIViewController<PCStoreControllerDelegate>*)viewController
{
  
  self = [super init];
  if (self)
  {
	_previewMode = NO;
    _rootViewController = [viewController retain];
    [_rootViewController setStoreController:self];
    [PCGoogleAnalytics start];
    [PCGoogleAnalytics trackAction:@"Application launch" category:@"General"];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge)];
    [InAppPurchases sharedInstance];
    [PCDownloadManager sharedManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendReceipt:) name:kInAppPurchaseManagerTransactionSucceededNotification object:nil];
    [self launch];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
  }
  return nil;
}

-(void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  //[_navigationController release], _navigationController = nil;
  [_rootViewController release], _rootViewController = nil;
  [_application release], _application = nil;
  [_revisionViewController release], _revisionViewController = nil;
  [super dealloc];
}

/*-(UINavigationController *)navigationController
{
  if (_navigationController)
  {
    _navigationController = [[UINavigationController alloc] initWithRootViewController:_rootViewController];
  }
  return _navigationController;
}*/

-(void)launch
{
  [UIApplication sharedApplication].applicationIconBadgeNumber = -1;
  [self downloadIssueList];
  
}

-(void)downloadIssueList
{
  [self showActivity];
  NSString *devId = [[UIDevice currentDevice]uniqueIdentifier];
  NSLog(@"Device ID - %@", devId);
	NSURL* theURL = [[PCConfig serverURL] URLByAppendingPathComponent:PCNetworkServiceJSONRPCPath];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
	[request setHTTPMethod:@"POST"];
	NSMutableDictionary *mainDict = [NSMutableDictionary dictionary];
	[mainDict setObject:@"client.getIssues" forKey:@"method"];
	
	NSDictionary *innerDict = [NSDictionary dictionaryWithObjectsAndKeys:devId, @"sUdid",[NSString stringWithFormat:@"%d",[PCConfig clientIdentifier]], @"iClientId",[NSString stringWithFormat:@"%d",[PCConfig applicationIdentifier]],@"iApplicationId", nil];
	[mainDict setObject:innerDict forKey:@"params"];
	[mainDict setObject:@"1" forKey:@"id"];
	SBJsonWriter *tmpJsonWriter = [[SBJsonWriter alloc] init];
	NSString *jsonString = [tmpJsonWriter stringWithObject:mainDict];
	[tmpJsonWriter release];
	[request setHTTPBody:[jsonString dataUsingEncoding:NSASCIIStringEncoding]];
  
  AFJSONRequestOperation* operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
    SBJsonWriter *tmpJsonWriter = [[SBJsonWriter alloc] init];
    NSString *temp = [tmpJsonWriter stringWithObject:JSON];
    [tmpJsonWriter release];
    NSString* stringWithoutNull = [temp stringByReplacingOccurrencesOfString:@"null" withString:@"\"\""];
		NSDictionary* theDict = [stringWithoutNull JSONValue];
//    NSLog(@"RESPONSE - %@", theDict);
    [[theDict objectForKey:@"result"] writeToFile:[[Helper getHomeDirectory] stringByAppendingPathComponent:@"server.plist"] atomically:YES];
    [self loadApplicationFromPlist];
  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
      [self showAlertWithTitle:[PCLocalizationManager localizedStringForKey:@"MSG_NO_NETWORK_CONNECTION" value:@"You must be connected to the Internet."]];
      [self loadApplicationFromPlist];
  }];
  operation.successCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  operation.failureCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  [operation start];
}

-(void)loadApplicationFromPlist
{
    NSString *plistPath = [[PCPathHelper pathForPrivateDocuments] stringByAppendingPathComponent:@"server.plist"];
    NSDictionary *plistContent = [NSDictionary dictionaryWithContentsOfFile:plistPath];
	NSString *alertTitle = [PCLocalizationManager localizedStringForKey:@"ALERT_TITLE_CANT_LOAD_MAGAZINES_LIST" value:@"The list of available magazines could not be downloaded"];
	
	
    if(plistContent == nil)
	{
		[self showAlertWithTitle:alertTitle];
	}
	else if([plistContent count]==0)
	{
		[self showAlertWithTitle:alertTitle];
	}
	else {
		NSDictionary *applicationsList = [plistContent objectForKey:PCJSONApplicationsKey];
		NSArray *keys = [applicationsList allKeys];
      
		if ([keys count] > 0)
		{
			NSDictionary *applicationParameters = [applicationsList objectForKey:[keys objectAtIndex:0]];
        
			self.application = [[[PCApplication alloc] initWithParameters:applicationParameters
															rootDirectory:[PCPathHelper pathForPrivateDocuments]] autorelease];
		} else 
		{
			[self showAlertWithTitle:alertTitle];
		}
	}
	[self hideActivity];
	if (!self.application) return;
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.rootViewController displayIssues];
	});
}

-(void)showActivity
{
  if ([self.rootViewController respondsToSelector:@selector(showActivityIndicator)])
  {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.rootViewController showActivityIndicator];
    });
  }
}

-(void)hideActivity
{
  if ([self.rootViewController respondsToSelector:@selector(hideActivityIndicator)])
  {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.rootViewController hideActivityIndicator];
    });
    
  }
}

-(void)showAlertWithTitle:(NSString*)title
{
  dispatch_async(dispatch_get_main_queue(), ^{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:nil
												   delegate:nil
										  cancelButtonTitle:[PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_OK" value:@"OK"]
										  otherButtonTitles:nil];
    [alert show];
    [alert release];
  });

}

- (PCRevision*) revisionWithIndex:(NSInteger)index
{
  NSMutableArray *allRevisions = [[[NSMutableArray alloc] init] autorelease];
  
  NSArray *issues = self.application.issues;
  for (PCIssue *issue in issues)
  {
    [allRevisions addObjectsFromArray:issue.revisions];
  }
  
  if (index>=0 && index<[allRevisions count])
  {
    PCRevision *revision = [allRevisions objectAtIndex:index];
    return revision;
  }
  
  return nil;
}

- (PCRevision*) revisionWithIdentifier:(NSInteger)identifier
{
  NSMutableArray *allRevisions = [[[NSMutableArray alloc] init] autorelease];
  
  NSArray *issues = self.application.issues;
  for (PCIssue *issue in issues)
  {
    [allRevisions addObjectsFromArray:issue.revisions];
  }
  
  for(PCRevision *currentRevision in allRevisions)
  {
    if(currentRevision.identifier == identifier) return currentRevision;
  }
  
  return nil;
}



#pragma mark - PCKioskDataSourceProtocol


- (NSInteger)numberOfRevisions
{
  NSInteger revisionsCount = 0;
  
  NSArray *issues = self.application.issues;
  for (PCIssue *issue in issues)
  {
    revisionsCount += [issue.revisions count];
  }
  
  return revisionsCount;
}

- (NSString *)issueTitleWithIndex:(NSInteger)index
{
  PCRevision *revision = [self revisionWithIndex:index];
  
  if (revision != nil && revision.issue != nil)
  {
    return revision.issue.title;
  }
  
  return @"";
}

- (NSString *)revisionTitleWithIndex:(NSInteger)index
{
  PCRevision *revision = [self revisionWithIndex:index];
  
  if (revision != nil)
  {
    return revision.title;
  }
  
  return @"";
}

- (NSString *)revisionStateWithIndex:(NSInteger)index
{
  return @"";
}

- (BOOL)isRevisionDownloadedWithIndex:(NSInteger)index
{
  PCRevision *revision = [self revisionWithIndex:index];
  
  if (revision)
  {
    return  [revision isDownloaded];
  }
  
  return NO;
}

- (UIImage *)revisionCoverImageWithIndex:(NSInteger)index andDelegate:(id<PCKioskCoverImageProcessingProtocol>)delegate
{
  PCRevision *revision = [self revisionWithIndex:index];
  
  if (revision)
  {
    return  revision.coverImage;
  }
  
  return nil;
}

-(BOOL)isRevisionPaidWithIndex:(NSInteger)index
{
	PCRevision *revision = [self revisionWithIndex:index];
  
  if (revision.issue)
  {
    return  revision.issue.paid;
  }
  
  return NO;
}


-(NSString *)priceWithIndex:(NSInteger)index
{
	PCRevision *revision = [self revisionWithIndex:index];
  return revision.issue.price;					
}

-(NSString *)productIdentifierWithIndex:(NSInteger)index
{
	PCRevision *revision = [self revisionWithIndex:index];
  return revision.issue.productIdentifier;
}

- (BOOL)previewAvailableForRevisionWithIndex:(NSInteger)index
{
	PCRevision *revision = [self revisionWithIndex:index];
	NSUInteger previewColumnsNumber = revision.issue.application.previewColumnsNumber;
	
	if (previewColumnsNumber == 0) {
		return NO;
	}
	
	return YES;
}

#pragma mark - PCKioskViewControllerDelegateProtocol

- (void) tapInKiosk
{
    [self.rootViewController tapInKiosk];
}


- (void) readRevisionWithIndex:(NSInteger)index
{
	PCRevision *currentRevision = [self revisionWithIndex:index];
   [self launchRevison:currentRevision withInitialPage:nil previewMode:NO];
}
	 
- (void) launchRevison:(PCRevision*)aRevison
	   withInitialPage:(PCPage*)aPage
		   previewMode:(BOOL)previewMode
{
#ifdef DEBUG
	NSAssert(aRevison, @"revision is nil");
#endif
	if (!aRevison) return;
//	[self rotateInterfaceIfNeedWithRevision:aRevison];
    
	[PCDownloadManager sharedManager].revision = aRevison;
	[[PCDownloadManager sharedManager] startDownloading];
    RevisionViewController *revisionController = nil;
		
	revisionController = [[RevisionViewController alloc] initWithRevision:aRevison withInitialPage:aPage previewMode:previewMode];
	
	revisionController.delegate = self;
	[self.rootViewController.navigationController pushViewController:revisionController animated:NO];
	[revisionController release];
	
    if (!aRevison.startVideo || [aRevison.startVideo isEqualToString:@""])
		[[PCVideoManager sharedVideoManager] setIsStartVideoShown:YES];
}

- (void) deleteRevisionDataWithIndex:(NSInteger)index
{
	PCRevision *revision = [self revisionWithIndex:index];
	NSString    *messageLocalized = [PCLocalizationManager localizedStringForKey:@"ALERT_MAGAZINE_REMOVAL_CONFIRMATION_MESSAGE"
                                                                           value:@"Are you sure you want to remove this issue?"];
    
    NSString    *message = [NSString stringWithFormat:@"%@ (%@)", messageLocalized, revision.issue.title];
  
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
													message:message
												   delegate:self
										  cancelButtonTitle:[PCLocalizationManager localizedStringForKey:@"ALERT_MAGAZINE_REMOVAL_CONFIRMATION_BUTTON_TITLE_CANCEL"
                                                                                                   value:@"Cancel"]
										  otherButtonTitles:[PCLocalizationManager localizedStringForKey:@"ALERT_MAGAZINE_REMOVAL_CONFIRMATION_BUTTON_TITLE_YES"
                                                                                                   value:@"Yes"],
						  nil];
	alert.delegate = self;
	alert.tag = index;
	[alert show];
	[alert release];
}

- (void) downloadRevisionWithIndex:(NSInteger)index
{
  PCRevision *revision = [self revisionWithIndex:index];
  
  if(revision)
  {
		
		AFNetworkReachabilityStatus remoteHostStatus = [PCDownloadApiClient sharedClient].networkReachabilityStatus;
    if(remoteHostStatus == AFNetworkReachabilityStatusNotReachable) 
		{
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[PCLocalizationManager localizedStringForKey:@"MSG_NO_NETWORK_CONNECTION"
                                                                                                           value:@"You must be connected to the Internet."]
															message:nil
														   delegate:nil
												  cancelButtonTitle:[PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_OK"
                                                                                                           value:@"OK"]
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
			return;
			
		}
    [self.rootViewController downloadStartedWithRevisionIndex:index];
    [self performSelectorInBackground:@selector(doDownloadRevisionWithIndex:) withObject:[NSNumber numberWithInteger:index]];
  }
}

- (void) cancelDownloadingRevisionWithIndex:(NSInteger)index
{
  PCRevision *revision = [self revisionWithIndex:index];
  
  if(revision)
  {
    [revision cancelDownloading];
  }
}

-(void) purchaseRevisionWithIndex:(NSInteger)index
{
	PCRevision *revision = [self revisionWithIndex:index];
	if (revision)
	{
		NSLog(@"doPay");
		
		NSLog(@"productId: %@", revision.issue.productIdentifier);
    
		if([[InAppPurchases sharedInstance] canMakePurchases])
		{
			
			[[InAppPurchases sharedInstance] purchaseForProductId:revision.issue.productIdentifier];
			
		}
		else
		{
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[PCLocalizationManager localizedStringForKey:@"ALERT_TITLE_CANT_MAKE_PURCHASE"
                                                                                                           value:@"You can't make the purchase"]
															message:nil
														   delegate:nil
												  cancelButtonTitle:[PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_OK"
                                                                                                           value:@"OK"]
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
    
	}
	
}


- (void) updateRevisionWithIndex:(NSInteger) index
{
}

#pragma mark - Download flow

- (void)doDownloadRevisionWithIndex:(NSNumber *)index
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  PCRevision          *revision = [self revisionWithIndex:[index integerValue]];
  
  if(revision)
  {
    [revision download:^{
      [self performSelectorOnMainThread:@selector(downloadRevisionFinishedWithIndex:)
                             withObject:index
                          waitUntilDone:NO];
    } failed:^(NSError *error) {
      [self performSelectorOnMainThread:@selector(downloadRevisionFailedWithIndex:)
                             withObject:index
                          waitUntilDone:NO];
    } canceled:^{
      [self performSelectorOnMainThread:@selector(downloadRevisionCanceledWithIndex:)
                             withObject:index
                          waitUntilDone:NO];
    } progress:^(float progress) {
      NSDictionary        *info = [NSDictionary dictionaryWithObjectsAndKeys:index, @"index", [NSNumber numberWithFloat:progress], @"progress", nil];
      
      [self performSelectorOnMainThread:@selector(downloadingRevisionProgressUpdate:)
                             withObject:info
                          waitUntilDone:NO];
    }];
  }
  
  
  [pool release];
}

- (void)downloadRevisionCanceledWithIndex:(NSNumber*)index
{
  [self.rootViewController downloadCanceledWithRevisionIndex:[index integerValue]];
  
  PCRevision      *revision = [self revisionWithIndex:[index integerValue]];
  if(revision)
  {
    [revision deleteContent];
    [self.rootViewController updateRevisionWithIndex:[index integerValue]];
  }
}

- (void)downloadRevisionFinishedWithIndex:(NSNumber*)index
{
  [self.rootViewController downloadFinishedWithRevisionIndex:[index integerValue]];
  
	if (_previewMode) {
		PCRevision *revision = [self revisionWithIndex:[index integerValue]];
		[self launchRevison:revision withInitialPage:nil previewMode:YES];
	}
}

- (void)downloadRevisionFailedWithIndex:(NSNumber*)index
{
  [self.rootViewController downloadFailedWithRevisionIndex:[index integerValue]];
  
	UIAlertView *errorAllert = [[UIAlertView alloc] 
                                initWithTitle:[PCLocalizationManager localizedStringForKey:@"ALERT_MAGAZINE_DOWNLOADING_FAILED_TITLE"
                                                                                     value:@"Error downloading issue!"]
                                message:[PCLocalizationManager localizedStringForKey:@"ALERT_MAGAZINE_DOWNLOADING_FAILED_MESSAGE"
                                                                               value:@"Try again later"] 
                                delegate:nil
                                cancelButtonTitle:[PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_OK"
                                                                                         value:@"OK"]
                                otherButtonTitles:nil];
  
  [errorAllert show];
  [errorAllert release];
  
  PCRevision      *revision = [self revisionWithIndex:[index integerValue]];
  if(revision)
  {
    [revision deleteContent];
    [self.rootViewController updateRevisionWithIndex:[index integerValue]];
  }
	
	_previewMode = NO;
}

- (void)downloadingRevisionProgressUpdate:(NSDictionary*)info
{
  NSNumber        *index = [info objectForKey:@"index"];
  NSNumber        *progress = [info objectForKey:@"progress"];
  
  [self.rootViewController downloadingProgressChangedWithRevisionIndex:[index integerValue]
                                                             andProgess:[progress floatValue]];
}

- (void)previewRevisionWithIndex:(NSInteger)index
{
	_previewMode = YES;
	[self downloadRevisionWithIndex:index];
}

#pragma mark - UIAlertViewDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex==1)
	{
    NSInteger       index = alertView.tag;
    PCRevision *revision = [self revisionWithIndex:index];
    
    if(revision)
    {
      PCDownloadManager* manager = [PCDownloadManager sharedManager];
      if (manager.revision == revision)
      {
        [manager cancelAllOperations];
      }
      
      if (revision)
      {
        [revision deleteContent];
        [self.rootViewController updateRevisionWithIndex:index];
      }
    }
	}
}

#pragma mark - misc
/*
- (void)rotateInterfaceIfNeedWithRevision:(PCRevision*) revision
{
  if(revision.horizontalOrientation)
  {
    UIInterfaceOrientation curOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    // if we enter in view controller in portrait with revision with horizontal orientation
    if(UIDeviceOrientationIsPortrait(curOrientation))
    {
      [UIView beginAnimations:@"View Flip" context:nil];
      [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
      [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
      [UIView setAnimationDelegate:self];
      
      self.rootViewController.view.frame = CGRectMake(0.0, 0.0, 1024, 768);
      self.rootViewController.view.center = CGPointMake(512, 384);
      [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
      CGAffineTransform landscapeTransform = CGAffineTransformMakeRotation( 90.0 * M_PI / -180.0 );
      landscapeTransform = CGAffineTransformTranslate( landscapeTransform, -128.0, -128.0 );
      self.rootViewController.view.transform = landscapeTransform;
      
      [UIView commitAnimations];
    }
  } 
}
*/
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if([animationID isEqualToString:@"View Flip"])
	{
		[self.rootViewController deviceOrientationDidChange];
	}
}

- (void) switchToKiosk
{
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	[[PCDownloadManager sharedManager] cancelAllOperations];
	[self.rootViewController.navigationController popToRootViewControllerAnimated:NO];
	self.revisionViewController = nil;
  
}

- (void) searchWithKeyphrase:(NSString*) keyphrase
{
	NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"PadCMS-CocoaTouch-Core-Resources" withExtension:@"bundle"]];
	PCSearchViewController* searchViewController = [[PCSearchViewController alloc] initWithNibName:@"PCSearchViewController" bundle:bundle];
	searchViewController.searchKeyphrase = keyphrase;
	searchViewController.application = _application;
	searchViewController.delegate = self;
	[self.rootViewController.navigationController pushViewController:searchViewController animated:NO];
  
	[searchViewController release];
}

-(void)subscribe
{
	[[InAppPurchases sharedInstance] subscribe];
}


#pragma mark - PCSearchViewControllerDelegate

- (void) showRevisionWithIdentifier:(NSInteger) revisionIdentifier andPageIndex:(NSInteger) pageIndex
{
	[self dismissPCSearchViewController:nil];
	PCRevision *currentRevision = [self revisionWithIdentifier:revisionIdentifier];
	NSAssert(pageIndex >= 0 && pageIndex < [currentRevision.pages count], @"pageIndex not within range");
	PCPage* page = [currentRevision.pages objectAtIndex:pageIndex];
	[self launchRevison:currentRevision withInitialPage:page previewMode:FALSE];
}

-(void)dismissPCSearchViewController:(PCSearchViewController *)currentPCSearchViewController
{
	[self.rootViewController.navigationController popViewControllerAnimated:NO];
}

-(void)restartApplication
{
	[self downloadIssueList];	
}


- (void) sendReceipt: (NSNotification *)notification
{
	NSLog(@"transactionReceipt: %@", [notification object]);
	
	NSString *devId = [[UIDevice currentDevice] uniqueIdentifier];
	
	NSURL* theURL = [[PCConfig serverURL] URLByAppendingPathComponent:PCNetworkServiceJSONRPCPath];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
	
	[request setHTTPMethod:@"POST"];
	
	NSMutableDictionary *mainDict = [NSMutableDictionary dictionary];
	[mainDict setObject:@"purchase.apple.verifyReceipt" forKey:@"method"];
  
	NSDictionary *innerDict = [NSDictionary dictionaryWithObjectsAndKeys:devId, @"sUdid", [notification object], @"sReceiptData", nil];
	
  
	
	[mainDict setObject:innerDict forKey:@"params"];
	
	[mainDict setObject:@"1" forKey:@"id"];
	
	SBJsonWriter *tmpJsonWriter = [[SBJsonWriter alloc] init];
	NSString *jsonString = [tmpJsonWriter stringWithObject:mainDict];
	
  //	NSLog(@"jsonString is:\n %@", jsonString);
	
	[tmpJsonWriter release];
	
	[request setHTTPBody:[jsonString dataUsingEncoding:NSASCIIStringEncoding]];
	
	NSData *dataReply = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
	if(dataReply != nil)
	{
		NSString *str = [[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
    //		NSLog(@"ReceiptVerify response:\n %@", str);
		[str release];
	}
	
	[self restartApplication];
	
	//[[NSNotificationCenter defaultCenter] postNotificationName:reloadCellNotification object:nil];
}

#pragma mark - RevisionViewControllerDelegate

- (void)revisionViewControllerDidDismiss:(RevisionViewController *)revisionViewController
{
	if (_previewMode) {
		[revisionViewController.revision deleteContent];
		_previewMode = NO;
	}
	
  [self.rootViewController.navigationController popViewControllerAnimated:NO];
}

- (void)revisionViewController:(RevisionViewController *)revisionViewController
willPresentGalleryViewController:(GalleryViewController *)galleryViewController
{
    [revisionViewController presentViewController:galleryViewController
										 animated:NO
									   completion:nil];
}

- (void)revisionViewController:(RevisionViewController *)revisionViewController
willDismissGalleryViewController:(GalleryViewController *)galleryViewController
{
    [revisionViewController dismissViewControllerAnimated:NO
											   completion:nil];
}


@end
