//
//  PageViewController.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Petrosyan on 7/8/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "BasicArticleViewController.h"
#import "PCPageElement.h"

@implementation BasicArticleViewController

@synthesize scrollView = _scrollView;

-(void)dealloc
{
	
	[_scrollView release], _scrollView = nil;
	[super dealloc];
}


-(void)releaseViews
{
	self.scrollView = nil;
}


-(void)loadFullView
{
	if (!_page.isComplete) return;
	CGRect scrollView_frame = self.view.bounds;
	PCPageElement* body = [[_page elementsForType:PCPageElementTypeBody] lastObject];
	
	NSDictionary* information = [NSDictionary dictionaryWithContentsOfFile:[[[self.page.revision.contentDirectory stringByAppendingPathComponent:body.resource] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"information.plist"]];
	CGFloat height = [[information objectForKey:@"height"] floatValue];
	CGSize scrollContentSize = CGSizeMake([UIScreen mainScreen].applicationFrame.size.width, height); 
	_scrollView = [[JCTiledScrollView alloc] initWithFrame:scrollView_frame contentSize:scrollContentSize];
	_scrollView.backgroundColor = [UIColor whiteColor];
	self.scrollView.dataSource = self;
	
	self.scrollView.zoomScale = 1.0f;
	
	// totals 4 sets of tiles across all devices, retina devices will miss out on the first 1x set
	self.scrollView.levelsOfZoom = 1;
	self.scrollView.levelsOfDetail = 2;
	self.scrollView.scrollView.maximumZoomScale = 1.0;
	
	[self.view addSubview:self.scrollView];

}

#pragma mark - JCTileSource


- (UIImage *)tiledScrollView:(JCTiledScrollView *)scrollView imageForRow:(NSInteger)row column:(NSInteger)column scale:(NSInteger)scale
{
	PCPageElement* body = [[_page elementsForType:PCPageElementTypeBody] lastObject];
	NSString* pathToResource = [[_page.revision.contentDirectory stringByAppendingPathComponent:body.resource] stringByDeletingPathExtension];
	UIImage* image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@_%d_%d.png", pathToResource, row + 1, column + 1]];
	return image;
}




@end
