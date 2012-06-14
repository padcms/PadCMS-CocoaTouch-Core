//
//  InAppPurchases.m
//  the_reader
//
//  Created by User on 18.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InAppPurchases.h"
#import "PCConfig.h"

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
							 [NSString stringWithString:product.productIdentifier], @"productIdentifier", nil];
			
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
				[self finishTransaction:transaction];
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
  
  if(_isSubscribed==YES)
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
	{
			
			//[self purchaseForProductId:@"com.mobile.rue89.oneyear"];
		[self purchaseForProductId:[[PCConfig subscriptions] lastObject]];
		}
	}
	else
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Vous ne pouvez procéder à l'achat" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
  
}

@end
