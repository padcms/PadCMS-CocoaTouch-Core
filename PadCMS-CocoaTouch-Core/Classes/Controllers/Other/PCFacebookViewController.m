//
//  PCFacebookViewController.m
//  Pad CMS
//
//  Created by Igor Getmanenko on 02.02.12.
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

#import "PCFacebookViewController.h"
#import "PCPathHelper.h"
//#import "JSON.h"
#import "SBJson.h"
#import "PCConfig.h"

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
            NSLog(@"Please, specify facebookID");
            return;
        }
        self.facebook = [[Facebook alloc] initWithAppId:facebookAppID andDelegate:nil];
    }
    
    SBJsonWriter *jsonWriter = [[SBJsonWriter new] autorelease];
    
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
