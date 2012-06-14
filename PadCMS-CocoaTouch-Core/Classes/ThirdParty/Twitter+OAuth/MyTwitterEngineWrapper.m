//
//  MyTwitterEngineWrapper.m
//  socgen
//
//  Created by peter on 10.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MyTwitterEngineWrapper.h"

#define kOAuthConsumerKey				@"xnh8OVHeabBGRl2bhK3g"
#define kOAuthConsumerSecret			@"6OimM1a0AmKbpPWNp3fydmjHb90QG7NxunOKDCwlg"

@implementation MyTwitterEngineWrapper
@synthesize  delegate = _delegate,_engine;

+ (MyTwitterEngineWrapper*) getEngineWithDelegate:(id <MyTwitterEngineWrapperDelegate>) delegate
{
	MyTwitterEngineWrapper* myengine = [[MyTwitterEngineWrapper new]retain];
	myengine.delegate=delegate;	
	myengine._engine = [[[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: delegate] autorelease];	
	
	myengine._engine.consumerKey = kOAuthConsumerKey;
	myengine._engine.consumerSecret = kOAuthConsumerSecret;	
	
	if (!myengine._engine.OAuthSetup) [myengine._engine requestRequestToken];
	
	return myengine;
}

- (id) init
{
	[super init];
	pin = [NSMutableString new];	
	username = [NSMutableString new];	
	password = [NSMutableString new];	
	
	return self;
}

- (BOOL)isAuthenticated
{
	return [_engine isAuthorized];
}

- (void) AuthentificationsStart:(NSString*)_username password:(NSString*)_password
{
	[username setString:_username];
	[password setString:_password];
	
	NSURLRequest* startRequest = [_engine authorizeURLRequest];
	NSLog(@"startRequestURL=%@\n\n\n",startRequest);
	
	UIWebView* web = [UIWebView new];	
	web.delegate=self;
	web.dataDetectorTypes = UIDataDetectorTypeLink;	
	[web loadRequest:startRequest];	
}

- (void) sendMessage:(NSString*)_message
{
	//[_engine sendUpdate: _message];
	//note from peter: twitter reject duplicating statuses 403 probably use something like this
	[_engine sendUpdate: [NSString stringWithFormat: @"%@ %@",_message,[NSDate date]]];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{	
	
	static BOOL started; 	
	//if(!started)
	{		
		NSString			*str0 = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var f = document.forms[0];\
																					 f.elements['username_or_email'].value = '%@';\
																					 f.elements['session[password]'].value = '%@';document.forms[0].submit();",username,password,nil]];	 		
		[webView stringByEvaluatingJavaScriptFromString:str0];		
		started=YES;
	}
	
}

-(NSString*) searchPIN:(NSString*)html
{
	
	int t;t++;
	
	if (html.length == 0) return nil;
	NSString* PIN;
	
	const char			*rawHTML = (const char *) [html UTF8String];
	int					length = strlen(rawHTML), chunkLength = 0;
	
	for (int i = 0; i < length; i++) {
		if (rawHTML[i] < '0' || rawHTML[i] > '9') {
			if (chunkLength == 7) {
				char				*buffer = (char *) malloc(chunkLength + 1);
				
				memmove(buffer, &rawHTML[i - chunkLength], chunkLength);
				buffer[chunkLength] = 0;
				
				PIN = [NSString stringWithUTF8String: buffer];
				free(buffer);
				return PIN;
			}
			chunkLength = 0;
		} else
			chunkLength++;
	}	
	return @"";//crash no found
}

- (void) gotPin {
	
	[_engine setPin:pin];
	[_engine requestAccessToken];	

	if ([_delegate respondsToSelector: @selector(twitterAuthenticated)]) 	
		[_delegate twitterAuthenticated];
	
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{	
	
	if( (navigationType == UIWebViewNavigationTypeFormResubmitted)||(navigationType == UIWebViewNavigationTypeFormSubmitted) )	
	{		
		
		webView.delegate=nil;
		NSError* err;
		NSData* dataReply = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&err];
		NSString* stringReply = (NSString *)[[[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding] autorelease];				
						
		if([stringReply rangeOfString:@"Invalid user name or password"].location!=NSNotFound)
		{
			
			if ([_delegate respondsToSelector: @selector(twitterAuthenticationFailed)]) 
				[_delegate twitterAuthenticationFailed];				

			return NO;	
		}		
				
		[pin setString:[self searchPIN:stringReply]];	
		
		
		[self performSelectorOnMainThread:@selector(gotPin)  withObject:nil	waitUntilDone:false];				
		return NO;
	}
	
	return TRUE;
}

@end
