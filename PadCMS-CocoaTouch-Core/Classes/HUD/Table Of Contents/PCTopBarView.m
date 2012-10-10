//
//  PCTopBarView.m
//  PCTopBarView
//
//  Created by Maxim Pervushin on 7/27/12.
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

#import "PCTopBarView.h"

#import "PCConfig.h"
#import "PCLocalizationManager.h"
#import "PCConfig.h"
#import "UIView+plist.h"

#define BarButtonOffset 0

NSString *TopBarViewStyle = @"PCTopBarViewStyle";
NSString *TopBarViewLogoImage = @"PCTopBarViewLogoImage";
NSString *TopBarViewSearchStyle = @"PCTopBarViewSearchStyle";
NSString *TopBarViewSearchEnabled = @"PCTopBarViewSearchEnabled";
NSString *TopBarViewHelpButtonStyle = @"PCTopBarViewHelpButtonStyle";
NSString *TopBarViewHelpButtonEnabled = @"PCTopBarViewHelpButtonEnabled";
NSString *TopBarViewHelpButtonImage = @"PCTopBarViewHelpButtonImage";
NSString *TopBarViewContactButtonStyle = @"PCTopBarViewContactButtonStyle";
NSString *TopBarViewContactButtonEnabled = @"PCTopBarViewContactButtonEnabled";
NSString *TopBarViewContactButtonImage = @"PCTopBarViewContactButtonImage";
NSString *TopBarViewContactButtonText = @"PCTopBarViewContactButtonText";
NSString *TopBarViewShareButtonStyle = @"PCTopBarViewShareButtonStyle";
NSString *TopBarViewShareButtonEnabled = @"PCTopBarViewShareButtonEnabled";
NSString *TopBarViewShareButtonImage = @"PCTopBarViewShareButtonImage";
NSString *TopBarViewSubscriptionsButtonStyle = @"PCTopBarViewSubscriptionsButtonStyle";
NSString *TopBarViewSubscriptionsButtonEnabled = @"PCTopBarViewSubscriptionsButtonEnabled";
NSString *TopBarViewSubscriptionsButtonImage = @"PCTopBarViewSubscriptionsButtonImage";
NSString *TopBarViewBackButtonStyle = @"PCTopBarViewBackButtonStyle";
NSString *TopBarViewBackButtonEnabled = @"PCTopBarViewBackButtonEnabled";
NSString *TopBarViewBackButtonImage = @"PCTopBarViewBackButtonImage";
NSString *TopBarViewSummaryButtonStyle = @"PCTopBarViewSummaryButtonStyle";
NSString *TopBarViewSummaryButtonEnabled = @"PCTopBarViewSummaryButtonEnabled";
NSString *TopBarViewSummaryButtonImage = @"PCTopBarViewSummaryButtonImage";


@interface PCTopBarView ()
{
    UIImageView *_backgroundImageView;
    UIButton *_backButton;
    UIButton *_summaryButton;
    UIImageView *_logoImageView;
    UITextField *_searchTextField;
    UIButton *_subscriptionsButton;
    UIButton *_contactButton;
    UIButton *_shareButton;
    UIButton *_helpButton;
}

- (void)buttonTapped:(UIButton *)sender;
//- (void)backButtonTapped:(UIButton *)button;
//- (void)summaryButtonTapped:(UIButton *)button;
//- (void)subscriptionsButtonTapped:(UIButton *)button;
//- (void)shareButtonTapped:(UIButton *)button;
//- (void)helpButtonTapped:(UIButton *)button;

@end

@implementation PCTopBarView
@synthesize delegate;
@synthesize backButton = _backButton;
@synthesize summaryButton = _summaryButton;
@synthesize subscriptionsButton = _subscriptionsButton;
@synthesize contactButton = _contactButton;
@synthesize shareButton = _shareButton;
@synthesize helpButton = _helpButton;

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
        _backgroundImageView.backgroundColor = [UIColor blackColor];
        [self addSubview:_backgroundImageView];
        
        NSDictionary *padCMSConfig = [PCConfig padCMSConfig];
        
        if (padCMSConfig == nil) {
            return self;
        }
        
        NSDictionary *topBarViewConfig = [padCMSConfig objectForKey:TopBarViewStyle];
        
        if (topBarViewConfig == nil) {
            return self;
        }
        
        // back button
        NSDictionary *backButtonConfig = [topBarViewConfig objectForKey:TopBarViewBackButtonStyle];
        

        if (backButtonConfig) {
            _backButton = [[UIButton alloc] init];
            [_backButton styledWithDictionary:backButtonConfig];
            [_backButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_backButton];
        }
            
        

