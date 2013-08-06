//
//  NSKitWorks.m
//  the_reader
//
//  Created by User on 17.12.11.
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

#import "NKitWorks.h"
#import "Helper.h"

static NKitWorks *singleton = nil;

@implementation NKitWorks

@synthesize extendedDownloads;

- (void) addNewCustomDelegateFor:(NKAssetDownload *) asset
{
    NKIssue *nkIssue = [asset issue];
    
    NSLog(@"Resuming download for issue %@ (asset ID: %@) and status %d", nkIssue.name, asset.identifier, nkIssue.status);
    
    NKitCustomDeletage *delegate = [[NKitCustomDeletage alloc] init];
    [extendedDownloads setObject:delegate forKey:nkIssue.name];
    [asset setUserInfo:[NSDictionary dictionaryWithObject:nkIssue.name forKey:@"finalName"]];
    [asset downloadWithDelegate:delegate];
    [delegate release];
}

+ (NKitWorks*) sharedInstance
{
    if (singleton == nil)
	{
		singleton = [[super allocWithZone:NULL] init];
		
        singleton.extendedDownloads = [[[NSMutableDictionary alloc] init] autorelease];
        NSLog(@"retain count %d", [singleton.extendedDownloads retainCount]);
    }
	
    return singleton;
}

+ (void) addIssueWithName:(NSString *) name date:(NSDate *) date
{
    if(![[NKLibrary sharedLibrary] issueWithName:name])
    {
        if(!date)
            date = [NSDate date];
        NSLog(@"addIssueWithName %@", name);
        [[NKLibrary sharedLibrary] addIssueWithName:name date:date];
    }
}

+ (NKIssue *) issueWithName:(NSString *) name
{
    return [[NKLibrary sharedLibrary] issueWithName:name];
}

+ (void) updateExtendedDownloads
{
    //NSLog(@"From updateExtendedDownloads");
    for(NKAssetDownload *asset in [[NKLibrary sharedLibrary] downloadingAssets])
    {
        //NSLog(@"asset %@", asset);
        [[NKitWorks sharedInstance] addNewCustomDelegateFor:asset];
    }
}

+ (NKitCustomDeletage *) getDelegateForIssue:(NSString*) issueName
{
    return [[NKitWorks sharedInstance].extendedDownloads objectForKey:issueName];
}

+ (void) deleteDelegateForIssue:(NSString*) issueName
{
    NSLog(@"delete delegate for issue named %@", issueName);
    [[NKitWorks sharedInstance].extendedDownloads removeObjectForKey:issueName];
}

#pragma mark Singletton Methods

+ (id) allocWithZone:(NSZone *)zone
{
    return [[self sharedInstance] retain];
}

- (id) copyWithZone:(NSZone *)zone
{
    return self;	
}

- (id) retain
{
    return self;
}

- (NSUInteger) retainCount
{
    return NSUIntegerMax;
}

- (oneway void) release
{
    //do nothing	
}

- (id) autorelease
{
    return self;	
}

@end

@implementation NKitCustomDeletage

@synthesize delegate;

- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes
{
    
    //NSLog(@"Connection recieve data: %lld \t %lld \t %lld", bytesWritten, totalBytesWritten, expectedTotalBytes);
    
    if(delegate && [delegate respondsToSelector:@selector(connection:didWriteData:totalBytesWritten:expectedTotalBytes:)])
    {
        [delegate connection:connection didWriteData:bytesWritten totalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
    }
}

- (void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes
{
    //NSLog(@"Connection resume data: %lld \t %lld", totalBytesWritten, expectedTotalBytes);
    
    if(delegate && [delegate respondsToSelector:@selector(connectionDidResumeDownloading:totalBytesWritten:expectedTotalBytes:)])
    {
        [delegate connectionDidResumeDownloading:connection totalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
    }
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *) destinationURL
{
    NKAssetDownload *nad = connection.newsstandAssetDownload;
    NSString *finalName = [[nad userInfo] objectForKey:@"finalName"];
    
    [NKitWorks deleteDelegateForIssue:finalName];
    
    //NSLog(@"finish with path %@", destinationURL);
    
    if([[NSFileManager defaultManager] fileExistsAtPath:destinationURL.path])
    {
        
        if(finalName)
        {
            NSString* zipFileName = [[Helper getHomeDirectory] stringByAppendingPathComponent:finalName];
            NSURL* finalURL = [NSURL fileURLWithPath:zipFileName];
            NSError* error = nil;
            if ([[NSFileManager defaultManager] fileExistsAtPath:zipFileName])
                [[NSFileManager defaultManager] removeItemAtURL:finalURL error:nil];
            [[NSFileManager defaultManager] copyItemAtURL:destinationURL toURL:finalURL error:&error];
            if (error)
            {
                NSLog(@"Error while moving newsstand downloaded zip to proper location. Error - %@", error);
            }
            [[NSFileManager defaultManager] removeItemAtURL:destinationURL error:&error];
        }
        
    }
    
    if(delegate && [delegate respondsToSelector:@selector(connectionDidFinishDownloading:destinationURL:)])
    {
        [delegate connectionDidFinishDownloading:connection destinationURL:destinationURL];
    }
}

@end
