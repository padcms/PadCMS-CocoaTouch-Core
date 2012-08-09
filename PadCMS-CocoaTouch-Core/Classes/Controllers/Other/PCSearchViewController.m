//
//  PCSearchViewController.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 05.03.12.
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

#import "PCSearchViewController.h"
#import "PCApplication.h"
#import "PCRevision.h"
#import "PCSearchProvider.h"
#import "PCSearchResultViewCell.h"
#import "PCSearchResult.h"
#import "PCSearchResultItem.h"

@interface PCSearchViewController ()

@property(nonatomic, retain) PCSearchProvider *searchProvider;

-(void) issueTitleClicked:(id)sender;
-(void) pageTitleClicked:(id)sender;
-(void) stopSearching;
-(void) resultItemSelectedWithIndex:(NSInteger) index
                  andUsingPageIndex:(BOOL) usePageIndex;

-(void) dismissByDelegate;
@end

@implementation PCSearchViewController
@synthesize titleLabel;
@synthesize searchResultsTableView;
@synthesize searchingActivityIndicator;
@synthesize searchKeyphrase;
@synthesize revision;
@synthesize application = _application;
@synthesize delegate = _delegate;
@synthesize searchProvider;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setTitle:nil];
    [self setSearchResultsTableView:nil];
    [self setSearchingActivityIndicator:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    self.searchProvider = [[[PCSearchProvider alloc] initWithKeyPhrase:self.searchKeyphrase
                                                       andApplication:self.application] autorelease];
    [UIView beginAnimations:@"startSearch" context:nil];
    [UIView setAnimationDuration:1];
    searchResultsTableView.alpha = 0.5;
    [UIView commitAnimations];
    
    [self.searchProvider searchInRevision:self.revision];
}
    
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc {
    [searchResultsTableView release];
    [searchingActivityIndicator release];
    [titleLabel release];
    
    self.searchProvider = nil;

    [super dealloc];
}

- (IBAction)cancelClick:(id)sender
{
    if(![self.searchProvider searchInPorgress])
    {
        if(self.revision!=nil)
        {
            [self dismissByDelegate];
        } else {
            if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) 
            {
                [self dismissViewControllerAnimated:YES completion:nil];
            } 
            else
            {
                [self dismissModalViewControllerAnimated:YES];
            }
        }
    } else {
        [self.searchProvider cancelSearch];
    }
}

#pragma mark --------- search table ---------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.searchProvider)
    {
        @synchronized (self.searchProvider.result)
        {
            if(self.searchProvider.result)
            {
                if(self.searchProvider.result.items)
                {
                    return [self.searchProvider.result.items count];
                }
            }
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString     *CellIdentifier = @"PCSearchResultViewCell";
    
    PCSearchResultViewCell  *cell = (PCSearchResultViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier
                                                                 owner:cell
                                                               options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    [cell assignIssueTitle:@""
              andPageTitle:@""];
    
    NSInteger                row = [indexPath row];

    cell.tag = row;
    
    if(self.searchProvider.result)
    {
        @synchronized (self.searchProvider.result)
        {
            if(self.searchProvider.result.items)
            {
                PCSearchResultItem      *item = [self.searchProvider.result.items objectAtIndex:row];
                
                if(item)
                {
                    [cell assignIssueTitle:item.issueTitle
                              andPageTitle:item.pageTitle];

                    cell.issueTitleButton.tag = row;
                    cell.pageTitleButton.tag = row;
                    
                    [cell.issueTitleButton addTarget:self
                                              action:@selector(issueTitleClicked:)
                                    forControlEvents:UIControlEventTouchUpInside];
                    
                    [cell.pageTitleButton addTarget:self
                                             action:@selector(pageTitleClicked:)
                                   forControlEvents:UIControlEventTouchUpInside];
                }
            }
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

-(void) resultItemSelectedWithIndex:(NSInteger) index
                  andUsingPageIndex:(BOOL) usePageIndex
{
    if(index>=0 && index<[self.searchProvider.result.items count])
    {
        PCSearchResultItem      *item = [self.searchProvider.result.items objectAtIndex:index];
        
        if(item)
        {
            if(self.revision!=nil)
            {
                [self dismissByDelegate];
            } else {
                if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) 
                {
                    [self dismissViewControllerAnimated:YES completion:nil];
                } 
                else
                {
                    [self dismissModalViewControllerAnimated:YES];
                }
            }
            
            [self.delegate showRevisionWithIdentifier:item.revisionIdentifier
                                         andPageIndex:(usePageIndex ? item.pageIndex : 0)];
        }
    }
}

-(void) issueTitleClicked:(id)sender
{
    if([self.searchProvider searchInPorgress]) return;
    if([sender isKindOfClass:[UIButton class]])
    {
        UIButton        *button = (UIButton*)sender;
        NSInteger       index = button.tag;
        [self resultItemSelectedWithIndex:index andUsingPageIndex:NO];
    }
}

-(void) pageTitleClicked:(id)sender
{
    if([self.searchProvider searchInPorgress]) return;
    if([sender isKindOfClass:[UIButton class]])
    {
        UIButton        *button = (UIButton*)sender;
        NSInteger       index = button.tag;
        [self resultItemSelectedWithIndex:index andUsingPageIndex:YES];
    }
}

#pragma mark ------- search task delegate events -------

-(void) searchTaskStarted
{
    [searchingActivityIndicator startAnimating];
}

-(void) searchTaskResultUpdated
{
    [searchResultsTableView reloadData];
}

-(void) searchTaskFinished
{
    [self stopSearching];
    [searchResultsTableView reloadData];
}

-(void) searchTaskCanceled
{
    [self stopSearching];
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) 
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    } 
    else
    {
        [self dismissModalViewControllerAnimated:YES];
    }
}

-(void) stopSearching
{
    [UIView setAnimationDuration:1];
    searchResultsTableView.alpha = 1.0;
    [UIView commitAnimations];
    [searchingActivityIndicator stopAnimating];
}

-(void) dismissByDelegate
{
    if([self.delegate respondsToSelector:@selector(dismissPCSearchViewController:)])
    {
        [self.delegate dismissPCSearchViewController:self];
    }
}

@end
