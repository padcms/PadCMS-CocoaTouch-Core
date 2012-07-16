//
//  RevisionViewController.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 7/4/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRComplexScrollView.h"

@class PCRevision;

@interface RevisionViewController : UIViewController <RRComplexScrollViewDatasource>

@property (readonly, nonatomic) PCRevision *revision;

- (id)initWithRevision:(PCRevision *)revision;

@end
