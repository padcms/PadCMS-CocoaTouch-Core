//
//  PCApplication.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 16.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

/**
 @class PCApplication
 @brief This class represents application model. It has basic information about application, id, title, description, notifications list and magazines list.
*/

#import <UIKit/UIKit.h>

#define PCTwitterNotificationType @"twitter"
#define PCFacebookNotificationType @"facebook"
#define PCEmailNotificationType @"email"

#define PCApplicationNotificationTitleKey @"title"
#define PCApplicationNotificationMessageKey @"message"

@class PCIssue;

@interface PCApplication : NSObject

/// @brief Application content directory
@property (nonatomic, retain) NSString *contentDirectory;
/// @brief Application identifier
@property (nonatomic, assign) NSInteger identifier;
/// @brief Application title
@property (nonatomic, retain) NSString *title;
/// @brief Application description
@property (nonatomic, retain) NSString *applicationDescription;
/// @brief Application product identifier
@property (nonatomic, retain) NSString *productIdentifier;
/// @brief Notifications options
@property (nonatomic, retain) NSMutableDictionary *notifications;
/// @brief Magazines array PCIssue
@property (nonatomic, retain) NSMutableArray *issues;

/**
 @brief Designated initializer.
 @param Dictionary with parameters to initialize instance
 @param Root directory for content
 */ 
- (id)initWithParameters:(NSDictionary *)parameters rootDirectory:(NSString *)rootDirectory;

/**
 @brief Return options for specific notification type. Options returns as NSDictionary*.
 
 @param Notification type
 */ 
- (NSDictionary *)notificationForType:(NSString *)notificationType;

/**
 @brief Return PCIssue object by its identifier
 @param Issue revision identifier
 */
- (PCIssue *)issueForRevisionWithId:(NSInteger)identifier;

@end
