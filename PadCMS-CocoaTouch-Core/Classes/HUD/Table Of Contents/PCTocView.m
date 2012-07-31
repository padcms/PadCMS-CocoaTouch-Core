//
//  PCTocView.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Maxim Pervushin on 7/30/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCTocView.h"

#import "PCGridView.h"
#import "UIColor+HexString.h"
#import "UIImage+CombinedImage.h"

#define TocViewButtonDefaultWidth 100
#define TocViewButtonDefaultHeight 50

#define TocViewStyle @"PCTocViewStyle"
#define TocViewButtonStyle @"PCTocViewButtonStyle"
#define TocViewButtonStyleColor @"PCTocViewButtonStyleColor"
#define TocViewButtonStyleImageName @"PCTocViewButtonStyleImageName"
#define TocViewButtonStyleBackgroundImageName @"PCTocViewButtonStyleBackgroundImageName"
#define TocViewBackgroundStyle @"PCTocViewBackgroundStyle"
#define TocViewBackgroundStyleColor @"PCTocViewBackgroundStyleColor"


typedef enum _PCTocViewPosition {
    PCTocViewPositionInvalid = -1,
    PCTocViewPositionTop = 0,
    PCTocViewPositionBottom = 1
} PCTocViewPosition;


@interface PCTocView ()
{
    PCTocViewPosition _position;
    PCTocViewState _state;
}

- (void)buttonTapped:(UIButton *)button;
- (void)setPosition:(PCTocViewPosition)position;

- (CGPoint)hiddenStateCenterForRect:(CGRect)rect;
- (CGPoint)visibleStateCenterForRect:(CGRect)rect;
- (CGPoint)activeStateCenterForRect:(CGRect)rect;

@end

@implementation PCTocView
@synthesize state = _state;
@synthesize backgroundView = _backgroundView;
@synthesize button = _button;
@synthesize gridView = _gridView;

- (void)dealloc
{
    [_button release];
    [_gridView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self != nil) {
        
        _position = PCTocViewPositionInvalid;
        _state = PCTocViewStateInvalid;
        
        self.backgroundColor = [UIColor clearColor];
        
        _backgroundView = [[UIView alloc] init];
        [self addSubview:_backgroundView];
        
        _button = [[UIButton alloc] init];
        [_button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_button];
        
        _gridView = [[PCGridView alloc] init];
        _gridView.backgroundColor = [UIColor clearColor];
        [self addSubview:_gridView];
    }
    
    return self;
}

#pragma mark - public methods

- (void)transitToState:(PCTocViewState)state animated:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(tocView:transitToState:animated:)]) {
        if ([self.delegate tocView:self transitToState:state animated:animated]) {
            _state = state;
        }
    }
}

- (CGPoint)centerForState:(PCTocViewState)state containerBounds:(CGRect)containerBounds
{
    switch (state) {
        case PCTocViewStateInvalid:
            return CGPointZero;
            break;
            
        case PCTocViewStateHidden:
            return [self hiddenStateCenterForRect:containerBounds];
            break;
            
        case PCTocViewStateVisible:
            return [self visibleStateCenterForRect:containerBounds];
            break;
            
        case PCTocViewStateActive:
            return [self activeStateCenterForRect:containerBounds];
            break;
            
        default:
            break;
    }
    
    return CGPointZero;
}

#pragma mark - private methods

- (void)buttonTapped:(UIButton *)button
{
    if (_state == PCTocViewStateInvalid || _state == PCTocViewStateHidden) {
        return;
    }
    
    if (_state == PCTocViewStateActive) {
        [self transitToState:PCTocViewStateVisible animated:YES];
    } else {
        [self transitToState:PCTocViewStateActive animated:YES];
    }
}

- (void)setPosition:(PCTocViewPosition)position
{
    _position = position;
}

