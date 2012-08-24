//
//  PCRevision.m
//  Pad CMS
//
//  Created by Maxim Pervushin on 4/26/12.
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

#import "PCRevision.h"
#import "PCPage.h"
#import "PCColumn.h"
#import "PCPageTemplatesPool.h"
#import "PCPathHelper.h"
#import "ZipArchive.h"
#import "PCSQLLiteModelBuilder.h"
#import "PCDownloadProgressProtocol.h"
#import "AFNetworking.h"
#import "UIColor+HexString.h"
#import "PCGoogleAnalytics.h"
#import "PCConfig.h"
#import "PCDownloadManager.h"

#define PCRevisionExportPath @"export/revision/id/"
#define PCRevisionDirectoryPrefix @"revision"
#define PCRevisionDatabaseFileName @"sqlite.db"
#define PCRevisionDatabaseArchiveFileName @"database.zip"
#define PCRevisionCoverImageFileName @"cover.jpg"
#define PCRevisionCoverImagePlaceholderName @"application-cover-placeholder.jpg"
#define PCPadCMSResourseURLPart @"/resources/none"

NSString * const PCHelpItemDidDownloadNotification = @"PCHelpItemDidDownloadNotification";
NSString * const PCHorizontalPageDidDownloadNotification = @"PCHorizontalPageDidDownloadNotification";
NSString * const PCHorizontalTocDidDownloadNotification = @"PCHorizontalTocDidDownloadNotification";


@interface PCRevision ()
{
	PCRevisionDownloadSuccessBlock _successBlock;
	PCRevisionDownloadProgressBlock _progressBlock;
}


- (void)clearData; // << clear pages, horizontalPages, etc.
- (void)initFromDatabase;
- (void)downloadStartVideo:(PCRevisionDownloadSuccessBlock)successCallback failed:(PCRevisionDownloadFailedBlock) failedCallback canceled:(PCRevisionDownloadCanceledBlock) canceledCallback progress:(PCRevisionDownloadProgressBlock) progressCallback;

@end

@implementation PCRevision

@synthesize backEndURL = _backEndURL;
@synthesize contentDirectory = _contentDirectory;
@synthesize issue = _issue;
@synthesize identifier = _identifier;
@synthesize title = _title;
@synthesize createDate = _createDate;
@synthesize updateDate = _updateDate;
@synthesize state = _state; 
@synthesize coverImageListURL = _coverImageListURL;
@synthesize toc = _toc;
@synthesize horizontalToc = _horizontalToc;
@synthesize pages = _pages;
@synthesize horizontalMode = _horizontalMode;
@synthesize horizontalOrientation = _horizontalOrientation;
@synthesize horizontalPages = _horizontalPages;
@synthesize horisontalTocItems = _horisontalTocItems;
@synthesize horisontalPagesObjects=_horisontalPagesObjects;
@synthesize helpPages = _helpPages;
@synthesize columns = _columns;
@synthesize horizontalHelpProgress=_horizontalHelpProgress;
@synthesize verticalHelpProgress=_verticalHelpProgress;
@synthesize isVerticalHelpComplete=_isVerticalHelpComplete;
@synthesize isHorizontalHelpComplete=_isHorizontalHelpComplete;
@synthesize progressDelegate=_progressDelegate;
@synthesize downloadOperation = _downloadOperation;
@synthesize color = _color;
@synthesize startVideo = _startVideo;
@synthesize downloadStartVideoOperation = _downloadStartVideoOperation;
@synthesize newHorizontalPages=_newHorizontalPages;
@synthesize alternativeCoverPage=_alternativeCoverPage;
@synthesize pageDictionary=_pageDictionary;
@dynamic verticalTocLoaded;
@dynamic horizontalTocLoaded;
@dynamic validVerticalTocItems;
@dynamic validHorizontalTocItems;

