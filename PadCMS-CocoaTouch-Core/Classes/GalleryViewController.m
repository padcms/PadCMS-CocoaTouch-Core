//
//  GalleryViewControllerViewController.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 7/19/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "GalleryViewController.h"
#import "PCPage.h"
#import "PCPageElement.h"
#import "PageElementViewController.h"
#import "PCStyler.h"
#import "PCPageElementBody.h"
#import "JCTiledView.h"

@interface GalleryViewController ()
{
	CGFloat _scale;
	NSMutableSet* _visibleElementControllers;
	BOOL _isHorizontal;
}

@property (nonatomic, retain) PageElementViewController* popupController;
@end

@implementation GalleryViewController
@synthesize galleryElements=_galleryElements;
@synthesize page=_page;
@synthesize galleryScrollView=_galleryScrollView;
@synthesize popupController=_popupController;

-(id)initWithPage:(PCPage *)page
{
	if (self = [super initWithNibName:nil bundle:nil])
    {
        _page = [page retain];
		_scale = [UIScreen mainScreen].scale;
		_galleryElements = [[page elementsForType:PCPageElementTypeGallery] retain];
		_visibleElementControllers = [[NSMutableSet alloc] init];
		//element weight normalization
		for (int i = 0; i < [_galleryElements count]; ++i) {
			[[_galleryElements objectAtIndex:i] setWeight:i];
		}
		_isHorizontal = NO;
		PCPageElementBody* bodyElement = (PCPageElementBody*)[page firstElementForType:PCPageElementTypeBody];
		if (bodyElement && bodyElement.showGalleryOnRotate) _isHorizontal = YES;
    }
    return self;
}


-(void)dealloc
{
	[_popupController release], _popupController = nil;
	[_visibleElementControllers release], _visibleElementControllers = nil;
	[_page release], _page = nil;
	[_galleryElements release], _galleryElements = nil;
	[_galleryScrollView release], _galleryScrollView = nil;
	[super dealloc];
}


- (void)viewDidLoad
{
	UIViewController *viewController = [[UIViewController alloc] init];
	[self presentModalViewController:viewController animated:NO];
	[self dismissModalViewControllerAnimated:NO];
	[viewController release];
    [super viewDidLoad];
	_galleryScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _galleryScrollView.pagingEnabled = YES;
    _galleryScrollView.backgroundColor = [UIColor whiteColor];
    _galleryScrollView.showsVerticalScrollIndicator = NO;
    _galleryScrollView.showsHorizontalScrollIndicator = NO;
	_galleryScrollView.directionalLockEnabled = YES;
	_galleryScrollView.delegate = self;
	_galleryScrollView.bounces = NO;
	_galleryScrollView.contentSize = CGSizeMake(self.view.bounds.size.width * [self.galleryElements count], self.view.bounds.size.height); 
//	_galleryScrollView.backgroundColor = [UIColor yellowColor];
	
    [self.view addSubview:_galleryScrollView];
	
	UIButton* btnReturn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSDictionary *buttonOption = [NSDictionary dictionaryWithObject:[NSValue valueWithCGRect:self.view.frame] forKey:PCButtonParentViewFrameKey];
    if (self.page.color)
    {
        buttonOption = [NSDictionary dictionaryWithObjectsAndKeys:self.page.color, PCButtonTintColorOptionKey, [NSValue valueWithCGRect:self.view.frame], PCButtonParentViewFrameKey,  nil];
    }
    [[PCStyler defaultStyler] stylizeElement:btnReturn withStyleName:PCGallaryReturnButtonKey withOptions:buttonOption];
    [btnReturn setFrame:CGRectMake(0, 0, btnReturn.frame.size.width, btnReturn.frame.size.height)];
	[[PCStyler defaultStyler] stylizeElement:btnReturn withStyleName:PCGallaryReturnButtonKey withOptions:buttonOption];
	[btnReturn addTarget:self action:@selector(btnReturnTap:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:btnReturn];
	
	[self tilePages];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
	self.galleryScrollView = nil;
	self.popupController = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (_isHorizontal)
	{
		 return UIInterfaceOrientationIsLandscape(interfaceOrientation);
	}
	else {
		 return UIInterfaceOrientationIsPortrait(interfaceOrientation);
	}
	
   
}

- (void)tilePages 
{
    // Calculate which pages are visible
    CGRect visibleBounds = _galleryScrollView.bounds;
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)) / CGRectGetWidth(visibleBounds));
    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex  = MIN(lastNeededPageIndex, [self.galleryElements count] - 1);
    NSLog(@"FIRST - %d, LAST - %d", firstNeededPageIndex, lastNeededPageIndex);
    //removing not visible images
	NSMutableSet* pagesToRemove = [[NSMutableSet alloc] init];
	for (PageElementViewController *controller in _visibleElementControllers) {
        if (controller.element.weight < firstNeededPageIndex || controller.element.weight > lastNeededPageIndex) {
            [pagesToRemove addObject:controller];
            [controller.elementView removeFromSuperview];
        }
    }
    [_visibleElementControllers minusSet:pagesToRemove];
	[pagesToRemove release];
	
    // add missing images
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        if (![self isDisplayingImageForIndex:index]) {
			PCPageElement* galleryElement = [self.galleryElements objectAtIndex:index];
			PageElementViewController* elementController = [[PageElementViewController alloc] initWithElement:galleryElement andFrame:CGRectOffset(self.view.bounds, _galleryScrollView.bounds.size.width * index, 0.0f)];
			if (_isHorizontal)
			{
				CGAffineTransform transform = CGAffineTransformMakeRotation(3.14159/2);
				CGRect frame = CGRectMake(_galleryScrollView.bounds.size.width * index, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height);
				elementController.elementView.transform = transform;
				elementController.elementView.frame = frame;
				//	elementController.elementView.autoresizesSubviews = NO;
				//	elementController.elementView.scrollView.frame = self.view.bounds;
				elementController.elementView.scrollView.contentSize = CGSizeMake(1024, 0);
				//	elementController.elementView.tiledView.frame = self.view.bounds;
				//	elementController.elementView.backgroundColor = [UIColor greenColor];
				//NSLog(@"FRAME - main %@, scrol - %@, tile - %@", NSStringFromCGSize(elementController.elementView.scrollView.contentSize), NSStringFromCGRect(elementController.elementView.scrollView.frame),NSStringFromCGRect([elementController.elementView.tiledView frame]));
			}
			
			NSArray* popups = [[galleryElement.dataRects allKeys] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@",PCPDFActiveZonePopup]];
			for (NSString* type in popups) {
				NSLog(@"POPUP - %@", type);
				CGRect rect = [galleryElement rectForElementType:type];
				if (!CGRectEqualToRect(rect, CGRectZero))
				{
					CGSize pageSize = elementController.elementView.bounds.size;
					float scale = pageSize.width/galleryElement.size.width;
					rect.size.width *= scale;
					rect.size.height *= scale;
					rect.origin.x *= scale;
					rect.origin.y *= scale;
					rect.origin.y = galleryElement.size.height*scale - rect.origin.y - rect.size.height;
					UIButton* popup = [UIButton buttonWithType:UIButtonTypeCustom];
					[popup setFrame:rect];
					popup.tag = 100 + [[type lastPathComponent] intValue];
					[popup addTarget:self action:@selector(popupAction:) forControlEvents:UIControlEventTouchUpInside];
					
					[elementController.elementView addSubview:popup];			
				}
			}
			
			[_galleryScrollView addSubview:elementController.elementView];
            [_visibleElementControllers addObject:elementController];
			[elementController release];
        }
    }    
}

