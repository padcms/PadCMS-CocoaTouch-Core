//
//  PCSliderBasedMiniArticleViewController.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 07.02.12.
//  Copyright (c) PadCMS (http://www.padcms.net)
//
//
//  This software is governed by the CeCILL-C  license under French law and
//  abiding by the rules of distribution of free software.  You can  use,
//  modify and/ or redistribute the software under the terms of the CeCILL-C
//  license as circulated by CEA, CNRS and INRIA at the following URL
//  "http://www.cecill.info".
//  
//  As a counterpart to the access to the source code and  rights to copy,
//  modify and redistribute granted by the license, users are provided only
//  with a limited warranty  and the software's author,  the holder of the
//  economic rights,  and the successive licensors  have only  limited
//  liability.
//  
//  In this respect, the user's attention is drawn to the risks associated
//  with loading,  using,  modifying and/or developing or reproducing the
//  software by the user in light of its specific status of free software,
//  that may mean  that it is complicated to manipulate,  and  that  also
//  therefore means  that it is reserved for developers  and  experienced
//  professionals having in-depth computer knowledge. Users are therefore
//  encouraged to load and test the software's suitability as regards their
//  requirements in conditions enabling the security of their systems and/or
//  data to be ensured and,  more generally, to use and operate it in the
//  same conditions as regards security.
//  
//  The fact that you are presently reading this means that you have had
//  knowledge of the CeCILL-C license and that you accept its terms.
//

#import "PCSliderBasedMiniArticleViewController.h"
//#import "PCPageElementsViewFactory.h"
#import "PCStyler.h"
#import "PCRevision.h"
#import "PCScrollView.h"

@implementation PCSliderBasedMiniArticleViewController

@synthesize miniArticleViews;
@synthesize thumbsView;


-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PCMiniArticleElementDidDownloadNotification object:self.page];
    self.miniArticleViews = nil;
    self.thumbsView = nil;
    [super dealloc];
}

-(id)initWithPage:(PCPage *)aPage
{
    if (self = [super initWithPage:aPage])
    {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(miniArticleDownloaded:) name:PCMiniArticleElementDidDownloadNotification object:self.page];
		
        self.miniArticleViews = [[[NSMutableArray alloc] init] autorelease];
        thumbsView = nil;
     }
    return self;
}

- (void) unloadButtons
{
    for(UIView *subView in [self.thumbsView subviews])
    {
        [subView removeFromSuperview];
    }
    
    [miniArticleViews removeAllObjects];
}

