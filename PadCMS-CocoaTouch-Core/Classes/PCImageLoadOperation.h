//
//  PCImageLoadOperation.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 8/10/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCPageElement;
@interface PCImageLoadOperation : NSBlockOperation
@property (nonatomic, retain) PCPageElement* operationElement;
@property (nonatomic, retain) NSNumber* tileIndex;

@end
