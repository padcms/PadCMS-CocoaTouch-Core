//
//  RRTableOfContentsItem.m
//  ReusingScrollViewDemo
//
//  Created by Maxim Pervushin on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RRTableOfContentsItem.h"

@interface RRTableOfContentsItem ()
{
    UIImageView *_imageView;
}

@end

@implementation RRTableOfContentsItem

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        self.backgroundColor = [UIColor clearColor];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
    }
    
    return self;
}

- (void)setImage:(UIImage *)image
{
    _imageView.image = image;

    if (image != nil) {
        CGFloat imageViewWidth = self.bounds.size.width - 20;
        CGFloat imageViewHeight = _imageView.image.size.height * (imageViewWidth / _imageView.image.size.width) + 20;
        
        CGRect imageViewRect = CGRectMake(10, 10, imageViewWidth, imageViewHeight);
        _imageView.frame = imageViewRect;
        
        if (imageViewRect.size.width < imageViewRect.size.height) {
            _imageView.contentMode = UIViewContentModeScaleAspectFit;
        } else {
            _imageView.contentMode = UIViewContentModeScaleAspectFill;
        }
    } else {
        _imageView.frame = CGRectMake(10, 10, self.bounds.size.width - 20, self.bounds.size.height - 20);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_imageView.image != nil) {
        CGFloat imageViewWidth = self.bounds.size.width - 20;
        CGFloat imageViewHeight = _imageView.image.size.height * (imageViewWidth / _imageView.image.size.width) + 20;
        
        CGRect imageViewRect = CGRectMake(10, 10, imageViewWidth, imageViewHeight);
        _imageView.frame = imageViewRect;
        
        if (imageViewRect.size.width < imageViewRect.size.height) {
            _imageView.contentMode = UIViewContentModeScaleAspectFit;
        } else {
            _imageView.contentMode = UIViewContentModeScaleAspectFill;
        }
    } else {
        _imageView.frame = CGRectMake(10, 10, self.bounds.size.width - 20, self.bounds.size.height - 20);
    }
}

- (void)clearContent
{
    [self setImage:nil];
}

@end
