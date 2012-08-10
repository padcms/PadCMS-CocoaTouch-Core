//
//  RRSummaryView.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Maxim Pervushin on 8/9/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCSummaryView.h"

#import "PCGridView.h"

#define BackgroundTopImage @"topNav_t.png"
#define BackgroundMiddleImage @"topNav_m.png"
#define BackgroundBottomImage @"topNav_b.png"

@interface PCSummaryView ()
{
    PCGridView *_gridView;
    UIImageView *_backgroundTopImageView;
    UIImageView *_backgroundMiddleImageView;
    UIImageView *_backgroundBottomImageView;
}

- (void)adjustLayout;

@end

@implementation PCSummaryView
@synthesize gridView = _gridView;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        _backgroundTopImageView = [[UIImageView alloc] init];
        [self addSubview:_backgroundTopImageView];

        _backgroundMiddleImageView = [[UIImageView alloc] init];
        [self addSubview:_backgroundMiddleImageView];

        _backgroundBottomImageView = [[UIImageView alloc] init];
        [self addSubview:_backgroundBottomImageView];

        _gridView = [[PCGridView alloc] init];
        [self addSubview:_gridView];
        
        [self adjustLayout];
    }
    
    return self;
}

- (void)adjustLayout
{
    UIImage *backgroundTopImage = [UIImage imageNamed:BackgroundTopImage];
    CGSize topImageSize = backgroundTopImage.size;
    UIImage *backgroundMiddleImage = [UIImage imageNamed:BackgroundMiddleImage];
    CGSize middleImageSize = backgroundMiddleImage.size;
    UIImage *backgroundBottomImage = [UIImage imageNamed:BackgroundBottomImage];
    CGSize bottomImageSize = backgroundBottomImage.size;
    
    CGFloat width = MIN(topImageSize.width, MIN(middleImageSize.width, bottomImageSize.width));
    CGFloat height = self.bounds.size.height;
    
    self.bounds = CGRectMake(0, 0, width, height);

    _backgroundTopImageView.frame = CGRectMake(0, 0, width, topImageSize.height);
    _backgroundTopImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    _backgroundTopImageView.image = backgroundTopImage;

    _backgroundMiddleImageView.frame = CGRectMake(0,
                                                  topImageSize.height,
                                                  width,
                                                  height - topImageSize.height - bottomImageSize.height);
    _backgroundMiddleImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _backgroundMiddleImageView.image = backgroundMiddleImage;

    _backgroundBottomImageView.frame = CGRectMake(0,
                                                  height - bottomImageSize.height,
                                                  width,
                                                  bottomImageSize.height);
    _backgroundBottomImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _backgroundBottomImageView.image = backgroundBottomImage;

    if (CGRectIsEmpty(_backgroundMiddleImageView.bounds)) {
        _gridView.frame = self.bounds;
    } else {
        _gridView.frame = _backgroundMiddleImageView.frame;
    }
    _gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    
//    if (_backgroundTopImageView.image != nil) {
//        CGSize backgroundTopImageSize = _backgroundTopImageView.image.size;
//        _backgroundTopImageView.frame = CGRectMake(0,
//                                                   0,
//                                                   backgroundTopImageSize.width,
//                                                   backgroundTopImageSize.height);
//    }
//    
//    if (_backgroundBottomImageView.image != nil) {
//        CGSize backgroundBottomImageSize = _backgroundBottomImageView.image.size;
//        _backgroundBottomImageView.frame = CGRectMake(0,
//                                                      self.bounds.size.height - backgroundBottomImageSize.height,
//                                                      backgroundBottomImageSize.width,
//                                                      backgroundBottomImageSize.height);
//    }
//
//    if (_backgroundMiddleImageView.image != nil) {
//        CGSize backgroundMiddleImageSize = _backgroundMiddleImageView.image.size;
//        _backgroundMiddleImageView.frame = CGRectMake(0,
//                                                      _backgroundTopImageView.frame.size.height,
//                                                      backgroundMiddleImageSize.width,
//                                                      self.bounds.size.height - _backgroundBottomImageView.frame.size.height- _backgroundTopImageView.frame.size.height);
////        self.bounds = CGRectMake(0, 0, backgroundMiddleImageSize.width, self.bounds.size.height);
//    }
//
//    
//    if (CGRectIsEmpty(_backgroundMiddleImageView.bounds)) {
//        _gridView.frame = self.bounds;
//    } else {
//        _gridView.frame = _backgroundMiddleImageView.frame;
//    }
//}

- (void)reloadData
{
    [_gridView reloadData];
}

@end
