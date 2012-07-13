//
//  PageElementViewController.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Petrosyan on 7/12/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCTiledScrollView.h"

@class PCPageElement;
@interface PageElementViewController : UIViewController<JCTileSource>
@property (nonatomic, retain) JCTiledScrollView *scrollView;
@property (nonatomic, retain) PCPageElement* element;
@property (nonatomic, retain) UIView* tiledView;
-(id)initWithElement:(PCPageElement *)element;
-(void)loadElementView;
@end