- (void) loadButtons
{
    CGRect thumbsRect = [self activeZoneRectForType:PCPDFActiveZoneThumbs];
    [self.thumbsView setFrame:thumbsRect];
    NSArray* minArticleElements = [page elementsForType:PCPageElementTypeMiniArticle];
    if (minArticleElements && [minArticleElements count] > 0)
    {
        minArticleElements = [minArticleElements sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"weight" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES],nil]];
        CGFloat marginLeft = 0;
        CGFloat marginBottom = 0;
        CGFloat marginElement = 0;
        NSString* magazineDirectory = self.page.revision.contentDirectory;
      
      
      
        for (unsigned i = 0; i < [minArticleElements count]; ++i)
        {
            PCPageElementMiniArticle* miniArticleElement = [minArticleElements objectAtIndex:i];
            
            NSString* thumbailPath = [magazineDirectory stringByAppendingPathComponent:miniArticleElement.thumbnail];
            NSString* thumbnailSelectedPath = [magazineDirectory stringByAppendingPathComponent:miniArticleElement.thumbnailSelected];
            
            UIImage* buttonImage = nil;
            UIImage* buttonSelectedImage = nil;
            
            if (thumbailPath)
                buttonImage = [UIImage imageWithContentsOfFile:thumbailPath];
            
            if (thumbnailSelectedPath)
                buttonSelectedImage = [UIImage imageWithContentsOfFile:thumbnailSelectedPath];
            
            CGSize tumbnailSize = CGSizeZero;
            if (buttonImage!=nil)
                tumbnailSize = CGSizeMake(buttonImage.size.width, buttonImage.size.height);
            
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            CGRect buttonRect = CGRectZero;
            if (self.page.pageTemplate.identifier == PCSlidersBasedMiniArticlesVerticalPageTemplate)
                buttonRect = CGRectMake(marginLeft,
                                        marginBottom + (tumbnailSize.height + marginElement) * i,
                                        tumbnailSize.width,
                                        tumbnailSize.height);
            else
                if (self.page.pageTemplate.identifier == PCSlidersBasedMiniArticlesHorizontalPageTemplate)
                    buttonRect = CGRectMake(marginLeft + (tumbnailSize.width + marginElement) * i,
                                            marginBottom,
                                            tumbnailSize.width,
                                            tumbnailSize.height);
            
            [button setTag:i];
            [button setFrame:buttonRect];
            [button addTarget:self action:@selector(changeArticle:) forControlEvents:UIControlEventTouchUpInside];
            [button setImage:buttonImage forState:UIControlStateNormal];
            [button setImage:buttonSelectedImage forState:UIControlStateSelected];
            if (i==0)
                [button setSelected:YES];
            
            [self.thumbsView addSubview:button];
            [self.thumbsView bringSubviewToFront:button];
            
            if (self.page.pageTemplate.identifier == PCSlidersBasedMiniArticlesVerticalPageTemplate)
                [self.thumbsView setContentSize:CGSizeMake(tumbnailSize.width,marginBottom + (tumbnailSize.height + marginElement) * (i + 1))];
            else
                if (self.page.pageTemplate.identifier == PCSlidersBasedMiniArticlesHorizontalPageTemplate)
                    [self.thumbsView setContentSize:CGSizeMake(marginLeft + (tumbnailSize.width + marginElement) * (i + 1), tumbnailSize.height)];
            
            NSString *fullResource = [page.revision.contentDirectory stringByAppendingPathComponent:miniArticleElement.resource];
            
            PCPageElementViewController* slideView = [[PCPageElementViewController alloc] initWithResource:fullResource];
          slideView.element = miniArticleElement;
          [miniArticleViews addObject:slideView];
            
            [slideView release];
            
        }
    }
    
    if (CGRectEqualToRect(self.thumbsView.frame, CGRectZero))
    {
        CGSize contentSize = self.thumbsView.contentSize;
        CGRect oldFrame = self.mainScrollView.frame;
        CGRect newRect = CGRectZero;
        
        if (self.page.pageTemplate.identifier == PCSlidersBasedMiniArticlesVerticalPageTemplate)
            newRect = CGRectMake(oldFrame.size.width - contentSize.width , 0, contentSize.width, oldFrame.size.height);
        
        
        if (self.page.pageTemplate.identifier == PCSlidersBasedMiniArticlesHorizontalPageTemplate)
            newRect = CGRectMake(0, oldFrame.size.height - contentSize.height, oldFrame.size.width, contentSize.height);
        
        
        if (self.page.pageTemplate.identifier == PCSlidersBasedMiniArticlesTopPageTemplate)
            newRect = CGRectMake(0, 0, oldFrame.size.width, contentSize.height);
        
        self.thumbsView.frame = newRect;
    }
    
    CGFloat dy = 0.0;
    CGFloat dx = 0.0;
    BOOL needsLayoutSubviews = NO;
    NSArray* buttons = [self.thumbsView subviews];
    int count = [buttons count];
    
    if (self.page.pageTemplate.identifier == PCSlidersBasedMiniArticlesVerticalPageTemplate)
    {
        if (self.thumbsView.frame.size.height > self.thumbsView.contentSize.height)
        {
            dy = (self.thumbsView.frame.size.height - self.thumbsView.contentSize.height) / (count + 1);
            needsLayoutSubviews = YES;
        }
    }
    else
        if (self.page.pageTemplate.identifier == PCSlidersBasedMiniArticlesHorizontalPageTemplate ||
            self.page.pageTemplate.identifier == PCSlidersBasedMiniArticlesTopPageTemplate)
        {
            if (self.thumbsView.frame.size.width > self.thumbsView.contentSize.width)
            {
                dx = (self.thumbsView.frame.size.width - self.thumbsView.contentSize.width) / (count + 1);
                needsLayoutSubviews = YES;            
            }
        }
    
    if (needsLayoutSubviews)
    {
        for (unsigned i = 0; i < [buttons count]; ++i)
        {
            UIButton* button = [buttons objectAtIndex:i];
            CGRect buttonRect = [button frame];
            
            if (dy != 0)
                buttonRect.origin.y += dy*(i+1);
            
            if (dx != 0)
                buttonRect.origin.x += dx*(i+1);
            
            button.frame = buttonRect;
        }
    }
    
    if (count == 0)
    {
        [self.view sendSubviewToBack:self.thumbsView];
    } else {
        [self.view bringSubviewToFront:self.thumbsView];
    }
  
  if (self.page.pageTemplate.identifier == PCSlidersBasedMiniArticlesVerticalPageTemplate)
    FrameMoveWithXOffset(self.thumbsView, [PCStyler getVerticalMiniArticleScrollerOffset]); 
}

