//
//  PCSearchTask.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 02.03.12.
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

#import "PCSearchTask.h"
#import "PCApplication.h"
#import "PCSQLLiteModelBuilder.h"
#import "PCPathHelper.h"
#import "PCRevision.h"

@interface PCSearchTask (Private)
- (void) searchThread:(id)someObject;
- (void) searchInRevision:(PCRevision *)_revision;
- (BOOL) isPage:(PCPage*)page containsKeyphrase:(NSString*)skeyphrase;
- (BOOL) isPageElement:(PCPageElement*)element containsKeyphrase:(NSString*)skeyphrase;
- (void) callDelegateTaskStarted;
- (void) callDelegateTaskFinished;
- (void) callDelegateTaskCanceled;
- (void) callDelegateTaskUpdated;
- (void) createRegexp;
@end

@implementation PCSearchTask
@synthesize keyphrase;
@synthesize keyphraseRegexp;
@synthesize result;
@synthesize searchingThread;
@synthesize delegate;
@synthesize application = _application;

- (id)init
{
    self = [super init];
    if (self)
    {
        delegate = nil;
        self.keyphrase = nil;
        searchingThread = nil;
        self.keyphraseRegexp = nil;
    }
    
    return self;
}

- (id)initWithRevision:(PCRevision *)srevision
             keyPhrase:(NSString *)skeyphrase 
              delegate:(id<PCSearchTaskDelegate>)sdelegate
           application:(PCApplication*) application;
{
    self = [super init];
    if (self)
    {
        searchingThread = nil;
        delegate = sdelegate;
        self.keyphrase = skeyphrase;
        revision = srevision;
        self.result = [[[PCSearchResult alloc] init] autorelease];
        searchingThread = nil;
        [self createRegexp];
        self.application = application;
    }
    
    return self;
}

- (void)dealloc
{
    self.keyphrase = nil;
    self.keyphraseRegexp = nil;
    self.result = nil;
    [super dealloc];
}


-(void) startSearch
{
    [NSThread detachNewThreadSelector:@selector(searchThread:)
                             toTarget:self
                           withObject:nil];
}

-(void) cancelSearch
{
    if(searchingThread)[searchingThread cancel];
}

#pragma mark - Private

- (void) searchThread:(id)someObject
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    self.searchingThread = [NSThread currentThread];
    
    [self callDelegateTaskStarted];

    if(revision)
    {
        [self searchInRevision:revision];
        
        if ([searchingThread isCancelled])
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
            [self searchInRevision:currentRevision];
            
            if([searchingThread isCancelled])
            {
                [self callDelegateTaskCanceled];
                break;
            }
        }
        
        [allRevisions release];
    }
    
    [self callDelegateTaskFinished];
    
    [pool release];
}

- (void)searchInRevision:(PCRevision *)_revision
{
    if(_revision == nil || _revision.pages == nil) return;
    
    for (int i = 0; i < [_revision.pages count]; i++)
    {
        if([searchingThread isCancelled])
        {
            return;
        }
        
        PCPage *currentPage = [_revision.pages objectAtIndex:i];
        
        if([self isPage:currentPage containsKeyphrase:self.keyphraseRegexp])
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

- (BOOL) isPage:(PCPage*)page containsKeyphrase:(NSString*)skeyphrase
{
    if(!page) return NO;
    if(!page.elements) return NO;
    
    for(PCPageElement* currentElement in page.elements)
    {
        if([searchingThread isCancelled])
        {
            return NO;
        }
        
        if([self isPageElement:currentElement containsKeyphrase:skeyphrase])
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL) isPageElement:(PCPageElement*)element containsKeyphrase:(NSString*)skeyphrase
{
    if(element)
    {
        if(element.contentText)
        {
            NSRange     r;
            
            r = [element.contentText rangeOfString:skeyphrase
                                           options:NSRegularExpressionSearch | NSCaseInsensitiveSearch];
            
            if(r.location!=NSNotFound)
            {
                return YES;
            }
        }
    }
    return NO;
}

- (void) createRegexp
{
    if(self.keyphrase)
    {
        self.keyphraseRegexp = self.keyphrase;
        self.keyphraseRegexp = [self.keyphraseRegexp stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
        self.keyphraseRegexp = [self.keyphraseRegexp stringByReplacingOccurrencesOfString:@"." withString:@"\\."];
        self.keyphraseRegexp = [self.keyphraseRegexp stringByReplacingOccurrencesOfString:@"{" withString:@"\\{"];
        self.keyphraseRegexp = [self.keyphraseRegexp stringByReplacingOccurrencesOfString:@"}" withString:@"\\}"];
        self.keyphraseRegexp = [self.keyphraseRegexp stringByReplacingOccurrencesOfString:@"[" withString:@"\\["];
        self.keyphraseRegexp = [self.keyphraseRegexp stringByReplacingOccurrencesOfString:@"]" withString:@"\\]"];
        self.keyphraseRegexp = [self.keyphraseRegexp stringByReplacingOccurrencesOfString:@"(" withString:@"\\("];
        self.keyphraseRegexp = [self.keyphraseRegexp stringByReplacingOccurrencesOfString:@")" withString:@"\\)"];
        
        NSMutableString     *trimmedStr = [NSMutableString stringWithString:self.keyphraseRegexp];
        NSUInteger          numReplacements;
        do {
            NSRange     fullRange = NSMakeRange(0, [trimmedStr length]);
            
            numReplacements = [trimmedStr replaceOccurrencesOfString:@"  "
                                                          withString:@" "
                                                             options:0
                                                               range:fullRange];
        } while(numReplacements > 0);
        
        self.keyphraseRegexp = [trimmedStr stringByReplacingOccurrencesOfString:@" " withString:@"[ ]+"];
    }
}

#pragma mark - Delegate communications

- (void) callDelegateTaskStarted
{
    NSObject        *delegateObject = delegate;
    
    if(delegateObject)
    {
        [delegateObject performSelectorOnMainThread:@selector(searchTaskStarted)
                                         withObject:delegate
                                      waitUntilDone:YES];
    }
}

- (void) callDelegateTaskFinished
{
    NSObject        *delegateObject = delegate;
    
    if(delegateObject)
    {
        [delegateObject performSelectorOnMainThread:@selector(searchTaskFinished)
                                         withObject:delegate
                                      waitUntilDone:YES];
    }
}

- (void) callDelegateTaskCanceled
{
    NSObject        *delegateObject = delegate;
    
    if ([delegateObject respondsToSelector:@selector(searchTaskCanceled)])
    {
        [delegateObject performSelectorOnMainThread:@selector(searchTaskCanceled)
                                         withObject:delegate
                                      waitUntilDone:YES];
    }
}

- (void) callDelegateTaskUpdated
{
    NSObject        *delegateObject = delegate;
    
    if(delegateObject)
    {
        [delegateObject performSelectorOnMainThread:@selector(searchTaskResultUpdated)
                                         withObject:delegate
                                      waitUntilDone:YES];
    }
}

@end
