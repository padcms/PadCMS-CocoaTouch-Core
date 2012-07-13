//
//  PCElement.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 02.02.12.
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

#import "PCPageElement.h"
#import "PCDownloadProgressProtocol.h"
#import "PCPage.h"

NSString * const PCGalleryElementDidDownloadNotification = @"PCGalleryElementDidDownloadNotification";

@implementation PCPageElement

@synthesize resource;
@synthesize identifier;
@synthesize fieldTypeName;
@synthesize weight;
@synthesize contentText;
@synthesize dataRects;
@synthesize activeZones;
@synthesize size;
@synthesize isComplete;
@synthesize downloadProgress=_downloadProgress;
@synthesize progressDelegate=_progressDelegate;
@synthesize page=_page;
@synthesize elementContentSize=_elementContentSize;
@synthesize isCropped=_isCropped;

- (void)dealloc
{
    _page = nil; 
    _progressDelegate = nil;
    [dataRects release];
    [fieldTypeName release];
    fieldTypeName = nil;
    [resource release];
    resource = nil;
    [activeZones release], activeZones = nil;
    [super dealloc];
}

- (id)init
{
    if (self = [super init])
    {
        size = CGSizeZero;
        identifier = -1;
        fieldTypeName = nil;
        resource = nil;
        weight = -1;
        contentText = nil;
        dataRects = nil;
        activeZones = [[NSMutableArray alloc] init];
        isComplete = YES;
		_isCropped = NO;
    }
    return self;
}

- (void)pushElementData:(NSDictionary*)data
{
    self.resource = [data objectForKey:PCSQLiteElementResourceAttributeName];
    if ([data objectForKey:PCSQLiteElementHeightAttributeName])
        size.height = [[data objectForKey:PCSQLiteElementHeightAttributeName] floatValue];
    
    if ([data objectForKey:PCSQLiteElementWidthAttributeName])
        size.width = [[data objectForKey:PCSQLiteElementWidthAttributeName] floatValue];
}

- (CGRect)rectForElementType:(NSString*)elementType;
{
    NSString* stringRect = [self.dataRects objectForKey:elementType];
    if (stringRect!=nil)
        return CGRectFromString(stringRect);
    return CGRectZero;
}

- (NSString*)description
{
    NSString* description = NSStringFromClass([self class]);
    description = [description stringByAppendingString:@"\r"];
    description = [description stringByAppendingFormat:@"identifier = %d\r",self.identifier];
    if (self.weight>=0)
    {
        description = [description stringByAppendingFormat:@"weight = %d\r",self.weight];
    }
    if (self.fieldTypeName)
    {
        description = [description stringByAppendingString:@"type = "];
        description = [description stringByAppendingString:self.fieldTypeName.description];
        description = [description stringByAppendingString:@"\r"];
    }
    if (self.resource)
    {
        description = [description stringByAppendingString:@"resource = "];
        description = [description stringByAppendingString:self.resource.description];
        description = [description stringByAppendingString:@"\r"];
    }

    if (self.contentText)
    {
        description = [description stringByAppendingString:@"contentText = "];
        description = [description stringByAppendingString:self.contentText];
        description = [description stringByAppendingString:@"\r"];
    }
    
    if (self.dataRects)
    {
        description = [description stringByAppendingString:@"dataRects = "];
        description = [description stringByAppendingString:self.dataRects.description];
        description = [description stringByAppendingString:@"\r"];
    }
    
    
    return description;
}

-(void)setDownloadProgress:(float)downloadProgress
{
  _downloadProgress = downloadProgress;
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.progressDelegate setProgress:downloadProgress];
  });
  
}

@end
