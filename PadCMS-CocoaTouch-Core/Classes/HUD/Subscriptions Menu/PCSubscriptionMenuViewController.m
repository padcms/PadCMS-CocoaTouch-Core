//
//  PCSubscriptionMenuViewController.m
//  Pad CMS
//
//  Created by Igor Getmanenko on 15.08.12.
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

#import "PCSubscriptionMenuViewController.h"
#import "InAppPurchases.h"
#import "PCLocalizationManager.h"
#import "PCMacros.h"

#define MenuWidth 150.0
#define MenuHeight 100.0
#define FontSize 15
#define FontName @"Arial"
#define SubscribeButtonIndex 0
#define RenewButtonIndex 1

@interface PCSubscriptionMenuViewController()
{
    NSArray *_buttonsText;
    BOOL _needRestoreIssues;
}

@property (nonatomic, retain) NSArray *buttonsText;
@property (nonatomic, assign) BOOL needRestoreIssues;

- (void)subscribeAction;

@end

@implementation PCSubscriptionMenuViewController

@synthesize buttonsText = _buttonsText;
@synthesize needRestoreIssues = _needRestoreIssues;
@synthesize delegate = _delegate;

- (id)initWithSubscriptionFlag:(BOOL) isIssuesToRestore;
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) 
    {
        _buttonsText = [[NSArray alloc] initWithObjects:
                        [PCLocalizationManager localizedStringForKey:@"SUBSCRIPTION_MENU_TITLE_SUBSCRIBE" 
                                                               value:@"Subscribe"],
                        [PCLocalizationManager localizedStringForKey:@"SUBSCRIPTION_MENU_TITLE_RENEW" 
                                                               value:@"Renew subscription"],
                        nil];
        _needRestoreIssues = isIssuesToRestore;
    }
    return self;
}

- (void)dealloc
{
    [_buttonsText release], _buttonsText = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subscribeAction) name:PCSubscribeButtonDidTapped object:nil];

    self.view.backgroundColor =  [UIColor colorWithWhite:0 alpha:0.5];
    self.contentSizeForViewInPopover = CGSizeMake(MenuWidth, MenuHeight);
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorColor = [UIColor clearColor];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

-(BOOL)shouldAutorotate{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)subscribeAction
{
    [[InAppPurchases sharedInstance] subscribe];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_buttonsText count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = [self.buttonsText objectAtIndex:indexPath.row];
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:FontName size:FontSize];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_delegate subscriptionsMenuButtonWillPressed];
    switch (indexPath.row) 
    {
        case SubscribeButtonIndex:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PCSubscribeButtonWillTapped object:nil];
            break;
        }
            
        case RenewButtonIndex:
        {
            [[InAppPurchases sharedInstance] renewSubscription:_needRestoreIssues];
            break;
        }
            
        default:
            break;
    }
}

@end