/*        if (backButtonConfig != nil &&
            [[backButtonConfig objectForKey:TopBarViewBackButtonEnabled] boolValue]) {
            
            _backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, boundsSize.height, boundsSize.height)];
            
            UIImage *homeButtonImage = [UIImage imageNamed:[backButtonConfig objectForKey:TopBarViewBackButtonImage]];
            if (homeButtonImage != nil) {
                [_backButton setImage:homeButtonImage forState:UIControlStateNormal];
            } else {
                _backButton.backgroundColor = [UIColor orangeColor];
            }
            NSLog(@"back frame: %@", NSStringFromCGRect(CGRectMake(0, 0, boundsSize.height, boundsSize.height)));
            NSLog(@"back font:  %@", _backButton.titleLabel.font);
            
            [_backButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:_backButton];
        }*/
        
        // summary button
        NSDictionary *summaryButtonConfig = [topBarViewConfig objectForKey:TopBarViewSummaryButtonStyle];
        
        if (summaryButtonConfig != nil &&
            [[summaryButtonConfig objectForKey:TopBarViewSummaryButtonEnabled] boolValue]) {
            
            _summaryButton = [[UIButton alloc] initWithFrame:CGRectMake(boundsSize.height + BarButtonOffset, 0, boundsSize.height, boundsSize.height)];
            
            UIImage *summaryButtonImage = [UIImage imageNamed:[summaryButtonConfig objectForKey:TopBarViewSummaryButtonImage]];
            if (summaryButtonImage != nil) {
                [_summaryButton setImage:summaryButtonImage forState:UIControlStateNormal];
            } else {
                _summaryButton.backgroundColor = [UIColor orangeColor];
            }
            NSLog(@"sum frame: %@", NSStringFromCGRect(CGRectMake(boundsSize.height + BarButtonOffset, 0, boundsSize.height, boundsSize.height)));
            NSLog(@"sum font:  %@", _summaryButton.titleLabel.font);
  
            [_summaryButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:_summaryButton];
        }
        
        // logo
        NSDictionary *logoConfig = [topBarViewConfig objectForKey:TopBarViewLogoImage];
        NSLog(@"%@", logoConfig);
        if (logoConfig) {
            _logoImageView = [[UIImageView alloc] init];
            [_logoImageView styledWithDictionary:logoConfig];
            [self addSubview:_logoImageView];
            /*
            _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((boundsSize.height + BarButtonOffset) * 2, 0, (boundsSize.width - 100) / 2 - (boundsSize.height + BarButtonOffset) * 2, boundsSize.height)];
            _logoImageView.image = [UIImage imageNamed:logoImage];
            _logoImageView.contentMode = UIViewContentModeLeft;
            [self addSubview:_logoImageView];*/
        }
        
        // search
        NSDictionary *searchConfig = [topBarViewConfig objectForKey:TopBarViewSearchStyle];
        
        if (searchConfig != nil && [[searchConfig objectForKey:TopBarViewSearchEnabled] boolValue]) {
            
            
            CGRect searchTextFieldFrame = CGRectMake((boundsSize.height + BarButtonOffset) * 2 + (boundsSize.width - 100) / 2 - (boundsSize.height + BarButtonOffset) * 2,
                                                     (boundsSize.height - 31) / 2 ,
                                                     (boundsSize.width - 100) / 2 - (boundsSize.height + BarButtonOffset) * 2,
                                                     31);
            _searchTextField = [[UITextField alloc] initWithFrame:searchTextFieldFrame];
            _searchTextField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            _searchTextField.returnKeyType = UIReturnKeySearch;
            _searchTextField.borderStyle = UITextBorderStyleRoundedRect;
            _searchTextField.delegate = self;
            NSLog(@"search frame: %@", NSStringFromCGRect(searchTextFieldFrame));
            NSLog(@"search font:  %@", _searchTextField.font);

            [self addSubview:_searchTextField];
        }
        
        // subscriptions button
        NSDictionary *subscriptionsButtonConfig = [topBarViewConfig objectForKey:TopBarViewSubscriptionsButtonStyle];
        
        if (subscriptionsButtonConfig) {
            _subscriptionsButton = [[UIButton alloc] init];
            [_subscriptionsButton styledWithDictionary:subscriptionsButtonConfig];
            [_subscriptionsButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_subscriptionsButton];
        }
        
