//
//  PCTOCGridViewCell.m
//  Pad CMS
//
//  Created by Maxim Pervushin on 7/16/12.
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

#import "PCTOCGridViewCell.h"

#define VerticalMargin 10
#define HorizontalMargin 10

@interface PCTOCGridViewCell ()
{
    UIImageView *_imageView;
}

@end

@implementation PCTOCGridViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageView];
    }
    
    return self;
}

- (void)setImage:(UIImage *)image
{
    _imageView.image = image;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_imageView.image != nil) {
        CGFloat imageViewWidth = self.bounds.size.width - HorizontalMargin * 2;
        CGFloat imageViewHeight = _imageView.image.size.height * (imageViewWidth / _imageView.image.size.width) + VerticalMargin * 2;
        CGRect imageViewRect = CGRectMake(HorizontalMargin, 
                                          VerticalMargin, 
                                          imageViewWidth, 
                                          imageViewHeight);
        
        _imageView.frame = imageViewRect;
    } else {
        _imageView.frame = CGRectMake(HorizontalMargin, 
                                      VerticalMargin, 
                                      self.bounds.size.width - HorizontalMargin * 2, 
                                      self.bounds.size.height - VerticalMargin * 2);
    }
}

- (void)clearContent
{
    [self setImage:nil];
}

@end
