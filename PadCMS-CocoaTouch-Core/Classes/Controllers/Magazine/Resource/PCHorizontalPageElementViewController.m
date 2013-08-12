//
//  PCHorizontalPageElementViewController.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 28.05.12.
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

#import "PCHorizontalPageElementViewController.h"
#import "Helper.h"

@interface PCHorizontalPageElementViewController ()
{
    CGFloat _targetHeight;
}

@end

@implementation PCHorizontalPageElementViewController
@synthesize targetHeight = _targetHeight;

- (void)correctSize
{
    CGSize imageSize = [Helper getSizeForImage:self.resource];
    
    if (!CGSizeEqualToSize(imageSize, CGSizeZero)) {
        CGFloat scale = self.targetHeight / imageSize.height;
        CGSize newSize = CGSizeMake(imageSize.width * scale, imageSize.height * scale);
        
        [self.view setFrame:CGRectMake(self.view.frame.origin.x,
                                       self.view.frame.origin.y, 
                                       newSize.width,
                                       newSize.height)];
        
        if (_resourceView != nil) {
            [_resourceView setFrame:CGRectMake(0, 0, newSize.width, newSize.height)];
        }
    }
}

@end