- (void)dealloc
{
    self.backEndURL = nil;
	self.horisontalPagesObjects = nil;
    self.horizontalPages = nil;
    self.helpPages = nil;
    self.coverImageListURL = nil;
    self.title = nil;
    self.pages = nil;
    self.toc = nil;
    self.horizontalToc = nil;
    self.columns = nil;
    self.horisontalTocItems = nil;
    self.downloadOperation = nil;
    self.downloadStartVideoOperation = nil;
    self.color = nil;
    self.startVideo = nil;
	self.newHorizontalPages = nil;
	self.alternativeCoverPage = nil;
	self.pageDictionary = nil;
	[_successBlock release];
	[_progressBlock release];
    [super dealloc];
}

- (id)initWithParameters:(NSDictionary *)parameters 
           rootDirectory:(NSString *)rootDirectory
              backEndURL:(NSURL *)backEndURL
{
    if (parameters == nil) {
        return nil;
    }

    self = [super init];

    if (self)
    {
        _toc = [[NSMutableArray alloc] init];
        _horizontalToc = [[NSMutableArray alloc] init];
        _pages = [[NSMutableArray alloc] init];
        _horizontalPages = [[NSMutableDictionary alloc] init];
        _horisontalPagesObjects = [[NSMutableDictionary alloc] init];
        _horisontalTocItems = [[NSMutableDictionary alloc] init];
		_newHorizontalPages = [[NSMutableArray alloc] init];
        _columns = [[NSMutableArray alloc] init];
        self.helpPages = [parameters objectForKey:PCJSONIssueHelpPagesKey];
        _horizontalMode = NO;
        
        if (backEndURL != nil) {
            _backEndURL = [backEndURL retain];
        } else {
            _backEndURL = [PCConfig serverURL];
        }
        
        NSString *identifierString = [parameters objectForKey:PCJSONRevisionIDKey];
        
        _identifier = [identifierString integerValue];
        _contentDirectory = [[rootDirectory stringByAppendingPathComponent:
                              [NSString stringWithFormat:@"%@-%@", PCRevisionDirectoryPrefix, identifierString]] copy];
        
        [PCPathHelper createDirectoryIfNotExists:_contentDirectory];
        
        _title = [[parameters objectForKey:PCJSONRevisionTitleKey] copy];

        id coverImageListURLObject = [parameters objectForKey:PCJSONRevisionRevisionCoverImageListKey];
        
        if ([coverImageListURLObject isKindOfClass:[NSString class]])
        {
            _coverImageListURL = [[NSURL URLWithString:coverImageListURLObject] copy];
        }
        
        NSString *issueColor = [parameters objectForKey:PCJSONIssueColorKey];
        if (![issueColor isKindOfClass:[NSNull class]])
        {
            _color = [[UIColor colorWithHexString:issueColor] retain];
        }
        
        NSString *horizontalModeValue = [parameters objectForKey:PCJSONIssueHorizontalMode];
        if (horizontalModeValue != nil && ![horizontalModeValue isEqualToString:@"none"])
        {
            _horizontalMode = YES;
        }
        
        NSString *video = [parameters objectForKey:PCJSONRevisionStartVideoKey];
        if (video != nil && ![video isEqualToString:@""])
        {
            _startVideo = [video copy];
        }

        NSString *stateString = [parameters objectForKey:PCJSONRevisionStateKey];
        if (stateString != nil)
        {
            if ([stateString isEqualToString:PCJSONIssueWorkInProgressStateValue])
            {
                _state = PCRevisionStateWorkInProgress;   
            }
            
            else if ([stateString isEqualToString:PCJSONIssuePublishedStateValue])
            {
                _state = PCRevisionStatePublished;
            }
            
            else if ([stateString isEqualToString:PCJSONIssueArchivedStateValue])
            {
                _state = PCRevisionStateArchived;   
            }
            
            else if ([stateString isEqualToString:PCJSONIssueForReviewStateValue])
            {
                _state = PCRevisionStateForReview;
            }
        }
        
        _horizontalOrientation = NO;
        NSString *orientationString = [parameters objectForKey:PCJSONRevisionOrientationKey];
        if(orientationString != nil)
        {
            if([orientationString isEqualToString:@"horizontal"])
            {
                _horizontalOrientation = YES;
            }
        }
               
        _isHorizontalHelpComplete = YES;
		_isVerticalHelpComplete = YES;
        
        [self initFromDatabase];
		
    }
    
    return self;
}