/*        if (subscriptionsButtonConfig != nil &&
            [[subscriptionsButtonConfig objectForKey:TopBarViewSubscriptionsButtonEnabled] boolValue]) {
            
            CGRect subscriptionsButtonFrame = CGRectMake(boundsSize.width - boundsSize.height * 2 - BarButtonOffset - 100, 0, 100, boundsSize.height);
            _subscriptionsButton = [[UIButton alloc] initWithFrame:subscriptionsButtonFrame];
            _subscriptionsButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            NSLog(@"subscriptions frame: %@", NSStringFromCGRect(subscriptionsButtonFrame));
            NSLog(@"subscriptions font:  %@", _subscriptionsButton.titleLabel.font.fontName);

            [_subscriptionsButton setTitle:[PCLocalizationManager localizedStringForKey:@"SUBSCRIPTION_MENU_BUTTON_TITLE" value:@"Subscription"] forState:UIControlStateNormal];
            _subscriptionsButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
            
            UIImage *subscriptionsButtonImage = [UIImage imageNamed:[subscriptionsButtonConfig objectForKey:TopBarViewSubscriptionsButtonImage]];
            if (subscriptionsButtonImage != nil) {
                [_subscriptionsButton setImage:subscriptionsButtonImage forState:UIControlStateNormal];
            }
            
            [_subscriptionsButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:_subscriptionsButton];
        }*/
        
        // contact button
        NSDictionary *contactButtonConfig = [topBarViewConfig objectForKey:TopBarViewContactButtonStyle];
        
        if (contactButtonConfig) {
            _contactButton = [[UIButton alloc] init];
            [_contactButton styledWithDictionary:contactButtonConfig];
            [_contactButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];            
            [self addSubview:_contactButton];
        }
        
        // share button
        NSDictionary *shareButtonConfig = [topBarViewConfig objectForKey:TopBarViewShareButtonStyle];
        if (shareButtonConfig) {
            _shareButton = [[UIButton alloc] init];
            [_shareButton styledWithDictionary:shareButtonConfig];
            [_shareButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_shareButton];
        }
        
/*        if (shareButtonConfig != nil &&
            [[shareButtonConfig objectForKey:TopBarViewShareButtonEnabled] boolValue]) {
            
            CGRect shareButtonFrame = CGRectMake(boundsSize.width - boundsSize.height * 2 - BarButtonOffset, 0, boundsSize.height, boundsSize.height);
            _shareButton = [[UIButton alloc] initWithFrame:shareButtonFrame];
            _shareButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            NSLog(@"Share frame: %@", NSStringFromCGRect(shareButtonFrame));
            NSLog(@"Share font:  %@", _shareButton.titleLabel.font.fontName);
            
            UIImage *shareButtonImage = [UIImage imageNamed:[shareButtonConfig objectForKey:TopBarViewShareButtonImage]];
            if (shareButtonImage != nil) {
                [_shareButton setImage:shareButtonImage forState:UIControlStateNormal];
            } else {
                _shareButton.backgroundColor = [UIColor orangeColor];
            }
            
            [_shareButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:_shareButton];
        }
 */       
        // help button
        NSDictionary *helpButtonConfig = [topBarViewConfig objectForKey:TopBarViewHelpButtonStyle];
        
        if (helpButtonConfig != nil &&
            [[helpButtonConfig objectForKey:TopBarViewHelpButtonEnabled] boolValue]) {
            
            CGRect helpButtonFrame = CGRectMake(boundsSize.width - boundsSize.height, 0, boundsSize.height, boundsSize.height);
            _helpButton = [[UIButton alloc] initWithFrame:helpButtonFrame];
            _helpButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            NSLog(@"Help frame: %@", NSStringFromCGRect(helpButtonFrame));
            NSLog(@"Help font:  %@", _helpButton.titleLabel.font.fontName);
            
            UIImage *helpButtomImage = [UIImage imageNamed:[helpButtonConfig objectForKey:TopBarViewHelpButtonImage]];
            if (helpButtomImage != nil) {
                [_helpButton setImage:helpButtomImage forState:UIControlStateNormal];
            } else {
                _helpButton.backgroundColor = [UIColor orangeColor];
            }
            
            [_helpButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:_helpButton];
        }
    }
        
    return self;
}

- (void)buttonTapped:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(topBarView:buttonTapped:)]) {
        [self.delegate topBarView:self buttonTapped:sender];
    }
}
/*
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
*/
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

- (void)hideKeyboard
{
    [_searchTextField resignFirstResponder];
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