- (CGPoint)hiddenStateCenterForRect:(CGRect)rect
{
    switch (_position) {
        case PCTocViewPositionInvalid:
            return CGPointZero;
            break;
        
        case PCTocViewPositionTop: {
            CGSize boundsSize = self.bounds.size;
            return CGPointMake((boundsSize.width / 2) + rect.origin.x,
                               -(boundsSize.height / 2) + rect.origin.y);
        }
            break;
        
        case PCTocViewPositionBottom: {
            CGSize boundsSize = self.bounds.size;
            return CGPointMake((boundsSize.width / 2) + rect.origin.x,
                               (boundsSize.height / 2) + rect.size.height + rect.origin.y);
        }
            break;
    }
    
    return CGPointZero;
}

- (CGPoint)visibleStateCenterForRect:(CGRect)rect
{
    switch (_position) {
        case PCTocViewPositionInvalid:
            return CGPointZero;
            break;
            
        case PCTocViewPositionTop: {
            CGSize boundsSize = self.bounds.size;
            CGSize buttonSize = _button.bounds.size;
            return CGPointMake((boundsSize.width / 2) + rect.origin.x,
                               -(boundsSize.height / 2) + buttonSize.height + rect.origin.y);
        }
            break;
            
        case PCTocViewPositionBottom: {
            CGSize boundsSize = self.bounds.size;
            CGSize buttonSize = _button.bounds.size;
            return CGPointMake((boundsSize.width / 2) + rect.origin.x,
                               (boundsSize.height / 2) + rect.size.height + rect.origin.y - buttonSize.height);
        }
            break;
    }
    
    return CGPointZero;
}

- (CGPoint)activeStateCenterForRect:(CGRect)rect
{
    switch (_position) {
        case PCTocViewPositionInvalid:
            return CGPointZero;
            break;
            
        case PCTocViewPositionTop: {
            CGSize boundsSize = self.bounds.size;
            return CGPointMake(boundsSize.width / 2 + rect.origin.x,
                               boundsSize.height / 2 + rect.origin.y);
        }
            break;
            
        case PCTocViewPositionBottom: {
            CGSize boundsSize = self.bounds.size;
            return CGPointMake((boundsSize.width / 2) + rect.origin.x,
                               (rect.size.height + rect.origin.y) - (boundsSize.height / 2));
        }
            break;
    }
    
    return CGPointZero;
}

#pragma mark - public class methods

+ (PCTocView *)topTocViewWithFrame:(CGRect)frame
{
    PCTocView *tocView = [[PCTocView alloc] initWithFrame:frame];
    
    [tocView setPosition:PCTocViewPositionTop];
    
    // Adjust layout
    NSDictionary *styleDictionary = [[[NSDictionary alloc] init] autorelease];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSDictionary *PADCMSConfigDictionary = [infoDictionary objectForKey:@"PADCMSConfig"];
    if (PADCMSConfigDictionary != nil) {
        NSDictionary *tempStyleDictionary = [PADCMSConfigDictionary objectForKey:TocViewStyle];
        if (tempStyleDictionary != nil) {
            styleDictionary = tempStyleDictionary;
        }
    }

    [tocView implementStyle:styleDictionary];
    
    CGSize tocSize = frame.size;
    CGSize buttonSize = tocView.button.bounds.size;
    tocView.button.center = CGPointMake(tocSize.width - (buttonSize.width / 2),
                                        tocSize.height - (buttonSize.height / 2));
    
    tocView.button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;

    CGRect gridViewFrame = CGRectMake(0,
                                      0,
                                      tocSize.width,
                                      tocSize.height - tocView.button.frame.size.height);
    tocView.gridView.frame = gridViewFrame;
    tocView.gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tocView.gridView.backgroundColor = [UIColor clearColor];

    tocView.backgroundView.frame = gridViewFrame;
    tocView.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    return [tocView autorelease];
}

