//
//  PageElementViewController.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 7/12/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PageElementViewController.h"
#import "PCPage.h"
#import "PCPageElement.h"
#import "PCScrollView.h"
#import "UIImage+Resize.h"

@interface PageElementViewController ()
@property (readonly) float scale;
@property (nonatomic, readonly) NSString* fullPathToContent;
@property (nonatomic, readonly) CGRect elementFrame;
@end

@implementation PageElementViewController
@synthesize elementView = _elementView;
@synthesize scale=_scale;
@synthesize element=_element;
@synthesize elementFrame=_elementFrame;

-(id)initWithElement:(PCPageElement *)element andFrame:(CGRect)elementFrame
{
	if (self = [super init])
    {
        _element = [element retain];
		_scale = [UIScreen mainScreen].scale;
		_elementFrame = elementFrame;
		
    }
    return self;
}

-(void)dealloc
{
	[_elementView removeFromSuperview];
	NSLog(@"element dealloc");
	[_element release], _element = nil;
	[_elementView release], _elementView = nil;
	[super dealloc];
}


-(void)releaseViews
{
	[_elementView release], _elementView = nil;
}

- (void)setElement:(PCPageElement *)element 
{
    if ([_element isEqual:element]) {
        return;
    }
    [_element release];
    _element = [element retain];
	[self releaseViews];
}

-(NSString *)fullPathToContent
{
	return [self.element.page.revision.contentDirectory stringByAppendingPathComponent:self.element.resource];
}

-(JCTiledScrollView *)elementView
{
	if (!self.element) return nil;
	if (!_elementView)
	{
		if (!self.element.isComplete) return nil;
		CGRect elementView_frame = _elementFrame;
		NSDictionary* information = [NSDictionary dictionaryWithContentsOfFile:[[self.fullPathToContent stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"information.plist"]];
		CGFloat height = [[information objectForKey:@"height"] floatValue];
		CGFloat width = [[information objectForKey:@"width"] floatValue];
		CGSize scrollContentSize = CGSizeMake(width, height); 
		_elementView = [[JCTiledScrollView alloc] initWithFrame:elementView_frame contentSize:scrollContentSize];
		_elementView.dataSource = self;
		
		_elementView.zoomScale = 1.0f;
		
		// totals 4 sets of tiles across all devices, retina devices will miss out on the first 1x set
		_elementView.levelsOfZoom = 1;
		_elementView.levelsOfDetail = 2;
		_elementView.scrollView.maximumZoomScale = 1.0;
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
			UIImage* image = [[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@BQ.png", [self.fullPathToContent stringByDeletingPathExtension]]] resizedImage:scrollContentSize interpolationQuality:kCGInterpolationLow];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				_elementView.scrollView.backgroundColor = [UIColor colorWithPatternImage:image];
			});
			

		});
	}
	return _elementView;
}


#pragma mark - JCTileSource


- (UIImage *)tiledScrollView:(JCTiledScrollView *)scrollView imageForRow:(NSInteger)row column:(NSInteger)column scale:(NSInteger)scale
{
	UIImage* image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@_%d_%d.png", [self.fullPathToContent stringByDeletingPathExtension], row + 1, column + 1]];
	return image;
}




@end
