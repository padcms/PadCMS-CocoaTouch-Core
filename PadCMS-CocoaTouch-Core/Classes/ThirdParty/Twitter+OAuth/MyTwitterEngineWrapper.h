//
//  MyTwitterEngineWrapper.h
//  socgen
//
//  Created by peter on 10.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SA_OAuthTwitterEngine.h"

@protocol MyTwitterEngineWrapperDelegate <NSObject>
@optional
- (void) twitterAuthenticated;
- (void) twitterAuthenticationFailed;
@end

@interface MyTwitterEngineWrapper : NSObject <UIWebViewDelegate> {
	SA_OAuthTwitterEngine				*_engine;
	NSMutableString* pin;
	NSMutableString* username;
	NSMutableString* password;	
	id <MyTwitterEngineWrapperDelegate>		_delegate;	
}

@property (nonatomic, readwrite, assign) id <MyTwitterEngineWrapperDelegate> delegate;
@property (retain) SA_OAuthTwitterEngine				*_engine;

+ (id) getEngineWithDelegate:(id <MyTwitterEngineWrapperDelegate>) delegate;
- (void) sendMessage:(NSString*)message;

- (BOOL)isAuthenticated;

- (void) AuthentificationsStart:(NSString*)_username password:(NSString*)_password;

@end
