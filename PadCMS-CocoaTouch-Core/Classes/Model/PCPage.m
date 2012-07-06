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

NSString* endOfDownloadingPageNotification   = @"endOfDownloadingPageNotification";
NSString* const PCBoostPageNotification = @"PCBoostPageNotification";

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
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _revision = nil;
        column = nil;
        identifier = -1;
        title = nil;
        pageTemplate = nil;
	
        machineName = nil;
        horisontalPageIdentifier = -1;

        elements = [[NSMutableArray alloc] init];
        links = [[NSMutableDictionary alloc] init];
        color = nil;
        isComplete = YES;
      _isUpdateProgress = NO;
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
    return [elements filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"fieldTypeName == %@",elementType]];
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
  
  if (self.pageTemplate.identifier == PCCoverPageTemplate)
  {
    PCPageElement* background = [self firstElementForType:PCPageElementTypeBackground];
    if (background) [array addObject:background];
    PCPageElement* body = [self firstElementForType:PCPageElementTypeBody];
    if (body) [array addObject:body];
    PCPageElement* advert = [self firstElementForType:PCPageElementTypeAdvert];
    if (advert) [array addObject:advert];
   
  }
  else if (self.pageTemplate.identifier == PCSimplePageTemplate)
  {
    PCPageElement* body = [self firstElementForType:PCPageElementTypeBody];
    if (body) [array addObject:body];
  }
  else if (self.pageTemplate.identifier == PCBasicArticlePageTemplate)
  {
    PCPageElement* body = [self firstElementForType:PCPageElementTypeBody];
    if (body) [array addObject:body];
  }
   else if ((self.pageTemplate.identifier == PCScrollingPageTemplate) || (self.pageTemplate.identifier == PCHorizontalScrollingPageTemplate))
  {
    PCPageElement* background = [self firstElementForType:PCPageElementTypeBackground];
    if (background) [array addObject:background];
    PCPageElement* scrollingPane = [self firstElementForType:PCPageElementTypeScrollingPane];
     if (scrollingPane) [array addObject:scrollingPane];
  }
  else if (self.pageTemplate.identifier == PCSlideshowPageTemplate)
  {
    PCPageElement* background = [self firstElementForType:PCPageElementTypeBackground];
    if (background) [array addObject:background];
    PCPageElement* firstSlide = [self firstElementForType:PCPageElementTypeSlide];
    if (firstSlide) [array addObject:firstSlide];
  }
  else if ((self.pageTemplate.identifier == PCSlidersBasedMiniArticlesTopPageTemplate)||
            (self.pageTemplate.identifier == PCSlidersBasedMiniArticlesHorizontalPageTemplate)||
            (self.pageTemplate.identifier == PCSlidersBasedMiniArticlesVerticalPageTemplate))
  {
    PCPageElement* background = [self firstElementForType:PCPageElementTypeBackground];
    if (background) [array addObject:background];
    NSArray* miniArticles = [self elementsForType:PCPageElementTypeMiniArticle];
    if (miniArticles) [array addObjectsFromArray:miniArticles];
  }
  else if (self.pageTemplate.identifier == PCGalleryFlashBulletInteractivePageTemplate)
  {
	  PCPageElement* background = [self firstElementForType:PCPageElementTypeBackground];
	  if (background) [array addObject:background];
	  PCPageElement* scrollingPane = [self firstElementForType:PCPageElementTypeScrollingPane];
	  if (scrollingPane) [array addObject:scrollingPane];
	  
  }
  else if (self.pageTemplate.identifier == PCFixedIllustrationArticleTouchablePageTemplate)
  {
    PCPageElement* background = [self firstElementForType:PCPageElementTypeBackground];
    if (background) [array addObject:background];
    PCPageElement* body = [self firstElementForType:PCPageElementTypeBody];
    if (body) [array addObject:body];
  }
	else if (self.pageTemplate.identifier == PCInteractiveBulletsPageTemplate)
  {
    PCPageElement* background = [self firstElementForType:PCPageElementTypeBackground];
    if (background) [array addObject:background];
    NSArray* miniArticles = [self elementsForType:PCPageElementTypeMiniArticle];
    if (miniArticles) [array addObjectsFromArray:miniArticles];
  }
  else if (self.pageTemplate.identifier == PCHTMLPageTemplate)
  {
    PCPageElement* body = [self firstElementForType:PCPageElementTypeBody];
    if (body) [array addObject:body];
    NSArray* html = [self elementsForType:PCPageElementTypeHtml];
    if (html) [array addObjectsFromArray:html];

  }
  else if (self.pageTemplate.identifier == PC3DPageTemplate)
  {
      PCPageElement *background = [self firstElementForType:PCPageElementTypeBackground];
      if (background != nil)
      {
          [array addObject:background];   
      }
      
      PCPageElement *graphics = [self firstElementForType:PCPageElementType3D];
      if (graphics != nil)
      {
          [array addObject:graphics];   
      }
  }
	
  _primaryElements = [[NSArray alloc] initWithArray:array];
  [array release];
           
  return _primaryElements;
}

