//
//  PCDownloadApiClient.h
//  Pad CMS
//
//  Created by Alexey Petrosyan on 4/30/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "AFHTTPClient.h"

@interface PCDownloadApiClient : AFHTTPClient
+ (PCDownloadApiClient *)sharedClient;

@end