- (id)initWithParameters:(NSDictionary *)parameters 
           rootDirectory:(NSString *)rootDirectory
{
    return [self initWithParameters:parameters 
                      rootDirectory:rootDirectory 
                         backEndURL:nil];
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [self initFromDatabase];
    }
    
    return self;
}

- (void)downloadDatabase
{
    NSString *databasePath = [self.contentDirectory stringByAppendingPathComponent:PCRevisionDatabaseFileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:databasePath])
    {
        NSString *serverURLString = _backEndURL != nil ? _backEndURL.absoluteString : [PCConfig serverURLString] ;
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@%d", 
                                           serverURLString, PCRevisionExportPath, self.identifier]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSData *data = [NSURLConnection sendSynchronousRequest:request 
                                             returningResponse:nil error:nil];
        
        NSString *filePath = [self.contentDirectory stringByAppendingPathComponent:PCRevisionDatabaseArchiveFileName];
        [data writeToFile:filePath atomically:YES];
        
        ZipArchive *zipArchive = [[ZipArchive alloc] init];
        BOOL openFileResult = [zipArchive UnzipOpenFile:filePath];
        
        if (openFileResult)
        {
            [zipArchive UnzipFileTo:self.contentDirectory overWrite:YES];
            [zipArchive UnzipCloseFile];
        }
        
        [zipArchive release];
    }
    
    [PCSQLLiteModelBuilder addPagesFromSQLiteBaseWithPath:databasePath toRevision:self];
}


- (UIImage *)coverImage
{
    NSString *coverImagePath = [self.contentDirectory stringByAppendingPathComponent:PCRevisionCoverImageFileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:coverImagePath])
    {
        return [UIImage imageWithContentsOfFile:coverImagePath];
    }
    else if (_coverImageListURL != nil)
    {
        NSURL *serverURL = _backEndURL != nil ? _backEndURL : [PCConfig serverURL] ;
        
        NSURL *fullCoverImageURL = [NSURL URLWithString:_coverImageListURL.absoluteString 
                                          relativeToURL:serverURL];
        
        NSData *imageData = [NSData dataWithContentsOfURL:fullCoverImageURL];
        UIImage *image = [UIImage imageWithData:imageData];
        
        if (image != nil)
        {
            [PCPathHelper createDirectoryIfNotExists:self.contentDirectory];

            [imageData writeToFile:coverImagePath atomically:YES];

            return [UIImage imageWithContentsOfFile:coverImagePath];
        }
    }
    
    return [UIImage imageNamed:PCRevisionCoverImagePlaceholderName];
}

- (void)deleteContent
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *revisionContent = [fileManager contentsOfDirectoryAtPath:self.contentDirectory error:nil];
    
    for (NSString *path in revisionContent)
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:[self.contentDirectory stringByAppendingPathComponent:path] error:&error];
    
        if (error != nil)
        {
            NSLog(@"ERROR ([PCRevision deleteContent]): %@", error.localizedDescription);
        }
    }
    [self clearData];
}

