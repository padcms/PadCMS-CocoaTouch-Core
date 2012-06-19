//
//  PCDownloadOperation.h
//  Pad CMS
//
//  Created by Alexey Petrosyan on 5/11/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "AFHTTPRequestOperation.h"
#import "PCPage.h"
#import "PCPageElement.h"

@interface PCDownloadOperation : AFHTTPRequestOperation
@property (nonatomic, assign) PCPage* page;
@property (nonatomic, assign) PCPageElement* element;
@property (nonatomic, copy) NSString* resource;
@property (nonatomic, assign) BOOL isThumbnail;
@property (nonatomic, assign) BOOL isPrimary;
@property (nonatomic, assign) NSNumber* horizontalPageKey;

@end
