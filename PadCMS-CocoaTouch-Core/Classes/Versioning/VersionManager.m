//
//  VersionManager.m
//  temp
//
//  Created by mark on 1/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VersionManager.h"
#import "PadCMSCoder.h"
#import "PCMainViewController.h"
#import "PCPadCMSAppDelegate.h"
#import "ZipArchive.h"
//#import "WiredNavigator.h"
#import "Helper.h"
#ifndef DISABLE_INAPP_PURCHASES
#import "InAppPurchases.h"
#endif
//#import "WiredSettings.h"
#import "NKitWorks.h"
#import "PCConfig.h"

static VersionManager *sharedVersionManager = nil;

@interface VersionManager (Private)
- (BOOL) readyStateForDictionary: (NSDictionary *) dict_;
- (void) addNewsstands;
@end

@implementation VersionManager
@synthesize items,reachability;

#pragma mark GUI Methods
/*
- (void) presentHelperRevision
{
	[[(PCPadCMSAppDelegate*)[[UIApplication sharedApplication] delegate] viewController] viewDidLoadStuff];
}*/
/*
- (void) showNavigator
{
	kioskTapped = NO;

	PCMainViewController* controller = [(PCPadCMSAppDelegate*)[[UIApplication sharedApplication] delegate] viewController];	
	
	controller.navigator = [[[WiredNavigator alloc] init] autorelease];
	[controller.navigator shouldPresentInOrientation:controller.interfaceOrientation];
    [controller.view addSubview:controller.navigator.view];
}*/

#pragma mark disk Cache Methods
/*
- (void) store
{
	@synchronized(self)
	{						
		[self.items writeToFile:[[Helper getHomeDirectory] stringByAppendingPathComponent:@"adminRevisions.plist"] atomically:YES];
	}
}

- (void) removeFromMemory
{	
	[self store];
	[self.items removeAllObjects];
//	[coder.filter removeAllObjects];
}

- (NSDictionary*) serverLoad
{
	@synchronized(self)
	{
		return [NSDictionary dictionaryWithContentsOfFile:[[Helper getHomeDirectory] stringByAppendingPathComponent:@"server.plist"]];
	}
}

- (NSDictionary*) tempServerLoad
{
	@synchronized(self)
	{
		NSDictionary* temp_server = [NSDictionary dictionaryWithContentsOfFile:[[Helper getHomeDirectory] stringByAppendingPathComponent:@"temp_server.plist"]];
		[[NSFileManager defaultManager]removeItemAtPath:[[Helper getHomeDirectory] stringByAppendingPathComponent:@"temp_server.plist"] error:nil];
		return temp_server;
	}
}

- (void) storeServer:(NSDictionary*)server
{
	@synchronized(self)
	{
		[server writeToFile:[[Helper getHomeDirectory] stringByAppendingPathComponent:@"server.plist"] atomically:YES];
	}	 
}

- (void) cleanAdminItems
{
	if([self.items count] > 0)
		[self.items removeAllObjects];
}

- (void) reloadAdminItems
{
	@synchronized(self)
	{	
		[self cleanAdminItems];	
		[self.items addObjectsFromArray:[NSArray arrayWithContentsOfFile:[[Helper getHomeDirectory] stringByAppendingPathComponent:@"adminRevisions.plist"]]];	
	}
}

- (NSArray*) loadServerItems
{
	@synchronized(self)
	{
		NSString* serverRevisionsPlistFileName = [[Helper getHomeDirectory] stringByAppendingPathComponent:@"serverRevisions.plist"];
		return [NSArray arrayWithContentsOfFile:serverRevisionsPlistFileName];
	}
}*/

#pragma mark Core

