//
//  TopBarView.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Maxim Pervushin on 7/27/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCTopBarView.h"

#import "PCConfig.h"
#import "PCLocalizationManager.h"

#define BarBackgroundImage @"panel_button.png"
#define BarLogoImage @"logo.png"
#define BarHomeButtonImage @"button_home.png"
#define BarSummaryButtonImage @"button_summary.png"
#define BarSubscriptionsButtonImage @"button_subscriptions.png"
#define BarShareButtonImage @"button_partager.png"
#define BarHelpButtonImage @"button_answ.png"

#define BarButtonOffset 0

@interface PCTopBarView ()
{
    UIImageView *_backgroundImageView;
    UIButton *_backButton;
    UIButton *_summaryButton;
    UIImageView *_logoImageView;
    UITextField *_searchTextField;
    UIButton *_subscriptionsButton;
    UIButton *_shareButton;
    UIButton *_helpButton;
}

- (void)backButtonTapped:(UIButton *)button;
- (void)summaryButtonTapped:(UIButton *)button;
- (void)subscriptionsButtonTapped:(UIButton *)button;
- (void)shareButtonTapped:(UIButton *)button;
- (void)helpButtonTapped:(UIButton *)button;

@end

@implementation PCTopBarView
@synthesize delegate;

- (void)dealloc
{
    [_backgroundImageView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        
        CGSize boundsSize = self.bounds.size;
        
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        _backgroundImageView.image = [UIImage imageNamed:BarBackgroundImage];
        _backgroundImageView.backgroundColor = [UIColor blackColor];
        [self addSubview:_backgroundImageView];
        
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, boundsSize.height, boundsSize.height)];
        UIImage *homeButtonImage = [UIImage imageNamed:BarHomeButtonImage];
        if (homeButtonImage != nil) {
            [_backButton setImage:homeButtonImage forState:UIControlStateNormal];
        } else {
            _backButton.backgroundColor = [UIColor orangeColor];
        }
        [_backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        
        _summaryButton = [[UIButton alloc] initWithFrame:CGRectMake(boundsSize.height + BarButtonOffset, 0, boundsSize.height, boundsSize.height)];
        UIImage *summaryButtonImage = [UIImage imageNamed:BarSummaryButtonImage];
        if (summaryButtonImage != nil) {
            [_summaryButton setImage:summaryButtonImage forState:UIControlStateNormal];
        } else {
            _summaryButton.backgroundColor = [UIColor orangeColor];
        }
        [_summaryButton addTarget:self action:@selector(summaryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_summaryButton];
        
        _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((boundsSize.height + BarButtonOffset) * 2, 0, (boundsSize.width - 100) / 2 - (boundsSize.height + BarButtonOffset) * 2, boundsSize.height)];
        _logoImageView.image = [UIImage imageNamed:BarLogoImage];
        _logoImageView.contentMode = UIViewContentModeLeft;
        [self addSubview:_logoImageView];
        
        BOOL searchEnabled = [PCConfig isSearchDisabled] ? NO : YES;
        if (searchEnabled) {
            _searchTextField = [[UITextField alloc] initWithFrame:CGRectMake((boundsSize.height + BarButtonOffset) * 2 + (boundsSize.width - 100) / 2 - (boundsSize.height + BarButtonOffset) * 2,
                                                                             (boundsSize.height - 31) / 2 ,
                                                                             (boundsSize.width - 100) / 2 - (boundsSize.height + BarButtonOffset) * 2,
                                                                             31)];
            _searchTextField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            _searchTextField.returnKeyType = UIReturnKeySearch;
            _searchTextField.borderStyle = UITextBorderStyleRoundedRect;
            _searchTextField.delegate = self;
            [self addSubview:_searchTextField];
        }
        
        _subscriptionsButton = [[UIButton alloc] initWithFrame:CGRectMake(boundsSize.width - boundsSize.height * 2 - BarButtonOffset - 100, 0, 100, boundsSize.height)];
        _subscriptionsButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        // TODO: make localizable
        [_subscriptionsButton setTitle:[PCLocalizationManager localizedStringForKey:@"Subscription" value:@"Subscription"] forState:UIControlStateNormal];
        _subscriptionsButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        
        [_subscriptionsButton setImage:[UIImage imageNamed:BarSubscriptionsButtonImage] forState:UIControlStateNormal];
        [_subscriptionsButton addTarget:self action:@selector(subscriptionsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_subscriptionsButton];
        
        _shareButton = [[UIButton alloc] initWithFrame:CGRectMake(boundsSize.width - boundsSize.height * 2 - BarButtonOffset, 0, boundsSize.height, boundsSize.height)];
        _shareButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        UIImage *shareButtonImage = [UIImage imageNamed:BarShareButtonImage];
        if (shareButtonImage != nil) {
            [_shareButton setImage:shareButtonImage forState:UIControlStateNormal];
        } else {
            _shareButton.backgroundColor = [UIColor orangeColor];
        }
        [_shareButton addTarget:self action:@selector(shareButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_shareButton];
        
        _helpButton = [[UIButton alloc] initWithFrame:CGRectMake(boundsSize.width - boundsSize.height, 0, boundsSize.height, boundsSize.height)];
        _helpButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        UIImage *helpButtomImage = [UIImage imageNamed:BarHelpButtonImage];
        if (helpButtomImage != nil) {
            [_helpButton setImage:helpButtomImage forState:UIControlStateNormal];
        } else {
            _helpButton.backgroundColor = [UIColor orangeColor];
        }
        [_helpButton addTarget:self action:@selector(helpButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_helpButton];
    }
    
    return self;
}

- (void)backButtonTapped:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(topBarView:backButtonTapped:)]) {
        [self.delegate topBarView:self backButtonTapped:button];
    }
}

- (void)summaryButtonTapped:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(topBarView:summaryButtonTapped:)]) {
        [self.delegate topBarView:self summaryButtonTapped:button];
    }
}

- (void)subscriptionsButtonTapped:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(topBarView:subscriptionsButtonTapped:)]) {
        [self.delegate topBarView:self subscriptionsButtonTapped:button];
    }
}

- (void)shareButtonTapped:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(topBarView:shareButtonTapped:)]) {
        [self.delegate topBarView:self shareButtonTapped:button];
    }
}

- (void)helpButtonTapped:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(topBarView:helpButtonTapped:)]) {
        [self.delegate topBarView:self helpButtonTapped:button];
    }
}

#pragma mark - public methods

- (void)setSummaryButtonHidden:(BOOL)hidden animated:(BOOL)animated
{
    void (^block)(void) = ^(void) {
        _summaryButton.alpha = hidden ? 0 : 1;
    };
    
    if (animated) {
        [UIView animateWithDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration
                         animations:block];
    } else {
        block();
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(topBarView:searchText:)]) {
        [self.delegate topBarView:self searchText:_searchTextField.text];
    }

    return YES;
}

@end
