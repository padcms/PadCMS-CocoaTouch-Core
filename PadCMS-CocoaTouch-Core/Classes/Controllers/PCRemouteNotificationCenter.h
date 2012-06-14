//
//  PCRemouteNotificationCenter.h
//  Pad CMS
//
//  Created by Rustam Mallarkubanov on 07.03.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCRemouteNotificationCenter : NSObject

+(PCRemouteNotificationCenter*)defaultRemouteNotificationCenter;
-(void)registerDeviceWithToken:(NSData*)token;
-(void)registrationDidFailWithError:(NSError*)aError;
-(void)didReceiveRemoteNotification:(NSDictionary*)aNotificationInfo;

@end
