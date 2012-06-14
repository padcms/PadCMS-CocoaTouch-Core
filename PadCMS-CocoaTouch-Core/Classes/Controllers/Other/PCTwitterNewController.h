//
//  PCTwitterNewController.h
//  Pad CMS
//
//  Created by Igor Getmanenko on 02.02.12.
//  Copyright 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Twitter/TWTweetComposeViewController.h>
#import <MobileCoreServices/MobileCoreServices.h>

@class PCTwitterNewController;

@protocol PCTwitterNewControllerDelegate <NSObject>

@required

- (void)dismissPCNewTwitterController:(TWTweetComposeViewController *)currentPCTwitterNewController;
- (void)showPCNewTwitterController:(TWTweetComposeViewController *)tweetController;

@end

@interface PCTwitterNewController : NSObject 
{
    TWTweetComposeViewController *_tweetViewController;
    NSString *_twitterMessage;
}

@property (nonatomic, assign, readwrite) id <PCTwitterNewControllerDelegate> delegate;
@property (nonatomic, retain) TWTweetComposeViewController *tweetViewController;
@property (nonatomic, retain) NSString *twitterMessage;

- (id) initWithMessage:(NSString*)message;
- (void) showTwitterController;

@end
