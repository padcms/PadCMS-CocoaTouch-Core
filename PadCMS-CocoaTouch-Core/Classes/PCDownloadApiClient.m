//
//  PCDownloadApiClient.m
//  Pad CMS
//
//  Created by Alexey Petrosyan on 4/30/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCDownloadApiClient.h"
#import "PCConfig.h"

@implementation PCDownloadApiClient

+ (PCDownloadApiClient *)sharedClient {
  static PCDownloadApiClient *_sharedClient = nil;
  static dispatch_once_t oncePredicate;
  dispatch_once(&oncePredicate, ^{
    _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:[PCConfig serverURLString]]];
  });
  
  return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
  self = [super initWithBaseURL:url];
  if (!self) {
    return nil;
  }
  
  [self.operationQueue setMaxConcurrentOperationCount:1];
  
  
  return self;
}


@end
