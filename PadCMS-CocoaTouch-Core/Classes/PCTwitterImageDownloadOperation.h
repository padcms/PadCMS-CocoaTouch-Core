//
//  PCTwitterImageDownloadOperation.h
//  Pad CMS
//
//  Created by admin on 21.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "QHTTPOperation.h"
#import "PCTwitterImageDownloadOperationDelegate.h"
@interface PCTwitterImageDownloadOperation : QHTTPOperation
{
    NSString* _imageKey;
}

@property(nonatomic, retain) NSDictionary* twitterUserDict;
@property(nonatomic, retain) NSObject <PCTwitterImageDownloadOperationDelegate>*operationTarget;
@property(nonatomic, retain) NSString* imageFilePath;

-(id)initWithTwitterUserDict:(NSDictionary*)dict forKey:(NSString*)imageKey;
-(NSString*)imageKey;

@end
