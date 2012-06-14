//
//  PCSearchTaskDelegate.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 02.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief Set of methods to be implemented to act PCSearchTask delegate
 */ 
@protocol PCSearchTaskDelegate <NSObject>
@required

/**
 @brief Called when background searching task is started
 */ 
-(void) searchTaskStarted;

/**
 @brief Called when background searching task updated result set with new PCSearchResultItem
 */ 
-(void) searchTaskResultUpdated;

/**
 @brief Called when background searching task is finished execution
 */ 
-(void) searchTaskFinished;

@optional

/**
 @brief Called when background searching task is canceled execution
 */ 
-(void) searchTaskCanceled;
@end
