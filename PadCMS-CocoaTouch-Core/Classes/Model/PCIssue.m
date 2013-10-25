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
#import "PCConfig.h"
#import "InAppPurchases.h"
#import "PCTag.h"
#import "NSString+HTML.h"

@implementation PCIssue

@synthesize application = _application;
//@synthesize currentRevision = _currentRevision;
@synthesize backEndURL = _backEndURL;
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
    self.backEndURL = nil;
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
        _productIdentifier =nil;
        _title = nil;
        _number = nil;
        _updatedDate = nil;
		_price = nil;
    }

    return self;
}

- (id)initWithParameters:(NSDictionary *)parameters
           rootDirectory:(NSString *)rootDirectory
              backEndURL:(NSURL *)backEndURL
{
    if (parameters == nil) {
        return nil;
    }

    self = [super init];
    
    if (self != nil) {
        NSString *identifierString = [parameters objectForKey:PCJSONIssueIDKey];
        
        if (backEndURL != nil) {
            _backEndURL = [backEndURL retain];
        } else {
            _backEndURL = [PCConfig serverURL];
        }

        _contentDirectory = [[rootDirectory stringByAppendingPathComponent:
                              [NSString stringWithFormat:@"issue-%@", identifierString]] copy];
        
        [PCPathHelper createDirectoryIfNotExists:_contentDirectory];
        
        _identifier = [identifierString integerValue];
        _title = [[parameters objectForKey:PCJSONIssueTitleKey] copy];
        self.titleShort = [parameters objectForKey:PCJSONIssueTitleShortKey];
        _number = [[parameters objectForKey:PCJSONIssueNumberKey] copy];
        
        _productIdentifier = [[parameters objectForKey:PCJSONIssueProductIDKey] copy];
        //_productIdentifier = @"com.mobile.rue89.issue_1000";
        
        _author = [[parameters objectForKey:PCJSONIssueAuthorKey] copy];
        _excerpt = [[[parameters objectForKey:PCJSONIssueExcerptKey] stringByDecodingHTMLEntities] copy];
        self.shortIntro = [[parameters objectForKey:PCJSONIssueShortIntroKey] stringByDecodingHTMLEntities];
        _imageLargeURL = [[parameters objectForKey:PCJSONIssueImageLargeURLKey] copy];
        _imageSmallURL = [[parameters objectForKey:PCJSONIssueImageSmallURLKey] copy];
        _wordsCount = [[parameters objectForKey:PCJSONIssueWordsCountKey] integerValue];
        _category = [[parameters objectForKey:PCJSONIssueCategoryKey] copy];
        
        _isIndividuallyPaid = [[parameters objectForKey:PCJSONIssueIsIndividuallyPaidKey]boolValue];
        
        self.publishDate = dateFromString([parameters objectForKey:PCJSONIssuePublishDateKey]);
        
        _paid = [[parameters objectForKey:PCJSONIssuePaidKey] boolValue];
		if ([_productIdentifier isEqualToString:@""])
		{
			_paid = YES;
		}
        
        NSString *issueSubscriptionType = [parameters objectForKey:PCJSONIssueSubscriptionTypeKey];
        
        if (issueSubscriptionType)
        {
            if ([issueSubscriptionType isEqualToString:PCJSONIssueAutoRenewableSubscriptionTypeValue])
            {
                _subscriptionType = PCIssueSubscriptionAutoRenewable;
				_paid = YES;
            }
        }
        
        //   NSDictionary *helpPages = [parameters objectForKey:PCJSONIssueHelpPagesKey];
        
        _revisions = [[NSMutableArray alloc] init];
        NSDictionary *revisionsParameters = [parameters objectForKey:PCJSONRevisionsKey];
        if ([revisionsParameters count] > 0)
        {
            for (NSString *key in revisionsParameters)
            {
                NSDictionary *revisionParameters = [revisionsParameters objectForKey:key];
                PCRevision *revision = [[PCRevision alloc] initWithParameters:revisionParameters
                                                                rootDirectory:_contentDirectory
                                                                   backEndURL:_backEndURL];
                
                if (revision != nil)
                {
                    [_revisions addObject:revision];
                }
                
                revision.issue = self;
                //         revision.helpPages = helpPages;
                
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
        
        _tags = [NSMutableArray new];
        
        NSArray * tagsParameters = [parameters objectForKey:PCJSONIssueTagsKey];
        
        if ([tagsParameters count] > 0) {
            for (NSDictionary * dic in tagsParameters) {
                PCTag * tag = [[PCTag alloc] initWithDictionary:dic];
                [_tags addObject:tag];
            }
        }
        
        //NSLog(@"TAGS : %@", _tags);
        
        
		[self loadProductPrices];
    }
    
    return self;
}

NSDate* dateFromString(NSString* strDate)
{
    if(strDate != nil && [strDate isKindOfClass:[NSString class]] && strDate.length)
    {
        NSRange range = {0, 10};
        strDate = [strDate substringWithRange:range];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        
        NSDate* date = [df dateFromString:strDate];
        
        [df release];
        return date;
    }
    else
    {
        return nil;
    }
}

- (id)initWithParameters:(NSDictionary *)parameters
           rootDirectory:(NSString *)rootDirectory
{
    return [self initWithParameters:parameters 
                      rootDirectory:rootDirectory
                         backEndURL:nil];
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


/*
- (PCRevision *)currentRevision
{
    if (_revisions == nil || [_revisions count] == 0) return nil;
    
    for (PCRevision *revision in _revisions)
    {
        if (revision.state = PCRevisionStatePublished)
        {
            return revision;
        }
    }
    
    return nil;
}
*/
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
                                   [UIColor whiteColor],        //hardcode, warning fix, 16.09.2013
                                   _coverImageThumbnailURL,
                                   _coverImageListURL,
                                   _coverImageURL,
                                   _updatedDate,
                                   NO,                          //hardcode, warning fix, 16.09.2013
                                   _contentDirectory,
                                   _revisions];
    
    return descriptionString;
}

@end
