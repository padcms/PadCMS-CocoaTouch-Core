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
#import "MBProgressHUD.h"

#define kDefaultCacheDeepness 2;

@interface PageElementViewController ()
{
	MBProgressHUD* HUD;
	NSInteger _firstNeededRow;
	NSInteger _lastNeededRow;
	NSInteger _firstNeededCol;
	NSInteger _lastNeededCol;
	
}
@property (readonly) float scale;
@property (nonatomic, readonly) NSString* fullPathToContent;
@property (nonatomic, readonly) CGRect elementFrame;

@end

@implementation PageElementViewController
@synthesize elementView = _elementView;
@synthesize scale=_scale;
@synthesize element=_element;
@synthesize elementFrame=_elementFrame;
@synthesize cachedTiles=_cachedTiles;

-(id)initWithElement:(PCPageElement *)element andFrame:(CGRect)elementFrame
{
	if (self = [super init])
    {
        _element = [element retain];
		_scale = [UIScreen mainScreen].scale;
		_elementFrame = elementFrame;
		_cachedTiles = [[NSMutableSet alloc] init];
		_firstNeededCol = 0;
		_lastNeededCol = 0;
		_firstNeededRow = 0;
		_lastNeededRow = 0;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateElement:) name:PCGalleryElementDidDownloadNotification object:self.element];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateElement:) name:PCMiniArticleElementDidDownloadNotification object:self.element];
    }
    return self;
}

-(void)dealloc
{
	_elementView.tiledScrollViewDelegate = nil;
	_elementView.dataSource = nil;
	[self hideHud];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PCGalleryElementDidDownloadNotification object:self.element];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PCMiniArticleElementDidDownloadNotification object:self.element];
	[_elementView removeFromSuperview];
	[_element release], _element = nil;
	[_elementView release], _elementView = nil;
	[_cachedTiles release], _cachedTiles = nil;
	[super dealloc];
}


-(void)releaseViews
{
	_elementView.tiledScrollViewDelegate = nil;
	_elementView.dataSource = nil;
	[_elementView release], _elementView = nil;
}

- (void)setElement:(PCPageElement *)element 
{
    if ([_element isEqual:element]) {
        return;
    }
	[_cachedTiles removeAllObjects];
    [_element release];
    _element = [element retain];
	
	[self releaseViews];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PCGalleryElementDidDownloadNotification object:self.element];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PCMiniArticleElementDidDownloadNotification object:self.element];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateElement:) name:PCGalleryElementDidDownloadNotification object:element];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateElement:) name:PCMiniArticleElementDidDownloadNotification object:element];
	
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
		BOOL isShowHud = NO;
		if (!self.element.isComplete) 
		{
			
			if ([self.element.fieldTypeName isEqualToString:PCPageElementTypeGallery] || [self.element.fieldTypeName isEqualToString:PCPageElementTypeMiniArticle])
			{
				isShowHud = YES;
			}
			else {
				return nil;
			}
		}
		CGRect elementView_frame = _elementFrame;
		CGSize scrollContentSize = [self.element realImageSize]; 
		_elementView = [[JCTiledScrollView alloc] initWithFrame:elementView_frame contentSize:scrollContentSize];
		_elementView.dataSource = self;
		if ([_element.resourceExtension isEqualToString:@"png"])
		{
			_elementView.tiledScrollViewDelegate = self;
		}
		
		
		_elementView.zoomScale = 1.0f;
		
		// totals 4 sets of tiles across all devices, retina devices will miss out on the first 1x set
		_elementView.levelsOfZoom = 1;
		_elementView.levelsOfDetail = 2;
		_elementView.scrollView.maximumZoomScale = 1.0;
		if (_element.isComplete && [_element.resourceExtension isEqualToString:@"png"])
		{
			NSInteger maxColumn = ceilf(_element.realImageSize.width / kDefaultTileSize);
			for (int col = 1; col <=2; ++col) {
				for (int row = 1; row <=2; ++row) {
					NSInteger index = (row - 1) * maxColumn + col;
					[_cachedTiles addObject:[NSNumber numberWithInt:index]];
				}
			}
			
			[self cacheTilesForBounds:_elementView.scrollView.bounds];
			
			
			
		}
		if ([_element.resourceExtension isEqualToString:@"jpg"])
		{
			_elementView.opaque = YES;
			_elementView.tiledView.opaque = YES;
			_elementView.scrollView.opaque = YES;
		}
		if (isShowHud) [self showHUD];
		
	
	}
	return _elementView;
}

