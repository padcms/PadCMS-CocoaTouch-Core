//
//  RRComplexScrollView.h
//  ComplexScrollResearch
//
//  Created by Maxim Pervushin on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _RRConnectionType
{
	LEFT = 0,
	RIGHT = 1,
	BOTTOM = 2,
	TOP = 3,
	ROTATE = 4
	
} RRConnectionType;

@protocol RRComplexScrollViewDatasource;
@protocol RRComplexScrollViewDelegate;

@interface RRComplexScrollView : UIView

@property (assign, nonatomic) IBOutlet id<RRComplexScrollViewDatasource> datasource;
@property (assign, nonatomic) IBOutlet id<RRComplexScrollViewDelegate> delegate;
@property (assign, nonatomic) UIView* currentElementView;

- (void)scrollToTopElementAnimated:(BOOL)animated;
- (void)scrollToBottomElementAnimated:(BOOL)animated;
- (void)scrollToLeftElementAnimated:(BOOL)animated;
- (void)scrollToRightElementAnimated:(BOOL)animated;



@end

@protocol RRComplexScrollViewDatasource 

-(UIView*)viewForConnection:(RRConnectionType)coonectionType;


@end

@protocol RRComplexScrollViewDelegate

-(void)viewDidMoved;

@end