- (void)implementStyle:(NSDictionary *)style
{
    // button style
    // default values
    UIImage *buttonBackgroundImage = nil;
    UIColor *buttonColor = [UIColor blackColor];
    
    NSDictionary *buttonStyle = [style objectForKey:TocViewButtonStyle];
    if (buttonStyle != nil) {
        // background color
        UIColor *tempButtonColor = nil;
        NSString *buttonColorString = [buttonStyle objectForKey:TocViewButtonStyleColor];
        if (buttonColorString != nil) {
            tempButtonColor = [UIColor colorWithHexString:buttonColorString];
            if (tempButtonColor != nil) {
                buttonColor = [tempButtonColor retain];
            }
        }
        
        // image
        NSString *buttonImageName = [buttonStyle objectForKey:TocViewButtonStyleImageName];
        UIImage *buttonImage = nil;
        if (buttonImageName != nil) {
            buttonImage = [UIImage imageNamed:buttonImageName];
        }
        
        // backgound image
        NSString *buttonBackgroundImageName = [buttonStyle objectForKey:TocViewButtonStyleBackgroundImageName];
        UIImage *tempButtonBackgroundImage = nil;
        if (buttonBackgroundImageName != nil) {
            tempButtonBackgroundImage = [UIImage imageNamed:buttonBackgroundImageName];
        }
        
        if (tempButtonColor != nil && buttonImage != nil && tempButtonBackgroundImage != nil) {
            buttonBackgroundImage = [UIImage combinedImage:tempButtonBackgroundImage
                                              overlayImage:buttonImage
                                                     color:tempButtonColor];
            CGSize imageSize = buttonBackgroundImage.size;
            _button.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
            [_button setImage:buttonBackgroundImage forState:UIControlStateNormal];
            
            buttonColor = [UIColor clearColor];

        } else if (tempButtonBackgroundImage != nil) {
            buttonBackgroundImage = tempButtonBackgroundImage;
        }
    }
    
    if (buttonBackgroundImage != nil) {
        CGSize imageSize = buttonBackgroundImage.size;
        _button.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
        [_button setImage:buttonBackgroundImage forState:UIControlStateNormal];
    } else {
        _button.bounds = CGRectMake(0, 0, TocViewButtonDefaultWidth, TocViewButtonDefaultHeight);
    }
    
    _button.backgroundColor = buttonColor;
    
    
    // background style
    UIColor *backgroundColor = [UIColor blackColor];
    NSDictionary *backgroundStyle = [style objectForKey:TocViewBackgroundStyle];
    if (backgroundStyle != nil) {
        NSString *backgroundColorString = [backgroundStyle objectForKey:TocViewBackgroundStyleColor];
        if (backgroundColorString != nil) {
            backgroundColor = [UIColor colorWithHexString:backgroundColorString];
        }
    }
    
    _backgroundView.backgroundColor = backgroundColor;
}

+ (PCTocView *)bottomTocViewWithFrame:(CGRect)frame
{
    PCTocView *tocView = [[PCTocView alloc] initWithFrame:frame];
    
    [tocView setPosition:PCTocViewPositionBottom];
    
    // Adjust layout
    
    tocView.backgroundColor = [UIColor clearColor];
    
    CGSize tocSize = frame.size;
    
    NSDictionary *styleDictionary = [[[NSDictionary alloc] init] autorelease];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSDictionary *PADCMSConfigDictionary = [infoDictionary objectForKey:@"PADCMSConfig"];
    if (PADCMSConfigDictionary != nil) {
        NSDictionary *tempStyleDictionary = [PADCMSConfigDictionary objectForKey:TocViewStyle];
        if (tempStyleDictionary != nil) {
            styleDictionary = tempStyleDictionary;
        }
    }
    
    [tocView implementStyle:styleDictionary];
    
    CGSize buttonSize = tocView.button.bounds.size;
    tocView.button.center = CGPointMake(buttonSize.width / 2, buttonSize.height / 2);

    tocView.button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    CGRect gridViewFrame = CGRectMake(0,
                                      tocView.button.frame.size.height,
                                      tocSize.width,
                                      tocSize.height - tocView.button.frame.size.height);
    tocView.gridView.frame = gridViewFrame;
    tocView.gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tocView.gridView.backgroundColor = [UIColor clearColor];
    
    tocView.backgroundView.frame = gridViewFrame;
    tocView.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    return [tocView autorelease];
}

@end
