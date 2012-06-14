//
//  InAppPurchases.h
//  the_reader
//
//  Created by User on 18.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"
#define kInAppPurchaseManagerTransactionFinished @"kInAppPurchaseManagerTransactionFinished"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"



@interface InAppPurchases : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
	NSMutableSet *dataQueue;
}

@property (retain) NSMutableSet *dataQueue;
@property BOOL isSubscribed;

+ (InAppPurchases *)sharedInstance;

- (void)requestProductDataWithProductId:(NSString *)productId;
- (void)requestProductDataWithProductIds:(NSSet *)productIds;

- (BOOL)canMakePurchases;
- (BOOL)queueIsEmpty;
- (void)purchaseForProductId:(NSString *)productId;

-(void)subscribe;

@end
