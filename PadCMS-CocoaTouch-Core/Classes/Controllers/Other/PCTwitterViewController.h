//
//  PCTwitterViewController.h
//  Pad CMS
//
//  Created by Igor Getmanenko on 02.02.12.
//  Copyright 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyTwitterEngineWrapper.h"

@interface PCTwitterViewController : UIViewController <MyTwitterEngineWrapperDelegate>
{
	MyTwitterEngineWrapper *_engine;
	
	NSString *_tuser;
	NSString *_tpassword;
	NSString *_tmessage;
	NSString *_twitterMessage;
}

@property (nonatomic, retain) IBOutlet UITextField* inputTwitterUsername;
@property (nonatomic, retain) IBOutlet UITextField* inputTwitterPassword;
@property (nonatomic, retain) IBOutlet UITextView* inputTwitterMessage;
@property (nonatomic, retain) IBOutlet UILabel* inputTwitterLabel;

@property (nonatomic, retain) NSString *twitterMessage;
@property (nonatomic, retain) NSString *tmessage;
@property (nonatomic, retain) NSString *tpassword;
@property (nonatomic, retain) NSString *tuser;
@property (nonatomic, retain) MyTwitterEngineWrapper *engine;

- (id) initWithMessage:(NSString*)message;
- (IBAction) dismissTwitter;
- (IBAction) btnEnvoyerClick:(id) sender;

@end
