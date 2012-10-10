//
//  InAppPurchases.m
//  the_reader
//
//  Created by User on 18.03.11.
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

#import "InAppPurchases.h"
#import "PCConfig.h"
#import "PCLocalizationManager.h"

static InAppPurchases *singleton = nil;

#pragma mark Core

@implementation InAppPurchases

@synthesize dataQueue;
@synthesize isSubscribed=_isSubscribed;

+ (InAppPurchases*) sharedInstance
{
    if (singleton == nil)
	{
		singleton = [[super allocWithZone:NULL] init];
		
		singleton.dataQueue = [[[NSMutableSet alloc] init] autorelease];
		
		[[SKPaymentQueue defaultQueue] addTransactionObserver:singleton];
    
  }
	
    return singleton;
}

- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

- (BOOL)queueIsEmpty
{
	return [[[SKPaymentQueue defaultQueue] transactions] count] == 0;
}

- (void)repurchase
{
	_isSubscribed = YES;
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)purchaseForProductId:(NSString *)productId
{
	//[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:productId];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)requestProductDataWithProductId:(NSString *)productId
{
	if(![singleton.dataQueue containsObject:productId])
	{
		NSLog(@"From requestProductDataWithProductId: %@", productId);
		if (!productId) {
            NSLog(@"Warning! Please add at least one issue.");
            return;
        }
		[singleton.dataQueue addObject:productId];
		
		NSSet *productIdentifiers = [NSSet setWithObject:productId];
		//[productId release];
		SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
		productsRequest.delegate = self;
		[productsRequest start];
		[productsRequest release];
	}
}

- (void)requestProductDataWithProductIds:(NSSet *)productIds
{
    NSSet *productIdentifiers = [NSSet setWithSet:productIds];
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
	[productsRequest release];
}

- (void)finishTransaction:(SKPaymentTransaction *)transaction
{
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
	[[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFinished object:nil];
}

- (NSString *)localizedPrice:(SKProduct *) prod
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:prod.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:prod.price];
    [numberFormatter release];
    return formattedString;
}

#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
	for(SKProduct *product in products)
	{
		if (product)
		{
			[singleton.dataQueue removeObject:product.productIdentifier];
			
			NSLog(@"Product title: %@"       , product.localizedTitle);
			NSLog(@"Product description: %@" , product.localizedDescription);
			NSLog(@"Product price: %@"       , product.price);
			NSLog(@"Product id: %@"          , product.productIdentifier);
			
			NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [self localizedPrice:product], @"localizedPrice",
                                  [NSString stringWithString:product.productIdentifier], @"productIdentifier",
                                  [NSString stringWithString:product.localizedTitle], @"localizedTitle",
                                  [NSString stringWithString:product.localizedDescription], @"localizedDescription",
                                  nil];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:data];
		}
	}

    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
    
    //[request release];
}

#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	
    for (SKPaymentTransaction *transaction in transactions)
    {
		NSLog(@"From paymentQueue with:\n");
		if([transaction error])
		   NSLog(@"error: %@", [transaction error]);
		if([transaction transactionDate])
			NSLog(@"transactionDate: %@", [transaction transactionDate]);
		if([transaction transactionIdentifier])
			NSLog(@"transactionIdentifier: %@", [transaction transactionIdentifier]);
		if([transaction transactionReceipt])
		{
			
			//NSLog(@"here is it %@", [[NSString alloc] initWithData:[transaction transactionReceipt] encoding:NSASCIIStringEncoding]);
				
			//NSLog(@"transactionReceipt: %@", [transaction transactionReceipt]);
		}
		if([transaction transactionState])
			NSLog(@"transactionState: %d", [transaction transactionState]);
		
		if([transaction originalTransaction])
		{
			NSLog(@"originalTransaction: %@", [transaction originalTransaction]);
		}
		if([transaction payment])
		{
			NSLog(@"payment:\nproductIdentifier:%@\nrequestData:%@\nquantity:%d", [[transaction payment] productIdentifier], [[[NSString alloc] initWithData:[[transaction payment] requestData] encoding:NSASCIIStringEncoding] autorelease], [[transaction payment] quantity]);
		}
		
		
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
				[[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification
						object:[[[[NSString alloc] initWithData:[transaction transactionReceipt] encoding:NSASCIIStringEncoding] autorelease] substringWithRange:NSMakeRange(1, [[transaction transactionReceipt] length] - 2)]];
				[self finishTransaction:transaction];
             _isSubscribed = NO;
                break;
            case SKPaymentTransactionStateFailed:
				[self finishTransaction:transaction];
             _isSubscribed = NO;
                break;
            case SKPaymentTransactionStateRestored:
				
				[[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification
																	object:[[[[NSString alloc] initWithData:[transaction transactionReceipt] encoding:NSASCIIStringEncoding] autorelease] substringWithRange:NSMakeRange(1, [[transaction transactionReceipt] length] - 2)]];
				[self finishTransaction:transaction];
				 _isSubscribed = NO;
                break;
            default:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
	NSLog(@"From paymentQueue removedTransactions");
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
	NSLog(@"From paymentQueue restoreComletedTransactionsFailedWithError");
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
	NSLog(@"From paymentQueueRestoreCompletedTransactionFinished");
}

-(void)subscribe
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

    if(_isSubscribed)
    {
        /*     UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Vous êtes déjà inscrit" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [alert show];
         [alert release];*/
    
        return;
    }
    _isSubscribed=YES;
    //product request
    NSLog(@"subscribing");
	
		
	if([self canMakePurchases])
	{
        //[self purchaseForProductId:@"com.mobile.rue89.oneyear"];
        [self purchaseForProductId:[[PCConfig subscriptions] lastObject]];
	}
	else
	{
        NSString        *title = [PCLocalizationManager localizedStringForKey:@"ALERT_TITLE_CANT_MAKE_PURCHASE"
                                                                        value:@"You can't make the purchase"];
        
        NSString        *buttonTitle = [PCLocalizationManager localizedStringForKey:@"BUTTON_TITLE_OK"
                                                                              value:@"OK"];
        
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:buttonTitle
                                              otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void) renewSubscription:(BOOL) needRenewIssues
{
    NSLog(@"renewSubscription");
    
    BOOL isFree = YES;
    
    for (NSString* subscriptionID in [PCConfig subscriptions]) 
    {
        isFree = NO;
        [[InAppPurchases sharedInstance] requestProductDataWithProductId:subscriptionID];
    }
    
    if (needRenewIssues)
        isFree = NO;
    
    if (!isFree)
    {
        [[InAppPurchases sharedInstance] repurchase];
    }
}

@end
