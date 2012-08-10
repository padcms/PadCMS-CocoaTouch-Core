//
//  RRSummaryGridViewCell.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Maxim Pervushin on 8/9/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCSummaryGridViewCell.h"

#define HorizontalMargin 5
#define VerticalMargin 5

@interface PCSummaryGridViewCell ()
{
    UIImageView *_imageView;
    UILabel *_titleLabel;
    UILabel *_label;
}

@end

@implementation PCSummaryGridViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor blackColor];
        [self addSubview:_imageView];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor orangeColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:_titleLabel.font.pointSize];
        [self addSubview:_titleLabel];
        
        _label = [[UILabel alloc] init];
        _label.textColor = [UIColor whiteColor];
        _label.backgroundColor = [UIColor clearColor];
        _label.numberOfLines = 3;
        _label.lineBreakMode = UILineBreakModeWordWrap;
        _label.font = [UIFont systemFontOfSize:14];
        [self addSubview:_label];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize selfSize = self.bounds.size;

    CGRect imageViewFrame = CGRectMake(HorizontalMargin,
                                       VerticalMargin,
                                       selfSize.height - HorizontalMargin * 2,
                                       selfSize.height - VerticalMargin * 2);
    _imageView.frame = imageViewFrame;


    NSArray *components = [_titleLabel.text componentsSeparatedByString:@" / "];
    
    if (components != nil) {
        NSString *title = [components objectAtIndex:0];
        _titleLabel.text = title;
        CGSize titleLabelSize = [title sizeWithFont:_titleLabel.font
                                  constrainedToSize:CGSizeMake(selfSize.width - selfSize.height - HorizontalMargin, 30)
                                      lineBreakMode:_titleLabel.lineBreakMode];
        _titleLabel.frame = CGRectMake(selfSize.height, VerticalMargin, titleLabelSize.width, titleLabelSize.height);
        
        NSMutableString *description = [[[NSMutableString alloc] init] autorelease];
        for (int index = 1; index < components.count; ++index) {
            [description appendFormat:@"%@\n", [components objectAtIndex:index]];
        }
        
        _label.text = description;
        CGSize labelSize = [description sizeWithFont:_label.font
                                   constrainedToSize:CGSizeMake(selfSize.width - selfSize.height - HorizontalMargin,
                                                                selfSize.height - 30 - VerticalMargin * 3)
                                       lineBreakMode:_label.lineBreakMode];
        _label.frame = CGRectMake(selfSize.height,
                                  _titleLabel.bounds.size.height + HorizontalMargin * 2,
                                  labelSize.width,
                                  labelSize.height);
    }
}

- (void)setImage:(UIImage *)image text:(NSString *)text
{
    _imageView.image = image;
    _titleLabel.text = text;

    [self setNeedsLayout];
}

@end
