//
//  PCFacebookViewController.h
//  Pad CMS
//
//  Created by Igor Getmanenko on 02.02.12.
//  Copyright 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"

@interface PCFacebookViewController : UIViewController <FBDialogDelegate>
{
    NSString *_facebookMessage;
    Facebook *_facebook;
}

@property (nonatomic, retain) NSString *facebookMessage;
@property (nonatomic, retain) Facebook *facebook;

- (id) initWithMessage:(NSString*)message;
- (void) initFacebookSharer;

@end
