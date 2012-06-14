//
//  PCTwitterNewController.m
//  Pad CMS
//
//  Created by Igor Getmanenko on 02.02.12.
//  Copyright 2012 Adyax. All rights reserved.
//

#import "PCTwitterNewController.h"
#import "PCPathHelper.h"

@implementation PCTwitterNewController

@synthesize tweetViewController = _tweetViewController;
@synthesize delegate = _delegate;
@synthesize twitterMessage = _twitterMessage;

- (id) initWithMessage:(NSString*)message
{
    self = [super init];
    
    if (self) 
    {
        _tweetViewController = [[TWTweetComposeViewController alloc] init];
        _delegate = nil;
        _twitterMessage = message;
    }
    
    return self;
}

- (void) dealloc
{
    [_tweetViewController release], _tweetViewController = nil;
    [_twitterMessage release], _twitterMessage = nil;
    _delegate = nil;
    
    [super dealloc];
}

- (void) showTwitterController
{
    TWTweetComposeViewControllerCompletionHandler completionHandler = ^(TWTweetComposeViewControllerResult result) 
    {
        switch (result)
        {
            case TWTweetComposeViewControllerResultCancelled:
                NSLog(@"Twitter Result: canceled");
                break;
            case TWTweetComposeViewControllerResultDone:
                NSLog(@"Twitter Result: sent");
                break;
            default:
                NSLog(@"Twitter Result: default");
                break;
        }
        [self.delegate dismissPCNewTwitterController:self.tweetViewController];
    };
    [self.tweetViewController setCompletionHandler:completionHandler];

    [self.tweetViewController setInitialText:self.twitterMessage];
    [self.tweetViewController addImage:nil];
    [self.tweetViewController addURL:nil];
    if (self.delegate)
    {
        [self.delegate showPCNewTwitterController:self.tweetViewController];
    }
    else
    {
        NSLog(@"PCTwitterNewController.delegate is not defined");
    }
}

@end
