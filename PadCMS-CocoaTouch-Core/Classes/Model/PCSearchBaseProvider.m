//
//  PCSearchBaseProvider.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Oleg Zhitnik on 31.07.12.
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

#import "PCSearchBaseProvider.h"

@interface PCSearchBaseProvider()
@end

@implementation PCSearchBaseProvider

@synthesize keyPhraseRegexp = _keyPhraseRegexp;
@synthesize searchInPorgress = _searchInPorgress;
@synthesize delegate;
@synthesize result;
@synthesize searchingThread;
@synthesize targetRevision;

-(id) initWithKeyPhrase:(NSString*) keyPhrase
{
    self = [super init];
    if (self)
    {
        self.keyPhraseRegexp = [self searchingRegexpFromKeyPhrase:keyPhrase];
        targetRevision = nil;
        searchingThread = nil;
        self.searchInPorgress = NO;
    }
    
    return self;
}

- (void)dealloc
{
    self.keyPhraseRegexp = nil;
    self.targetRevision = nil;
    self.searchingThread = nil;
    self.result = nil;
    [super dealloc];
}

-(BOOL) isStringContainsRegexp:(NSString*) string
{
    NSRange     r;

    r = [string rangeOfString:_keyPhraseRegexp
                      options:NSRegularExpressionSearch | NSCaseInsensitiveSearch];

    if(r.location!=NSNotFound)
    {
        return YES;
    }

    return NO;
}

-(void) searchInRevision:(PCRevision*) revision
{
    self.targetRevision = revision;
    [self startSearch];
}

-(void) startSearch
{
    if(self.result)self.result = nil;
    self.result = [[[PCSearchResult alloc] init] autorelease];
    
    [NSThread detachNewThreadSelector:@selector(searchThread:)
                             toTarget:self
                           withObject:nil];
}

-(void) cancelSearch
{
    if(self.searchingThread)[self.searchingThread cancel];
}

- (void) search
{
    if ([searchingThread isCancelled])
    {
        [self callDelegateTaskCanceled];
        return;
    }
}

- (void) searchThread:(id)someObject
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    searchingThread = [NSThread currentThread];

    self.searchInPorgress = YES;
    [self callDelegateTaskStarted];
    [self search];
    [self callDelegateTaskFinished];
    self.searchInPorgress = NO;
    
    [pool release];
}

- (NSString*) searchingRegexpFromKeyPhrase:(NSString*) keyphrase
{
    NSString        *keyphraseRegexp = nil;

    if(keyphrase)
    {
        keyphraseRegexp = keyphrase;
        keyphraseRegexp = [keyphraseRegexp stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
        keyphraseRegexp = [keyphraseRegexp stringByReplacingOccurrencesOfString:@"." withString:@"\\."];
        keyphraseRegexp = [keyphraseRegexp stringByReplacingOccurrencesOfString:@"*" withString:@"\\*"];
        keyphraseRegexp = [keyphraseRegexp stringByReplacingOccurrencesOfString:@"{" withString:@"\\{"];
        keyphraseRegexp = [keyphraseRegexp stringByReplacingOccurrencesOfString:@"}" withString:@"\\}"];
        keyphraseRegexp = [keyphraseRegexp stringByReplacingOccurrencesOfString:@"[" withString:@"\\["];
        keyphraseRegexp = [keyphraseRegexp stringByReplacingOccurrencesOfString:@"]" withString:@"\\]"];
        keyphraseRegexp = [keyphraseRegexp stringByReplacingOccurrencesOfString:@"(" withString:@"\\("];
        keyphraseRegexp = [keyphraseRegexp stringByReplacingOccurrencesOfString:@")" withString:@"\\)"];
        
        NSMutableString     *trimmedStr = [NSMutableString stringWithString:keyphraseRegexp];
        NSUInteger          numReplacements;
        do {
            NSRange     fullRange = NSMakeRange(0, [trimmedStr length]);
            
            numReplacements = [trimmedStr replaceOccurrencesOfString:@"  "
                                                          withString:@" "
                                                             options:0
                                                               range:fullRange];
        } while(numReplacements > 0);
        
        keyphraseRegexp = [trimmedStr stringByReplacingOccurrencesOfString:@" " withString:@"[ ]+"];
    }
    
    return keyphraseRegexp;
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