- (void)download:(PCRevisionDownloadSuccessBlock)successCallback failed:(PCRevisionDownloadFailedBlock) failedCallback canceled:(PCRevisionDownloadCanceledBlock) canceledCallback progress:(PCRevisionDownloadProgressBlock) progressCallback
{
    if (self.downloadOperation) {
        return;
    }

    NSString *serverURLString = _backEndURL != nil ? _backEndURL.absoluteString : [PCConfig serverURLString] ;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@%d", 
                                       serverURLString, PCRevisionExportPath, self.identifier]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
   
    AFHTTPRequestOperation      *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    self.downloadOperation = operation;
    
    [PCPathHelper createDirectoryIfNotExists:self.contentDirectory];

    NSString *filePath = [self.contentDirectory stringByAppendingPathComponent:PCRevisionDatabaseArchiveFileName];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];

    [operation setDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float       total = self.downloadOperation.response.expectedContentLength;
        
        if(total>0)
        {
            float       progress;
            
            if (self.startVideo && ![self.startVideo isEqualToString:@""])
            {
                progress = ((float)totalBytesRead)*0.1 / total;
            } else {
                progress = (float)totalBytesRead / total;
            }
            
            if(progressCallback)progressCallback(progress);
        }
    }];
    
    [operation setCompletionBlock:^{
        if([operation isCancelled])
        {
            if(canceledCallback)canceledCallback();
        } else {
            if([operation error])
            {
                if(failedCallback)failedCallback([operation error]);
            } else {
                ZipArchive *zipArchive = [[ZipArchive alloc] init];
                BOOL openFileResult = [zipArchive UnzipOpenFile:filePath];
                
                if (openFileResult)
                {
                    [zipArchive UnzipFileTo:self.contentDirectory overWrite:YES];
                    [zipArchive UnzipCloseFile];
                }
                
                [zipArchive release];
                
                [self downloadStartVideo:successCallback
                                  failed:failedCallback
                                canceled:canceledCallback
                                progress:progressCallback];
            }
        }
        self.downloadOperation = nil;
    }];
    
    [operation start];
}

- (void)downloadStartVideo:(PCRevisionDownloadSuccessBlock)successCallback failed:(PCRevisionDownloadFailedBlock) failedCallback canceled:(PCRevisionDownloadCanceledBlock) canceledCallback progress:(PCRevisionDownloadProgressBlock) progressCallback;
{
    if (self.startVideo && ![self.startVideo isEqualToString:@""])
    {
        NSString *serverURLString = _backEndURL != nil ? _backEndURL.absoluteString : [PCConfig serverURLString] ;

        NSString *videoURL = [serverURLString stringByAppendingString:self.startVideo];
        NSURL *url = [NSURL URLWithString:videoURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        self.downloadStartVideoOperation = operation;
        
        NSString *videoPath = [videoURL stringByReplacingOccurrencesOfString:[serverURLString stringByAppendingString:PCPadCMSResourseURLPart] withString:self.contentDirectory];
        NSLog(@"videPAth - %@", videoPath);
        NSString* directoryPath = [videoPath stringByDeletingLastPathComponent];
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
        if (![[NSFileManager defaultManager] createFileAtPath:videoPath  contents:nil attributes:nil]) 
        {
            NSLog(@"Error was code: %d - message: %s", errno, strerror(errno));
        }

        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:videoPath append:NO];
        [operation setDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            float       total = operation.response.expectedContentLength;
            
            if(total>0)
            {
                float progress = 0.1+((float)totalBytesRead)*0.6 / total;
                if(progressCallback)progressCallback(progress);
            }
        }];

        [operation setCompletionBlock:^{
            if([operation isCancelled])
            {
                if(canceledCallback)canceledCallback();
            } else {
                if([operation error])
                {
                    if(failedCallback)failedCallback([operation error]);
                } else {
                    
                    [self initFromDatabase];
					
					if (self.coverPage)
					{
						[PCDownloadManager sharedManager].revision = self;
						if ([[PCDownloadManager sharedManager] prepareForDownloading])
						{
							[self.coverPage addObserver:self forKeyPath:@"isComplete" options:NSKeyValueObservingOptionNew context:NULL];
							_successBlock = [successCallback retain];
							_progressBlock = [progressCallback retain];
							PCPageElement* element = [self.coverPage firstElementForType:PCPageElementTypeBody];
							element.progressDelegate = self;
							[[PCDownloadManager sharedManager] launchCoverPageDownloading];
						}
					//	[PCDownloadManager sharedManager].revision = nil;
						
					}
					else {
						[PCGoogleAnalytics trackAction:[NSString stringWithFormat:@"Revision %d has been downloaded", self.identifier] 
											  category:@"ContentLoading"];
						
						if(successCallback)successCallback();
					}
                }
            }
            self.downloadStartVideoOperation = nil;
        }];
        
        [operation start];
    }
    else
    {
        [self initFromDatabase];
        
		if (self.coverPage)
		{
			[PCDownloadManager sharedManager].revision = self;
			if ([[PCDownloadManager sharedManager] prepareForDownloading])
			{
				[self.coverPage addObserver:self forKeyPath:@"isComplete" options:NSKeyValueObservingOptionNew context:NULL];
				_successBlock = [successCallback retain];
				_progressBlock = [progressCallback retain];
				PCPageElement* element = [self.coverPage firstElementForType:PCPageElementTypeBody];
				element.progressDelegate = self;
				[[PCDownloadManager sharedManager] launchCoverPageDownloading];
			}
			

		}
		else {
			[PCGoogleAnalytics trackAction:[NSString stringWithFormat:@"Revision %d has been downloaded", self.identifier] 
								  category:@"ContentLoading"];
			
			if(successCallback)successCallback();
		}
		
        
    }
}



