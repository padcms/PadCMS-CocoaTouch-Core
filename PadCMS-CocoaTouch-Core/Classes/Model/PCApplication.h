//
//  PCApplication.h
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 16.02.12.
//  Copyright (c) PadCMS (http://www.padcms.net)
//
//
//  This software is governed by the CeCILL-C  license under French law and
//  abiding by the rules of distribution of free software.  You can  use,
//  modify and/ or redistribute the software under the terms of the CeCILL-C
//  license as circulated by CEA, CNRS and INRIA at the following URL
//  "http://www.cecill.info".
//  
//  As a counterpart to the access to the source code and  rights to copy,
//  modify and redistribute granted by the license, users are provided only
//  with a limited warranty  and the software's author,  the holder of the
//  economic rights,  and the successive licensors  have only  limited
//  liability.
//  
//  In this respect, the user's attention is drawn to the risks associated
//  with loading,  using,  modifying and/or developing or reproducing the
//  software by the user in light of its specific status of free software,
//  that may mean  that it is complicated to manipulate,  and  that  also
//  therefore means  that it is reserved for developers  and  experienced
//  professionals having in-depth computer knowledge. Users are therefore
//  encouraged to load and test the software's suitability as regards their
//  requirements in conditions enabling the security of their systems and/or
//  data to be ensured and,  more generally, to use and operate it in the
//  same conditions as regards security.
//  
//  The fact that you are presently reading this means that you have had
//  knowledge of the CeCILL-C license and that you accept its terms.
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

/// @brief URL of back end server
@property (nonatomic, retain) NSURL *backEndURL;
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
/// @brief Number of columns available in preview mode
@property (assign) NSUInteger previewColumnsNumber;
/// @brief Message that appears in bottom popup
@property (nonatomic, retain) NSString * messageForReaders;
/// @brief Message that will appear on sharing popup
@property (nonatomic, retain) NSString * shareMessage;




/**
 @brief Designated initializer.
 @param Dictionary with parameters to initialize instance
 @param Root directory for content
 @param Back end url to download content from
 */ 
- (id)initWithParameters:(NSDictionary *)parameters 
           rootDirectory:(NSString *)rootDirectory 
              backEndURL:(NSURL *)backEndURL;

/**
 @brief Designated initializer.
 @param Dictionary with parameters to initialize instance
 @param Root directory for content
 */ 
- (id)initWithParameters:(NSDictionary *)parameters 
           rootDirectory:(NSString *)rootDirectory;

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

/**
 @brief Return YES if at least one issue has a product identifier
 */
- (BOOL) hasIssuesProductID;

@end
