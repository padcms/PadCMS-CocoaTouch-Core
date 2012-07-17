//
//  PCSubscriptionsMenuView.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Igor Getmanenko on 17.07.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCSubscriptionsMenuView.h"

@interface PCSubscriptionsMenuView()

- (void) subscribe;
- (void) renewSubscription;

@end

@implementation PCSubscriptionsMenuView

@synthesize delegate;
@synthesize needRestoreIssues;

- (id)initWithFrame:(CGRect)frame andSubscriptionFlag:(BOOL) isIssuesToRestore
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        needRestoreIssues = isIssuesToRestore;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIImageView* bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"subscriptionsPopup.png"]];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, bg.frame.size.width, bg.frame.size.height);
    [self addSubview:bg];
    [bg release];
    
    UIButton *subscribeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    subscribeButton.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height/2);
    subscribeButton.center = CGPointMake(subscribeButton.frame.size.width/2, subscribeButton.frame.size.height/2);
    [subscribeButton addTarget:self action:@selector(subscribe) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:subscribeButton];
    
    UIButton *renewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    renewButton.frame = CGRectMake(self.frame.origin.x, self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2);
    renewButton.center = CGPointMake(renewButton.frame.size.width/2, renewButton.frame.size.height/2 + renewButton.frame.origin.y);
    [renewButton addTarget:self action:@selector(renewSubscription) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:renewButton];
}

- (void)subscribe
{
    self.hidden = YES;
    [self.delegate newSubscription];
}

- (void)renewSubscription
{
    self.hidden = YES;
    [self.delegate renewSubscription:needRestoreIssues];
}

@end
