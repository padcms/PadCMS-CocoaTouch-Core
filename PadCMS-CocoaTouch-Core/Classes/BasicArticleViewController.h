//
//  PageViewController.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 7/8/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JCTiledScrollView.h"
#import "AbstractBasePageViewController.h"


@interface BasicArticleViewController : AbstractBasePageViewController<JCTileSource>

@property (nonatomic, retain) JCTiledScrollView *scrollView;


@end
