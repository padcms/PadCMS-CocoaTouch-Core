//
//  PCApplication.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 16.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCApplication.h"
#import "PCIssue.h"
#import "PCPathHelper.h"
#import "PCConfig.h"
#import "InAppPurchases.h"

@implementation PCApplication

@synthesize contentDirectory = _contentDirectory;
@synthesize identifier = _identifier;
@synthesize title = _title;
@synthesize applicationDescription = _applicationDescription;
@synthesize productIdentifier = _productIdentifier;
@synthesize notifications = _notifications;
@synthesize issues = _issues;

- (void)dealloc
{
    self.title = nil;
    self.applicationDescription = nil;
    self.productIdentifier = nil;
    self.notifications = nil;
    self.issues = nil;
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _identifier = -1;
        _title = nil;
        _applicationDescription = nil;
        _productIdentifier = nil;
        _notifications = nil;
        _issues = nil;
        _notifications = [[NSMutableDictionary alloc] init];
        _issues = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (id)initWithParameters:(NSDictionary *)parameters rootDirectory:(NSString *)rootDirectory
{
    if (parameters == nil) return nil;
    
    self = [super init];
    
    if (self)
    {
        // Set up application parameters
        
        NSString *identifierString = [parameters objectForKey:PCJSONApplicationIDKey]; 
        
        _contentDirectory = [[rootDirectory stringByAppendingPathComponent:
                              [NSString stringWithFormat:@"application-%@", identifierString]] copy];
        
        [PCPathHelper createDirectoryIfNotExists:_contentDirectory];
        
        _identifier = [identifierString integerValue];
        _title = [[parameters objectForKey:PCJSONApplicationTitleKey] copy];
        _applicationDescription = [[parameters objectForKey:PCJSONApplicationDescriptionKey] copy];
        _productIdentifier = [[parameters objectForKey:PCJSONApplicationProductIDKey] copy];
        
        // Set up notifications
        
        _notifications = [[NSMutableDictionary alloc] init];
        
        if ([parameters objectForKey:PCJSONApplicationNotificationEmailKey] 
            && [parameters objectForKey:PCJSONApplicationNotificationEmailTitleKey])
        {
            NSString *emailKey = [parameters objectForKey:PCJSONApplicationNotificationEmailKey];
            NSString *emailTitle = [parameters objectForKey:PCJSONApplicationNotificationEmailTitleKey];
            NSDictionary *emailNotificationType = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   emailKey, PCApplicationNotificationMessageKey,
                                                   emailTitle, PCApplicationNotificationTitleKey,
                                                   nil];
            
            [_notifications setObject:emailNotificationType forKey:PCEmailNotificationType];
        }
        
        if ([parameters objectForKey:PCJSONApplicationNotificationTwitterKey])
        {
            NSString *twitterKey = [parameters objectForKey:PCJSONApplicationNotificationTwitterKey];
            NSDictionary *twitterNotificationType = [NSDictionary dictionaryWithObjectsAndKeys:
                                                     twitterKey, PCApplicationNotificationMessageKey,
                                                     nil];
            
            [_notifications setObject:twitterNotificationType forKey:PCTwitterNotificationType];
        }
        
        if ([parameters objectForKey:PCJSONApplicationNotificationFacebookKey])
        {
            NSString *facebookKey = [parameters objectForKey:PCJSONApplicationNotificationFacebookKey];
            NSDictionary *facebookNotificationType = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      facebookKey, PCApplicationNotificationMessageKey,
                                                      nil] ;
            
            [_notifications setObject:facebookNotificationType forKey:PCFacebookNotificationType];
        }
        
        // Set up issues
        
        _issues = [[NSMutableArray alloc] init];
        
        NSDictionary *issuesList = [parameters objectForKey:PCJSONIssuesKey];
        
        if (issuesList != nil && [issuesList count] != 0)
        {
            NSArray *keys = [issuesList allKeys];
            for (NSString* key in keys)
            {
                NSDictionary *issueParameters = [issuesList objectForKey:key];
                PCIssue *issue = [[PCIssue alloc] initWithParameters:issueParameters 
                                                       rootDirectory:_contentDirectory];
                if (issue != nil)
                {
                    [_issues addObject:issue];
                    [issue release];
                }
                
                issue.application = self;
            }
        }
        
		[_issues sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            PCIssue *issue1 = (PCIssue *)obj1;
            NSNumber *number1 = [NSNumber numberWithInteger:issue1.number.integerValue];
            PCIssue *issue2 = (PCIssue *)obj2;
            NSNumber *number2 = [NSNumber numberWithInteger:issue2.number.integerValue];
			return [number1 compare:number2];
		}];
		
		for (NSString* subscriptionID in [PCConfig subscriptions]) {
			[[InAppPurchases sharedInstance] requestProductDataWithProductId:subscriptionID];
		}
    }
    
    return self;
}

- (NSDictionary *)notificationForType:(NSString *)notificationType
{
    return [self.notifications objectForKey:notificationType]; 
}

- (PCIssue *)issueForRevisionWithId:(NSInteger)identifier
{
    NSArray *filtredIssues = [self.issues filteredArrayUsingPredicate:
                              [NSPredicate predicateWithFormat:@"revisionIdentifier = %d", identifier]];
    
    if (filtredIssues != nil && [filtredIssues count] > 0)
    {
        return [filtredIssues objectAtIndex:0];   
    }
    
    return nil;
}

- (NSString *)description
{
    NSString *descriptionString = [NSString stringWithFormat:@"%@\ridentifier: %d\rtitle: %@\r"
                                   "applicationDescription: %@\rproductIdentifier: %@\r"
                                   "contentDirectory: %@\rnotifications: %@\rissues: %@", 
                                   [super description],
                                   _identifier,
                                   _title,
                                   _applicationDescription,
                                   _productIdentifier,
                                   _contentDirectory,
                                   _notifications,
                                   _issues];
    
    return descriptionString;
}

@end
