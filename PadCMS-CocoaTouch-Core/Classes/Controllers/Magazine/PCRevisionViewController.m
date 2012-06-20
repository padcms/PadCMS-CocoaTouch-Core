//
//  PCMagazineViewController.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PCRevisionViewController.h"

#import "NSString+XMLEntities.h"
#import "PCConfig.h"
#import "PCDefaultStyleElements.h"
#import "PCGalleryViewController.h"
#import "PCGoogleAnalytics.h"
#import "PCHelpViewController.h"
#import "PCHorizontalPageController.h"
#import "PCMacros.h"
#import "PCMagazineViewControllersFactory.h"
#import "PCRevision.h"
#import "PCScrollView.h"
#import "PCSearchProvider.h"
#import "PCSearchViewController.h"
#import "PCStyler.h"

#define TocElementWidth 130
#define TocElementsMargin 20


@interface PCRevisionViewController(ForwardDeclaration)
- (void) updateViewsForCurrentIndex;
- (void) createHorizontalView;
- (void) deviceOrientationDidChange;
- (void) updateViewsForCurrentIndexHorizontal;
- (void) initTopMenu;
- (NSInteger) currentColumnIndex;
- (BOOL) isOrientationChanged:(UIDeviceOrientation) orientation;
- (void) createHorizontalSummary;
- (void) changeHorizontalPage:(id) sender;
- (void) horizontalTapAction:(id) sender;
- (void) hideMenus;
- (PCPage *) pageAtHorizontalIndex:(NSInteger)currentHorisontalPageIndex;
- (void) unloadSummaries;
@end

@implementation PCRevisionViewController

@synthesize revision;
@synthesize searchTextField;
@synthesize initialPageIndex;
@synthesize mainViewController;
@synthesize mainScrollView;
@synthesize horizontalPagesViewController;
@synthesize topSummaryView;
@synthesize helpButton;
@synthesize topSummaryButton;
@synthesize horizontalSummaryView;
@synthesize horizontalHelpButton;

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:endOfDownloadingTocNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PCHorizontalTocDidDownloadNotification object:nil];

    self.revision = nil;

    [mainScrollView release];
    mainScrollView = nil;
    [columnsViewControllers release];
    columnsViewControllers = nil;
    [tableOfContentsView release];
    tableOfContentsView = nil;
    [tapGestureRecognizer release];
    tapGestureRecognizer = nil;
    [horizontalTapGestureRecognizer release],
    horizontalTapGestureRecognizer = nil;
    [tableOfContentButton release];
    tableOfContentButton = nil;
    [facebookViewController release];
    facebookViewController = nil;
    [emailController release];
    emailController = nil;
    [_videoController release];
    _videoController = nil;
    [shareMenu release];
    shareMenu = nil;
    self.horizontalPagesViewController = nil;
   /* if(horizontalPagesViewControllers)
    {
        [horizontalPagesViewControllers release];
        horizontalPagesViewControllers = nil;
        [horizontalScrollView release];
        horizontalScrollView = nil;
    }*/
    [horizontalScrollView release], horizontalScrollView = nil;
    [topSummaryView release], topSummaryView = nil;
    [topSummaryScrollView release], topSummaryScrollView = nil;
    [helpController release], helpController = nil;
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [searchTextField release];
    searchTextField = nil;
    [horizontalHelpButton release];
    [helpButton release];
    [topSummaryButton release];
    [horizontalSummaryView release], horizontalSummaryView = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) 
    {
        revision = nil;
        columnsViewControllers = [[NSMutableArray alloc] init];
        tableOfContentsView = nil;
        mainScrollView = nil;
        tapGestureRecognizer = nil;
        horizontalTapGestureRecognizer = nil;
        tableOfContentButton = nil;
        topMenuView = nil;
        horizontalTopMenuView = nil;
        facebookViewController = nil;
        emailController = nil;
        _videoController = nil;
        shareMenu = nil;
        initialPageIndex = 0;
        horizontalScrollView = nil;
        topSummaryView = nil;
        topSummaryScrollView = nil;
        horizontalSummaryView = nil;
        helpController = nil;
        horizontalPagesViewControllers = [[NSMutableArray alloc] init];
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishTocDownload:) name:endOfDownloadingTocNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createHorizontalSummary) name:PCHorizontalTocDidDownloadNotification object:nil];
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [self updateViewsForCurrentIndex];
}

#pragma mark - View lifecycle

- (void)createMagazineView
{
    NSUInteger revisionColumnsCount = revision.columns.count;
    
    mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width * revisionColumnsCount, mainScrollView.frame.size.height);
    
    for (unsigned i = 0; i < revisionColumnsCount; i++)
    {
        PCColumn* column  = [revision.columns objectAtIndex:i];
        PCColumnViewController* columnViewController = [[PCMagazineViewControllersFactory factory] viewControllerForColumn:column];

        columnViewController.horizontalOrientation = revision.horizontalOrientation;

        if(revision.horizontalOrientation)
        {
            [columnViewController setPageSize:CGSizeMake(1024, 768)];
        }

        [columnViewController setMagazineViewController:self];
        [columnViewController.view setFrame:CGRectMake(mainScrollView.frame.size.width * i, 0, mainScrollView.frame.size.width, mainScrollView.frame.size.height)];
        [mainScrollView addSubview:columnViewController.view];
        [columnsViewControllers addObject:columnViewController];
    }
}