-(void) observeValueForKeyPath: (NSString *)keyPath ofObject: (id) object
                        change: (NSDictionary *) change context: (void *) context
{
	if([change objectForKey:NSKeyValueChangeNewKey] != [NSNull null]) 
	{
		BOOL newValue = [[change objectForKey: NSKeyValueChangeNewKey] boolValue];
		if (newValue)
		{
			[PCGoogleAnalytics trackAction:[NSString stringWithFormat:@"Revision %d has been downloaded", self.identifier] 
								  category:@"ContentLoading"];
			
			if(_successBlock)
			{
				_successBlock();
			}
			[self.coverPage removeObserver:self forKeyPath:@"isComplete"];
			PCPageElement* element = [self.coverPage firstElementForType:PCPageElementTypeBody];
			element.progressDelegate = nil;
			[PCDownloadManager sharedManager].revision = nil;
		}
	}
}

-(void)setProgress:(float)progress
{
	//NSLog(@"progress");
	if(_progressBlock)_progressBlock(0.7 + progress * 0.3);
}


- (void)cancelDownloading
{
    if(self.downloadOperation)
    {
        [self.downloadOperation cancel];
    }
    
    if(self.downloadStartVideoOperation)
    {
        [self.downloadStartVideoOperation cancel];
    }
}

- (BOOL)isDownloaded
{
    NSString *databasePath = [self.contentDirectory stringByAppendingPathComponent:PCRevisionDatabaseFileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:databasePath])
    {
        NSError *error = nil;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager]
										attributesOfItemAtPath:databasePath
										error:&error];
        if (error != nil)
        {
            NSLog(@"ERROR ([PCRevision isDownloaded]): %@", error.localizedDescription);
        } else {
            NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
            long long fileSize = [fileSizeNumber longLongValue];
            
            if(fileSize > 0)
            {
                return YES;
            }
        }

    }
    return NO;
}

- (void)clearData
{
    [self.pages removeAllObjects];
    [self.horizontalPages removeAllObjects];
    [[self toc] removeAllObjects];
    [self.columns removeAllObjects];
}

- (void)initFromDatabase
{
    if([self isDownloaded])
    {
        NSString *databasePath = [self.contentDirectory stringByAppendingPathComponent:PCRevisionDatabaseFileName];

        [PCSQLLiteModelBuilder addPagesFromSQLiteBaseWithPath:databasePath toRevision:self];
    }
}

