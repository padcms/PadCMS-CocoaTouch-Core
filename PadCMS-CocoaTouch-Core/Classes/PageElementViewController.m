//
//  PageElementViewController.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Petrosyan on 7/12/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PageElementViewController.h"
#import "PCPageElement.h"
#import "PCPage.h"

@interface PageElementViewController ()
@property (readonly) float scale;
@property (nonatomic, readonly) NSString* fullPathToContent;

@end

@implementation PageElementViewController
@synthesize scrollView = _scrollView;
@synthesize scale=_scale;
@synthesize element=_element;
@synthesize tiledView=_tiledView;

-(id)initWithElement:(PCPageElement *)element
{
	if (self = [super initWithNibName:nil bundle:nil])
    {
        _element = [element retain];
		_scale = [UIScreen mainScreen].scale;
    }
    return self;
}

-(void)dealloc
{
	[_tiledView release], _tiledView = nil;
	[_element release], _element = nil;
	[_scrollView release], _scrollView = nil;
	[super dealloc];
}


-(void)releaseViews
{
	self.scrollView = nil;
	self.tiledView = nil;
}

-(NSString *)fullPathToContent
{
	return [self.element.page.revision.contentDirectory stringByAppendingPathComponent:self.element.resource];
}

-(void)loadElementView
{
	[self.scrollView removeFromSuperview];
	self.scrollView = nil;
	if (!self.element.isComplete) return;
	self.view.backgroundColor = [UIColor clearColor];
	CGRect scrollView_frame = [UIScreen mainScreen].applicationFrame;
	NSDictionary* information = [NSDictionary dictionaryWithContentsOfFile:[[self.fullPathToContent stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"information.plist"]];
	CGFloat height = [[information objectForKey:@"height"] floatValue];
	CGSize scrollContentSize = CGSizeMake([UIScreen mainScreen].applicationFrame.size.width, height); 
	_scrollView = [[JCTiledScrollView alloc] initWithFrame:scrollView_frame contentSize:scrollContentSize];
	_scrollView.backgroundColor = [UIColor greenColor];
	
	_scrollView.dataSource = self;
	
	_scrollView.zoomScale = 1.0f;
	
	// totals 4 sets of tiles across all devices, retina devices will miss out on the first 1x set
	_scrollView.levelsOfZoom = 1;
	_scrollView.levelsOfDetail = 2;
	_scrollView.scrollView.maximumZoomScale = 1.0;
	//self.view = _scrollView;
	//[self.view addSubview:_scrollView];
	
}

#pragma mark - JCTileSource


- (UIImage *)tiledScrollView:(JCTiledScrollView *)scrollView imageForRow:(NSInteger)row column:(NSInteger)column scale:(NSInteger)scale
{
	UIImage* image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@_%d_%d.png", [self.fullPathToContent stringByDeletingPathExtension], row + 1, column + 1]];
	return image;
}




@end