+ (VersionManager*) sharedManager
{	
    if (sharedVersionManager == nil)
	{		
        sharedVersionManager = [[super allocWithZone:NULL] init];
#ifndef DISABLE_INAPP_PURCHASES		
		[[NSNotificationCenter defaultCenter] addObserver:sharedVersionManager selector:@selector(productDataRecieved:) name:kInAppPurchaseManagerProductsFetchedNotification object:nil]; 
#endif		
		sharedVersionManager.reachability = [Reachability reachabilityForInternetConnection];
		[sharedVersionManager.reachability startNotifier];
		
		sharedVersionManager.items = [[[NSMutableArray alloc] init] autorelease];	
	//	sharedVersionManager.coder = [[[PadCMSCoder alloc] initWithDelegate:sharedVersionManager] autorelease];
		
        //TODO !!!!!!!!!!!!!!!!!!!!!NOT FOR KIOSQUE
		[Helper setInternalRevision:-1];
		
		NSLog(@"UDID %@",[UIDevice currentDevice].uniqueIdentifier);
    }	
	
    return sharedVersionManager;
}
/*
- (int) hasRevision: (NSArray*)theArr revision_: (int)revision_
{
	
	for (int i=0;i<[theArr count];i++) 
	{
		if([[[theArr objectAtIndex:i]objectForKey:@"revision_id"]intValue] == revision_) return i;		
	}
	return -1;
	
}

- (void) updateServerAdminRevisionDiff: (NSDictionary*)sourceRevision targetRevision: (NSMutableDictionary*)targetRevision
{
	
	//if([sourceRevision objectForKey:@"readyState"]!=nil)
	//	[targetRevision setObject:[sourceRevision objectForKey:@"readyState"] forKey:@"readyState"];
	
	if([sourceRevision objectForKey:@"server_filename"]!=nil)
		[targetRevision setObject:[sourceRevision objectForKey:@"server_filename"] forKey:@"server_filename"];
	
	if([sourceRevision objectForKey:@"total_bytes"]!=nil)
		[targetRevision setObject:[sourceRevision objectForKey:@"total_bytes"] forKey:@"total_bytes"];
	
}

- (void) arhiveRevision:(NSMutableDictionary*)revision
{
	//[revision setObject:@"arhived" forKey:@"issue_state"];
	[revision setObject:@"arhived" forKey:@"revision_state"];	
}

- (void) mergeAdminItems
{
	
	@synchronized(self)
	{
		
		NSLog(@"merge server_items to existing admin items");
		NSString* adminRevisionsFileName = [[Helper getHomeDirectory] stringByAppendingPathComponent:@"adminRevisions.plist"];
		if ([self.items count] == 0) [self.items addObjectsFromArray:[NSArray arrayWithContentsOfFile:adminRevisionsFileName]];
		
		NSMutableArray* newAdminItems = [[NSMutableArray alloc] init];
		//we don't miss objects that we already have,even if at server doesn't exist then unpublished status and their will be filtered.when unfiltered download etc resume if file was not changed
		[newAdminItems addObjectsFromArray:self.items];
		
		NSArray* serverRevisions = [self loadServerItems];
		for (int i = 0; i < [serverRevisions count]; i++)
		{
			NSDictionary* serverRevision = [serverRevisions objectAtIndex:i];
			int searchingRevision = [[serverRevision objectForKey:@"revision_id"]intValue];
			int newAdminItemsRevisionIndex = [self hasRevision:self.items  revision_:searchingRevision];
			
			NSMutableDictionary* newRevision = [[NSMutableDictionary alloc] init];
			[newRevision addEntriesFromDictionary:serverRevision];
			
			if(newAdminItemsRevisionIndex != -1)
			{
				[self updateServerAdminRevisionDiff:[newAdminItems objectAtIndex:newAdminItemsRevisionIndex] targetRevision:newRevision];
				[newAdminItems replaceObjectAtIndex:newAdminItemsRevisionIndex withObject:newRevision];
			}
			else
			{
				[newAdminItems addObject:newRevision];
			}
			[newRevision release];
		}
		
		//walk adminItems loop and if not found from serverItems then unpublish.if server send all revisions with different state,their already updated. 	
		for (int i = 0; i < [self.items count]; i++)
		{		
			int searchingRevision = [[[self.items objectAtIndex:i] objectForKey:@"revision_id"] intValue];		
			int serverItemsRevisionIndex = [self hasRevision:serverRevisions  revision_:searchingRevision];
			
			if(serverItemsRevisionIndex == -1)
			{//server remove this item so unpublish
				int newRevisionsIndex = [self hasRevision:newAdminItems revision_:searchingRevision];//it must have this revison we added it at top
				[self arhiveRevision:[newAdminItems objectAtIndex:newRevisionsIndex]];	
			}
		}
		
		//self.items = nil;
		self.items = newAdminItems;
		//[newAdminItems release];
		[newAdminItems release];
		[self loadProductPrices];
        [self addNewsstands];
	}	
	
	[self store];
	
}
*//*
- (void) loadProductPrices
{
#ifndef DISABLE_INAPP_PURCHASES
  for (NSString* subscriptionID in [PCConfig subscriptions]) {
    [[InAppPurchases sharedInstance] requestProductDataWithProductId:subscriptionID];
  }
      
	for(int i = 0; i < [self.items count]; ++i)
	{
		NSDictionary *item = [self.items objectAtIndex:i];
		if(![item objectForKey:@"price"] && ![[item objectForKey:@"paid"] boolValue])
		{
			[[InAppPurchases sharedInstance] requestProductDataWithProductId:[item objectForKey:@"issue_product_id"]];
		}
	}
#endif
}

- (void) productDataRecieved:(NSNotification *) notification
{
	NSLog(@"From VersionManager::productDataRecieved: %@ %@", [(NSDictionary *)[notification object] objectForKey:@"productIdentifier"], [(NSDictionary *)[notification object] objectForKey:@"localizedPrice"]);
	for(int i = 0; i < [self.items count]; ++i)
	{
		NSDictionary *item = [self.items objectAtIndex:i];
		
		if([[(NSDictionary *)[notification object] objectForKey:@"productIdentifier"] isEqualToString:[item objectForKey:@"issue_product_id"]])
		{
			[item setValue:[NSString stringWithString:[(NSDictionary *)[notification object] objectForKey:@"localizedPrice"]] forKey:@"price"];
			return;
		}
	}
}*/
/*
- (void) extractRevisionsFromServer
{
	//server sorting will be here
	
	NSString* serverPlistFileName = [[Helper getHomeDirectory] stringByAppendingPathComponent:@"server.plist"];
	NSDictionary* tserverDict = [NSDictionary dictionaryWithContentsOfFile:serverPlistFileName];
	
	NSMutableArray* new_revisions = [[NSMutableArray alloc] init];
	
	
	NSArray* issuesKeys = [[[tserverDict objectForKey:@"issues"]allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	
	for (int k = 0; k < [issuesKeys count]; k++)
	{
		NSString* issueKey = [issuesKeys objectAtIndex:k];
		
		NSDictionary* issue = [[tserverDict objectForKey:@"issues"]objectForKey:issueKey];
		
		NSMutableDictionary* issueTemp = [[NSMutableDictionary alloc] init];
		[issueTemp addEntriesFromDictionary:issue];
		[issueTemp removeObjectForKey:@"revisions"];
		
		NSArray* revisionsSortedKeys = [[[issue objectForKey:@"revisions"]allKeys]sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
		
		for (int i=0;i<[revisionsSortedKeys count];i++)
		{
			NSString* key = [revisionsSortedKeys objectAtIndex:i];
			NSMutableDictionary* new_revision = [[NSMutableDictionary alloc] init];
			[new_revision addEntriesFromDictionary:[[issue objectForKey:@"revisions"]objectForKey:key]];
			[new_revision addEntriesFromDictionary:issueTemp];		
			[new_revisions addObject:new_revision];
			[new_revision release];			
		}
		
		[issueTemp release];
		
	}
	
	//replase paid is we don't have product_is
	for(NSDictionary *dict in new_revisions)
	{
		if([[dict objectForKey:@"issue_product_id"] isEqualToString:@""] || [self readyStateForDictionary:dict])
		{
			[dict setValue:@"true" forKey:@"paid"];
		}
	}
	
	NSString* serverRevisionsPlistFileName = [[Helper getHomeDirectory] stringByAppendingPathComponent:@"serverRevisions.plist"];	
	
	if (new_revisions==nil) NSLog(@"attemt store nil to file");
	[new_revisions writeToFile:serverRevisionsPlistFileName atomically:YES];	
	[new_revisions release];	
	
	
}*/

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[[NSThread mainThread] cancel];
	exit(0);//for simulator	
}
/*
- (void) reloadAllData
{
	[coder syncServerPlistDownload];

	[self cleanAdminItems];
	[self extractRevisionsFromServer];
	[self mergeAdminItems];
	
	[coder reloadFilter];

	[[NSNotificationCenter defaultCenter] postNotificationName:reloadCellNotification object:nil];
}*/

