//
//  PCHorizontalPage.h
//  Pad CMS
//
//  Created by Alexey Petrosyan on 5/7/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PCDownloadProgressProtocol;
@interface PCHorizontalPage : NSObject

@property (nonatomic, retain) NSNumber* identifier;
@property (nonatomic, assign) float downloadProgress;
@property (nonatomic, assign) id<PCDownloadProgressProtocol> progressDelegate;
@property (assign) BOOL isComplete;

@end
