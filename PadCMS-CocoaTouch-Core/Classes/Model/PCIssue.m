//
//  PCMagazine.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 02.02.12.
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

#import "PCIssue.h"
#import "PCRevision.h"
#import "PCPathHelper.h"
#import "InAppPurchases.h"

@implementation PCIssue

@synthesize application = _application;
//@synthesize currentRevision = _currentRevision;
@synthesize contentDirectory = _contentDirectory;
@synthesize revisions = _revisions;
@synthesize subscriptionType = _subscriptionType;
@synthesize paid = _paid;
@synthesize identifier = _identifier;
@synthesize title = _title;
@synthesize number = _number;
@synthesize productIdentifier = _productIdentifier;
@synthesize coverImageThumbnailURL = _coverImageThumbnailURL;
@synthesize coverImageListURL = _coverImageListURL;
@synthesize coverImageURL = _coverImageURL;
@synthesize updatedDate = _updatedDate;
@synthesize price=_price;

- (void)dealloc
{
    self.updatedDate = nil;
//    self.revisionCreatedDate = nil;
//    self.revisionUpdateDate = nil;
//    self.revisionTitle = nil;
    self.productIdentifier = nil;
    self.coverImageThumbnailURL = nil;
    self.coverImageListURL = nil;
    self.coverImageURL = nil;
    self.number = nil;
    self.title = nil;
	self.price = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _subscriptionType = PCIssueUnknownSubscriptionType;
        _paid = NO;
        _identifier = -1;
	}

    return self;
}

- (id)initWithParameters:(NSDictionary *)parameters rootDirectory:(NSString *)rootDirectory
{
    if (parameters == nil) return nil;

    self = [super init];
    
    if (self)
    {
        NSString *identifierString = [parameters objectForKey:PCJSONIssueIDKey];
        
        _contentDirectory = [[rootDirectory stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"issue-%@", identifierString]] copy];

        [PCPathHelper createDirectoryIfNotExists:_contentDirectory];

        _identifier = [identifierString integerValue];
        _title = [[parameters objectForKey:PCJSONIssueTitleKey] copy];
        _number = [[parameters objectForKey:PCJSONIssueNumberKey] copy];
        _productIdentifier = [[parameters objectForKey:PCJSONIssueProductIDKey] copy];
        
        _paid = [[parameters objectForKey:PCJSONIssuePaidKey] boolValue];
		
		//if there is no product identifuer the this issue is free
		if ([_productIdentifier isEqualToString:@""])
		{
			_paid = YES;
		}
        
        NSString *issueSubscriptionType = [parameters objectForKey:PCJSONIssueSubscriptionTypeKey];
        
		//if user is subscribed then issueSubscriptionType not empty
        if (issueSubscriptionType)
        {
            if ([issueSubscriptionType isEqualToString:PCJSONIssueAutoRenewableSubscriptionTypeValue])
            {
                _subscriptionType = PCIssueSubscriptionAutoRenewable;
				_paid = YES;
            }
        }
        
        _revisions = [[NSMutableArray alloc] init];
        NSDictionary *revisionsParameters = [parameters objectForKey:PCJSONRevisionsKey];
        if ([revisionsParameters count] > 0)
        {
            NSArray *revisionsKeys = [revisionsParameters allKeys];
            for (NSString *key in revisionsKeys)
            {
                PCRevision *revision = [[PCRevision alloc]
										initWithParameters:[revisionsParameters objectForKey:key]
										rootDirectory:_contentDirectory];
                
                if (revision != nil)
                {
                    [_revisions addObject:revision];
                }
                
                revision.issue = self;
                [revision release];
            }
			[_revisions sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
				NSNumber* number1 = [NSNumber numberWithInteger:((PCRevision*)obj1).identifier];
				NSAssert(number1,@"Error");
				NSNumber* number2 = [NSNumber numberWithInteger:((PCRevision*)obj2).identifier];
				NSAssert(number2,@"Error");
				return [number1 compare:number2];
			}];
        }
		[self loadProductPrices];
    }
    
    return self;
}

- (void) loadProductPrices
{
	if(!_paid && !_price)
	{
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(productDataRecieved:) 
													 name:kInAppPurchaseManagerProductsFetchedNotification
												   object:nil];
		[[InAppPurchases sharedInstance] requestProductDataWithProductId:_productIdentifier];
	}
}

- (void) productDataRecieved:(NSNotification *) notification
{
	NSLog(@"From PCIssue::productDataRecieved: %@ %@", [(NSDictionary *)[notification object] objectForKey:@"productIdentifier"], [(NSDictionary *)[notification object] objectForKey:@"localizedPrice"]);
		
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kInAppPurchaseManagerProductsFetchedNotification object:nil];
	if([[(NSDictionary *)[notification object] objectForKey:@"productIdentifier"] isEqualToString:_productIdentifier])
	{
		self.price = [NSString stringWithString:[(NSDictionary *)[notification object] objectForKey:@"localizedPrice"]];
		return;
	}

}

- (NSString *)description
{
    NSString *descriptionString = [NSString stringWithFormat:@"%@\ridentifier: %d\rtitle: %@\r"
                                   "number: %@\rproductIdentifier: %@\rsubscriptionType: %d\r"
                                   "paid: %d\rcolor: %@\rcoverImageThumbnailURL: %@\r"
                                   "coverImageListURL: %@\rcoverImageURL: %@\rupdatedDate: %@\r"
                                   "horisontalMode: %d\rcontentDirectory: %@\r"
                                   "revisions: %@", 
                                   [super description],
                                   _identifier,
                                   _title,
                                   _number,
                                   _productIdentifier,
                                   _subscriptionType,
                                   _paid,
                                   _coverImageThumbnailURL,
                                   _coverImageListURL,
                                   _coverImageURL,
                                   _updatedDate,
                                   _contentDirectory,
                                   _revisions];
    
    return descriptionString;
}

@end