- (void) createHorizontalView
{
    [horizontalScrollView release], horizontalScrollView = nil;
    if(revision.horizontalMode && revision.horizontalPages)
    {
        if([revision.horizontalPages count] > 0)
        {
//            self.horizontalPagesViewController = [[[PCLandscapeViewController alloc] init] autorelease];
//            self.horizontalPagesViewController.view.backgroundColor = [UIColor whiteColor];
            horizontalScrollView.backgroundColor = [UIColor whiteColor];
            horizontalScrollView = [[PCScrollView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
            horizontalScrollView.contentSize = CGSizeMake(1024 * [revision.horizontalPages count], 768);
            horizontalScrollView.delegate = self;
            horizontalScrollView.showsHorizontalScrollIndicator = NO;
            horizontalScrollView.showsVerticalScrollIndicator = NO;
            
            horizontalScrollView.pagingEnabled = YES;
            horizontalScrollView.alwaysBounceHorizontal = NO;
            horizontalScrollView.bounces = NO;
            horizontalScrollView.horizontalScrollButtonsEnabled = YES;
            
//            [self.horizontalPagesViewController.view addSubview:horizontalScrollView];
            
            NSArray     *keys = [revision.horizontalPages allKeys];
            NSArray     *sortedKeys = [keys sortedArrayUsingSelector: @selector(compare:)];

            for (int i = 0; i<[sortedKeys count]; i++)
            {
                NSNumber* key = [sortedKeys objectAtIndex:i];
                NSString* resource  = [revision.horizontalPages objectForKey:key];
                
                PCHorizontalPageController* viewController = [[PCHorizontalPageController alloc] init];
                [viewController.view setFrame:CGRectMake(1024 * i, 0, 1024, 768)];
                viewController.revision = self.revision;
                viewController.revisionViewController = self;
                viewController.resource = resource;
                viewController.pageIdentifier = [key integerValue];
				viewController.identifier = key;
                
				viewController.horizontalPage = [self.revision.horisontalPagesObjects objectForKey:key];
                
                viewController.view.backgroundColor = [UIColor whiteColor];

                [horizontalScrollView addSubview:viewController.view];
                [horizontalPagesViewControllers addObject:viewController];
            }
            
            if ([horizontalPagesViewControllers count] > 0)
            {
                PCHorizontalPageController   *first = [horizontalPagesViewControllers objectAtIndex:0];
                [first loadFullView];

                PCHorizontalPageController   *next = [horizontalPagesViewControllers objectAtIndex:1];
                if(next)
                {
                    [next loadFullView];
                }
            }

            [horizontalScrollView setHidden:YES];
            [self.view addSubview:horizontalScrollView];
            
            if (!horizontalTapGestureRecognizer)
            {
                horizontalTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(horizontalTapAction:)];
            }
            horizontalTapGestureRecognizer.cancelsTouchesInView=NO;
            horizontalTapGestureRecognizer.delegate = self;
            [horizontalScrollView addGestureRecognizer:horizontalTapGestureRecognizer];
        }
    }
}

- (void)createHorizontalSummary
{
    NSArray *keys = [revision.horizontalPages allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingSelector: @selector(compare:)];
    NSString *halfImagePath = [@"horisontal_toc_items" stringByAppendingPathComponent:[self.revision.horizontalPages objectForKey:[sortedKeys lastObject]]]; // TODO: remove @"horisontal_toc_items"
    NSString *imagePath = [revision.contentDirectory stringByAppendingPathComponent:halfImagePath];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
    if (!fileExists) {
        return;
    }
    
    CGRect horizontalSummaryViewFrame = CGRectMake(0, 600, 1024, 178); // TODO: remove magic numbers
	[horizontalSummaryView release], horizontalSummaryView = nil;
    horizontalSummaryView = [[PCScrollView alloc] initWithFrame:horizontalSummaryViewFrame];
    horizontalSummaryView.backgroundColor = [UIColor blackColor];
    horizontalSummaryView.showsVerticalScrollIndicator = NO;
    horizontalSummaryView.opaque = YES;

    CGFloat contentWidth = 0;
    NSUInteger index = 0;
    for (NSString *key in sortedKeys) {
        NSString *halfImagePath = [@"horisontal_toc_items" stringByAppendingPathComponent:[self.revision.horizontalPages objectForKey:key]];
        NSString *imagePath = [revision.contentDirectory stringByAppendingPathComponent:halfImagePath];
        if (imagePath == nil) { // TODO: nil???
            continue;
        }
        
        UIImage *tocImage = [UIImage imageWithContentsOfFile:imagePath];
        if (tocImage == nil) {
            continue;
        }
        CGSize imageSize = tocImage.size;
        CGRect tocButtonFrame = CGRectMake((imageSize.width + TocElementsMargin) * index, 
                                           (horizontalSummaryViewFrame.size.height - imageSize.height) / 2, 
                                           imageSize.width, 
                                           imageSize.height);
        UIButton *tocButton = [[UIButton alloc] initWithFrame:tocButtonFrame];
        tocButton.tag = index * 100; // TODO: ???????
        [tocButton setImage:tocImage forState:UIControlStateNormal];
        [tocButton addTarget:self action:@selector(changeHorizontalPage:) forControlEvents:UIControlEventTouchUpInside];
        [horizontalSummaryView addSubview:tocButton];
        [tocButton release];
        contentWidth = tocButtonFrame.origin.x + tocButtonFrame.size.width + TocElementsMargin;
        ++index;
    }

    CGSize horizontalSummaryViewContentSize = CGSizeMake(contentWidth, 178); // TODO: replace 178
    horizontalSummaryView.contentSize = horizontalSummaryViewContentSize;
    [self.view addSubview:horizontalSummaryView];
    [self.view bringSubviewToFront:horizontalSummaryView];
    [horizontalSummaryView setHidden:YES];
    [horizontalTopMenuView setHidden:YES];
}

- (void)_old_createHorizontalSummary
{
    CGFloat elemetMargin = 20;
    NSArray *keys = [revision.horizontalPages allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingSelector: @selector(compare:)];
    NSString *halfImagePath = [@"horisontal_toc_items" stringByAppendingPathComponent:[self.revision.horizontalPages objectForKey:[sortedKeys lastObject]]];
    NSString *imagePath = [revision.contentDirectory stringByAppendingPathComponent:halfImagePath];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
    if (!fileExists)
        return;
    horizontalSummaryView = [[PCScrollView alloc] initWithFrame:CGRectMake(0, 600, 1024, 178)];
    horizontalSummaryView.backgroundColor = [UIColor redColor];
    horizontalSummaryView.showsVerticalScrollIndicator = NO;
    horizontalSummaryView.opaque = YES;
    horizontalSummaryView.contentSize = CGSizeMake((204+elemetMargin)*([revision.horizontalPages count]+4), horizontalSummaryView.frame.size.height);

    for (unsigned i = 0; i < [revision.horisontalTocItems count]; i++)
    {
        NSString *halfImagePath = [@"horisontal_toc_items" stringByAppendingPathComponent:[self.revision.horizontalPages objectForKey:[sortedKeys objectAtIndex:i]]];
        NSString *imagePath = [revision.contentDirectory stringByAppendingPathComponent:halfImagePath];
        if (imagePath == nil)
            continue;
        UIImage* tocImage = [UIImage imageWithContentsOfFile:imagePath];
        if (tocImage == nil)
            continue;
        UIButton* tocButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [tocButton setTag:i*100];
        [tocButton setImage:tocImage forState:UIControlStateNormal];
        CGRect imageViewRect = CGRectMake((tocImage.size.width+elemetMargin)*i, (horizontalSummaryView.frame.size.height - tocImage.size.height)/2 , tocImage.size.width, tocImage.size.height);
        [tocButton setFrame:imageViewRect];
        [tocButton addTarget:self action:@selector(changeHorizontalPage:) forControlEvents:UIControlEventTouchUpInside];
        [horizontalSummaryView addSubview:tocButton];
    }
    [self.view addSubview:horizontalSummaryView];
    [self.view bringSubviewToFront:horizontalSummaryView];
    [horizontalSummaryView setHidden:YES];
    [horizontalTopMenuView setHidden:YES];
}

- (void)createTableOfContents
{
    CGFloat viewHeight = self.view.frame.size.height;
    CGFloat viewWidth = self.view.frame.size.width;
    
    CGRect tableOfContentsFrame = CGRectMake(0, 
                                             MAX(viewHeight, viewWidth) - MAX(viewHeight, viewWidth) / 3, 
                                             MIN(viewHeight, viewWidth), 
                                             MAX(viewHeight, viewWidth) / 3);
        
    [tableOfContentsView release], tableOfContentsView = nil;
    tableOfContentsView = [[PCScrollView alloc] initWithFrame:tableOfContentsFrame];
    tableOfContentsView.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:tableOfContentsView];
    [self.view bringSubviewToFront:tableOfContentsView];

    NSArray *revisionTocItems = revision.toc;
    NSUInteger tocItemIndex = 0;
    for (PCTocItem *tocItem in revisionTocItems) {
        
        NSString *imagePath = [revision.contentDirectory stringByAppendingPathComponent:tocItem.thumbStripe];
        UIImage *tocImage = [UIImage imageWithContentsOfFile:imagePath];
        
        // Skip TOC elements without image
        if (tocImage == nil) {
            continue;
        }
        
        NSInteger pageIndex = -1;
        NSArray *revisionPages = revision.pages;
        for (PCPage *page in revisionPages) {
            if (page.identifier == tocItem.firstPageIdentifier) {
                pageIndex = [revisionPages indexOfObject:page];
            }
        }

        // Skip TOC elements without reference
        if (pageIndex == -1) {
            continue;
        }
        
        CGFloat imageHeight = tocImage.size.height * (TocElementWidth / tocImage.size.width);
        CGRect tocElementFrame = CGRectMake(tocItemIndex * (TocElementWidth + TocElementsMargin) + TocElementsMargin, 
                                            0, 
                                            TocElementWidth, 
                                            imageHeight);
        
        UIButton *tocButton = [[UIButton alloc] initWithFrame:tocElementFrame];
        [tocButton setImage:tocImage forState:UIControlStateNormal];
        [tocButton addTarget:self action:@selector(selectTOCItemAction:) forControlEvents:UIControlEventTouchUpInside];
        [tocButton setTag:pageIndex];
        [tableOfContentsView addSubview:tocButton];
        [tocButton release];
        
        ++tocItemIndex;
    }

    CGSize tableOfContentsContentSize = CGSizeMake(tocItemIndex * (TocElementWidth + TocElementsMargin) + TocElementsMargin, 
                                                   tableOfContentsFrame.size.height);
        
    tableOfContentsView.contentSize = tableOfContentsContentSize;
    tableOfContentsView.hidden = YES;
    tableOfContentsView.alpha = 0;
    
    [self createTableOfContentsButton];
}

