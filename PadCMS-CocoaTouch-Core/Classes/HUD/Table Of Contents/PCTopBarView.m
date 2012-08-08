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

#define BarButtonOffset 0

#define TopBarViewStyle @"PCTopBarViewStyle"
#define TopBarViewLogoImage @"PCTopBarViewLogoImage"
#define TopBarViewSearchStyle @"PCTopBarViewSearchStyle"
#define TopBarViewSearchEnabled @"PCTopBarViewSearchEnabled"
#define TopBarViewHelpButtonStyle @"PCTopBarViewHelpButtonStyle"
#define TopBarViewHelpButtonEnabled @"PCTopBarViewHelpButtonEnabled"
#define TopBarViewHelpButtonImage @"PCTopBarViewHelpButtonImage"
#define TopBarViewShareButtonStyle @"PCTopBarViewShareButtonStyle"
#define TopBarViewShareButtonEnabled @"PCTopBarViewShareButtonEnabled"
#define TopBarViewShareButtonImage @"PCTopBarViewShareButtonImage"
#define TopBarViewSubscriptionsButtonStyle @"PCTopBarViewSubscriptionsButtonStyle"
#define TopBarViewSubscriptionsButtonEnabled @"PCTopBarViewSubscriptionsButtonEnabled"
#define TopBarViewSubscriptionsButtonImage @"PCTopBarViewSubscriptionsButtonImage"
#define TopBarViewBackButtonStyle @"PCTopBarViewBackButtonStyle"
#define TopBarViewBackButtonEnabled @"PCTopBarViewBackButtonEnabled"
#define TopBarViewBackButtonImage @"PCTopBarViewBackButtonImage"
#define TopBarViewSummaryButtonStyle @"PCTopBarViewSummaryButtonStyle"
#define TopBarViewSummaryButtonEnabled @"PCTopBarViewSummaryButtonEnabled"
#define TopBarViewSummaryButtonImage @"PCTopBarViewSummaryButtonImage"


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
        
        if (backButtonConfig != nil &&
            [[backButtonConfig objectForKey:TopBarViewBackButtonEnabled] boolValue]) {
            
            _backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, boundsSize.height, boundsSize.height)];
            
            UIImage *homeButtonImage = [UIImage imageNamed:[backButtonConfig objectForKey:TopBarViewBackButtonImage]];
            if (homeButtonImage != nil) {
                [_backButton setImage:homeButtonImage forState:UIControlStateNormal];
            } else {
                _backButton.backgroundColor = [UIColor orangeColor];
            }
            
            [_backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:_backButton];
        }
        
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
            
            [_summaryButton addTarget:self action:@selector(summaryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:_summaryButton];
        }
        
        // logo
        NSString *logoImage = [topBarViewConfig objectForKey:TopBarViewLogoImage];
        
        if (logoImage != nil && ![logoImage isEqualToString:@""]) {
            
            _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((boundsSize.height + BarButtonOffset) * 2, 0, (boundsSize.width - 100) / 2 - (boundsSize.height + BarButtonOffset) * 2, boundsSize.height)];
            _logoImageView.image = [UIImage imageNamed:logoImage];
            _logoImageView.contentMode = UIViewContentModeLeft;
            
            [self addSubview:_logoImageView];
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
            [self addSubview:_searchTextField];
        }
        
        // subscriptions button
        NSDictionary *subscriptionsButtonConfig = [topBarViewConfig objectForKey:TopBarViewSubscriptionsButtonStyle];
        
        if (subscriptionsButtonConfig != nil &&
            [[subscriptionsButtonConfig objectForKey:TopBarViewSubscriptionsButtonEnabled] boolValue]) {
            
            CGRect subscriptionsButtonFrame = CGRectMake(boundsSize.width - boundsSize.height * 2 - BarButtonOffset - 100, 0, 100, boundsSize.height);
            _subscriptionsButton = [[UIButton alloc] initWithFrame:subscriptionsButtonFrame];
            _subscriptionsButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            
            [_subscriptionsButton setTitle:[PCLocalizationManager localizedStringForKey:@"Subscription" value:@"Subscription"] forState:UIControlStateNormal];
            _subscriptionsButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
            
            UIImage *subscriptionsButtonImage = [UIImage imageNamed:[subscriptionsButtonConfig objectForKey:TopBarViewSubscriptionsButtonImage]];
            if (subscriptionsButtonImage != nil) {
                [_subscriptionsButton setImage:subscriptionsButtonImage forState:UIControlStateNormal];
            }
            
            [_subscriptionsButton addTarget:self action:@selector(subscriptionsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:_subscriptionsButton];
        }
        
        // share button
        NSDictionary *shareButtonConfig = [topBarViewConfig objectForKey:TopBarViewShareButtonStyle];
        
        if (shareButtonConfig != nil &&
            [[shareButtonConfig objectForKey:TopBarViewShareButtonEnabled] boolValue]) {
            
            CGRect shareButtonFrame = CGRectMake(boundsSize.width - boundsSize.height * 2 - BarButtonOffset, 0, boundsSize.height, boundsSize.height);
            _shareButton = [[UIButton alloc] initWithFrame:shareButtonFrame];
            _shareButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            
            UIImage *shareButtonImage = [UIImage imageNamed:[shareButtonConfig objectForKey:TopBarViewShareButtonImage]];
            if (shareButtonImage != nil) {
                [_shareButton setImage:shareButtonImage forState:UIControlStateNormal];
            } else {
                _shareButton.backgroundColor = [UIColor orangeColor];
            }
            
            [_shareButton addTarget:self action:@selector(shareButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:_shareButton];
        }
        
        // help button
        NSDictionary *helpButtonConfig = [topBarViewConfig objectForKey:TopBarViewHelpButtonStyle];
        
        if (helpButtonConfig != nil &&
            [[helpButtonConfig objectForKey:TopBarViewHelpButtonEnabled] boolValue]) {
            
            CGRect helpButtonFrame = CGRectMake(boundsSize.width - boundsSize.height, 0, boundsSize.height, boundsSize.height);
            _helpButton = [[UIButton alloc] initWithFrame:helpButtonFrame];
            _helpButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            
            UIImage *helpButtomImage = [UIImage imageNamed:[helpButtonConfig objectForKey:TopBarViewHelpButtonImage]];
            if (helpButtomImage != nil) {
                [_helpButton setImage:helpButtomImage forState:UIControlStateNormal];
            } else {
                _helpButton.backgroundColor = [UIColor orangeColor];
            }
            
            [_helpButton addTarget:self action:@selector(helpButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:_helpButton];
        }
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
