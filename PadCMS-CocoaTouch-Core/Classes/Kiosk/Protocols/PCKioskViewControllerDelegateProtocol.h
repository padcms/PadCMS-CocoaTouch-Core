//
//  PCKioskViewControllerDelegateProtocol.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 04.05.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PCKioskViewControllerDelegateProtocol <NSObject>

- (void) downloadRevisionWithIndex:(NSInteger) index;
- (void) cancelDownloadingRevisionWithIndex:(NSInteger) index;
- (void) readRevisionWithIndex:(NSInteger) index;
- (void) deleteRevisionDataWithIndex:(NSInteger) index;
- (void) updateRevisionWithIndex:(NSInteger) index;
- (void) purchaseRevisionWithIndex:(NSInteger) index;

@end