- (void)createTableOfContentsButton
{
    tableOfContentButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    
    NSDictionary *buttonOption = nil; 
    
    if (revision.color != nil)
    {
        buttonOption = [NSDictionary dictionaryWithObject:revision.color forKey:PCButtonTintColorOptionKey];
    }
    
    [[PCStyler defaultStyler] stylizeElement:tableOfContentButton withStyleName:PCTocButtonKey withOptions:buttonOption];
    [tableOfContentButton setFrame:CGRectMake(0, MAX(self.view.frame.size.height, self.view.frame.size.width) - tableOfContentButton.frame.size.height, tableOfContentButton.frame.size.width, tableOfContentButton.frame.size.height)];
    [[PCStyler defaultStyler] stylizeElement:tableOfContentButton withStyleName:PCTocButtonKey withOptions:buttonOption];
    [tableOfContentButton addTarget:self action:@selector(showTOCAction:) forControlEvents:UIControlEventTouchUpInside];
    tableOfContentButton.hidden = YES;
    tableOfContentButton.alpha = 0;
    tableOfContentButton.exclusiveTouch = YES;
    
    [self.view addSubview:tableOfContentButton];
    [self.view bringSubviewToFront:tableOfContentButton];  
}

- (void)_old_createTableOfContents
{
    PCTocItem* tocItem = [revision.toc objectAtIndex:[revision.toc count] - 1];
    NSString* imagePath = [revision.contentDirectory stringByAppendingPathComponent:tocItem.thumbStripe];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
    if (!fileExists)
        return;
    CGFloat imageWidth = 130;//?
    CGFloat elemetMargin = 20;//?
    tableOfContentsView = [[PCScrollView alloc] initWithFrame:CGRectMake(0, MAX(self.view.frame.size.height, self.view.frame.size.width) - MAX(self.view.frame.size.height, self.view.frame.size.width)/3, MIN(self.view.frame.size.height, self.view.frame.size.width), MAX(self.view.frame.size.height, self.view.frame.size.width)/3)];
    tableOfContentsView.backgroundColor = [UIColor blackColor];
    tableOfContentsView.opaque = YES;
    
    NSMutableArray *thumbStripeArray = [[NSMutableArray alloc] init];
    
    for (PCTocItem *tocItem in revision.toc)
    {
        if (tocItem.thumbStripe)
        {
            [thumbStripeArray addObject:tocItem];
        }
    }
    [tableOfContentsView setContentSize:CGSizeMake((imageWidth+elemetMargin)*[thumbStripeArray count], tableOfContentsView.frame.size.height)];
    for (int i = 0; i < [thumbStripeArray count]; i++)
    {
        PCTocItem* tocItem = [thumbStripeArray objectAtIndex:i];

        NSString* imagePath = [revision.contentDirectory stringByAppendingPathComponent:tocItem.thumbStripe];
        
        UIImage* tocImage = [UIImage imageWithContentsOfFile:imagePath];
        if (tocImage == nil)
            continue;
        UIButton* tocButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        PCPage *page = [[PCPage alloc]init];
        int counter = 0;
        while (page.identifier != tocItem.firstPageIdentifier) 
        {
            page = [revision.pages objectAtIndex:counter];
            counter++;
        }
        
        [tocButton setTag:[revision.pages indexOfObject:page]];
        [page release];
    
    
   /* for (unsigned i = 0; i < [revision.toc count]; i++)
    {
        PCTocItem* tocItem = [revision.toc objectAtIndex:i];
        
        NSString* imagePath = [revision.contentDirectory stringByAppendingPathComponent:tocItem.thumbStripe];
        if (imagePath == nil)
            continue;
        UIImage* tocImage = [UIImage imageWithContentsOfFile:imagePath];
        if (tocImage == nil)
            continue;
        UIButton* tocButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [tocButton setTag:i];*/
        [tocButton setImage:tocImage forState:UIControlStateNormal];
        CGFloat imageHeight = tocImage.size.height * (imageWidth/tocImage.size.width);
        CGRect imageViewRect = CGRectMake(i*(imageWidth+elemetMargin), 0 , imageWidth, imageHeight);
        [tocButton setFrame:imageViewRect];
        [tocButton addTarget:self action:@selector(selectTOCItemAction:) forControlEvents:UIControlEventTouchUpInside];
        [tableOfContentsView addSubview:tocButton];
    }
    
    [thumbStripeArray release];
    
    //tableOfContentsView.contentSize = CGSizeMake((imageWidth+elemetMargin)*[revision.toc count], tableOfContentsView.frame.size.height);
    tableOfContentsView.hidden = YES;
    tableOfContentsView.alpha = 0;
    
    [self.view addSubview:tableOfContentsView];
    [self.view bringSubviewToFront:tableOfContentsView];
    
    tableOfContentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    NSDictionary* buttonOption = nil; 
    

    if (revision.color)
    {
        buttonOption = [NSDictionary dictionaryWithObject:revision.color forKey:PCButtonTintColorOptionKey];
    }
    
    [[PCStyler defaultStyler] stylizeElement:tableOfContentButton withStyleName:PCTocButtonKey withOptions:buttonOption];
    [tableOfContentButton setFrame:CGRectMake(0, MAX(self.view.frame.size.height, self.view.frame.size.width) - tableOfContentButton.frame.size.height, tableOfContentButton.frame.size.width, tableOfContentButton.frame.size.height)];
    [[PCStyler defaultStyler] stylizeElement:tableOfContentButton withStyleName:PCTocButtonKey withOptions:buttonOption];
    [tableOfContentButton addTarget:self action:@selector(showTOCAction:) forControlEvents:UIControlEventTouchUpInside];
    tableOfContentButton.hidden = YES;
    tableOfContentButton.alpha = 0;
    tableOfContentButton.exclusiveTouch = YES;
    
    [self.view addSubview:tableOfContentButton];
    [self.view bringSubviewToFront:tableOfContentButton];  
}

