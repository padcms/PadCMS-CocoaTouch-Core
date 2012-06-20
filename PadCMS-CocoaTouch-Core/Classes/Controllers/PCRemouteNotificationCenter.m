//
//  PCRemouteNotificationCenter.m
//  Pad CMS
//
//  Created by Rustam Mallarkubanov on 07.03.12.
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

#import "PCRemouteNotificationCenter.h"
#import "JSON.h"
#import "PCConfig.h"

NSString* PCRemouteNotificationCenterUUIDKey = @"RemouteNotificationCenterUUID";

@implementation PCRemouteNotificationCenter

+(PCRemouteNotificationCenter*)defaultRemouteNotificationCenter
{
    static PCRemouteNotificationCenter* defaultRemouteNotificationCenter = nil;
    static dispatch_once_t predicate = 0;
	dispatch_once(&predicate, ^{ defaultRemouteNotificationCenter = [[PCRemouteNotificationCenter alloc] init]; });
    return defaultRemouteNotificationCenter;
}

-(id)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

-(NSURL*)serviceURL
{
    return [PCConfig serverURL];
}

-(NSURL*)registerTokenURL
{
    return [[self serviceURL] URLByAppendingPathComponent:@"/api/v1/jsonrpc.php"];
}

-(NSString*)UUID
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:PCRemouteNotificationCenterUUIDKey])
    {   
        CFUUIDRef UUID =  CFUUIDCreate(nil);
        CFStringRef strUUID = CFUUIDCreateString(nil,UUID);
        [[NSUserDefaults standardUserDefaults] setObject:(NSString*)strUUID forKey:PCRemouteNotificationCenterUUIDKey];
        CFRelease(UUID);
        CFRelease(strUUID);
    }
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:PCRemouteNotificationCenterUUIDKey];
}

-(NSString*)normalizeDeviceToken:(NSData*)aDevToken
{
    NSString *deviceToken = [[[[aDevToken description] 
                               stringByReplacingOccurrencesOfString:@"<"withString:@""] 
                              stringByReplacingOccurrencesOfString:@">" withString:@""] 
                             stringByReplacingOccurrencesOfString: @" " withString: @""];
    return deviceToken;
}

-(NSString*)generateDeviceRequestWithToken:(NSString*)deviceToken
{
    NSString* appIdentifier = [NSString stringWithFormat:@"%d",[PCConfig applicationIdentifier]];
    //NSString* UUID = [self UUID];
    NSString *UUID =  [[UIDevice currentDevice] uniqueIdentifier];
    NSMutableDictionary *mainDict = [NSMutableDictionary dictionary];
    [mainDict setObject:PCJSONSetDeviceTokenMethodName forKey:PCJSONMethodNameKey];
    
    NSDictionary *innerDict = [NSDictionary dictionaryWithObjectsAndKeys:UUID, PCJSONSDUDIDKey, deviceToken, PCJSONSDTokenKey, appIdentifier, PCJSONSDApplicationIDKey, nil];
    [mainDict setObject:innerDict forKey:PCJSONParamsKey];
    
    [mainDict setObject:@"1" forKey:PCJSONIDKey];
    
    SBJsonWriter *tmpJsonWriter = [[SBJsonWriter alloc] init];
    NSString *jsonString = [tmpJsonWriter stringWithObject:mainDict];
    [tmpJsonWriter release];

    return jsonString;
}

-(void)registerDeviceWithToken:(NSData*)aDevToken
{
    
    NSString *deviceToken = [self normalizeDeviceToken:aDevToken];    
    
    dispatch_queue_t requestQueue = dispatch_queue_create("WebServiceAPIQueue", NULL);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(requestQueue,
                   ^{
                       NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self registerTokenURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5.0];
                       
                       [request setHTTPMethod:@"POST"];
                       
                       NSString* jsonString = [self generateDeviceRequestWithToken:deviceToken];
                       NSLog(@"tokenRequest - %@", jsonString);
                       [request setHTTPBody:[jsonString dataUsingEncoding:NSASCIIStringEncoding]];
                       
                       NSError* error = nil;
                       NSURLResponse *response = nil;
                       
                       NSData *dataReply = [NSURLConnection  sendSynchronousRequest:request returningResponse:&response error:&error];
                       //NSDictionary* jsonResponse = nil;
                       
                       if(dataReply != nil) 
                       {
                           NSString* stringReply = [[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
                           NSLog(@"tokenReply - %@", stringReply);
                           //NSString* stringWithoutNull = [stringReply stringByReplacingOccurrencesOfString:@"null" withString:@"\"\""];
                           //sonResponse = [stringWithoutNull JSONValue];
                           [stringReply release];
                       }
                       else
                       {
                           NSLog(@"WebServiceAPI error=%@",error);
                           NSLog(@"WebServiceAPI response=%@",response);
                       }
                       
                       dispatch_async(mainQueue,
                                      ^{
                                      });
                       
                   });
    dispatch_release(requestQueue);
    
}


-(void)registrationDidFailWithError:(NSError*)aError
{
    NSLog(@"registration for registration Error=%@",aError);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1)
    {
        //TODO: bay last magazine action
    }
}

-(void)didReceiveRemoteNotification:(NSDictionary*)aNotificationInfo
{
    if ([aNotificationInfo objectForKey:@"aps"])
    {
        id alert = [[aNotificationInfo objectForKey:@"aps"] objectForKey:@"alert"];
        if (alert)
        {
            NSString* title = nil;
            
            if ([alert isKindOfClass:[NSString class]])
            {
                title = alert;
            }
            
            if ([alert isKindOfClass:[NSDictionary class]])
            {
                title = [(NSDictionary*)alert objectForKey:@"body"];
            }
            
            UIAlertView* alertView  = [[UIAlertView alloc] initWithTitle:title 
                                                                 message:nil 
                                                                delegate:self 
                                                       cancelButtonTitle:@"OK" 
                                                       otherButtonTitles:nil];
            [alertView show];
            [alertView release];
        }
    }
}

@end