- (void)updateColumns
{
    [self.columns removeAllObjects];
    
    NSMutableArray *pagesForColumn = [[NSMutableArray alloc] init];
    PCPage *firstColumnPage = [self coverPage];
    while (firstColumnPage != nil)
    {
        [pagesForColumn removeAllObjects];
    
        PCPage *nextPage = firstColumnPage;
        while (nextPage != nil)
        {
            if ([firstColumnPage color] != nil)
            {
                [nextPage setColor:[firstColumnPage color]];
            }
            
            [pagesForColumn addObject:nextPage];
            id bottomLink = [nextPage linkForConnector:PCTemplateBottomConnector];
            nextPage = [self pageForLink:bottomLink];
        }
        
        PCColumn *column = [[PCColumn alloc] initWithPages:[[pagesForColumn copy] autorelease]];
        
        for (PCPage *page in pagesForColumn)
        {
            [page setColumn:column];
        }
        
        [firstColumnPage setColumn:column];
        [_columns addObject:column];
        [column release];
        
        id rightLink = [firstColumnPage linkForConnector:PCTemplateRightConnector];
        firstColumnPage = [self pageForLink:rightLink];
    }
    
    [pagesForColumn release];
}

- (PCPage *)pageWithId:(NSInteger)identifier
{
    if (identifier <= 0) return nil;
    
    /*NSArray *findedPages = [self.pages filteredArrayUsingPredicate:
                            [NSPredicate predicateWithFormat:@"identifier = %d", identifier]];
    
    if ([findedPages count] > 0)
    {
        return [findedPages objectAtIndex:0];
    }
    
    return nil;*/
	return [_pageDictionary objectForKey:[NSNumber numberWithInteger:identifier]];
}

- (PCPage *)pageForLink:(id)link
{
    if (link == nil) return nil;
    
    return [self pageWithId:[link integerValue]];
}

- (PCPage *)pageWithMachineName:(NSString *)machineName
{
    if (machineName == nil || [machineName length] == 0) return nil;
    
    NSArray *findedPages = [self.pages filteredArrayUsingPredicate:
                            [NSPredicate predicateWithFormat:@"machineName = %@", machineName]];
    
    if ([findedPages count] > 0)
    {
        return [findedPages objectAtIndex:0];
    }
    
    return nil;
}

- (PCPage *)coverPage
{
    NSArray *findedPages = [self.pages filteredArrayUsingPredicate:
                            [NSPredicate predicateWithFormat:@"pageTemplate.identifier==%d",PCCoverPageTemplate]];
    
    if ([findedPages count] > 0)
    {
        return [findedPages objectAtIndex:0];
    }
    
    return nil;
}

-(void)setHorizontalHelpProgress:(float)horizontalHelpProgress
{
	
	_horizontalHelpProgress = horizontalHelpProgress;
	
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (!(orientation == UIInterfaceOrientationPortrait) && !(orientation == UIInterfaceOrientationPortraitUpsideDown))
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.progressDelegate setProgress:horizontalHelpProgress];
		});
	}
	
	
}

-(void)setVerticalHelpProgress:(float)verticalHelpProgress
{
	_verticalHelpProgress = verticalHelpProgress;
	
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if ((orientation == UIInterfaceOrientationPortrait) || (orientation == UIInterfaceOrientationPortraitUpsideDown))
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.progressDelegate setProgress:verticalHelpProgress];
		});
	}
	
}

- (BOOL)supportsInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (!self.horizontalOrientation && !self.horizontalMode) {
        // vertical(portrait) only revision
        return !UIDeviceOrientationIsLandscape(interfaceOrientation);
        
    } else if (self.horizontalOrientation && !self.horizontalMode) {
        // horizontal(landscape) only revision
        return !UIDeviceOrientationIsPortrait(interfaceOrientation);
        
    } else if (!self.horizontalOrientation && self.horizontalMode) {
        // vertical and horizontal revision
        return YES;
    }
    
    return NO;
}

