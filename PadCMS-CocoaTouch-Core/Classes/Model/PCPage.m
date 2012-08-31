//
//  PCPage.m
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

#import "PCPage.h"
#import "PCPageTemplatesPool.h"
#import "PCPageElement.h"
#import "PCDownloadProgressProtocol.h"
#import "PCPageElementMiniArticle.h"
#import "PCPageActiveZone.h"
//#import "PCPageTemplate.h"

NSString* endOfDownloadingPageNotification   = @"endOfDownloadingPageNotification";
NSString* const PCBoostPageNotification = @"PCBoostPageNotification";
NSString * const PCMiniArticleElementDidDownloadNotification = @"PCMiniArticleElementDidDownloadNotification";

@interface NSMutableArray (elementForType)
- (void) addIfNotNilFromArray:(NSArray*)array;
- (void) addFromArray:(NSArray*)array started:(NSInteger)aStartElement;
- (void) addIfNotNilFromObject:(PCPageElement*)object;
@end

@implementation NSMutableArray (elementForType)
- (void) addIfNotNilFromArray:(NSArray*)array{
    if(array && [array count])
        [self addObjectsFromArray:array];
}
- (void) addFromArray:(NSArray*)array started:(NSInteger)aStartElement{
    if(array && ([array count]>aStartElement))
        [self addObjectsFromArray:[array objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(aStartElement, [array count]-aStartElement)]]];
}
- (void) addIfNotNilFromObject:(PCPageElement*)object{
    if(object)
        [self addObject:object];
}
@end

@implementation PCPage

@synthesize revision = _revision;
@synthesize column;
@synthesize identifier;
@synthesize title;
@synthesize pageTemplate;
@synthesize machineName;
@synthesize horisontalPageIdentifier;
@synthesize elements;
@synthesize links;
@synthesize color;
@synthesize isComplete;
@synthesize primaryProgress=_primaryProgress;
@synthesize progressDelegate=_progressDelegate;
@synthesize primaryElements=_primaryElements;
@synthesize secondaryElements=_secondaryElements;
@synthesize repeatingTimer=_repeatingTimer;
@synthesize isUpdateProgress=_isUpdateProgress;
@synthesize isHorizontal=_isHorizontal;
@synthesize backgroundColor=_backgroundColor;
@synthesize onRotatePage=_onRotatePage;

- (void)dealloc
{
    self.revision = nil;
    [color release];
    [title release];
    [pageTemplate release];
    [machineName release];
    [elements release];
    [links release];
    _progressDelegate = nil;
    [_primaryElements release], _primaryElements = nil;
    [_secondaryElements release], _secondaryElements = nil;
	[_backgroundColor release], _backgroundColor = nil;
	_onRotatePage = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        identifier = -1;
        horisontalPageIdentifier = -1;
        
        elements = [[NSMutableArray alloc] init];
        links = [[NSMutableDictionary alloc] init];
        isComplete = YES;
		_isUpdateProgress = NO;
		_isSecondaryElementComplete = NO;
		_isHorizontal = NO;
        
    }
    return self;
}

- (id)linkForConnector:(PCPageTemplateConnectorOptions)aConnector
{
    return [links objectForKey:[NSNumber numberWithInt:aConnector]];
}

- (NSArray*)elementsForType:(NSString*)elementType
{
    if (elements == nil || [elements count] == 0)
        return nil;
	NSArray* result = [elements filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"fieldTypeName == %@",elementType]];
	result = [result sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"weight" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES],nil]];
	
    return result;
}

- (PCPageElement*)firstElementForType:(NSString*)elementType
{
    NSArray* elementsForType = [self elementsForType:elementType];
    if (elementsForType != nil && [elementsForType count] > 0)
    {
        return [elementsForType objectAtIndex:0];
    }
    return nil;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ identifier = %d", [super description], identifier];
    
    NSString* discription = NSStringFromClass(self.class);
    discription = [discription stringByAppendingString:@"\r"];
    
    discription = [discription stringByAppendingFormat:@"id = %d\r",self.identifier];
    
    if (self.title)
    {
        discription = [discription stringByAppendingString:@"title = "];
        discription = [discription stringByAppendingString:self.title.description];
        discription = [discription stringByAppendingString:@"\r"];
    }
    
    if (self.pageTemplate)
    {
        discription = [discription stringByAppendingString:@"pageTemplate = "];
        discription = [discription stringByAppendingString:self.pageTemplate.title.description];
        discription = [discription stringByAppendingString:@"\r"];
    }
    
    if (self.machineName)
    {
        discription = [discription stringByAppendingString:@"machineName = "];
        discription = [discription stringByAppendingString:self.machineName.description];
        discription = [discription stringByAppendingString:@"\r"];
    }
    
    discription = [discription stringByAppendingFormat:@"horisontalPageIdentifier = %d\r",self.horisontalPageIdentifier];
    
    if (self.color)
    {
        discription = [discription stringByAppendingString:@"color = "];
        discription = [discription stringByAppendingString:self.color.description];
        discription = [discription stringByAppendingString:@"\r"];
    }
    
    if (self.links && [self.links count]>0)
    {
        discription = [discription stringByAppendingString:@"links = "];
        discription = [discription stringByAppendingString:self.links.description];
        discription = [discription stringByAppendingString:@"\r"];
    }
    
    if (self.elements && [self.elements count]>0)
    {
        discription = [discription stringByAppendingString:@"elements = {"];
        
        for (PCPageElement* element in self.elements)
        {
            discription = [discription stringByAppendingString:element.description];
            discription = [discription stringByAppendingString:@"\r"];
        }
        discription = [discription stringByAppendingString:@"\r}\r"];
        
    }
    
    return discription;
}