#pragma mark data receive/send stuff Methods
/*
- (NSString*) cover: (int)index_
{
	@synchronized(self)
	{
		return [[self.items objectAtIndex:index_]valueForKey:@"revision_cover_image_list"];	
	}
}

- (NSString*) caption: (int)index_
{
	@synchronized(self)
	{
		return [[self.items objectAtIndex:index_]valueForKey:@"issue_title"];	
	}
}

- (NSString*) revision_caption:	(int)index_
{
	@synchronized(self)
	{
		return [[self.items objectAtIndex:index_]valueForKey:@"revision_title"];	
	}
}

- (NSString*) server_filename: (int)index_
{
	@synchronized(self)
	{
		return [[self.items objectAtIndex:index_]valueForKey:@"server_filename"];
	}
}

- (BOOL) readyStateForDictionary: (NSDictionary *) dict_
{
	@synchronized(self)
	{
		NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
		id readyState = [ud objectForKey:[NSString stringWithFormat:@"%d_readyState",[[dict_ valueForKey:@"revision_id"] intValue]]];
		if(readyState)
			return [readyState boolValue];
	}
	return NO;
}

- (BOOL) readyState: (int)index_
{
	return [self readyStateForDictionary:[self.items objectAtIndex:index_]];
}

- (int) revision:				(int)index
{
	@synchronized(self)
	{
		return [ [ [self.items objectAtIndex:index] valueForKey:@"revision_id"] intValue];
	}
}

- (int) total_bytes:			(int)index_
{
	@synchronized(self)
	{
		return [[[self.items objectAtIndex:index_]valueForKey:@"total_bytes"]intValue];
	}
}

- (BOOL) didPayed:				(int)index
{
	@synchronized(self)
	{
		id tmp = [[self.items objectAtIndex:index]valueForKey:@"paid"];
		if(tmp)
			return [tmp boolValue];
		else
			return NO;
	}
}

- (int) issue_id:				(int)index
{
	@synchronized(self)
	{
		return [[[self.items objectAtIndex:index]valueForKey:@"issue_id"]intValue];
	}
}

- (NSString *) productId: (int) index
{
	@synchronized(self)
	{
		return [[self.items objectAtIndex:index] valueForKey:@"issue_product_id"];
	}
}

- (NSString *) price:			(int)index
{
	@synchronized(self)
	{
		return [[self.items objectAtIndex:index] valueForKey:@"price"];
	}
}

- (void) updateTotal_bytes:		(int)value			index:(int)index_
{
	
	@synchronized(self)
	{
		NSDictionary* old_revision = [self.items objectAtIndex:index_];
		NSMutableDictionary* new_revision = [[NSMutableDictionary alloc] init];
		[new_revision addEntriesFromDictionary:old_revision];		 
		[new_revision setObject:[NSNumber numberWithInt:value] forKey:@"total_bytes"];		
		[self.items replaceObjectAtIndex:index_ withObject:new_revision];
		[new_revision release];		
		[self store];		
    }
	
}

- (void) updateServer_filename:	(NSString*)value	index:(int)index_
{
	
	@synchronized(self)
	{
		NSDictionary* old_revision = [self.items objectAtIndex:index_];
		NSMutableDictionary* new_revision = [[NSMutableDictionary alloc] init];
		[new_revision addEntriesFromDictionary:old_revision];		 
		[new_revision setObject:value forKey:@"server_filename"];		
		[self.items replaceObjectAtIndex:index_ withObject:new_revision];
		[new_revision release];		
		[self store];		
    }	
	
}

- (void) updateReadyState:(BOOL) value index:(int) index_
{	
	@synchronized(self)
	{
		NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
		[ud setValue:value ? @"YES" : @"NO" forKey:[NSString stringWithFormat:@"%d_readyState",[[[self.items objectAtIndex:index_] valueForKey:@"revision_id"] intValue]]];
		[ud synchronize];
    }	
}

- (void) updateResize_done:		(int)value			index:(int)index_
{
	@synchronized(self) {
		NSMutableDictionary* new_revision = [[NSMutableDictionary alloc] init];
		[new_revision addEntriesFromDictionary:[self.items objectAtIndex:index_]];
		[new_revision setValue:[NSNumber numberWithInt:value] forKey:@"resize_done"];
		[self.items replaceObjectAtIndex:index_ withObject:new_revision];
		[new_revision release];
		[self store];
	}
}

- (void) updateResize_total:	(int)value			index:(int)index_
{
	@synchronized(self)
	{	
		NSMutableDictionary* new_revision = [[NSMutableDictionary alloc] init];
		[new_revision addEntriesFromDictionary:[self.items objectAtIndex:index_]];
		[new_revision setValue:[NSNumber numberWithInt:value] forKey:@"resize_total"];
		[self.items replaceObjectAtIndex:index_ withObject:new_revision];
		[new_revision release];
		[self store];
	}
}

- (void)appLoaded {
	//ud store active_revision from Helper	
	
	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	[ud setObject:[NSString stringWithFormat:@"%d",[Helper getInternalRevision]] forKey:@"internal_revision"];
	[ud setObject:[Helper getIssueText] forKey:@"internal_revision_text"];
	[ud synchronize];
	
}
*/
#pragma mark Kiosk activation Methods
/*
- (void) kioskTap
{
	
	if (kioskTapped) return;	
	kioskTapped = YES;	
	
	[coder syncServerPlistDownload];
	
	[self cleanAdminItems];
	[self extractRevisionsFromServer];
	[self mergeAdminItems];
	
	[coder reloadFilter];
	
	[self performSelectorOnMainThread: @selector(showNavigator) withObject:nil waitUntilDone:NO];
	
	kioskTapped = NO;	
}*/
/*
- (void) navigatorShouldAppear
{
	
	static BOOL once;//prevent viewDidAppear call it many times
	if(once) return;
	once = YES;
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	//NSLog(@"we got cached snap");
	//[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"we_got_cached_snap"];
	//[[NSUserDefaults standardUserDefaults] synchronize];
	
	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	//if([ud objectForKey:@"internal_revision"] != nil && [self issuePaidWithRevision:[[ud objectForKey:@"internal_revision"] intValue]])
	if([ud objectForKey:@"internal_revision"] != nil)
	{
		[Helper setInternalRevision:[[ud objectForKey:@"internal_revision"]intValue]];
		[Helper setIssueText:[ud objectForKey:@"internal_revision_text"]];
		
		[self performSelectorOnMainThread: @selector(presentHelperRevision) withObject:nil waitUntilDone:NO];
	}
	else
	{
		NSString* serverPlistFileName = [[Helper getHomeDirectory] stringByAppendingPathComponent:@"server.plist"];
//		NSString* adminRevisionsFileName = [[Helper getHomeDirectory] stringByAppendingPathComponent:@"adminRevisions.plist"];
		
//		NSDictionary* serverDict = nil;			
//		if([[NSFileManager defaultManager]fileExistsAtPath:serverPlistFileName])
//			serverDict = [NSDictionary dictionaryWithContentsOfFile:serverPlistFileName];			
//		
//		if(!serverDict)	serverDict = [NSDictionary dictionary];		
		
//		NSMutableArray* revisions = [NSArray arrayWithContentsOfFile:adminRevisionsFileName];
		
		BOOL someProblem = NO;
		
		//BOOL we_got_cached_snap = [[[NSUserDefaults standardUserDefaults] objectForKey:@"we_got_cached_snap"] boolValue];
		BOOL we_got_cached_snap = NO;
		
		if(!we_got_cached_snap)
		{
			NetworkStatus remoteHostStatus = [[VersionManager sharedManager].reachability currentReachabilityStatus];
			if(remoteHostStatus == NotReachable) 
			{
				//UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"Vous devez être connecté à Internet." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]autorelease];
				UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Vous devez être connecté à Internet." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				alert.delegate = self;
				[alert show];
				[alert release];
				//return;
				someProblem = YES;
			}
		}
		
		if(!we_got_cached_snap)
			//if([revisions count]==0)//empty launch,trying to fill
		{					
			if(![sharedVersionManager.coder syncServerPlistDownload])
			{						
				NSLog(@"UDID isValid %d",coder.validUDID);
				
				UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"La liste des numéros disponibles n'a pu être téléchargée" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]autorelease];
				alert.delegate = self;
				[alert show];
				//return;
				someProblem = YES;
			}
			else
			{
				NSLog(@"UDID isValid %d",coder.validUDID);
				
				NSDictionary* tserverDict = [NSDictionary dictionaryWithContentsOfFile:serverPlistFileName];
				if(tserverDict == nil)
				{
					UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"La liste des numéros disponibles n'a pu être téléchargée" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]autorelease];
					alert.delegate = self;
					[alert show];
					//return;
					someProblem = YES;
				}
				else
				{
					
					if([tserverDict count]==0)
					{
						UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"La liste des numéros disponibles n'a pu être téléchargée" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]autorelease];
						alert.delegate = self;
						[alert show];						
						//return;
						someProblem = YES;
					}
					else
					{
						NSLog(@"got server array with empty launch");
						//got server array.at first laucnh				
						[self extractRevisionsFromServer];
						
						NSString* serverRevisionsPlistFileName = [[Helper getHomeDirectory]stringByAppendingPathComponent:@"serverRevisions.plist"];	
						NSArray* testServArr = [NSArray arrayWithContentsOfFile:serverRevisionsPlistFileName];
						if((testServArr == nil) || ([testServArr count] == 0))
						{							
							//wtf wrong structure empty server answer at first launch
							//UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"Can't download issues list at first launch.no revisions from server.possible there is no revisions." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]autorelease];
							UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"La liste des numéros disponibles n'a pu être téléchargée" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]autorelease];
							alert.delegate = self;
							[alert show];						
							//return;
							someProblem = YES;
						}
						else
						{
							NSString* adminRevisionsPlistFileName = [[Helper getHomeDirectory] stringByAppendingPathComponent:@"adminRevisions.plist"];	
							if (adminRevisionsPlistFileName==nil) NSLog(@"attemt store nil to file");										
							[testServArr writeToFile:adminRevisionsPlistFileName atomically:YES];
							
							[self reloadAdminItems];
							[Helper setInternalRevision:-1];
							[self mergeAdminItems];
							[coder reloadFilter];	
						}
					}
				}					
			}
			//all ok contruct navigator to user choose revision on library				
			//NSLog(@"empty starting with non empty server answer done okey");
			
			//[self performSelectorOnMainThread: @selector(showNavigator) withObject:nil waitUntilDone:NO];
			//[pool release];
			//return;
		}
		
		if(!someProblem)
			[self performSelectorOnMainThread: @selector(showNavigator) withObject:nil waitUntilDone:NO];
		//NSLog(@"when start empty app.terminate it,or/then just not read any issue");
		//when start empty app.terminate it,or/then just not read any issue
	}
	[pool release];
}*/

