//
//  PageElementViewController.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 7/12/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCTiledScrollView.h"

@class PCPageElement;
@interface PageElementViewController : NSObject<JCTileSource, JCTiledScrollViewDelegate>
@property (nonatomic, retain) JCTiledScrollView *elementView;
@property (nonatomic, retain) PCPageElement* element;
@property (nonatomic, retain) NSMutableSet* cachedTiles;

-(id)initWithElement:(PCPageElement *)element andFrame:(CGRect)elementFrame;

@end