- (void)createTopSummaryView
{
    CGFloat imageSize = 85;
    CGFloat imageMargin = 10;
    CGFloat verticalPos = 43;
        
    topSummaryView.frame = CGRectMake(20, verticalPos, topSummaryView.frame.size.width, topSummaryView.frame.size.height);
    topSummaryView.hidden = YES;
    topSummaryView.alpha = 0;

    CGFloat contentHeight = 0;
    NSUInteger index = 0;
    NSArray *revisionToc = revision.toc;
    for (PCTocItem *tocItem in revisionToc) {
        if (tocItem.thumbSummary == nil) {
            continue;
        }
        
        NSInteger pageIndex = -1;
        NSArray *revisionPages = revision.pages;
        for (PCPage *page in revisionPages) {
            if (page.identifier == tocItem.firstPageIdentifier) {
                pageIndex = [revisionPages indexOfObject:page];
            }
        }
        
        // Skip TOC elements without reference
        if (pageIndex == -1) {
            continue;
        }
        
        NSString *imagePath = [revision.contentDirectory stringByAppendingPathComponent:tocItem.thumbSummary];
        UIImage *tocImage = [UIImage imageWithContentsOfFile:imagePath];
        if (tocImage == nil) {
            continue;
        }
        
        CGRect tocElementFrame = CGRectMake(imageMargin, index * (imageSize + imageMargin), imageSize, imageSize);
        UIButton *tocButton = [[UIButton alloc] initWithFrame:tocElementFrame];
        [tocButton setImage:tocImage forState:UIControlStateNormal];
        [tocButton addTarget:self action:@selector(selectTOCItemAction:) forControlEvents:UIControlEventTouchUpInside];
        [tocButton setTag:pageIndex];
        [topSummaryScrollView addSubview:tocButton];
        [tocButton release];

        contentHeight = tocElementFrame.origin.y + tocElementFrame.size.height + imageMargin;

        NSString *text = [tocItem.title stringByReplacingOccurrencesOfString:@" / " withString:@"\r"];
        CGSize labelSize = CGSizeMake(topSummaryScrollView.frame.size.width - imageSize - imageMargin * 3, imageSize);
        CGRect tocLabelRect = CGRectMake(imageSize + imageMargin * 2, index * (imageSize + imageMargin), labelSize.width, labelSize.height);
        UILabel *tocTextLabel = [[UILabel alloc] initWithFrame:tocLabelRect];
        tocTextLabel.font = [UIFont fontWithName:@"Arial" size:12];
        tocTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        tocTextLabel.textColor = [UIColor whiteColor];
        tocTextLabel.backgroundColor = [UIColor blackColor];
        tocTextLabel.text = text;
        tocTextLabel.numberOfLines = 100;
        [topSummaryScrollView addSubview:tocTextLabel];			
        [tocTextLabel release];
        
        ++index;
    }

    topSummaryScrollView.contentSize = CGSizeMake(topSummaryView.frame.size.width, contentHeight);
    
    [self.view addSubview:topSummaryView];
    [self initTopMenu];
}

- (void)_original_createTopSummaryView
{
    PCTocItem* tocItem = [revision.toc objectAtIndex:[revision.toc count]-1];
    NSString* imagePath = [revision.contentDirectory stringByAppendingPathComponent:tocItem.thumbSummary];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
    if (!fileExists)
        return;
    CGFloat imageSize = 85;
    CGFloat imageMargin = 10;
    CGFloat verticalPos = 43;
    topSummaryView.hidden = YES;
    topSummaryView.alpha = 0;
    [topSummaryView setFrame:CGRectMake(20, verticalPos, topSummaryView.frame.size.width, topSummaryView.frame.size.height)];
    
    NSMutableArray *thumbSummaryArray = [[NSMutableArray alloc] init];
   
    for (PCTocItem *tocItem in revision.toc)
    {
        if (tocItem.thumbSummary)
        {
            [thumbSummaryArray addObject:tocItem];
        }
    }
    [topSummaryScrollView setContentSize:CGSizeMake(topSummaryScrollView.frame.size.width, (imageSize+imageMargin)*[thumbSummaryArray count])];
    for (int i = 0; i < [thumbSummaryArray count]; i++)
    {
        PCTocItem* tocItem = [thumbSummaryArray objectAtIndex:i];
        if (!tocItem.thumbSummary)		
            continue;
        NSString* imagePath = [revision.contentDirectory stringByAppendingPathComponent:tocItem.thumbSummary];
        
        UIImage* tocImage = [UIImage imageWithContentsOfFile:imagePath];
        if (tocImage == nil)
            continue;
        UIButton* tocButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        PCPage *page = [[PCPage alloc]init];
        int counter = 0;
        while (page.identifier != tocItem.firstPageIdentifier) 
        {
            page = [revision.pages objectAtIndex:counter];
            counter++;
        }
        
        [tocButton setTag:[revision.pages indexOfObject:page]];
        [page release];
        
        [tocButton setImage:tocImage forState:UIControlStateNormal];
        CGRect imageViewRect = CGRectMake(imageMargin, i*(imageSize+imageMargin), imageSize, imageSize);
        [tocButton setFrame:imageViewRect];
        [tocButton addTarget:self action:@selector(selectTOCItemAction:) forControlEvents:UIControlEventTouchUpInside];
        [topSummaryScrollView addSubview:tocButton];
        
        NSString* text = [tocItem.title stringByReplacingOccurrencesOfString:@" / " withString:@"\r"];
        CGSize labelSize = CGSizeMake(topSummaryScrollView.frame.size.width - imageSize - imageMargin*3, imageSize);
        UILabel* tocTextLabel = [[[UILabel alloc] initWithFrame:CGRectMake(imageSize+imageMargin*2, i*(imageSize+imageMargin), labelSize.width, labelSize.height)] autorelease];
        tocTextLabel.font = [UIFont fontWithName:@"Arial" size:12];
        tocTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        tocTextLabel.textColor = [UIColor whiteColor];
        tocTextLabel.backgroundColor = [UIColor blackColor];
        tocTextLabel.text = text;
        tocTextLabel.numberOfLines = 100;
        [topSummaryScrollView addSubview:tocTextLabel];			
    }
    
    [thumbSummaryArray release], thumbSummaryArray = nil;
    
    [self.view addSubview:topSummaryView];
    [self initTopMenu];
}

- (void)initTopMenu
{
    topMenuView.hidden = YES;
    topMenuView.alpha = 0;
    [topMenuView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 43)];

    if ([revision.toc count] > 0)
    {
        PCTocItem* tocItem = [revision.toc objectAtIndex:[revision.toc count] - 2];
        NSString* imagePath = [revision.contentDirectory stringByAppendingPathComponent:tocItem.thumbSummary];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
        topSummaryButton.hidden = !fileExists;
    }
    
    [self.view addSubview:topMenuView];
    
    horizontalTopMenuView.hidden = YES;
    horizontalTopMenuView.alpha = 0;
    [horizontalTopMenuView setFrame:CGRectMake(0, 0, self.view.frame.size.height, 43)];
    
    [self.view addSubview:horizontalTopMenuView];
}
- (void) adjustHelpButton
{
    BOOL        hide = NO;
    
    if (revision.helpPages)
    {
         if([[revision.helpPages objectForKey:@"horizontal"] isEqualToString:@""] && [[revision.helpPages objectForKey:@"vertical"] isEqualToString:@""])
         {
             hide = YES;
         }
    }
    horizontalHelpButton.hidden = hide;
    helpButton.hidden = hide;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mainScrollView.delegate = self;
	mainScrollView.pagingEnabled = YES;
	mainScrollView.alwaysBounceHorizontal = NO;
	mainScrollView.bounces = NO;
    mainScrollView.showsVerticalScrollIndicator = NO;
    mainScrollView.showsHorizontalScrollIndicator = NO;

    if (revision != nil)
    {
        if(revision.horizontalOrientation)
        {
            self.view.frame = CGRectMake(0, 0, 1024, 768);
            [horizontalScrollView setHidden:YES];
            [mainScrollView setHidden:NO];
            [mainScrollView setFrame:self.view.frame];
            [topMenuView setFrame:CGRectMake(0, 0, self.view.frame.size.width, topMenuView.frame.size.height)];
        }

        [self createMagazineView];
        if ([revision.toc count] > 0)
        {
            [self createTableOfContents];
            [self createTopSummaryView];
        }
        
        if ([revision.horizontalPages count] > 0)
        {
            [self createHorizontalSummary];
        }

        [self initTopMenu];
        [self showPageWithIndex:initialPageIndex];
        [self createHorizontalView];
        [self adjustHelpButton];
        
        if([PCConfig IsDisableSearching])
        {
            searchTextField.hidden = YES;
            searchTextField.enabled = NO;
            searchTextField.userInteractionEnabled = NO;
        }
    }
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tapGestureRecognizer.cancelsTouchesInView=NO;
    tapGestureRecognizer.delegate = self;
    [mainScrollView addGestureRecognizer:tapGestureRecognizer];
    
    if (!_videoController)
    {
        _videoController = [[PCVideoController alloc] init];
    }
    _videoController.delegate = self;
    
    [self updateViewsForCurrentIndex];
    
    if (revision.horizontalMode  && !revision.horizontalOrientation)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(deviceOrientationDidChange) 
                                                     name:UIDeviceOrientationDidChangeNotification 
                                                   object:nil];
    }
    
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
/*    
    // if we enter in view controller in portrait with revision with horizontal orientation
    if(revision.horizontalOrientation && UIDeviceOrientationIsPortrait(currentOrientation))
    {
        self.navigationController.view.userInteractionEnabled = NO;
        [UIView beginAnimations:nil context:NULL];
        // when rotation is done, we can add new views, because UI orientation is OK

        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:NO];
        [self.navigationController.view setTransform: CGAffineTransformMakeRotation(M_PI / 2)];
        // set size of view
        [self.navigationController.view setFrame:CGRectMake(0, 0, 748, 1024)];
        [UIView commitAnimations];
    }*/
    
    if (self.revision.horizontalMode && !revision.horizontalOrientation)
    {
        [mainScrollView setAutoresizingMask:UIViewContentModeScaleAspectFill];
        if (UIDeviceOrientationIsLandscape(currentOrientation) && self.revision.horizontalPages.count != 0)
        {
            [horizontalScrollView setFrame:CGRectMake(0, 0, 1024, 768)];
            [horizontalScrollView setHidden:NO];
            [mainScrollView setHidden:YES];
			
			CGFloat     index = horizontalScrollView.contentOffset.x / horizontalScrollView.frame.size.width;
			NSInteger   currentIndex = lrintf(round(index));
			PCHorizontalPageController      *currentPageController = [horizontalPagesViewControllers objectAtIndex:currentIndex];
            [currentPageController showHUD];
			[[NSNotificationCenter defaultCenter] postNotificationName:PCBoostPageNotification object:currentPageController.identifier userInfo:nil];
        }
        else
        {
            [horizontalScrollView setHidden:YES];
            [horizontalSummaryView setHidden:YES];
            [mainScrollView setHidden:NO];
            
			[self.currentColumnViewController.currentPageViewController showHUD];
        }

        currentMagazineOrientation = [[UIDevice currentDevice] orientation];
    }
}


- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setHorizontalHelpButton:nil];
    [self setHelpButton:nil];
    [self setTopSummaryButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (self.revision.horizontalOrientation)
    {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    }
        
    if (self.revision.horizontalMode && self.revision.horizontalPages.count != 0)
    {
        return YES;
    }

    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (BOOL)isOrientationChanged:(UIDeviceOrientation)orientation
{
    UIDeviceOrientation tempOrientation;
    tempOrientation = currentMagazineOrientation;
    
    if (UIDeviceOrientationIsLandscape(orientation))
    {
        currentMagazineOrientation = orientation;
        return (UIDeviceOrientationIsPortrait(tempOrientation));
    }
    else if (UIDeviceOrientationIsPortrait(orientation))
    {
        currentMagazineOrientation = orientation;
        return (UIDeviceOrientationIsLandscape(tempOrientation));
    }
    return NO;
}

-(void)deviceOrientationDidChange
{
    if (self.revision.horizontalMode && horizontalPagesViewControllers.count != 0)
    {
        if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
        {
			CGFloat     index = horizontalScrollView.contentOffset.x / horizontalScrollView.frame.size.width;
			NSInteger   currentIndex = lrintf(round(index));
			PCHorizontalPageController      *currentPageController = [horizontalPagesViewControllers objectAtIndex:currentIndex];
          
			[[NSNotificationCenter defaultCenter] postNotificationName:PCBoostPageNotification object:currentPageController.identifier userInfo:nil];
          
			
//            self.view.frame = CGRectMake(0, 0, 1024, 768);
//            [horizontalScrollView setFrame:CGRectMake(0, 0, 1024, 768)];
            [horizontalScrollView setHidden:NO];
            [mainScrollView setHidden:YES];
            
            if ([self isOrientationChanged:[[UIDevice currentDevice] orientation]])
            {
                [self hideMenus];
                NSInteger currentHorisontalPage = ((PCPage*)[((PCColumn*)[self.revision.columns objectAtIndex:[self currentColumnIndex]]).pages objectAtIndex:0]).horisontalPageIdentifier;
                NSArray *keys = [revision.horizontalPages allKeys];
                NSArray *sortedKeys = [keys sortedArrayUsingSelector: @selector(compare:)];
                NSInteger currentHorisontalPageIndex = [sortedKeys indexOfObject:[NSNumber numberWithInt:currentHorisontalPage]];
                [horizontalScrollView scrollRectToVisible:CGRectMake(1024*currentHorisontalPageIndex, 0, 1024, 768) animated:YES];
            }
			[currentPageController showHUD];
        }
        else if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]))
        {
          if (!self.currentColumnViewController.currentPageViewController.page.isComplete)
          {
            [[NSNotificationCenter defaultCenter] postNotificationName:PCBoostPageNotification object:self.currentColumnViewController.currentPageViewController.page userInfo:nil];
          }
			
          
            self.view.frame = CGRectMake(0, 0, 768, 1024);
            [mainScrollView setFrame:CGRectMake(0, 0, 768, 1024)];
            [horizontalScrollView setHidden:YES];
            [mainScrollView setHidden:NO];
            
            NSUInteger columnIndex = 0;
            NSArray *columns = mainScrollView.subviews;
            for (UIView *column in columns) {
                column.frame = CGRectMake(self.view.frame.size.width * columnIndex, 
                                          0, 
                                          self.view.frame.size.width, 
                                          self.view.frame.size.height);
                ++columnIndex;
            }
            
            if ([self isOrientationChanged:[[UIDevice currentDevice] orientation]])
            {
                [self hideMenus];
                NSInteger currentHorisontalPageIndex = lrint(horizontalScrollView.contentOffset.x/horizontalScrollView.frame.size.width);
                PCPage *page = [self pageAtHorizontalIndex:currentHorisontalPageIndex];
                [self showPage:page];
            }
            if (!isOS5())
            {
                [topMenuView setFrame:CGRectMake(0, 0, self.view.frame.size.width, topMenuView.frame.size.height)];
                tableOfContentButton.hidden = topMenuView.hidden;
            }
			[self.currentColumnViewController.currentPageViewController showHUD];
        }
    }
}

- (PCPage *) pageAtHorizontalIndex:(NSInteger)currentHorisontalPageIndex
{
    NSArray *keys = [revision.horizontalPages allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingSelector: @selector(compare:)];
    if (currentHorisontalPageIndex < 0 || currentHorisontalPageIndex >= [sortedKeys count])
        return nil;
    NSInteger currentHorisontalPage = [[sortedKeys objectAtIndex:currentHorisontalPageIndex] integerValue];
    PCPage *currentPage = nil;
    NSInteger pageCounter = 0;
    while (currentPage.horisontalPageIdentifier != currentHorisontalPage && pageCounter < [self.revision.pages count]) 
    {
        currentPage = [self.revision.pages objectAtIndex:pageCounter];
        pageCounter ++;
    }
    if (currentPage.horisontalPageIdentifier != currentHorisontalPage)
    {
        if (currentHorisontalPageIndex > 1)
        {
            currentHorisontalPageIndex --;
            currentPage = [self pageAtHorizontalIndex:currentHorisontalPageIndex];
        }
    }
    return currentPage;
}

- (void) changeHorizontalPage:(id) sender
{
    [self hideMenus];
    NSInteger index = [sender tag]/100;
    if (index < 0 || index >= [self.revision.horizontalPages count])
        return;
    [horizontalScrollView scrollRectToVisible:CGRectMake(1024*index, 0, 1024, 768) animated:YES];
}

