//
//  PCPDFActiveZone.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 07.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCPageActiveZone : NSObject
{
    CGRect rect;
    NSString* URL;
}

@property (nonatomic,assign) CGRect rect;
@property (nonatomic,copy) NSString* URL;

- (id)initWithRect:(CGRect)aRect URL:(NSString*)aURL;

@end
