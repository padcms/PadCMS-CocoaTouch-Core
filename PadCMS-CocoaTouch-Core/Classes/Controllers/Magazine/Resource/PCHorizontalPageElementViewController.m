//
//  PCHorizontalPageElementViewController.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 28.05.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCHorizontalPageElementViewController.h"
#import "Helper.h"

@interface PCHorizontalPageElementViewController ()

@end

@implementation PCHorizontalPageElementViewController
@synthesize targetHeight;

- (void) correctSize
{
    CGSize imageSize = [Helper getSizeForImage:self.resource];
    
    if(!CGSizeEqualToSize(imageSize, CGSizeZero))
    {
        CGFloat scale = self.targetHeight / imageSize.height;
        
        CGSize newSize = CGSizeMake(imageSize.width * scale, imageSize.height * scale);
        
        [self.view setFrame:CGRectMake(self.view.frame.origin.x,
                                       self.view.frame.origin.y, 
                                       newSize.width,
                                       newSize.height)];
        
        if(imageView != nil)
        {
            [imageView setFrame:CGRectMake(0, 0, newSize.width, newSize.height)];
        }
    }
}

@end
