//
//  PCKioskCoverImageProcessingProtocol.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 30.04.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PCKioskCoverImageProcessingProtocol <NSObject>

-(void) updateCoverImage:(UIImage*) coverImage;
-(void) downloadingCoverImageFailed;

@end