- (BOOL) hasPageActiveZonesOfType: (NSString*)zoneType
{
    for (PCPageElement* element in self.elements)
    {
        for (PCPageActiveZone* pdfActiveZone in element.activeZones)
        {
            if ([pdfActiveZone.URL hasPrefix:zoneType])
            {
                return YES;
            }
            
        }
    }
    return NO;
}

- (void)startRepeatingTimer
{
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                      target:self selector:@selector(updateProgress:)
                                                    userInfo:nil repeats:YES];
    self.repeatingTimer = timer;
}

- (void)stopRepeatingTimer
{
    [_repeatingTimer invalidate];
    self.repeatingTimer = nil;
}

-(void)updateProgress:(NSTimer*)theTimer
{
    if (!_isUpdateProgress) return;
    NSUInteger count = [self.primaryElements count];
    BOOL isMiniArticleMet = NO;
    float accumulatedProgress = 0.0f;
    for (PCPageElement* element in self.primaryElements) {
        
        if ([element isKindOfClass:[PCPageElementMiniArticle class]]) {
            if (!isMiniArticleMet) accumulatedProgress+=element.downloadProgress;
            isMiniArticleMet = YES;
            PCPageElementMiniArticle* miniArticle = (PCPageElementMiniArticle*)element;
            accumulatedProgress+=miniArticle.thumbnailProgress;
            accumulatedProgress+=miniArticle.thumbnailSelectedProgress;
        }
        else {
            accumulatedProgress+=element.downloadProgress;
        }
        
    }
    _primaryProgress = accumulatedProgress/(float)count;
    //  NSLog(@"Primary progress for page %d - %f",self.identifier, _primaryProgress);
    if (_progressDelegate != nil) {
        [_progressDelegate setProgress:_primaryProgress];
    }
}


-(NSArray *)primaryElements
{
    if (_primaryElements) return _primaryElements;
    NSMutableArray* array = [[NSMutableArray alloc] init];
    switch (self.pageTemplate.identifier) {
        case PCCoverPageTemplate:
            [array addIfNotNilFromObject: [self firstElementForType:PCPageElementTypeBackground]];
            [array addIfNotNilFromObject: [self firstElementForType:PCPageElementTypeBody]];
            [array addIfNotNilFromObject: [self firstElementForType:PCPageElementTypeAdvert]];
            break;
        case PCSimplePageTemplate:
            [array addIfNotNilFromObject: [self firstElementForType:PCPageElementTypeBody]];
            break;
        case PCBasicArticlePageTemplate:
            [array addIfNotNilFromObject: [self firstElementForType:PCPageElementTypeBody]];
            break;
        case PCScrollingPageTemplate:
        case PCHorizontalScrollingPageTemplate:
            [array addIfNotNilFromObject: [self firstElementForType:PCPageElementTypeBackground]];
            [array addIfNotNilFromObject: [self firstElementForType:PCPageElementTypeScrollingPane]];
            break;
        case PCSlideshowPageTemplate:
            [array addIfNotNilFromObject: [self firstElementForType:PCPageElementTypeBackground]];
            [array addIfNotNilFromObject: [self firstElementForType:PCPageElementTypeSlide]];
            break;
        case PCSlidersBasedMiniArticlesTopPageTemplate:
        case PCSlidersBasedMiniArticlesHorizontalPageTemplate:
        case PCSlidersBasedMiniArticlesVerticalPageTemplate:
            [array addIfNotNilFromObject: [self firstElementForType:PCPageElementTypeBackground]];
            [array addIfNotNilFromArray: [self elementsForType:PCPageElementTypeMiniArticle]];
            break;
        case PCGalleryFlashBulletInteractivePageTemplate:
            [array addIfNotNilFromObject: [self firstElementForType:PCPageElementTypeBackground]];
            [array addIfNotNilFromObject: [self firstElementForType:PCPageElementTypeScrollingPane]];
            break;
        case PCFixedIllustrationArticleTouchablePageTemplate:
            [array addIfNotNilFromObject: [self firstElementForType:PCPageElementTypeBackground]];
            [array addIfNotNilFromObject: [self firstElementForType:PCPageElementTypeBody]];
            break;
        case PCInteractiveBulletsPageTemplate:
            [array addIfNotNilFromObject: [self firstElementForType:PCPageElementTypeBackground]];
            [array addIfNotNilFromArray: [self elementsForType:PCPageElementTypeMiniArticle]];
            break;
        case PCHTMLPageTemplate:
            [array addIfNotNilFromObject: [self firstElementForType:PCPageElementTypeBody]];
            [array addIfNotNilFromArray: [self elementsForType:PCPageElementTypeHtml]];
            break;
        case PCHtml5PageTemplate:
            [array addIfNotNilFromArray: [self elementsForType:PCPageElementTypeHtml5]];
            break;
        case PC3DPageTemplate:
            [array addIfNotNilFromObject: [self firstElementForType:PCPageElementTypeBackground]];
            [array addIfNotNilFromObject: [self firstElementForType:PCPageElementType3D]];
            break;
        default:
            break;
    }
    
	
    _primaryElements = [[NSArray alloc] initWithArray:array];
    [array release];
    
    return _primaryElements;
}

