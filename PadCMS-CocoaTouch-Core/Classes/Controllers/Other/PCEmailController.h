//
//  PCEmailController.h
//  Pad CMS
//
//  Created by Igor Getmanenko on 02.02.12.
//  Copyright 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@class PCEmailController;

@protocol PCEmailControllerDelegate <NSObject>

@required

- (void)dismissPCEmailController:(MFMailComposeViewController *)currentPCEmailController;
- (void)showPCEmailController:(MFMailComposeViewController *)emailControllerToShow;

@end

@interface PCEmailController : NSObject <MFMailComposeViewControllerDelegate>
{
    MFMailComposeViewController *_emailViewController;
    NSDictionary *_emailMessageAndTitle;
}

@property (nonatomic, assign, readwrite) id <PCEmailControllerDelegate> delegate;
@property (nonatomic, retain) MFMailComposeViewController *emailViewController;
@property (nonatomic, retain) NSDictionary *emailMessageAndTitle;

- (id) initWithMessage:(NSDictionary*)messageParams;
- (void) emailShow;

@end