- (void) loadFullView
{
    [super loadFullView];
    
    [self unloadButtons];
    
    [self loadButtons];
    if (self.bodyViewController==nil)
        [self showArticleAtIndex:0];
}

- (void) unloadFullView
{
    [self unloadButtons];
    
    [super unloadFullView];
}

-(void)showArticleAtIndex:(NSUInteger)index
{
    //TODO we need something for more blurring page change
    if (miniArticleViews != nil && [miniArticleViews count] > index)
    {
        if([self.bodyViewController isEqual:[miniArticleViews objectAtIndex:index]])
        {
            return;
        }
        
        for (UIView* view in [self.thumbsView subviews])
            if ([view isKindOfClass:[UIButton class]])
            {
                [(UIButton*)view setSelected:[view tag]==index];
            }
        
        PCPageElementViewController *prevController = [self.bodyViewController retain];
        
        self.bodyViewController = [miniArticleViews objectAtIndex:index];
      
        currentMiniArticleIndex = index;
      
        [self.mainScrollView addSubview:self.bodyViewController.view];
      
      
		if (!self.bodyViewController.element.isComplete && index!=0) {
			[[NSNotificationCenter defaultCenter] postNotificationName:PCBoostPageNotification object:self.bodyViewController.element];
      NSLog(@"BOOST message from miniarticle element - %d", self.bodyViewController.element?self.bodyViewController.element.identifier:0);
		}
		
        [self.bodyViewController loadFullViewImmediate];
        [self.bodyViewController showHUD];
        
        [prevController.view removeFromSuperview];
        if (self.page.pageTemplate.identifier==PCFlashBulletInteractivePageTemplate)
        {
            self.bodyViewController.view.alpha = 0.0;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:.5];
            self.bodyViewController.view.alpha = 1.0;
            [UIView commitAnimations];
        }
        [prevController unloadView];
        
        [prevController release];
    }
      
}

-(void)viewDidLoad
{
    [super viewDidLoad];

    self.mainScrollView.scrollEnabled = NO;
    
    CGRect thumbsRect = [self activeZoneRectForType:PCPDFActiveZoneThumbs];
    
    self.thumbsView = [[[PCScrollView alloc] initWithFrame:thumbsRect] autorelease];
    self.thumbsView.showsVerticalScrollIndicator = NO;
    self.thumbsView.showsHorizontalScrollIndicator = NO;

    [self.view addSubview:self.thumbsView];
    [self.view bringSubviewToFront:self.thumbsView];
    
    NSArray* minArticleElements = [page elementsForType:PCPageElementTypeMiniArticle];
 // articlesCount = [minArticleElements count];
    if (minArticleElements && [minArticleElements count] > 0)
    {
        minArticleElements = [minArticleElements sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"weight" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES],nil]];
        
        for (PCPageElement* element in minArticleElements)
        {    
            NSString *fullResource = [self.page.revision.contentDirectory stringByAppendingPathComponent:element.resource];
            
            PCPageElementViewController* slideView = [[PCPageElementViewController alloc] initWithResource:fullResource];
            slideView.element = element;
            [self.miniArticleViews addObject:slideView];
            
            [slideView release];
        }
    }
  
   
}

-(void)changeArticle:(id)sender
{
  
    [self showArticleAtIndex:[sender tag]];

}

-(BOOL) pdfActiveZoneAction:(PCPageActiveZone*)activeZone
{
    [super pdfActiveZoneAction:activeZone];
    
    if ([activeZone.URL hasPrefix:PCPDFActiveZoneActionButton])
    {
        NSString* additional = [activeZone.URL lastPathComponent];
        //if (self.page.pageTemplate.identifier == PCInteractiveBulletsPageTemplate)
        {
            [self showArticleAtIndex:[additional integerValue] - 1];
            return YES;
        }
    }
    return NO;
}

-(void)tapAction:(id)sender
{
    [super tapAction:sender];
}

- (void)miniArticleDownloaded:(NSNotification*)notif
{
	PCPageElementMiniArticle* galleryElement = [[notif userInfo] objectForKey:@"element"];
	if (self.bodyViewController.element == galleryElement)
	{
		 [[NSNotificationCenter defaultCenter] postNotificationName:endOfDownloadingPageNotification object:self.page];
	}
}

@end
