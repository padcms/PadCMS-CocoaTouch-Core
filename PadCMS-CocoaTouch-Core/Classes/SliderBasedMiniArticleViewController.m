//
//  SliderBasedMiniArticleViewController.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 7/9/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "SliderBasedMiniArticleViewController.h"
#import "PCPageTemplatesPool.h"
#import "PCPageElementMiniArticle.h"

#define IMAGE_TAG					101
@interface SliderBasedMiniArticleViewController ()

@end

@implementation SliderBasedMiniArticleViewController
@synthesize thumbsScrollView=_thumbsScrollView;
@synthesize miniArticles=_miniArticles;
@synthesize selectedMiniArticle=_selectedMiniArticle;

-(void)loadFullView
{
	if (!_page.isComplete) [self showHUD];
	if (!_page.isComplete) return;
	[self loadBackground];
	CGRect frameRect;
	self.miniArticles = [_page elementsForType:PCPageElementTypeMiniArticle];
	
	self.selectedMiniArticle = [_miniArticles objectAtIndex:0];
	
	PageElementViewController* miniArticleController = [[PageElementViewController alloc] initWithElement:_selectedMiniArticle andFrame:self.view.bounds];
	self.bodyViewController = miniArticleController;
	[miniArticleController release];
	[self.view addSubview:self.bodyViewController.elementView];
	
	
	if ([self.miniArticles count] > 1)
	{
		UIImage* image = [UIImage imageWithContentsOfFile:[_page.revision.contentDirectory stringByAppendingPathComponent:((PCPageElementMiniArticle*)[_miniArticles lastObject]).thumbnail]];
		CGSize thumbSize = image.size;
		EasyTableView *thumbsView;
		if (self.page.pageTemplate.identifier == PCSlidersBasedMiniArticlesHorizontalPageTemplate)
		{
			frameRect	= CGRectMake(0, self.view.bounds.size.height - thumbSize.height, self.view.bounds.size.width, thumbSize.height);
			thumbsView	= [[EasyTableView alloc] initWithFrame:frameRect numberOfColumns:[_miniArticles count] ofWidth:thumbSize.width];
		}
		else if (self.page.pageTemplate.identifier == PCSlidersBasedMiniArticlesVerticalPageTemplate)
		{
			frameRect	= CGRectMake(0, self.view.bounds.size.width - thumbSize.width, self.view.bounds.size.height, thumbSize.width);
			thumbsView	= [[EasyTableView alloc] initWithFrame:frameRect numberOfRows:[_miniArticles count] ofHeight:thumbSize.height];
		}
		
		
		
		thumbsView.delegate						= self;
		thumbsView.tableView.backgroundColor	= [UIColor clearColor];
		thumbsView.tableView.allowsSelection	= YES;
		thumbsView.tableView.separatorColor		= [UIColor darkGrayColor];
		thumbsView.cellBackgroundColor			= [UIColor darkGrayColor];
		thumbsView.autoresizingMask				= UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
		self.thumbsScrollView = thumbsView;
		[thumbsView release];
		[self.view addSubview:_thumbsScrollView];
		[self.thumbsScrollView reloadData];
		[self.thumbsScrollView selectCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO];

	}
			
	
}

#pragma mark - EasyTableViewDelegate

- (UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect {
	// Create a container view for an EasyTableView cell
	UIView *container = [[UIView alloc] initWithFrame:rect];
	
	// Setup an image view to display an image
	UIImageView *imageView	= [[UIImageView alloc] initWithFrame:CGRectMake(1, 0, rect.size.width-2, rect.size.height)];
	imageView.tag			= IMAGE_TAG;
	imageView.contentMode	= UIViewContentModeScaleAspectFill;
	
	[container addSubview:imageView];
	return container;
}

// Second delegate populates the views with data from a data source

- (void)easyTableView:(EasyTableView *)easyTableView setDataForView:(UIView *)view forIndexPath:(NSIndexPath *)indexPath {
			
	// Set the image for the given index
	PCPageElementMiniArticle* miniArticle = [self.miniArticles objectAtIndex:indexPath.row];
	NSString* path = [self.page.revision.contentDirectory stringByAppendingPathComponent:miniArticle.thumbnail];
	UIImageView *imageView = (UIImageView *)[view viewWithTag:IMAGE_TAG];
	imageView.image = [UIImage imageWithContentsOfFile:path];
}

- (void)easyTableView:(EasyTableView *)easyTableView selectedView:(UIView *)selectedView atIndexPath:(NSIndexPath *)indexPath deselectedView:(UIView *)deselectedView
{
	UIImageView *deselectedImageView = (UIImageView *)[deselectedView viewWithTag:IMAGE_TAG];
	NSString* thumbailPath = [self.page.revision.contentDirectory stringByAppendingPathComponent:_selectedMiniArticle.thumbnail];
	deselectedImageView.image = [UIImage imageWithContentsOfFile:thumbailPath];
	
	PCPageElementMiniArticle* miniArticle = [self.miniArticles objectAtIndex:indexPath.row];
	NSString* selectedThumbailPath = [self.page.revision.contentDirectory stringByAppendingPathComponent:miniArticle.thumbnailSelected];
	UIImageView *imageView = (UIImageView *)[selectedView viewWithTag:IMAGE_TAG];
	imageView.image = [UIImage imageWithContentsOfFile:selectedThumbailPath];

	if (self.bodyViewController.element != miniArticle)
	{
		[self.bodyViewController.elementView removeFromSuperview];
		self.bodyViewController.element = miniArticle;
		self.selectedMiniArticle = miniArticle;
		[self.view addSubview:self.bodyViewController.elementView];
		[self.view sendSubviewToBack:self.bodyViewController.elementView];
	}
	

}


-(void)dealloc
{
	[_miniArticles release], _miniArticles = nil;
	[_thumbsScrollView release], _thumbsScrollView = nil;
	[_selectedMiniArticle release], _selectedMiniArticle = nil;
	[super dealloc];
}

-(void)releaseViews
{
	[super releaseViews];
	self.miniArticles = nil;
	self.thumbsScrollView = nil;
	self.selectedMiniArticle = nil;
	
}


@end