- (void) horizontalTapAction:(id) sender
{
    NSLog(@"tapAction sender=%@",NSStringFromCGPoint([sender locationInView:[sender view]]));
    [horizontalTopMenuView setFrame:CGRectMake(0, 0, 1024, 43)];

    if (![horizontalSummaryView.subviews count] > 0)
    {
        [self createHorizontalSummary];
    }
    
    horizontalSummaryView.hidden = !horizontalSummaryView.hidden;
    horizontalSummaryView.alpha = horizontalSummaryView.hidden?0.0:1.0;
    [self.view bringSubviewToFront:horizontalSummaryView];
    
    horizontalTopMenuView.hidden = !horizontalTopMenuView.hidden;
    horizontalTopMenuView.alpha = horizontalTopMenuView.hidden?0.0:1.0;
    [self.view bringSubviewToFront:horizontalTopMenuView];
}

-(PCPageViewController*)showPage:(PCPage*)page
{    
    NSInteger columnIndex  = [self.revision.columns indexOfObject:page.column];
    if (columnIndex!=NSNotFound && columnIndex<[columnsViewControllers count])
    {
        PCColumnViewController* columnViewController = [columnsViewControllers objectAtIndex:columnIndex];
        [mainScrollView scrollRectToVisible:columnViewController.view.frame animated:YES];
        return [columnViewController showPage:page];
    }
    return nil;
}

-(PCColumnViewController*)showColumnAtIndex:(NSInteger)columnIndex
{
    if (columnIndex >= 0 && columnIndex < [columnsViewControllers count])
    {
        PCColumnViewController* columnViewController = [columnsViewControllers objectAtIndex:columnIndex];
        if (columnViewController)
            [mainScrollView scrollRectToVisible:columnViewController.view.frame animated:YES];
        return columnViewController;
    }
    return nil;
}

-(PCColumnViewController*)showColumn:(PCColumn*)column
{
    NSInteger columnIndex = [self.revision.columns indexOfObject:column];
    if (columnIndex != NSNotFound && columnIndex < [columnsViewControllers count])
        return [self showColumnAtIndex:columnIndex];
    return nil;
}

-(BOOL)showNextColumn
{
    CGPoint point = [mainScrollView contentOffset];
    point.x += mainScrollView.frame.size.width;
    if (point.x < mainScrollView.contentSize.width - mainScrollView.frame.size.width)
    {
        [mainScrollView setContentOffset:point animated:YES];
        return YES;
    }
    else
    {
        return NO;
    }
}

-(BOOL)showPrevColumn
{
    CGPoint point = [mainScrollView contentOffset];
    point.x -= mainScrollView.frame.size.width;
    if (point.x > 0)
    {
        [mainScrollView setContentOffset:point animated:YES];
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void) loadFullColumnAtIndex:(NSInteger) index
{
    if(index >= 0 && index < [columnsViewControllers count])
    {
        PCColumnViewController *currentColumn = [columnsViewControllers objectAtIndex:index];
        [currentColumn loadFullView];
    }
}

- (void) unloadFullColumnAtIndex:(NSInteger) index
{
    if(index >= 0 && index < [columnsViewControllers count])
    {
        PCColumnViewController *columnViewController = [columnsViewControllers objectAtIndex:index];
        [columnViewController unloadFullView];
    }
}

- (NSInteger) currentColumnIndex
{
    if(self.revision.horizontalOrientation) return mainScrollView.contentOffset.x / 1024;
    return mainScrollView.contentOffset.x / 768;
}

- (PCColumnViewController*) currentColumnViewController
{
    if([self currentColumnIndex] >= 0 && [self currentColumnIndex] < [columnsViewControllers count])
    {
        return [columnsViewControllers objectAtIndex:[self currentColumnIndex]];
    }
    return nil;
}

- (void)clearMemory
{
	NSInteger currentIndex = [self currentColumnIndex];
	
    
    for(int i = 0; i < [columnsViewControllers count]; ++i)
    {
        if(ABS(currentIndex - i) > 0)
        {
            [self unloadFullColumnAtIndex:i];
        }
        else
        {
            [self loadFullColumnAtIndex:i];
        }
    }
    
    [self hideMenus];
    [self unloadSummaries];
}

- (void)unloadAll
{
	
    for(int i = 0; i < [columnsViewControllers count]; ++i)
    {
       [self unloadFullColumnAtIndex:i];
	}
	
	for(int i = 0; i < [horizontalPagesViewControllers count]; i++)
    {
        PCHorizontalPageController      *page = [horizontalPagesViewControllers objectAtIndex:i];
		
        [page unloadFullView];
	}
    
    for (UIView *tocView in topSummaryView.subviews)
    {
        [tocView removeFromSuperview];
    }
    
    [self unloadSummaries];
}

- (void) unloadSummaries
{
    for (UIView *stripeView in tableOfContentsView.subviews)
    {
        [stripeView removeFromSuperview];
    }
    
    for (UIView *horizontalStripeView in horizontalSummaryView.subviews)
    {
        [horizontalStripeView removeFromSuperview];
    }
}

- (void) updateViewsForCurrentIndex
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		if (!self.currentColumnViewController.currentPageViewController.page.isComplete)
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:PCBoostPageNotification object:self.currentColumnViewController.currentPageViewController.page userInfo:nil];
		}
		
		
		NSInteger currentIndex = [self currentColumnIndex];
		[self loadFullColumnAtIndex:currentIndex];
		
		for(int i = 0; i < [columnsViewControllers count]; ++i)
		{
			if(ABS(currentIndex - i) > 1)
			{
				[self unloadFullColumnAtIndex:i];
			}
			else
			{	
				if (i != currentIndex)[self loadFullColumnAtIndex:i];
			}
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.currentColumnViewController.currentPageViewController showHUD];
		});
		
		[PCGoogleAnalytics trackPageView:self.currentColumnViewController.currentPageViewController.page];
	});
  
}

