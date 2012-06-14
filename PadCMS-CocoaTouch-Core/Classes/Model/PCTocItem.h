//
//  PCTocItem.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"

/**
 @class PCTocItem
 @brief Represents a model of Table of Contents element. PCMagazineViewController use to this class to build TOC view. 
 */
PADCMS_EXTERN NSString* endOfDownloadingTocNotification;

@interface PCTocItem : NSObject
{
    NSString* title; 
    NSString* tocItemDescription; 
    UIColor* color; 
    NSString* thumbStripe; 
    NSString* thumbSummary; 
    NSInteger firstPageIdentifier;
}

/**
 @brief Title
 */ 
@property (nonatomic,retain) NSString* title;

/**
 @brief Description
 */ 
@property (nonatomic,retain) NSString* tocItemDescription;

/**
 @brief Color
 */ 
@property (nonatomic,retain) UIColor* color;

/**
 @brief Path to a Stripe image
 */ 
@property (nonatomic,retain) NSString* thumbStripe;

/**
 @brief Path to a Summary image
 */ 
@property (nonatomic,retain) NSString* thumbSummary;

/**
 @brief Page identifier this point is linked with
 */ 
@property (nonatomic,assign) NSInteger firstPageIdentifier;

- (id)init;

@end
