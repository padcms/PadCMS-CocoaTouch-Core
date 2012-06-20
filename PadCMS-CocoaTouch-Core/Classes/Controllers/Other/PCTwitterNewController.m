//
//  PCTwitterNewController.m
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

#import "PCTwitterNewController.h"
#import "PCPathHelper.h"

@implementation PCTwitterNewController

@synthesize tweetViewController = _tweetViewController;
@synthesize delegate = _delegate;
@synthesize twitterMessage = _twitterMessage;

- (id) initWithMessage:(NSString*)message
{
    self = [super init];
    
    if (self) 
    {
        _tweetViewController = [[TWTweetComposeViewController alloc] init];
        _delegate = nil;
        _twitterMessage = message;
    }
    
    return self;
}

- (void) dealloc
{
    [_tweetViewController release], _tweetViewController = nil;
    [_twitterMessage release], _twitterMessage = nil;
    _delegate = nil;
    
    [super dealloc];
}

- (void) showTwitterController
{
    TWTweetComposeViewControllerCompletionHandler completionHandler = ^(TWTweetComposeViewControllerResult result) 
    {
        switch (result)
        {
            case TWTweetComposeViewControllerResultCancelled:
                NSLog(@"Twitter Result: canceled");
                break;
            case TWTweetComposeViewControllerResultDone:
                NSLog(@"Twitter Result: sent");
                break;
            default:
                NSLog(@"Twitter Result: default");
                break;
        }
        [self.delegate dismissPCNewTwitterController:self.tweetViewController];
    };
    [self.tweetViewController setCompletionHandler:completionHandler];

    [self.tweetViewController setInitialText:self.twitterMessage];
    [self.tweetViewController addImage:nil];
    [self.tweetViewController addURL:nil];
    if (self.delegate)
    {
        [self.delegate showPCNewTwitterController:self.tweetViewController];
    }
    else
    {
        NSLog(@"PCTwitterNewController.delegate is not defined");
    }
}

@end
