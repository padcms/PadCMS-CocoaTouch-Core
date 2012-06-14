//
//  PCFacebookViewController.m
//  Pad CMS
//
//  Created by Igor Getmanenko on 02.02.12.
//  Copyright 2012 Adyax. All rights reserved.
//

#import "PCFacebookViewController.h"
#import "PCPathHelper.h"
#import "JSON.h"
#import "PCConfig.h"

static NSString* kAppId = @"209011709219556";
static NSString* PCFacebookDefaultDescription = @"Je lis ce magazine, et c'est merveilleux";
static NSString* PCFacebookDefaultPictureURL = @"http://www.appleinsider.ru/wp-content/uploads/2012/03/1325776461_itunes_10_10.jpg";

@implementation PCFacebookViewController

@synthesize facebookMessage = _facebookMessage;
@synthesize facebook = _facebook;

- (id) initWithMessage:(NSString*)message
{
    self = [super init];
    if (self)
    {
        _facebookMessage = message;
        _facebook = nil;
    }
	return self;
}

- (void) dealloc
{
    [_facebookMessage release], _facebookMessage = nil;
    [_facebook release], _facebook = nil;
    
    [super dealloc];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
	self.view.backgroundColor = [UIColor clearColor];
    
    [self initFacebookSharer];
}

- (void) initFacebookSharer
{
    NSString *stringHTML = [NSString stringWithContentsOfURL:[NSURL URLWithString:self.facebookMessage] encoding:NSUTF8StringEncoding error:nil];
    
    NSString *captionString = @"itunes.apple.com";
    
    NSRange range = [stringHTML rangeOfString:@"<title>"];
    NSString *nameString = [stringHTML substringFromIndex:(range.length + range.location)];
    range = [nameString rangeOfString:@"</title>"];
    nameString = [nameString substringToIndex:range.location];
    
    range = [stringHTML rangeOfString:@"name=\"description\" content=\""];
    NSString *descriptionString = PCFacebookDefaultDescription;
    if (range.length !=0)
    {
        descriptionString = [stringHTML substringFromIndex:(range.length + range.location)];
    }
    range = [descriptionString rangeOfString:@"\" />"];
    if (range.length !=0)
    {
        descriptionString = [descriptionString substringToIndex:range.location];
    }
    descriptionString = [descriptionString stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
    descriptionString = [descriptionString stringByReplacingOccurrencesOfString:@" " withString:@" "];
    
    NSString *pictureURLString;
    range = [stringHTML rangeOfString:@"class=\"portrait\" src=\""];
    if (range.length ==0)
    {
        range = [stringHTML rangeOfString:@"class=\"landscape\" src=\""];
        if (range.length ==0)
        {
            pictureURLString = PCFacebookDefaultPictureURL;
        }
    }
    NSLog(@"facebook message - %@", self.facebookMessage);
    if (range.length !=0)
    {
        pictureURLString = [stringHTML substringFromIndex:(range.length + range.location)];
        range = [pictureURLString rangeOfString:@"\" />"];
        if (range.length !=0)
        {
            pictureURLString = [[pictureURLString substringToIndex:range.location] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        else 
        {   
            pictureURLString = PCFacebookDefaultPictureURL;
        }
    }
    else 
    {   
        pictureURLString = PCFacebookDefaultPictureURL;
    }
    

    if (!self.facebook)
    {
        NSString *facebookAppID = [PCConfig facebookApplicationId];
        if (!facebookAppID)
        {
            facebookAppID = kAppId;
        }
        self.facebook = [[Facebook alloc] initWithAppId:facebookAppID andDelegate:nil];
    }
    
    SBJSON *jsonWriter = [[SBJSON new] autorelease];
    
    // The action links to be shown with the post in the feed
    NSArray* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                      @"Get started",@"name",@"http://itunes.apple.com/fr/app/air-le-mag-par-mcdonalds/id392259401?mt=8",@"link", nil], nil];
    NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
    // Dialog parameters
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   nameString, @"name",
                                   captionString, @"caption",
                                   descriptionString, @"description",
                                   self.facebookMessage, @"link",
                                   pictureURLString, @"picture",
                                   actionLinksStr, @"actions",
                                   nil];
    
    [self.facebook dialog:@"feed"
                      andParams:params
                    andDelegate:self];
    
    //urlstr = [NSString stringWithFormat:@"http://facebook.com/sharer.php?u=%@", self.facebookMessage];
}

#pragma mark FBDialog delegate methods

- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error
{
    if ([error code] == -999)
    {
        [self initFacebookSharer];
    }
}

- (void)dialogCompleteWithUrl:(NSURL *)url
{
    NSLog(@"dialogCompleteWithUrl - %@", url);
    
    if ([[url absoluteString] hasPrefix:@"fbconnect://success"])
    {
        [_facebook release], _facebook = nil;
    }
}

@end
