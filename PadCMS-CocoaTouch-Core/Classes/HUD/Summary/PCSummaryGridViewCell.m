//
//  PCSummaryGridViewCell.m
//  Pad CMS
//
//  Created by Maxim Pervushin on 8/9/12.
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
