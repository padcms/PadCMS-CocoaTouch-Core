//
//  PCPageElementManager.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 21.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCPageElementManager.h"
#import "PCData.h"
#import "PCPageElemetTypes.h"

@interface  PCPageElementManager(ForwardDeclarations)
- (void)initializeBaseElements;
@end

@implementation PCPageElementManager

+ (PCPageElementManager*)sharedManager
{
    static PCPageElementManager * sharedManager = nil;
    if (sharedManager == nil)
    {
        sharedManager = [[PCPageElementManager alloc] init];
    }
    return sharedManager;
}

- (void)dealloc
{
    [elementClasses release];
    elementClasses = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        elementClasses = [[NSMutableDictionary alloc] init];
        [self initializeBaseElements];
    }
    
    return self;  
}

- (void)initializeBaseElements
{
    [self registerPageElementClass:[PCPageElement class] forElementType:PCPageElementTypeBackground];
    [self registerPageElementClass:[PCPageElement class] forElementType:PCPageElementTypeOverlay];
    [self registerPageElementClass:[PCPageElement class] forElementType:PCPageElementTypeSound];
    [self registerPageElementClass:[PCPageElement class] forElementType:PCPageElementTypePopup];
    
    [self registerPageElementClass:[PCPageElementBody class] forElementType:PCPageElementTypeBody];
    [self registerPageElementClass:[PCPageElementVideo class] forElementType:PCPageElementTypeVideo];
    [self registerPageElementClass:[PCPageElementAdvert class] forElementType:PCPageElementTypeAdvert];
    [self registerPageElementClass:[PCPageElementScrollingPane class] forElementType:PCPageElementTypeScrollingPane];
    [self registerPageElementClass:[PCPageElementMiniArticle class] forElementType:PCPageElementTypeMiniArticle];
    [self registerPageElementClass:[PCPageElementSlide class] forElementType:PCPageElementTypeSlide];
    [self registerPageElementClass:[PCPageElementHtml class] forElementType:PCPageElementTypeHtml];
    [self registerPageElementClass:[PCPageElementHtml5 class] forElementType:PCPageElementTypeHtml5];
    [self registerPageElementClass:[PCPageElementDragAndDrop class] forElementType:PCPageElementTypeDragAndDrop];
    [self registerPageElementClass:[PCPageElement class] forElementType:PCPageElementType3D];
    [self registerPageElementClass:[PCPageElementGallery class] forElementType:PCPageElementTypeGallery];
}

- (Class)elementClassForElementType:(NSString*)aElementType
{
    return [elementClasses objectForKey:aElementType];
}

- (void)registerPageElementClass:(Class)aClass forElementType:(NSString*)aElementType
{
    [elementClasses setObject:aClass forKey:aElementType];
}

@end