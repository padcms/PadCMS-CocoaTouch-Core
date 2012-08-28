//
//  PopupView.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 8/27/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PopupView.h"

@implementation PopupView
@synthesize popupElementView=_popupElementView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)dealloc
{
	[_popupElementView release], _popupElementView = nil;
	[super dealloc];
}
/*-(UIResponder *)nextResponder
{
	NSLog(@"responder - %@", [self.superview viewWithTag:kScrollViewTag]);
	return [self.superview viewWithTag:kScrollViewTag];
}*/

@end