-(NSArray *)secondaryElements
{
  if (_secondaryElements) return _secondaryElements;
  NSMutableArray* array = [[NSMutableArray alloc] init];
  
  if (self.pageTemplate.identifier == PCCoverPageTemplate)
  {
        
  }
  else if (self.pageTemplate.identifier == PCSimplePageTemplate)
  {
   
  }
  else if (self.pageTemplate.identifier == PCBasicArticlePageTemplate)
  {
    NSArray* galleryElements = [self elementsForType:PCPageElementTypeGallery];
    if (galleryElements) [array addObjectsFromArray:galleryElements];
  }
  else if ((self.pageTemplate.identifier == PCScrollingPageTemplate) || (self.pageTemplate.identifier == PCHorizontalScrollingPageTemplate))
  {
    NSArray* galleryElements = [self elementsForType:PCPageElementTypeGallery];
	  if (galleryElements) [array addObjectsFromArray:galleryElements];

  }
  else if (self.pageTemplate.identifier == PCSlideshowPageTemplate)
  {
    NSArray* slides = [self elementsForType:PCPageElementTypeSlide];
    if ([slides count] > 1) [array addObjectsFromArray:[slides objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [slides count]-1)]]];
  }
  else if ((self.pageTemplate.identifier == PCSlidersBasedMiniArticlesTopPageTemplate)||
           (self.pageTemplate.identifier == PCSlidersBasedMiniArticlesHorizontalPageTemplate)||
           (self.pageTemplate.identifier == PCSlidersBasedMiniArticlesVerticalPageTemplate))
  {
    NSArray* miniArticles = [self elementsForType:PCPageElementTypeMiniArticle];
    if (miniArticles) if ([miniArticles count] > 1) [array addObjectsFromArray:[miniArticles objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [miniArticles count]-1)]]];
  }
  else if (self.pageTemplate.identifier == PCGalleryFlashBulletInteractivePageTemplate)
  {
	  NSArray* galleryElements = [self elementsForType:PCPageElementTypeGallery];
	  if (galleryElements) [array addObjectsFromArray:galleryElements];
	  NSArray* popupsElements = [self elementsForType:PCPageElementTypePopup];
	  if (popupsElements) [array addObjectsFromArray:popupsElements];
  }
  else if (self.pageTemplate.identifier == PCFixedIllustrationArticleTouchablePageTemplate)
  {
      NSArray* galleryElements = [self elementsForType:PCPageElementTypeGallery];
      if (galleryElements) [array addObjectsFromArray:galleryElements];
      NSArray* popupsElements = [self elementsForType:PCPageElementTypePopup];
	  if (popupsElements) [array addObjectsFromArray:popupsElements];
  }
  else if (self.pageTemplate.identifier == PCInteractiveBulletsPageTemplate)
  {
    NSArray* miniArticles = [self elementsForType:PCPageElementTypeMiniArticle];
    if (miniArticles) if ([miniArticles count] > 1) [array addObjectsFromArray:[miniArticles objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [miniArticles count]-1)]]];
  }
  else if (self.pageTemplate.identifier == PCHTMLPageTemplate)
  {
    
  }

  _secondaryElements = [[NSArray alloc] initWithArray:array];
  [array release];
  
  return _secondaryElements;

}



@end
