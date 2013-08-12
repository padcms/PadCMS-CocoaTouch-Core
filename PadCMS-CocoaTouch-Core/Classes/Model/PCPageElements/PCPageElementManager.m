//
//  PCPageElementManager.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 21.02.12.
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
