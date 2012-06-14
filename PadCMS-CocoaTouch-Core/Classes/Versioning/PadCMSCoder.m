//
//  PadCMSCoder.m
//  temp
//
//  Created by mark on 1/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PadCMSCoder.h"
#import "JSON.h"
#import "Reachability.h"
#import "VersionManager.h"
#import "Helper.h"
#import "InAppPurchases.h"
#import "PCConfig.h"

NSString* PCNetworkServiceJSONRPCPath = @"/api/v1/jsonrpc.php";

@implementation PadCMSCoder
@synthesize validUDID;//,filter;
@synthesize isAdminUDID;

- (id) initWithDelegate:(id <PadCMSCodeDelegate>) padDelegate_
{
	if ((self = [super init]))
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendReceipt:) name:kInAppPurchaseManagerTransactionSucceededNotification object:nil];
		
		padDelegate = padDelegate_;
	//	self.filter = [[[NSMutableArray alloc] init] autorelease];
	}
	return self;
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
  
#ifdef RUE
  NSDictionary *innerDict = [NSDictionary dictionaryWithObjectsAndKeys:devId, @"sUdid", [notification object], @"sReceiptData",@"f9103179a4044887ba078217e4a0cd76", @"sSecretPassword", nil];
  
#elif UNI
   NSDictionary *innerDict = [NSDictionary dictionaryWithObjectsAndKeys:devId, @"sUdid", [notification object], @"sReceiptData",@"2bc3f7bac5f04609bd13ba27f878eaa9", @"sSecretPassword", nil];
#else
  NSDictionary *innerDict = [NSDictionary dictionaryWithObjectsAndKeys:devId, @"sUdid", [notification object], @"sReceiptData", nil];
#endif
	

	
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
	
	[padDelegate restartApplication];
	
	//[[NSNotificationCenter defaultCenter] postNotificationName:reloadCellNotification object:nil];
}
/*
- (BOOL) syncServerPlistDownloadToDirectory:(NSString *)directory
{
	NSString *devId = [[UIDevice currentDevice]uniqueIdentifier];
	
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
	
//	NSLog(@"jsonString is: %@", jsonString);
	
	[tmpJsonWriter release];
	
	[request setHTTPBody:[jsonString dataUsingEncoding:NSASCIIStringEncoding]];
	
//    NSLog(@"Url is :%@", request.URL);
    
	NSData *dataReply = [NSURLConnection  sendSynchronousRequest:request returningResponse:nil error:nil];
	
	if(dataReply != nil) 
	{
		NSString* stringReply = [[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
//		NSLog(@"stringReply is:\n%@", stringReply);
		NSString* stringWithoutNull = [stringReply stringByReplacingOccurrencesOfString:@"null" withString:@"\"\""];
		NSDictionary* theDict = [stringWithoutNull JSONValue];
        
        
		
		[stringReply release];
		
		if([theDict valueForKey:@"result"] == nil)
			self.validUDID = NO;
		else
		{
			NSDictionary* aDict = [theDict objectForKey:@"result"];
			self.validUDID = NO;
			if(aDict == nil) return NO;
			self.validUDID = YES;
            
            [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", [Helper getHomeDirectory], directory] 
                                      withIntermediateDirectories:YES 
                                                       attributes:nil 
                                                            error:nil];
            
            NSString *path = [NSString stringWithFormat:@"%@/%@/%@", [Helper getHomeDirectory], directory, @"server.plist"];
            
//            NSLog(@"Path: %@", path);
            
			[aDict writeToFile:path atomically:YES];
			return YES;
		}
	}
	
	return NO;	
}*/

- (BOOL) syncServerPlistDownload
{
	
	NSString *devId = [[UIDevice currentDevice]uniqueIdentifier];
	
	NSURL* theURL = [[PCConfig serverURL] URLByAppendingPathComponent:PCNetworkServiceJSONRPCPath];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
	
	[request setHTTPMethod:@"POST"];
	
	NSMutableDictionary *mainDict = [NSMutableDictionary dictionary];
	[mainDict setObject:@"client.getIssues" forKey:@"method"];
	

	/*NSDictionary *innerDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",[PCConfig clientIdentifier]], @"iClientId",[NSString stringWithFormat:@"%d",[PCConfig applicationIdentifier]],@"iApplicationId", nil];*/

	NSDictionary *innerDict = [NSDictionary dictionaryWithObjectsAndKeys:devId, @"sUdid",[NSString stringWithFormat:@"%d",[PCConfig clientIdentifier]], @"iClientId",[NSString stringWithFormat:@"%d",[PCConfig applicationIdentifier]],@"iApplicationId", nil];
	[mainDict setObject:innerDict forKey:@"params"];
	
	[mainDict setObject:@"1" forKey:@"id"];
	
	SBJsonWriter *tmpJsonWriter = [[SBJsonWriter alloc] init];
	NSString *jsonString = [tmpJsonWriter stringWithObject:mainDict];
	
//	NSLog(@"jsonString is:\n%@", jsonString);
	
	[tmpJsonWriter release];
	
	[request setHTTPBody:[jsonString dataUsingEncoding:NSASCIIStringEncoding]];
	
	NSData *dataReply = [NSURLConnection  sendSynchronousRequest:request returningResponse:nil error:nil];
	
	if(dataReply != nil) 
	{
		NSString* stringReply = [[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
//		NSLog(@"stringReply is:\n%@", stringReply);
		NSString* stringWithoutNull = [stringReply stringByReplacingOccurrencesOfString:@"null" withString:@"\"\""];
		NSDictionary* theDict = [stringWithoutNull JSONValue];
    
				
		[stringReply release];
		
		if([theDict valueForKey:@"result"] == nil)
			self.validUDID = NO;
		else
		{
			NSDictionary* aDict = [theDict objectForKey:@"result"];
			self.validUDID = NO;
			if(aDict == nil) return NO;
			self.validUDID = YES;
			[aDict writeToFile:[[Helper getHomeDirectory]stringByAppendingPathComponent:@"server.plist"] atomically:YES];
			return YES;
		}
	}
	
	return NO;	
}
/*
- (void) reloadFilter
{
	[self.filter removeAllObjects];					  
	
	VersionManager* manager = [VersionManager sharedManager];
	
	NSMutableArray* sortedItems = [[NSMutableArray alloc] init];
	[sortedItems addObjectsFromArray:manager.items];
	NSSortDescriptor *revisionSorter = [[NSSortDescriptor alloc] initWithKey:@"revision_id" ascending:YES];	
	[sortedItems sortUsingDescriptors:[NSArray arrayWithObject:revisionSorter]];
	[revisionSorter release];
	
    for (int i=0; i<[sortedItems count]; i++)
    {
        NSDictionary* revision =  [sortedItems  objectAtIndex:i];
        int manager_index = [manager.items indexOfObject:revision];
        [self.filter addObject:[NSNumber numberWithInt:manager_index]];				
    }
	
	[self.filter writeToFile:[[Helper getHomeDirectory]stringByAppendingPathComponent:@"filter.plist"] atomically:YES];
	
	[sortedItems release];
	
}*/

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
//	self.filter = nil;
	[super dealloc];
}

@end