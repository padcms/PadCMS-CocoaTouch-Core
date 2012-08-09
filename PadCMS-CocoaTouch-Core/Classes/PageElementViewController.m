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
#import "ImageCache.h"
#import "JCTiledView.h"
#import "PCVideoManager.h"

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
    //[[PCVideoManager sharedVideoManager] dismissVideo];
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
		/*NSDictionary* information = [NSDictionary dictionaryWithContentsOfFile:[[self.fullPathToContent stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"information.plist"]];
		CGFloat height = [[information objectForKey:@"height"] floatValue];
		CGFloat width = [[information objectForKey:@"width"] floatValue];*/
		CGSize scrollContentSize = [self.element realImageSize]; 
		_elementView = [[JCTiledScrollView alloc] initWithFrame:elementView_frame contentSize:scrollContentSize];
		_elementView.dataSource = self;
		
		_elementView.zoomScale = 1.0f;
		
		// totals 4 sets of tiles across all devices, retina devices will miss out on the first 1x set
		_elementView.levelsOfZoom = 1;
		_elementView.levelsOfDetail = 2;
		_elementView.scrollView.maximumZoomScale = 1.0;
	/*	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
			UIImage* image = [[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/BQresource.png", [self.fullPathToContent stringByDeletingLastPathComponent]]] resizedImage:scrollContentSize interpolationQuality:kCGInterpolationLow];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				_elementView.scrollView.backgroundColor = [UIColor colorWithPatternImage:image];
			});
			

		});*/
	}
	return _elementView;
}


#pragma mark - JCTileSource


- (UIImage *)tiledScrollView:(JCTiledScrollView *)scrollView imageForRow:(NSInteger)row column:(NSInteger)column scale:(NSInteger)scale
{
/*	ImageCache* cache = [ImageCache sharedImageCache];
	NSInteger index = [_element tileIndexForResource:[NSString stringWithFormat:@"resource_%d_%d", row + 1, column + 1]];
	//UIImage* goodQualityImage = [cache.elementCache valueForKeyPath: [NSString stringWithFormat:@"%d.%d", _element.identifier, index]];
	UIImage* goodQualityImage = [[cache.elementCache objectForKey:[NSNumber numberWithInt:_element.identifier]] objectForKey:[NSNumber numberWithInt:index]];
	if (goodQualityImage)
	{
		return goodQualityImage;

	}	
	UIImage* badQualityimage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/BQresource_%d_%d.png", [self.fullPathToContent stringByDeletingLastPathComponent], row + 1, column + 1]];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		
		[cache storeTileForElement:_element withIndex:index];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.elementView.tiledView setNeedsDisplayInRect:CGRectMake(column * kDefaultTileSize, row * kDefaultTileSize, kDefaultTileSize, kDefaultTileSize)];
		});
	});
	return badQualityimage;*/
	UIImage* image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/resource_%d_%d.png", [self.fullPathToContent stringByDeletingLastPathComponent], row + 1, column + 1]];
	return image;
	
/*	ImageCache* cache = [ImageCache sharedImageCache];
	 NSInteger index = [_element tileIndexForResource:[NSString stringWithFormat:@"resource_%d_%d", row + 1, column + 1]];
	UIImage* goodQualityImage = [[cache.elementCache objectForKey:[NSNumber numberWithInt:_element.identifier]] objectForKey:[NSNumber numberWithInt:index]];
	if (goodQualityImage)
	{
		return goodQualityImage;
		
	}
	[cache storeTileForElement:_element withIndex:index];
	return [[cache.elementCache objectForKey:[NSNumber numberWithInt:_element.identifier]] objectForKey:[NSNumber numberWithInt:index]];*/
	
	
	//setNeedDisplay withoy badQualities
/*	ImageCache* cache = [ImageCache sharedImageCache];
	 NSInteger index = [_element tileIndexForResource:[NSString stringWithFormat:@"resource_%d_%d", row + 1, column + 1]];
	 UIImage* goodQualityImage = [[cache.elementCache objectForKey:[NSNumber numberWithInt:_element.identifier]] objectForKey:[NSNumber numberWithInt:index]];
	 if (goodQualityImage)
	 {
	 return goodQualityImage;
	 
	 }	
	 
	 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
	 
	 [cache storeTileForElement:_element withIndex:index];
	 dispatch_async(dispatch_get_main_queue(), ^{
	 [self.elementView.tiledView setNeedsDisplayInRect:CGRectMake(column * kDefaultTileSize, row * kDefaultTileSize, kDefaultTileSize, kDefaultTileSize)];
	 });
	 });
	 return nil;*/
	
}





@end