- (BOOL)isDisplayingImageForIndex:(NSUInteger)index
{
    BOOL foundImage = NO;
    for (PageElementViewController *controller in _visibleElementControllers) {
        if (controller.element.weight == index) {
            foundImage = YES;
            break;
        }
    }
    return foundImage;
}

-(void)popupAction:(UIButton*)sender
{
	self.popupController = nil;
	for (UIView* v in sender.superview.subviews) {
		if ([v isKindOfClass:[JCTiledScrollView class]])
		{
			[v removeFromSuperview];
			if (v.tag == sender.tag) return;
		}
	}
	NSLog(@"POPUP tag - %d", sender.tag);
	int index = sender.tag - 100 - 1;
	NSArray* popupsElements = [self.page elementsForType:PCPageElementTypePopup];
	PCPageElement* popupElement = [popupsElements objectAtIndex:index];
	
	if (!popupElement.isComplete)
		[[NSNotificationCenter defaultCenter] postNotificationName:PCBoostPageNotification object:popupElement];
	
		
	PageElementViewController* elementController = [[PageElementViewController alloc] initWithElement:popupElement andFrame:self.view.bounds];
	self.popupController = elementController;
	UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
	tapGestureRecognizer.cancelsTouchesInView = NO;
	//tapGestureRecognizer.delegate = self;
    [elementController.elementView  addGestureRecognizer:tapGestureRecognizer];
	[tapGestureRecognizer release];
	[sender.superview addSubview:elementController.elementView ];
//	[sender.superview sendSubviewToBack:elementController.elementView ];
	for (UIView* v in sender.superview.subviews) {
		if ([v isKindOfClass:[UIButton class]])
		{
			[sender.superview bringSubviewToFront:v];
		}
	}
	[elementController release];
	
}

-(void)tapAction:(UIGestureRecognizer *)gestureRecognizer
{
	[gestureRecognizer.view removeFromSuperview];
	self.popupController = nil;
}


- (void)btnReturnTap:(id)sender
{
	[self.navigationController popViewControllerAnimated:NO];
}


#pragma mark -
#pragma mark ScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self tilePages];
}

@end