-(NSArray *)secondaryElements
{
    if (_secondaryElements) return _secondaryElements;
    NSMutableArray* array = [[NSMutableArray alloc] init];
    
    switch (self.pageTemplate.identifier) {
        case PCCoverPageTemplate:
            break;
        case PCSimplePageTemplate:
            break;
        case PCBasicArticlePageTemplate:
            [array addIfNotNilFromArray: [self elementsForType:PCPageElementTypeGallery]];
            break;
        case PCScrollingPageTemplate:
        case PCHorizontalScrollingPageTemplate:
            [array addIfNotNilFromArray: [self elementsForType:PCPageElementTypeGallery]];
            break;
        case PCSlideshowPageTemplate:
            [array addFromArray:[self elementsForType:PCPageElementTypeSlide] started:1];
            break;
        case PCSlidersBasedMiniArticlesTopPageTemplate:
        case PCSlidersBasedMiniArticlesHorizontalPageTemplate:
        case PCSlidersBasedMiniArticlesVerticalPageTemplate:
            [array addFromArray:[self elementsForType:PCPageElementTypeMiniArticle] started:1];
            break;
        case PCGalleryFlashBulletInteractivePageTemplate:
            [array addIfNotNilFromArray: [self elementsForType:PCPageElementTypeGallery]];
            [array addIfNotNilFromArray: [self elementsForType:PCPageElementTypePopup]];
            break;
        case PCFixedIllustrationArticleTouchablePageTemplate:
            [array addIfNotNilFromArray: [self elementsForType:PCPageElementTypeGallery]];
            [array addIfNotNilFromArray: [self elementsForType:PCPageElementTypePopup]];
            break;
        case PCInteractiveBulletsPageTemplate:
            [array addFromArray:[self elementsForType:PCPageElementTypeMiniArticle] started:1];
            break;
        case PCHTMLPageTemplate:
            break;
        case PCHtml5PageTemplate:
            break;
        case PC3DPageTemplate:
            break;
        default:
            break;
    }
    
    _secondaryElements = [[NSArray alloc] initWithArray:array];
    [array release];
    
    return _secondaryElements;
    
}

-(BOOL)isSecondaryElementsComplete
{
	if (_isSecondaryElementComplete) return YES;
	for (PCPageElement* element in self.secondaryElements) {
		if (!element.isComplete) return NO;
	}
	_isSecondaryElementComplete = YES;
	return YES;
}


-(PCPage *)rightPage
{
	return [self.revision pageForLink:[self.links objectForKey:[NSNumber numberWithInt:PCTemplateRightConnector]]];
}

-(PCPage *)leftPage
{
	NSNumber* leftPageId = [self.links objectForKey:[NSNumber numberWithInt:PCTemplateLeftConnector]];
	PCPage* ressultPage = [self.revision pageForLink:leftPageId];
	return ressultPage;
}

-(PCPage *)bottomPage
{
	return [self.revision pageForLink:[self.links objectForKey:[NSNumber numberWithInt:PCTemplateBottomConnector]]];
}

-(PCPage *)topPage
{
	return [self.revision pageForLink:[self.links objectForKey:[NSNumber numberWithInt:PCTemplateTopConnector]]];
}


@end
