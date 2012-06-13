//
//  PCKioskSubviewDelegateProtocol.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 23.04.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PCKioskSubviewDelegateProtocol <NSObject>

- (void) downloadButtonTappedWithRevisionIndex:(NSInteger) index;
- (void) readButtonTappedWithRevisionIndex:(NSInteger) index;
- (void) cancelButtonTappedWithRevisionIndex:(NSInteger) index;
- (void) deleteButtonTappedWithRevisionIndex:(NSInteger) index;
- (void) updateButtonTappedWithRevisionIndex:(NSInteger) index;
- (void) purchaseButtonTappedWithRevisionIndex:(NSInteger) index;

@end
