//
//  InteractivesBulletsViewController.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 7/12/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "InteractivesBulletsViewController.h"
#import "PCPageElementMiniArticle.h"
#import "PCPageActiveZone.h"

@interface InteractivesBulletsViewController ()

@end

@implementation InteractivesBulletsViewController
@synthesize miniArticles=_miniArticles;
@synthesize selectedMiniArticle=_selectedMiniArticle;

-(void)dealloc
{
	[_miniArticles release], _miniArticles = nil;
	[_selectedMiniArticle release], _selectedMiniArticle = nil;
	[super dealloc];
}

-(void)releaseViews
{
	self.miniArticles = nil;
}


-(void)loadFullView
{
	if (!_page.isComplete) return;
	[self loadBackground];
	
	PCPageElement* backgroundElement = [_page firstElementForType:PCPageElementTypeBackground];
	
	self.miniArticles = [_page elementsForType:PCPageElementTypeMiniArticle];
	self.selectedMiniArticle = [_miniArticles objectAtIndex:0];
	
	PageElementViewController* miniArticleController = [[PageElementViewController alloc] initWithElement:_selectedMiniArticle andFrame:self.view.bounds];
	self.bodyViewController = miniArticleController;
	[miniArticleController release];
	[self.view addSubview:self.bodyViewController.elementView];
	
	for (PCPageActiveZone* activeZone in backgroundElement.activeZones) {
		if ([activeZone.URL hasPrefix:PCPDFActiveZoneActionButton])
		{
			NSInteger index = [[activeZone.URL lastPathComponent] integerValue] - 1;
			PCPageElementMiniArticle* miniArticleElement = [self.miniArticles objectAtIndex:index];
					
			UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
			[button setTag:index];
			CGRect buttonRect = [self activeZoneRectForType:activeZone.URL];
			[button setFrame:buttonRect];
			[button addTarget:self action:@selector(changeArticle:) forControlEvents:UIControlEventTouchUpInside];
			
			if (miniArticleElement.thumbnail)
			{
				NSString* thumbailPath = [self.page.revision.contentDirectory stringByAppendingPathComponent:miniArticleElement.thumbnail];
				 UIImage* buttonImage = [UIImage imageWithContentsOfFile:thumbailPath];
				[button setImage:buttonImage forState:UIControlStateNormal];
			}
      
            if (miniArticleElement.thumbnailSelected)
			{
				NSString* thumbnailSelectedPath = [self.page.revision.contentDirectory  stringByAppendingPathComponent:miniArticleElement.thumbnailSelected];
				UIImage* buttonSelectedImage = [UIImage imageWithContentsOfFile:thumbnailSelectedPath];
				[button setImage:buttonSelectedImage forState:UIControlStateSelected];
			}
            
			if (miniArticleElement == _selectedMiniArticle)
				[button setSelected:YES];
			[self.view addSubview:button];
		}
	}
}

-(void)changeArticle:(UIButton*)sender
{
	self.selectedMiniArticle = [self.miniArticles objectAtIndex:sender.tag];
		
	if (self.bodyViewController.element != _selectedMiniArticle)
	{
		[self.bodyViewController.elementView removeFromSuperview];
		self.bodyViewController.element = _selectedMiniArticle;
		[self.view addSubview:self.bodyViewController.elementView];
		[self.view sendSubviewToBack:self.bodyViewController.elementView];
	}
	
}


@end
