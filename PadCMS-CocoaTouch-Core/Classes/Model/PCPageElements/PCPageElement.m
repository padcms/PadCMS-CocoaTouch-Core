//
//  PCElement.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 02.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
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
