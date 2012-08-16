//
//  PCSearchProvider.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 01.03.12.
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

#import "PCSearchProvider.h"
#import "PCIssue.h"
#import "PCSearchResultItem.h"

@interface PCSearchProvider ()
- (void) doSearchInRevision:(PCRevision *)_revision;
- (BOOL) isPageContainsRegexp:(PCPage*)page;
- (BOOL) isPageElementContainsRegexp:(PCPageElement*)element;
@end

@implementation PCSearchProvider
@synthesize application;

-(id) initWithKeyPhrase:(NSString*) keyPhrase andApplication:(PCApplication*)_application
{
    self = [super init];
    if (self)
    {
        [super initWithKeyPhrase:keyPhrase];
        self.application = _application;
    }
    return self;
}

- (void)dealloc
{
    self.application = nil;
    [super dealloc];
}

- (void) search
{
    if(self.targetRevision)
    {
        [self doSearchInRevision:self.targetRevision];
        
        if ([self.searchingThread isCancelled])
        {
            [self callDelegateTaskCanceled];
        }
    } else {
        // search in all revisions
        NSMutableArray *allRevisions = [[NSMutableArray alloc] init];
        
        NSArray *issues = self.application.issues;
        for (PCIssue *issue in issues)
        {
            [allRevisions addObjectsFromArray:issue.revisions];
        }
        
        for(PCRevision *currentRevision in allRevisions)
        {
            [self doSearchInRevision:currentRevision];
            
            if([self.searchingThread isCancelled])
            {
                [self callDelegateTaskCanceled];
                break;
            }
        }
        
        [allRevisions release];
    }
}

#pragma mark --- Private ---

- (void) doSearchInRevision:(PCRevision *)_revision;
{
    if(_revision == nil || _revision.pages == nil) return;
    
    for (int i = 0; i < [_revision.pages count]; i++)
    {
        if([self.searchingThread isCancelled])
        {
            return;
        }
        
        PCPage *currentPage = [_revision.pages objectAtIndex:i];
        
        if([self isPageContainsRegexp:currentPage])
        {
            // add page to result set
            PCSearchResultItem  *item = [[PCSearchResultItem alloc] initWithIssueTitle:_revision.issue.title
                                                                          andPageTitle:currentPage.title
                                                                 andRevisionIdentifier:_revision.identifier
                                                                          andPageIndex:i];
            [self.result addResultItem:item];
            [item release];
            [self callDelegateTaskUpdated];
        }
    }
}

- (BOOL) isPageContainsRegexp:(PCPage*)page;
{
    if(!page) return NO;
    if(!page.elements) return NO;
    
    for(PCPageElement* currentElement in page.elements)
    {
        if([self.searchingThread isCancelled])
        {
            return NO;
        }
        
        if([self isPageElementContainsRegexp:currentElement])
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL) isPageElementContainsRegexp:(PCPageElement*)element;
{
    if(element)
    {
        if(element.contentText)
        {
            if([self isStringContainsRegexp:element.contentText]) return YES;
        }
    }
    return NO;
}

@end
