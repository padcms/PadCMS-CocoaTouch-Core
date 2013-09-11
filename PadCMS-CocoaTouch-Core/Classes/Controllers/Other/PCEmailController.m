//
//  PCEmailController.m
//  Pad CMS
//
//  Created by Igor Getmanenko on 02.02.12.
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

#import "PCEmailController.h"
#import "PCApplication.h"
#import "PCLocalizationManager.h"

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
         _emailViewController = [[MFMailComposeViewController alloc] init];
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
									initWithTitle:[PCLocalizationManager localizedStringForKey:@"TITLE_ERROR_SENDING_EMAIL"
                                                                                         value:@"Error sending email!"] 
									message:[PCLocalizationManager localizedStringForKey:@"MSG_EMAIL_CLIENT_IS_NOT_CONFIGURED"
                                                                                   value:@"Email client is not configured."]
									delegate:nil
									cancelButtonTitle:[PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_OK"
                                                                                             value:@"OK"]
									otherButtonTitles:nil];
        
        [errorAllert show];
		[errorAllert release];
		
		return;
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