-(void)showHUD
{
	NSAssert(!self.element.isComplete,@"Invalid show hud");
	if (self.element.isComplete) return;
	if (HUD)
    {
        return;
        _element.progressDelegate = nil;
        [HUD removeFromSuperview];
        [HUD release];
        HUD = nil;
    }
    HUD = [[MBProgressHUD alloc] initWithView:_elementView];
    [_elementView addSubview:HUD];
    HUD.mode = MBProgressHUDModeAnnularDeterminate;
    _element.progressDelegate = HUD;
    [HUD show:YES];
}

-(void)hideHud
{
	if (HUD)
	{
		[HUD hide:YES];
		_element.progressDelegate = nil;
		[HUD removeFromSuperview];
		[HUD release];
		HUD = nil;
	}
}


#pragma mark - JCTileSource


- (UIImage *)tiledScrollView:(JCTiledScrollView *)scrollView imageForRow:(NSInteger)row column:(NSInteger)column scale:(NSInteger)scale
{
	if (!self.element.isComplete) return nil;
/*	NSLog(@"row - %d, column - %d", row, column);
	ImageCache* cache = [ImageCache sharedImageCache];
	NSInteger index = [_element tileIndexForResource:[NSString stringWithFormat:@"resource_%d_%d", row + 1, column + 1]];
	//UIImage* goodQualityImage = [cache.elementCache valueForKeyPath: [NSString stringWithFormat:@"%d.%d", _element.identifier, index]];
	UIImage* goodQualityImage = [[cache.elementCache objectForKey:[NSNumber numberWithInt:_element.identifier]] objectForKey:[NSNumber numberWithInt:index]];
	if (goodQualityImage)
	{
		NSLog(@"drawn - %@", NSStringFromCGRect(CGRectMake(column * kDefaultTileSize, row * kDefaultTileSize, kDefaultTileSize, kDefaultTileSize)));
		return goodQualityImage;

	}	
	UIImage* badQualityimage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/BQresource_%d_%d.png", [self.fullPathToContent stringByDeletingLastPathComponent], row + 1, column + 1]];
	NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
		[cache storeTileForElement:_element withIndex:index];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.elementView.tiledView setNeedsDisplayInRect:CGRectMake(column * kDefaultTileSize, row * kDefaultTileSize, kDefaultTileSize, kDefaultTileSize)];
			NSLog(@"rect - %@", NSStringFromCGRect(CGRectMake(column * kDefaultTileSize, row * kDefaultTileSize, kDefaultTileSize, kDefaultTileSize)));
		});
	}];
	[cache.queue addOperation:operation];
	
	return badQualityimage;*/
	/*UIImage* image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/resource_%d_%d.png", [self.fullPathToContent stringByDeletingLastPathComponent], row + 1, column + 1]];
	return image;*/
//---------------------------------------------------------------------------------------------	
	
	if ([_element.resourceExtension isEqualToString:@"png"])
	{
		ImageCache* cache = [ImageCache sharedImageCache];
		NSInteger index = [_element tileIndexForResource:[NSString stringWithFormat:@"resource_%d_%d", row + 1, column + 1]];
		UIImage* goodQualityImage = [[cache.elementCache objectForKey:[NSNumber numberWithInt:_element.identifier]] objectForKey:[NSNumber numberWithInt:index]];
		if (goodQualityImage)
		{
			NSLog(@"HIT!!!!");
			
			return goodQualityImage;
			
		}
		
		NSLog(@"MISS!!!");
	}
	
//	[cache storeTileForElement:_element withIndex:index];
//	return [[cache.elementCache objectForKey:[NSNumber numberWithInt:_element.identifier]] objectForKey:[NSNumber numberWithInt:index]];
	if (!_element) return nil;
	return [UIImage imageWithContentsOfFile:[[NSString stringWithFormat:@"%@/resource_%d_%d", [self.fullPathToContent stringByDeletingLastPathComponent], row + 1, column + 1] stringByAppendingPathExtension:_element.resourceExtension]];
//---------------------------------------------------------------------------------------------		
	
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

-(void)updateElement:(NSNotification*)notif
{
	[self hideHud];
//	_elementView.tiledView.layer.contents = nil;
//	[_elementView.tiledView.layer setNeedsDisplayInRect:_elementView.tiledView.layer.bounds];
//	[_elementView.tiledView.layer setNeedsDisplay];
	
	
	CGSize scrollContentSize = [self.element realImageSize];
	
	_elementView.tiledView.frame = CGRectMake(0.0, 0.0, scrollContentSize.width, scrollContentSize.height);
	
	[_elementView.tiledView setNeedsDisplay];
	
/*	NSLog(@"TILED VIEW - %@", _elementView.tiledView);
	
	NSInteger maxColumn = ceilf(_elementFrame.size.width / kDefaultTileSize);
	NSInteger maxRaw = ceilf(_elementFrame.size.height / kDefaultTileSize);
	for (int column = 1; column <=maxColumn; ++column) {
		for (int row = 1; row <=maxRaw; ++row) {
			[self.elementView.tiledView setNeedsDisplayInRect:CGRectMake(column * kDefaultTileSize, row * kDefaultTileSize, kDefaultTileSize, kDefaultTileSize)];
		}
	}*/
	
}

-(void)tiledScrollViewDidScroll:(JCTiledScrollView *)scrollView
{
	if ([UIScreen mainScreen].scale < 2.0) {
		return;
	}
	[self cacheTilesForBounds:scrollView.scrollView.bounds];
}

-(void)cacheTilesForBounds:(CGRect)bounds
{
	if ([UIScreen mainScreen].scale < 2.0) {
		return;
	}
	CGRect visibleBounds = bounds;
	NSInteger maxColumn = ceilf(self.element.realImageSize.width / kDefaultTileSize);
	NSInteger maxRow = ceilf(self.element.realImageSize.height / kDefaultTileSize);
	
	int firstNeededRow = floorf(CGRectGetMinY(visibleBounds) / kDefaultTileSize) + 1;
	firstNeededRow-=kDefaultCacheDeepness;
	firstNeededRow = MAX(firstNeededRow, 1);
	int lastNeededRow  = floorf((CGRectGetMaxY(visibleBounds)) / kDefaultTileSize) + 1;
	lastNeededRow+=kDefaultCacheDeepness;
	lastNeededRow = MIN(lastNeededRow, maxRow);
	int firstNeededCol = floorf(CGRectGetMinX(visibleBounds) / kDefaultTileSize) + 1;
	firstNeededCol-=kDefaultCacheDeepness;
	firstNeededCol = MAX(firstNeededCol, 1);
	int lastNeededCol  = floorf((CGRectGetMaxX(visibleBounds)) / kDefaultTileSize) + 1;
	lastNeededCol+=kDefaultCacheDeepness;
	lastNeededCol = MIN(lastNeededCol, maxColumn);
	if (firstNeededCol != _firstNeededCol || lastNeededCol != _lastNeededCol || firstNeededRow != _firstNeededRow || lastNeededRow != _lastNeededRow)
	{
		_firstNeededRow = firstNeededRow;
		_lastNeededRow = lastNeededRow;
		_firstNeededCol = firstNeededCol;
		_lastNeededCol = lastNeededCol;
	}
	else {
		return;
	}
	NSLog(@"Colums - %d ... %d, Rows - %d ... %d, maxc - %d, maxr - %d", firstNeededCol, lastNeededCol, firstNeededRow, lastNeededRow, maxColumn, maxRow);
	//	NSLog(@"CURRENT - %@", _cachedTiles);
	NSMutableSet* newSet = [[NSMutableSet alloc] init];
	NSMutableSet* oldSet = [[NSMutableSet alloc] initWithSet:_cachedTiles copyItems:YES];
	for (int row = firstNeededRow; row <= lastNeededRow; ++row) {
		for (int col = firstNeededCol; col <= lastNeededCol; ++col) {
			NSUInteger index = (row - 1) * maxColumn + col;
			[newSet addObject:[NSNumber numberWithInteger:index]];
			
		}
	}
	//	NSLog(@"NEW - %@", newSet);
	self.cachedTiles = [[newSet copy] autorelease];;
	
	ImageCache* cache = [ImageCache sharedImageCache];
	[newSet minusSet:oldSet];
	
	//	NSLog(@"ADD - %@", newSet);
	for (NSNumber* index in newSet) {
		NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
			[cache storeTileForElement:self.element withIndex:[index integerValue]];
		}];
		[cache.queue addOperation:operation];
	}
	
	
	[oldSet minusSet:_cachedTiles];
	//NSLog(@"DELETE - %@", oldSet);
	for (NSNumber* index in oldSet)
	{
		[cache clearMemoryForElement:self.element withIndex:[index integerValue]];
	}
	[newSet release];
	[oldSet release];
	
	//
}


@end
