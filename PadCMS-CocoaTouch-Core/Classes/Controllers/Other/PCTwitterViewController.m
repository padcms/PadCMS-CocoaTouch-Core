//
//  PCTwitterViewController.m
//  Pad CMS
//
//  Created by Igor Getmanenko on 02.02.12.
//  Copyright 2012 Adyax. All rights reserved.
//

#import "PCTwitterViewController.h"
#import "PCPathHelper.h"

@interface PCTwitterViewController() 

- (void) twitterClick:(NSString*) message fromUser:(NSString*) username withPassword:(NSString*) password;
- (void) completeTwitterPost:(NSString*) status;
- (void) twitterViewControllerRemoveFromSuperView;

@end

@implementation PCTwitterViewController

@synthesize inputTwitterUsername;
@synthesize inputTwitterPassword;
@synthesize inputTwitterMessage;
@synthesize inputTwitterLabel;

@synthesize twitterMessage = _twitterMessage;
@synthesize tuser = _tuser;
@synthesize tpassword = _tpassword;
@synthesize tmessage = _tmessage;
@synthesize engine = _engine;

- (id) initWithMessage:(NSString*)message
{
	if (self = [super init])
	{
		_engine = nil;
        _twitterMessage = message;
        _tuser = nil;
        _tpassword = nil;
        _tmessage = nil;
	}
	
	return self;
}

- (void)dealloc
{
	[_engine release], _engine = nil;
	[_twitterMessage release], _twitterMessage = nil;
    [_tuser release], _tuser = nil;
    [_tmessage release], _tmessage = nil;
    [_tpassword release], _tpassword = nil;
    
    [super dealloc];
}

- (IBAction) dismissTwitter
{
    [self twitterViewControllerRemoveFromSuperView];
}

- (IBAction) btnEnvoyerClick:(id) sender
{
	[self twitterClick:self.inputTwitterMessage.text fromUser:self.inputTwitterUsername.text withPassword:self.inputTwitterPassword.text];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.engine = [MyTwitterEngineWrapper getEngineWithDelegate:self];
    self.inputTwitterMessage.text = self.twitterMessage;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void) twitterViewControllerRemoveFromSuperView
{
    [self.view removeFromSuperview]; 
}

#pragma mark Text Methods

- (void) textViewDidChange:(UITextView *)textView
{
	
	if (textView == self.inputTwitterMessage)
	{
		int len = [textView.text length];
		int rest = 140 - len;
		NSString* restString = [NSString stringWithFormat:@"(%d caracteres restants)",rest];		
		inputTwitterLabel.text = restString;
	}
	
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView == self.inputTwitterMessage) 
	{
		if (!([textView.text length] + [text length] - range.length <= 140))
		{
			return NO;
		}
	}
    
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField == self.inputTwitterUsername)
	{
		if (!([textField.text length] + [string length] - range.length <= 50))
		{
			return NO;
		}
	}
	else if(textField == self.inputTwitterPassword)
	{
		if (!([textField.text length] + [string length] - range.length <= 50))
		{
			return NO;
		}	
	}
	
	return YES;
}

#pragma mark TwitterEngineDelegate

- (void) requestSucceeded: (NSString *) requestIdentifier
{
	NSLog(@"Request %@ succeeded", requestIdentifier);
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Le message suivant a été posté sur votre compte twitter.", nil) message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];	
	[alert release];
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error
{
	NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);
}

- (void) twitterAuthenticated
{
	[self.engine sendMessage:self.twitterMessage];
	NSLog(@"twitterAuthenticated");
}

- (void) twitterAuthenticationFailed
{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Impossible de publier sur twitter", nil) message:NSLocalizedString(@"Utilisateur ou mot de passe incorrects", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
	NSLog(@"twitterAuthenticationFailed");	
}

- (void) doTwitterAuthentificate
{
	[self.engine AuthentificationsStart:self.tuser password:self.tpassword];	
}

- (void) doTwitterPost:(NSString*) message
{
	NSString* status = @"";
	
	@try
	{
		if([self.engine isAuthenticated])
        {
			[self.engine sendMessage:message];
        }
        
		else
		{
			self.twitterMessage = [NSString stringWithString:message];
			[self doTwitterAuthentificate];
		}
	}
	@catch (NSException * e)
	{
		status = @"General error";
	}
	
	[self completeTwitterPost:status];
}

- (void) completeTwitterPost:(NSString*) status
{
    [self twitterViewControllerRemoveFromSuperView];
}

- (void) twitterClick:(NSString*) message fromUser:(NSString*) username withPassword:(NSString*) password
{
	self.tuser = [NSString stringWithString:username];
	self.tpassword = [NSString stringWithString:password];
	self.tmessage = [NSString stringWithString:message];
    
    if (self.engine)
    {
        [self doTwitterPost:self.tmessage];
    }
    else
    {
        NSLog(@"MyTwitterEngineWrapper is not defined");
    }
}

@end
