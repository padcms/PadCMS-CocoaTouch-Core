//
//  PCEmailController.m
//  Pad CMS
//
//  Created by Igor Getmanenko on 02.02.12.
//  Copyright 2012 Adyax. All rights reserved.
//

#import "PCEmailController.h"
#import "PCApplication.h"

@implementation PCEmailController

#pragma mark Properties

@synthesize delegate = _delegate;
@synthesize emailViewController = _emailViewController;
@synthesize emailMessageAndTitle = _emailMessageAndTitle;

#pragma mark PCEmailController instance methods

- (id) initWithMessage:(NSDictionary*)messageParams
{
	self = [super init];
    
    if (self) 
    {
        _delegate = nil;
        _emailViewController = nil;
        _emailMessageAndTitle = messageParams;
    }
    
	return self;
}

- (void) dealloc
{   
    [_emailViewController release], _emailViewController = nil;
    [_emailMessageAndTitle release], _emailMessageAndTitle = nil;
    _delegate = nil;
    
    [super dealloc];
}

- (void) emailShow
{
	if (![MFMailComposeViewController canSendMail])
	{
		UIAlertView *errorAllert = [[UIAlertView alloc] 
									initWithTitle:NSLocalizedString(@"Envoi d'erreur email!", nil) 
									message:NSLocalizedString(@"Client de messagerie n'est pas configurée.", nil) 
									delegate:nil
									cancelButtonTitle:@"OK" 
									otherButtonTitles:nil];
        
        [errorAllert show];
		[errorAllert release];
		
		return;
	}
    
    if (_emailViewController == nil)
    {
        _emailViewController = [[MFMailComposeViewController alloc] init];
    }
    
	self.emailViewController.mailComposeDelegate = self;

    [self.emailViewController setSubject:[self.emailMessageAndTitle objectForKey:PCApplicationNotificationTitleKey]];
    [self.emailViewController setMessageBody:[self.emailMessageAndTitle objectForKey:PCApplicationNotificationMessageKey] isHTML:YES];
	
    if (self.delegate)
    {
        [self.delegate showPCEmailController:self.emailViewController];
    }
    
    else
    {
        NSLog(@"PCEmailController.delegate is not defined");
    }
}

- (void) mailComposeController: (MFMailComposeViewController *)controller didFinishWithResult: (MFMailComposeResult)result error: (NSError *)error
{
    [self.delegate dismissPCEmailController:controller];
    //[self.emailViewController removeFromParentViewController];
}

@end