- (BOOL)verticalTocLoaded
{
    NSFileManager *defaultFileManager = [NSFileManager defaultManager];
    NSArray *verticalToc = [[_toc copy] autorelease];
    for (PCTocItem* tocItem in verticalToc) {
        
        NSString *thumbStripe = tocItem.thumbStripe;
        if (thumbStripe != nil) {
            NSString *imagePath = [_contentDirectory stringByAppendingPathComponent:thumbStripe];
            if (![defaultFileManager fileExistsAtPath:imagePath]) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL)horizontalTocLoaded
{
    NSFileManager *defaultFileManager = [NSFileManager defaultManager];
    NSArray *horizontalToc = [[_horizontalToc copy] autorelease];
    for (PCTocItem* tocItem in horizontalToc) {
        
        NSString *thumbStripe = tocItem.thumbStripe;
        if (thumbStripe != nil) {
            NSString *imagePath = [_contentDirectory stringByAppendingPathComponent:thumbStripe];
            if (![defaultFileManager fileExistsAtPath:imagePath]) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (NSArray *)validVerticalTocItems
{
    NSMutableArray *validTocItems = [[[NSMutableArray alloc] init] autorelease];
    NSFileManager *defaultFileManager = [NSFileManager defaultManager];
    
    NSArray *verticalTocItems = [_toc copy];
    for (PCTocItem *tocItem in verticalTocItems) {
        
        // toc item thumb image should exist
        NSString *imagePath = [_contentDirectory stringByAppendingPathComponent:tocItem.thumbStripe];
        if (![defaultFileManager fileExistsAtPath:imagePath]) {
            continue;
        }
        
        // toc item page reference should refer to existing page
        BOOL refersToExistingPage = NO;
        for (PCPage *page in _pages) {
            if (page.identifier == tocItem.firstPageIdentifier) {
                refersToExistingPage = YES;
            }
        }
        
        if (!refersToExistingPage) {
            continue;
        }
        
        [validTocItems addObject:tocItem];
    }
    [verticalTocItems release];
    
    return validTocItems;
}

- (NSArray *)validHorizontalTocItems
{
    NSMutableArray *validTocItems = [[[NSMutableArray alloc] init] autorelease];
    NSFileManager *defaultFileManager = [NSFileManager defaultManager];
    
    NSArray *horizontalTocItems = [_horizontalToc copy];
    for (PCTocItem *tocItem in horizontalTocItems) {
        
        // toc item thumb image should exist
        NSString *imagePath = [_contentDirectory stringByAppendingPathComponent:tocItem.thumbStripe];
        
        BOOL directory = NO;
        if (![defaultFileManager fileExistsAtPath:imagePath isDirectory:&directory] || directory) {
            continue;
        }
        
        // toc item page reference shoul refer to existign page
        if (![[_horizontalPages allKeys] containsObject:[NSNumber numberWithInt:tocItem.firstPageIdentifier]]) {
            continue;
        }
        
        [validTocItems addObject:tocItem];
    }
    [horizontalTocItems release];
    
    return validTocItems;
}

- (NSString *)description
{
    return [NSString stringWithFormat:
            @"PCRevision: %@\r"
            "identifier: %d\r"
            "title: %@\r"
            "contentDirectory: %@\r"
            "createDate: %@\r"
            "updateDate: %@\r"
            "state: %d\r"
            "coverImageListURL: %@\r"
            "toc: %@\r"
            "pages: %@\r"
            "horizontalMode: %d\r"
            "horizontalPages: %@\r"
            "helpPages: %@\r"
            "columns: %@\r",
            [super description],
            self.identifier,
            self.title,
            self.contentDirectory,
            self.createDate,
            self.updateDate,
            self.state,
            self.coverImageListURL,
            self.toc,
            self.pages,
            self.horizontalMode,
            self.horizontalPages,
            self.helpPages,
            self.columns];
}

@end