- (void) updateViewsForCurrentIndexHorizontal
{
    if (horizontalPagesViewControllers == nil || horizontalPagesViewControllers.count == 0) {
        return;
    }

    CGFloat     index = horizontalScrollView.contentOffset.x / horizontalScrollView.frame.size.width;
    NSInteger   currentIndex = lrintf(round(index));
	//NSAssert((currentIndex >= 0 && currentIndex < [horizontalPagesViewControllers count]),!"Ivalid currentIndex");
	PCHorizontalPageController      *currentPageController = [horizontalPagesViewControllers objectAtIndex:currentIndex];
 
	[[NSNotificationCenter defaultCenter] postNotificationName:PCBoostPageNotification object:currentPageController.identifier userInfo:nil];
    
    for(int i = 0; i < [horizontalPagesViewControllers count]; i++)
    {
        PCHorizontalPageController      *page = [horizontalPagesViewControllers objectAtIndex:i];

        if(ABS(currentIndex - i) > 1)
        {
            [page unloadFullView];
        }
        else
        {
            [page loadFullView];
        }
    }
     [currentPageController showHUD];
    if (currentIndex >= 0 && currentIndex < [horizontalPagesViewControllers count])
    {
        PCHorizontalPageController      *page = [horizontalPagesViewControllers objectAtIndex:currentIndex];
        [horizontalScrollView scrollRectToVisible:page.view.frame animated:YES];
    }

    PCRevision *currentRevision = currentPageController.revision;
    PCIssue *currentIssue = currentRevision.issue;
    PCApplication *currentApplication = currentIssue.application;
    
    [PCGoogleAnalytics trackPageNameView:[NSString stringWithFormat:@"/Application_%u/Issue_%u/Revision_%u/Page_%u",
                                          currentApplication.identifier, currentIssue.identifier, currentRevision.identifier, 
                                          currentPageController.pageIdentifier]];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate)
    {
        if(scrollView==horizontalScrollView)
        {
            [self updateViewsForCurrentIndexHorizontal];
        } else {
            [self updateViewsForCurrentIndex];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView==horizontalScrollView)
    {
        [self updateViewsForCurrentIndexHorizontal];
    } else {
        [self updateViewsForCurrentIndex];
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if(scrollView==horizontalScrollView)
    {
        [self updateViewsForCurrentIndexHorizontal];
    } else {
        [self updateViewsForCurrentIndex];
    }
}


-(void)tapAction:(UIGestureRecognizer*)sender
{
    if (revision.horizontalOrientation) {
        [topMenuView setFrame:CGRectMake(0, 0, 1024, 43)];
    } else {
        [topMenuView setFrame:CGRectMake(0, 0, 768, 43)];
    }

    [UIView animateWithDuration:0.3f animations:^{

        if (revision.toc.count > 0) {
            PCTocItem *tocItem = [revision.toc objectAtIndex:revision.toc.count - 2];
            NSString *imagePath = [revision.contentDirectory stringByAppendingPathComponent:tocItem.thumbSummary];
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
            if (fileExists) {
                tableOfContentButton.hidden = !tableOfContentButton.hidden;
            } else {
                tableOfContentButton.hidden = YES;
            }
            tableOfContentButton.alpha = tableOfContentButton.hidden ? 0 : 1;
        } else {
            tableOfContentButton.hidden = YES;
            tableOfContentButton.alpha = 0;
        }
        
        if (!tableOfContentsView.hidden) {
            tableOfContentsView.hidden = YES;
            tableOfContentsView.alpha = 0;
        }
        
        topMenuView.hidden = !topMenuView.hidden;
        topMenuView.alpha = topMenuView.hidden ? 0 : 1;
        
        if (!topSummaryView.hidden) {
            topSummaryView.hidden = YES;
            topSummaryView.alpha = 0;
        }
        
        if (!shareMenu.hidden) {
            shareMenu.hidden = YES;
            shareMenu.alpha = 0;
        }
        
    }];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *) touch {
 
  if (([touch.view isKindOfClass:[UIButton class]]) &&
      ((gestureRecognizer == tapGestureRecognizer) || (gestureRecognizer == horizontalTapGestureRecognizer))) {
    return NO;
  }
  return YES;
}

-(IBAction)showTOCAction:(id)sender
{
    [topSummaryView setHidden:YES];
    [UIView beginAnimations:@"showTocView" context:nil];
    
    if (![tableOfContentsView.subviews count] > 0)
    {
        [self createTableOfContents];
    }
    
    [UIView setAnimationDuration:1];
    tableOfContentsView.hidden = !tableOfContentsView.hidden;
    tableOfContentsView.alpha = tableOfContentsView.hidden?0.0:1.0;
    [UIView commitAnimations];
}

-(void)selectTOCItemAction:(id)sender
{
    NSInteger index = [sender tag];
    
    NSLog(@"selectTOCItemAction: tag: %d", index);
    NSLog(@"tableOfContentsView.contentSize %@", NSStringFromCGSize(tableOfContentsView.contentSize));
    
    //if (index < 0 || index >= [self.revision.toc count])
    //    return;
    //PCTocItem* tocItem = [self.revision.toc objectAtIndex:index];
    //PCPage* page = [self.revision pageWithId:tocItem.firstPageIdentifier];
    [self hideMenus];
    //[self showPage:page];
    [self showPageWithIndex:index];
}

-(IBAction)showTopSummary:(id)sender
{
    [tableOfContentsView setHidden:YES];
    [UIView beginAnimations:@"showTopSummaryView" context:nil];
    
    if (![topSummaryView.subviews count] > 0)
    {
        [self createTopSummaryView];
    }
    
    [UIView setAnimationDuration:1];
    topSummaryView.hidden = !topSummaryView.hidden;
    topSummaryView.alpha = topSummaryView.hidden?0.0:1.0;
    [UIView commitAnimations];
}

-(IBAction)homeAction:(id)sender
{
    // return to kiosk
    [self hideMenus];
	[self unloadAll];
    [self.mainViewController switchToKiosk];
}

-(IBAction)helpAction:(id)sender
{
    [self hideMenus];
    if (!helpController)
    {
        helpController = [[PCHelpViewController alloc] initWithRevision:self.revision];
        helpController.tintColor = self.revision.color;
        helpController.delegate = self;
    }

    [self.view addSubview:helpController.view];
}

-(IBAction)shareAction:(id)sender
{
    if (!shareMenu)
    {
        shareMenu = [[UIView alloc] init];
        
        UIImageView* bg = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sharePopup.png"]] autorelease];
        shareMenu.frame = CGRectMake(self.view.frame.size.width - 200, 38, bg.frame.size.width, bg.frame.size.height);
        [shareMenu addSubview:bg];
        
        UILabel* caption = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, shareMenu.frame.size.width, 20)];
        caption.text = @"PARTAGE";
        caption.font = [UIFont fontWithName:@"Helvetica" size:17];
        caption.textColor = [UIColor whiteColor];
        caption.textAlignment = UITextAlignmentCenter;
        caption.backgroundColor = [UIColor clearColor];
        [shareMenu addSubview:caption];
        [caption release];
        
        UIButton *btnFacebook = [UIButton buttonWithType:UIButtonTypeCustom];
        btnFacebook.frame = CGRectMake(0, 0, 153, 45);
        btnFacebook.center = CGPointMake(85, 76);
        [btnFacebook addTarget:self action:@selector(facebookShow) forControlEvents:UIControlEventTouchUpInside];
        [btnFacebook setImage:[UIImage imageNamed:@"btnFacebook.png"] forState:UIControlStateNormal];
        [shareMenu addSubview:btnFacebook];
        
        UILabel* facebookTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 45)];
        facebookTitle.font = [UIFont fontWithName:@"Arial" size:13];
        facebookTitle.textColor = [UIColor whiteColor];
        facebookTitle.backgroundColor = [UIColor blackColor];
        facebookTitle.center = CGPointMake(95, 76);
        facebookTitle.text = @"Facebook";
        [shareMenu addSubview:facebookTitle];
        [facebookTitle release];
        
        UIButton *btnTwitter = [UIButton buttonWithType:UIButtonTypeCustom];
        btnTwitter.frame = CGRectMake(0, 0, 153, 45);
        btnTwitter.center = CGPointMake(85, btnFacebook.center.y + 45);
        [btnTwitter addTarget:self action:@selector(twitterShow) forControlEvents:UIControlEventTouchUpInside];
        [btnTwitter setImage:[UIImage imageNamed:@"btnTwitter.png"] forState:UIControlStateNormal];
        [shareMenu addSubview:btnTwitter];
        
        UILabel* twitterTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 45)];
        twitterTitle.font = [UIFont fontWithName:@"Arial" size:13];
        twitterTitle.textColor = [UIColor whiteColor];
        twitterTitle.backgroundColor = [UIColor blackColor];
        twitterTitle.center = CGPointMake(95, btnFacebook.center.y + 45);
        twitterTitle.text = @"Twitter";
        [shareMenu addSubview:twitterTitle];
        [twitterTitle release];
        
        UIButton *btnEmail = [UIButton buttonWithType:UIButtonTypeCustom];
        btnEmail.frame = CGRectMake(0, 0, 153, 45);
        btnEmail.center = CGPointMake(85, btnTwitter.center.y + 45);
        [btnEmail addTarget:self action:@selector(emailShow) forControlEvents:UIControlEventTouchUpInside];
        [btnEmail setImage:[UIImage imageNamed:@"btnEmail.png"] forState:UIControlStateNormal];
        [shareMenu addSubview:btnEmail];
        
        UILabel* emailTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 102, 45)];
        emailTitle.font = [UIFont fontWithName:@"Arial" size:13];
        emailTitle.textColor = [UIColor whiteColor];
        emailTitle.backgroundColor = [UIColor blackColor];
        emailTitle.center = CGPointMake(95 + 11, btnTwitter.center.y + 45);
        emailTitle.text = @"Envoyer un Mail";
        [shareMenu addSubview:emailTitle];
        [emailTitle release];
        
        [self.view addSubview:shareMenu];
        shareMenu.hidden = YES;
    }
    
    shareMenu.frame = CGRectMake(self.view.frame.size.width - 200, 38, shareMenu.frame.size.width, shareMenu.frame.size.height);
    shareMenu.hidden = !shareMenu.hidden;
    shareMenu.alpha = shareMenu.hidden?0.0:1.0;
    /*if([shareMenu isDescendantOfView:self.view])
    {
        [shareMenu removeFromSuperview];
    } else {
        [self.view addSubview:shareMenu];
    }*/
}