/*
- (BOOL) issuePaidWithRevision:(int) revision
{
	for(NSDictionary *item in self.items)
	{
		if([[item objectForKey:@"revision_id"] intValue] == revision)
			return [[item objectForKey:@"paid"] boolValue];
	}
	return NO;
}*/

#pragma mark Newsstand Methods

- (void) addNewsstands
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
  
  if ([PCConfig useNewsstand]) {
    if(!isOS5())
      return;
    
    for(int i = 0; i < [self.items count]; ++i)
    {
      NSDictionary *item = [self.items objectAtIndex:i];
      
      NSDateFormatter *df = [[NSDateFormatter alloc] init];
      [df setFormatterBehavior:NSDateFormatterBehavior10_4];
      [df setDateFormat:@"yyyy-MM-dd"];
      NSString *strDate = [item objectForKey:@"revision_created"];
      NSRange range = [strDate rangeOfString:@"T"];
      if(range.length)
      {
        strDate = [strDate substringToIndex:range.location];
      }
      NSDate *date = [df dateFromString:strDate];
      
      [df release];
      
      
      [NKitWorks addIssueWithName:[NSString stringWithFormat:@"%@.zip",[item objectForKey:@"revision_id"]] date:date];
    }

  }
  
    
	
}

- (void) updateNewsstandIcon:(int) index
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
  

  if ([PCConfig useNewsstand]) 
  {
    if(!isOS5())
      return;
    
    NSLog(@"setting newsstand icon");
    
    static int lastCoverImageRevision = 0;
    
    int revision = [self revision:index];
    
    if(revision > lastCoverImageRevision)
    {
      lastCoverImageRevision = revision;
      
      NSString *documentsDirectoryPath = [Helper getHomeDirectory];
      
      NSString* fileName = [[[self cover:index] lastPathComponent] stringByAppendingPathExtension:@"jpg"];
      
      NSString* fullName = [documentsDirectoryPath stringByAppendingPathComponent:fileName];
      
      UIImage *img = [UIImage imageWithContentsOfFile:fullName];
      
      if(img)
      {
        [[UIApplication sharedApplication] setNewsstandIconImage:img];
      }
    }

    
  }
  
   
}

@end
