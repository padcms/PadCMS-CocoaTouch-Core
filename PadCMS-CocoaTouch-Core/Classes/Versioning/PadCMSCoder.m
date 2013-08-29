//
//  PadCMSCoder.m
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
  
    NSDictionary *innerDict = [NSDictionary dictionaryWithObjectsAndKeys:devId, @"sUdid", [notification object], @"sReceiptData", [PCConfig sharedSecretKey], @"sSecretPassword", nil];
	
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
    
        NSLog(@"%@", theDict);
				
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