- (void)hideMenus
{
    [shareMenu setHidden:YES];
    [tableOfContentsView setHidden:YES];
    [tableOfContentButton setHidden:YES];
    [topSummaryView setHidden:YES];
    [topMenuView setHidden:YES];
    [horizontalSummaryView setHidden:YES];
    [horizontalTopMenuView setHidden:YES];
}

- (void)emailShow
{
    //Email Controller show
    [self hideMenus];
    //[shareMenu removeFromSuperview];
    if (!emailController)
    {
        NSDictionary *emailMessage = [self.revision.issue.application.notifications objectForKey:PCEmailNotificationType];
        emailController = [[PCEmailController alloc] initWithMessage:emailMessage];
    }
    emailController.delegate = self;
    [emailController emailShow];
}

- (void)facebookShow
{
    // Facebook Controller Show
    [self hideMenus];

    if (!facebookViewController)
    {
        NSString *facebookMessage = [[self.revision.issue.application.notifications objectForKey:PCFacebookNotificationType]objectForKey:PCApplicationNotificationMessageKey];
        facebookViewController = [[PCFacebookViewController alloc] initWithMessage:facebookMessage];
    }
    [facebookViewController initFacebookSharer];
}

- (void)twitterShow
{
    //Twitter Controller show
    [self hideMenus];
    //[shareMenu removeFromSuperview];
    NSString *twitterMessage = [[self.revision.issue.application.notifications objectForKey:PCTwitterNotificationType]objectForKey:PCApplicationNotificationMessageKey];
    if (isOS5())
    {
        PCTwitterNewController *twitterController = [[[PCTwitterNewController alloc] initWithMessage:twitterMessage] autorelease];
        twitterController.delegate = self;
        [twitterController showTwitterController];
    }
}


-(void)finishTocDownload:(NSNotification*)notif
{
  [self createTableOfContents];
  [self createTopSummaryView];
}
#pragma mark PCEmailControllerDelegate methods

- (void)dismissPCEmailController:(MFMailComposeViewController *)currentPCEmailController
{
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) 
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    } 
    else
    {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)showPCEmailController:(MFMailComposeViewController *)emailControllerToShow
{
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) 
    {
        [self presentViewController:emailControllerToShow animated:YES completion:nil];
    } 
    else 
    {
        [self presentModalViewController:emailControllerToShow animated:YES];   
    }
}

#pragma mark TwitterNewControllerDelegate methods

- (void)dismissPCNewTwitterController:(TWTweetComposeViewController *)currentPCTwitterNewController
{
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) 
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    } 
    else
    {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)showPCNewTwitterController:(TWTweetComposeViewController *)tweetController
{
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) 
    {
        [self presentViewController:tweetController animated:YES completion:nil];
    } 
    else 
    {
        [self presentModalViewController:tweetController animated:YES];   
    }
}

- (void)dismissPCHelpViewController:(PCHelpViewController *)currentPCHelpViewController
{
    [currentPCHelpViewController.view removeFromSuperview];
    [self deviceOrientationDidChange];
}

- (IBAction)searchTextDidEndOnExit:(id)sender
{
    if([sender isKindOfClass:[UITextField class]])
    {
        UITextField     *searchField = (UITextField*) sender;
        [searchField resignFirstResponder];
        
        [self hideMenus];
        if (!searchController)
        {
            searchController = [[PCSearchViewController alloc] initWithNibName:@"PCSearchViewController" bundle:nil];
            searchController.revision = self.revision;
            searchController.delegate = self;
        }
        searchController.searchKeyphrase = searchField.text;
        
        [self.view addSubview:searchController.view];
    }
}

-(void)showPageWithIndex:(NSInteger) pageIndex
{
    if (revision.pages)
    {
        if (pageIndex >= 0 && pageIndex < [revision.pages count])
        {
            PCPage *page = [revision.pages objectAtIndex:pageIndex];
            [self showPage:page];
        }
    }
}

#pragma mark - PCSearchViewControllerDelegate

- (void) showRevisionWithIdentifier:(NSInteger) revisionIdentifier andPageIndex:(NSInteger) pageIndex
{
    if(revisionIdentifier==revision.identifier)
    {
        [self showPageWithIndex:pageIndex];
    }
}

- (void)dismissPCSearchViewController:(PCSearchViewController *)currentPCSearchViewController
{
    [currentPCSearchViewController.view removeFromSuperview];
    [self deviceOrientationDidChange];
}

#pragma mark - PCVideoControllerDelegate

//- (void) videoControllerWillShow:(UIViewController *)videoControllerToShow animated:(BOOL)willAnimated
//{
//    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) 
//    {
//        [self presentViewController:videoControllerToShow animated:willAnimated completion:nil];
//    } 
//    else 
//    {
//        [self presentModalViewController:videoControllerToShow animated:willAnimated];   
//    } 
//}

- (void)videoControllerShow:(PCVideoController *)videoController
{
    UIView *playerView = videoController.moviePlayer.view;
    playerView.autoresizingMask = UIViewContentModeScaleAspectFill;
    playerView.frame = self.view.bounds;
    [self.view addSubview:playerView];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)videoControllerHide:(PCVideoController *)videoController
{
    [videoController.moviePlayer.view removeFromSuperview];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

#pragma mark -

//- (void) moviePlayerWillShow:(MPMoviePlayerController *)moviePlayerToShow
//{ 
//    [moviePlayerToShow.view setAutoresizingMask:UIViewContentModeScaleAspectFill];
//    [moviePlayerToShow.view setFrame:self.view.bounds];
//    [self.view addSubview:moviePlayerToShow.view];
//}

- (void) showGalleryViewController:(PCGalleryViewController*)vgalleryViewController
{
    [self hideMenus];
    [self.mainScrollView setScrollEnabled:NO];
    galleryViewController = vgalleryViewController;
    [self.view addSubview:galleryViewController.view];
  //  [self unloadAll];
	[self clearMemory];
/*    
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) 
    {
        [self presentViewController:galleryViewController animated:YES completion:nil];
    } 
    else 
    {
        [self presentModalViewController:galleryViewController animated:YES];   
    }
 */
}

- (void) dismissGalleryViewController
{
	
    [galleryViewController.view removeFromSuperview];
    [self.mainScrollView setScrollEnabled:YES];
	[self updateViewsForCurrentIndex];
/*    
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) 
    {
        [self dismissViewControllerAnimated:YES completion:nil]; 
    } 
    else
    {
        [self dismissModalViewControllerAnimated:YES];
    }
    
    [self.mainScrollView setScrollEnabled:YES];*/
    [self deviceOrientationDidChange];
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
	{
		[self updateViewsForCurrentIndexHorizontal];
	}
	else
	{
		[self updateViewsForCurrentIndex];
	}
		
}

@end
