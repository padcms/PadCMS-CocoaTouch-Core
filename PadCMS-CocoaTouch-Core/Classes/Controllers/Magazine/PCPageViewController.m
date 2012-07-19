//
//  PCPageViewController.m
//  Pad CMS
//
//  Created by Rustam Mallakurbanov on 03.02.12.
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

#import "PCPageViewController.h"

#import "Helper.h"
#import "MBProgressHud.h"
#import "PCDefaultStyleElements.h"
#import "PCGoogleAnalytics.h"
#import "PCRevision.h"
#import "PCScrollView.h"
#import "PCSliderBasedMiniArticleViewController.h"
#import "PCStyler.h"
#import "PCBrowserViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface  PCPageViewController(ForwardDeclaration)

- (void) createGalleryButton;
- (void) showHUD;
- (void) hideHUD;
- (void) showGallery:(id)sender;
- (void) showGalleryWithID:(NSInteger)ID initialPhotoID:(NSInteger)photoID;
- (void) showVideoWebView: (NSString *)videoWebViewURL inRect: (CGRect)videoWebViewRect;
- (void) hideVideoWebView;
- (void) hideSubviews;

@end

@implementation PCPageViewController

@synthesize magazineViewController;
@synthesize columnViewController;
@synthesize page;
@synthesize backgroundViewController;
@synthesize mainScrollView;
@synthesize bodyViewController;
@synthesize galleryButton;
@synthesize videoButton;
@synthesize isVisible;
@synthesize galleryViewController;
@synthesize videoWebView;

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:endOfDownloadingPageNotification object:nil];
	[self.page removeObserver:self forKeyPath:@"isComplete"];
    if ([self mainScrollView] != nil)
        [[self mainScrollView] removeGestureRecognizer:tapGestureRecognizer];
    
    [tapGestureRecognizer release];
    tapGestureRecognizer = nil;
    
    self.page = nil;
    self.backgroundViewController = nil;
    self.mainScrollView = nil;
    self.bodyViewController = nil;
    self.galleryButton = nil;
    self.videoButton = nil;
    self.magazineViewController = nil;
    self.columnViewController = nil;
    self.galleryViewController = nil;
    self.videoWebView = nil;
    [HUD release];
    [super dealloc];
}


-(id)initWithPage:(PCPage *)aPage
{
    if (self = [super initWithNibName:nil bundle:nil])
    {
        self.page = aPage;
        magazineViewController = nil;
        columnViewController = nil;
        backgroundViewController = nil;
        bodyViewController = nil;
        mainScrollView = nil;
        galleryButton = nil;
        videoButton = nil;
        videoWebView = nil;
        if ([self.page elementsForType:PCPageElementTypeGallery].count > 0)
        {
            galleryViewController = [[PCGalleryViewController alloc] initWithPage:self.page];
        }
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endDownloadingPCPageOperation:) name:endOfDownloadingPageNotification object:self.page];
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    CGSize pageSize = [self.columnViewController pageSizeForViewController:self];
    CGRect pageRect = CGRectMake(0, 0, 600, 1000);
    
    self.view = [[[UIView alloc] initWithFrame:pageRect] autorelease];  
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.opaque = NO;
    
    self.mainScrollView  = [[[PCScrollView alloc] initWithFrame:self.view.bounds] autorelease];
    self.mainScrollView.showsVerticalScrollIndicator = NO;
    self.mainScrollView.showsHorizontalScrollIndicator = NO;
    self.mainScrollView.bounces = YES;
    self.mainScrollView.pagingEnabled = NO;
    self.mainScrollView.alwaysBounceVertical = NO;
    self.mainScrollView.alwaysBounceHorizontal = NO;
    self.mainScrollView.clipsToBounds = YES;
    self.mainScrollView.verticalScrollButtonsEnabled = YES;

    [self.mainScrollView setContentSize:self.bodyViewController.view.frame.size];
    [self.view addSubview:self.mainScrollView];
    
    if (self.page.pageTemplate != [[PCPageTemplatesPool templatesPool] templateForId:PCBasicArticlePageTemplate] 
        && self.page.pageTemplate != [[PCPageTemplatesPool templatesPool] templateForId:PCArticleWithFixedIllustrationPageTemplate]) {
      self.mainScrollView.scrollEnabled = NO;
    } else {
        self.mainScrollView.scrollEnabled = YES;
    }
    
//    if (self.page.color != nil) {
//        self.mainScrollView.scrollButtonsTintColor = self.page.color; 
//    }
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
	tapGestureRecognizer.cancelsTouchesInView = NO;
	tapGestureRecognizer.delegate = self;
    [self.mainScrollView  addGestureRecognizer:tapGestureRecognizer];
    
    if (self.galleryButton != nil) {
        [self.galleryButton.superview bringSubviewToFront:self.galleryButton];
    }
}

- (void) loadFullView
{
	isLoaded = YES;
	//[self showHUD];
    [self.backgroundViewController loadFullViewImmediate];
    [self.bodyViewController loadFullViewImmediate];
    
    CGSize bodySize = self.bodyViewController.view.frame.size;
    
    [self.mainScrollView setContentSize:bodySize];
    
    if ([self.page hasPageActiveZonesOfType:PCPDFActiveZoneVideo] && 
        ![self.page hasPageActiveZonesOfType:PCPDFActiveZoneActionVideo])
    {
        CGRect videoRect = [self activeZoneRectForType:PCPDFActiveZoneVideo];
        PCPageElementVideo *videoElement = (PCPageElementVideo*)[self.page firstElementForType:PCPageElementTypeVideo];
        
        if (videoElement.stream)
            [self showVideoWebView:videoElement.stream inRect:videoRect];
        
        else if (videoElement.resource)
            [self showVideoWebView:[page.revision.contentDirectory stringByAppendingPathComponent:videoElement.resource] inRect:videoRect];
    }
    
    [self createGalleryButton];
    
    if (self.galleryButton != nil) {
        [self.galleryButton.superview bringSubviewToFront:self.galleryButton];
    }
}

- (void) unloadFullView
{
	isLoaded = NO;
	[self hideSubviews];
    [self.backgroundViewController unloadView];
    [self.bodyViewController unloadView];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //TODO need setting size only of biggest source to contentSize
    PCPageElement* backgroundElement = [page firstElementForType:PCPageElementTypeBackground];
    if (backgroundElement != nil)
    {
        NSString *fullResource = [page.revision.contentDirectory stringByAppendingPathComponent:backgroundElement.resource];
        
        self.backgroundViewController = [[[PCPageElementViewController alloc] initWithResource:fullResource] autorelease];
  //    self.backgroundViewController.element = backgroundElement;
        [self.backgroundViewController setTargetWidth:self.mainScrollView.bounds.size.width];
        [self.mainScrollView addSubview:self.backgroundViewController.view];
        [self.mainScrollView setContentSize:[self.backgroundViewController.view frame].size];
        
        CGFloat backgroundWidth = self.backgroundViewController.view.frame.size.width;
        CGFloat backgroundHeight = self.backgroundViewController.view.frame.size.height;
        self.backgroundViewController.view.frame = CGRectMake(0, 0, backgroundWidth, backgroundHeight);
    }
    
    PCPageElementBody* bodyElement = (PCPageElementBody*)[page firstElementForType:PCPageElementTypeBody];
    if (bodyElement != nil)
    {
        NSString *fullResource = [page.revision.contentDirectory stringByAppendingPathComponent:bodyElement.resource];
        
        self.bodyViewController = [[[PCPageElementViewController alloc] initWithResource:fullResource] autorelease];
     // self.bodyViewController.element = bodyElement;
        [self.bodyViewController setTargetWidth:self.mainScrollView.bounds.size.width];
        
//        if (self.page.pageTemplate == [[PCPageTemplatesPool templatesPool] templateForId:PCBasicArticlePageTemplate])  
//        {
//            /* if (self.bodyViewController.view.frame.size.height - self.mainScrollView.bounds.size.height < 3)//3 is a magic number!
//                 self.mainScrollView.scrollEnabled = NO;  */
//        }

        [self.mainScrollView addSubview:self.bodyViewController.view];
        [self.mainScrollView setContentSize:[self.bodyViewController.view frame].size];

        CGFloat bodyWidth = self.bodyViewController.view.frame.size.width;
        CGFloat bodyHeight = self.bodyViewController.view.frame.size.height;
        self.bodyViewController.view.frame = CGRectMake(0, 0, bodyWidth, bodyHeight);
    }
	
	[self.page addObserver:self forKeyPath:@"isComplete" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self hideSubviews];
    [super viewWillDisappear:animated];
}

- (void)showVideoWebView: (NSString *)videoWebViewURL inRect: (CGRect)videoWebViewRect
{
    CGRect videoRect = videoWebViewRect;
    if (CGRectEqualToRect(videoRect, CGRectZero))
    {
        videoRect = [[UIScreen mainScreen] bounds];
    }
    if (!webBrowserViewController)
    {
        webBrowserViewController = [[PCBrowserViewController alloc] init];
    }
    webBrowserViewController.videoRect = videoRect;
    [self.mainScrollView addSubview:webBrowserViewController.view];
    if (self.page.pageTemplate == 
        [[PCPageTemplatesPool templatesPool] templateForId:PCFixedIllustrationArticleTouchablePageTemplate])
    {
        [self changeVideoLayout:bodyViewController.view.hidden];
    }
    [webBrowserViewController presentURL:videoWebViewURL];
}

- (void)changeVideoLayout: (BOOL)isVideoEnabled
{
    if (webBrowserViewController)
    {
        if (isVideoEnabled)
        {
            [self.mainScrollView bringSubviewToFront:webBrowserViewController.view];
        }
        else 
        {
            [self.mainScrollView insertSubview:webBrowserViewController.view aboveSubview:self.backgroundViewController.view];    
        }
    }
}

- (void)hideVideoWebView
{
    /*if (videoWebView)
    {
        [videoWebView removeFromSuperview];
        [videoWebView release], videoWebView = nil;
    }*/
    if (webBrowserViewController)
    {
        [webBrowserViewController.view removeFromSuperview];
    }
}

- (void) hideSubviews
{
    [self hideHUD];
    [self hideVideoWebView];
}

-(void)showHUD
{
	if (!isLoaded) return;
	if (self.page.isComplete) return;
    if (HUD)
    {
        return;
        page.progressDelegate = nil;
        [HUD removeFromSuperview];
        [HUD release];
        HUD = nil;
    }
    self.page.isUpdateProgress = YES;
    HUD = [[MBProgressHUD alloc] initWithView:self.mainScrollView];
    [self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeAnnularDeterminate;
    page.progressDelegate = HUD;
    [HUD show:YES];

    if (self.galleryButton != nil) {
        [self.galleryButton.superview bringSubviewToFront:self.galleryButton];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
 // [self showHUD];
}

-(void)hideHUD
{
	if (HUD)
	{
    [HUD hide:YES];
    self.page.isUpdateProgress = NO;
		page.progressDelegate = nil;
		[HUD removeFromSuperview];
		[HUD release];
		HUD = nil;
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(self.magazineViewController.revision.horizontalOrientation)
    {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    }

    if (self.magazineViewController.revision.horizontalMode)
    {
        return YES;
    }

    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void) createGalleryButton
{
    if ([self.page hasPageActiveZonesOfType:PCPDFActiveZoneActionPhotos] 
        || [[self.page elementsForType:PCPageElementTypeGallery]count]<=0)
        return;
    
    PCPageElementGallery* galleryElement = (PCPageElementGallery*)[[page elementsForType:PCPageElementTypeGallery]objectAtIndex:0];
    
    PCPageElementBody* bodyElement = (PCPageElementBody*)[page firstElementForType:PCPageElementTypeBody];
    
    // Base controller must ignore gallery in page with template that show gallery when device orientation changed
    if (bodyElement && bodyElement.showGalleryOnRotate) return;
    
    if (galleryElement != nil || (bodyElement && bodyElement.hasPhotoGalleryLink))
    {
        if(self.galleryButton != nil)
        {
            [self.galleryButton removeFromSuperview];
        }
        
        //TODO need another style of this button ! (for the active zones)
        
        self.galleryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        NSDictionary* buttonOption = nil;
        if (self.page.color)
            buttonOption = [NSDictionary dictionaryWithObject:self.page.color forKey:PCButtonTintColorOptionKey];
        [[PCStyler defaultStyler] stylizeElement:self.galleryButton withStyleName:PCGalleryEnterButtonKey withOptions:buttonOption];
        [self.galleryButton setFrame:CGRectMake(self.view.frame.size.width - self.galleryButton.frame.size.width, 0, self.galleryButton.frame.size.width, self.galleryButton.frame.size.height)];
        [[PCStyler defaultStyler] stylizeElement:self.galleryButton withStyleName:PCGalleryEnterButtonKey withOptions:buttonOption];
        [self.galleryButton addTarget:self action:@selector(showGallery:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.galleryButton];
    }
    
}

- (void) showVideo:(NSString *)resourcePath
{      
    if (resourcePath == nil) return;
    
    if([[resourcePath pathExtension] isEqualToString:@""])
    {
        //[[NSNotificationCenter defaultCenter] postNotificationName:PCVCPushVideoScreenNotification object:resourcePath];
        
        CGRect mainScreenRect = [[UIScreen mainScreen] bounds];
        if (!webBrowserViewController)
        {
            webBrowserViewController = [[PCBrowserViewController alloc] init];
        }
        webBrowserViewController.videoRect = mainScreenRect;
        [self.view addSubview:webBrowserViewController.view];
        [webBrowserViewController presentURL:resourcePath];
    }
    else
    {
        NSURL* videoURL = nil;
        if ([resourcePath hasPrefix:@"http://"]||[resourcePath hasPrefix:@"https://"])
        {
            videoURL = [NSURL URLWithString:resourcePath];
        }
        else
        {
            videoURL = [NSURL fileURLWithPath:resourcePath];
        }
        if (videoURL)
            [[NSNotificationCenter defaultCenter] postNotificationName:PCVCFullScreenMovieNotification object:videoURL];
    }
}

- (void) showGallery:(id)sender
{
    [self showGalleryWithID:-1 initialPhotoID:-1];
}

- (void) showGalleryWithID:(NSInteger)ID initialPhotoID:(NSInteger)photoID
{
    if (galleryViewController)
    {
        galleryViewController.delegate = self;
        galleryViewController.horizontalOrientation = self.magazineViewController.revision.horizontalOrientation;
        galleryViewController.galleryID = ID;
        [self hideSubviews];
        [self.magazineViewController showGalleryViewController:galleryViewController];
        if (photoID > 0)
        {
            [galleryViewController setCurrentPhoto:photoID - 1];
            [galleryViewController showPhotoAtIndex:photoID - 1];
        }
    }
}

- (CGRect)activeZoneRectForType:(NSString*)zoneType
{
    for (PCPageElement* element in self.page.elements)
    {
        CGRect rect = [element rectForElementType:zoneType];
        if (!CGRectEqualToRect(rect, CGRectZero))
        {
            CGSize pageSize = [self.columnViewController pageSizeForViewController:self];
            float scale = pageSize.width/element.size.width;
            rect.size.width *= scale;
            rect.size.height *= scale;
            rect.origin.x *= scale;
            rect.origin.y *= scale;
            rect.origin.y = element.size.height*scale - rect.origin.y - rect.size.height;
            return rect;
        }
    }
    return CGRectZero;
}

//TODO in some time we have few active zones on one point

-(NSArray*)activeZonesAtPoint:(CGPoint)point
{
    NSMutableArray* activeZones = [[NSMutableArray alloc] init];
    
    for (PCPageElement* element in self.page.elements)
    {
        for (PCPageActiveZone* pdfActiveZone in element.activeZones)
        {
            CGRect rect = pdfActiveZone.rect;
            if (!CGRectEqualToRect(rect, CGRectZero))
            {
                CGSize pageSize = [self.columnViewController pageSizeForViewController:self];
                float scale = pageSize.width/element.size.width;
                rect.size.width *= scale;
                rect.size.height *= scale;
                rect.origin.x *= scale;
                rect.origin.y *= scale;
                rect.origin.y = element.size.height*scale - rect.origin.y - rect.size.height;
//                UIView* testView = [[UIView alloc] initWithFrame:rect];
//                testView.backgroundColor = [UIColor redColor];
//                [self.mainScrollView addSubview:testView];
                if (CGRectContainsPoint(rect, point))
                {
                    [activeZones addObject:pdfActiveZone];
                }
//                NSLog(@"fieldTypeName=%@ pdfActiveZone=%@",element.fieldTypeName,pdfActiveZone.URL);
            }
        }
    }
    return [activeZones autorelease];
}

-(BOOL)pdfActiveZoneAction:(PCPageActiveZone*)activeZone
{
    if ([activeZone.URL hasPrefix:PCPDFActiveZoneNavigation])
    {
        NSString* mashinName = [activeZone.URL lastPathComponent];
        NSArray* components = [mashinName componentsSeparatedByString:@"#"];
        NSString* addeditional = nil;
        if ([components count] > 1)
        {
            mashinName = [components objectAtIndex:0];
            addeditional = [components objectAtIndex:1];
        }
        
        PCPage* targetPage = [page.revision pageWithMachineName:mashinName];
        
        if (targetPage)
        {
            PCPageViewController* pageController = [magazineViewController showPage:targetPage];
            if ([pageController isKindOfClass:[PCSliderBasedMiniArticleViewController class]])
            {
                [(PCSliderBasedMiniArticleViewController*)pageController showArticleAtIndex:[addeditional integerValue] - 1];
                return YES;
            }
        }
    }
    //if ([activeZone.URL hasPrefix:PCPDFActiveZoneActionVideo]||[activeZone.URL hasPrefix:PCPDFActiveZoneVideo])
    if ([activeZone.URL hasPrefix:PCPDFActiveZoneActionVideo])
    {
        if ([self.page hasPageActiveZonesOfType:PCPDFActiveZoneVideo])
        {
            if (videoWebView && videoWebView.superview)
                [self hideVideoWebView];
            else
            {
                CGRect videoRect = [[UIScreen mainScreen] bounds];
                PCPageElementVideo *videoElement = (PCPageElementVideo*)[self.page firstElementForType:PCPageElementTypeVideo];
                [self showVideoWebView:videoElement.stream inRect:videoRect];
            }
            return YES;
        }
        NSArray* videoElements = [page elementsForType:PCPageElementTypeVideo];
        PCPageElementVideo* video = nil;
        if ([videoElements count]>1)
        {
            NSArray* comps = [activeZone.URL componentsSeparatedByString:PCPDFActiveZoneActionVideo];
            if (comps&&[comps count]>1)
            {
            
                NSString* num = [comps objectAtIndex:1];
                int number = [num intValue]-1;
                video = [videoElements objectAtIndex:number];
            }
            else
            {
                video = [videoElements objectAtIndex:0];
            }
        }
        else 
        {
            if ([videoElements count]>0)
                video = [videoElements objectAtIndex:0];
        }
        
        if (video)
        {
            if (video.stream)
                [self showVideo:video.stream];
                
            if (video.resource)
                [self showVideo:[page.revision.contentDirectory stringByAppendingPathComponent:video.resource]];
            
            return YES;
        }
    }
    
    if ([activeZone.URL hasPrefix:PCPDFActiveZoneActionPhotos])
    {
        NSString *url = activeZone.URL;
        NSInteger photoID = [[url lastPathComponent] integerValue];
        NSInteger galleryID = [[[url stringByDeletingLastPathComponent] lastPathComponent] integerValue];
        if (galleryID == 0)
        {
            galleryID = photoID;
            photoID = 0;
        }
        NSLog(@"url - %@, gallery - %d, photo - %d", activeZone.URL, galleryID, photoID);
        [self showGalleryWithID:galleryID initialPhotoID:photoID];
        return YES;
    }
    
    if ([activeZone.URL hasPrefix:@"http://"])
    {
        if ([[activeZone.URL pathExtension] isEqualToString:@"mp4"]||[[activeZone.URL pathExtension] isEqualToString:@"avi"])
        {
            [self showVideo:activeZone.URL];
            return YES;
        }
        
        else if ([activeZone.URL hasPrefix:@"http://youtube.com"] || [activeZone.URL hasPrefix:@"http://www.youtube.com"] ||
                  [activeZone.URL hasPrefix:@"http://youtu.be"] || [activeZone.URL hasPrefix:@"http://www.youtu.be"] || 
                  [activeZone.URL hasPrefix:@"http://dailymotion.com"] || [activeZone.URL hasPrefix:@"http://www.dailymotion.com"] ||
                  [activeZone.URL hasPrefix:@"http://vimeo.com"] || [activeZone.URL hasPrefix:@"http://www.vimeo.com"])
        {
            CGRect videoRect = [self activeZoneRectForType:PCPDFActiveZoneVideo];
            [self showVideoWebView:activeZone.URL inRect:videoRect];            
            return YES;
        }
        
        else 
        {
            if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:activeZone.URL]])
            {
                NSLog(@"Failed to open url:%@",[activeZone.URL description]);
            }
        }
    }
    return NO;
}

-(void)tapAction:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.mainScrollView];
    NSArray* actions = [self activeZonesAtPoint:point];
    for (PCPageActiveZone* action in actions)
        if ([self pdfActiveZoneAction:action])
            break;
    if (actions.count == 0)
    {
        [self.magazineViewController tapAction:gestureRecognizer];
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *) touch {
	
	if (([touch.view isKindOfClass:[UIButton class]]) &&
		(gestureRecognizer == tapGestureRecognizer)) {
		return NO;
	}
	return YES;
}


- (void)endDownloadingPCPageOperation:(NSNotification*)notif
{
  if (!isLoaded) return;
  if (notif.object == self.page)
  {
    [self unloadFullView];
    [self loadFullView];
    if (self.page.pageTemplate == [[PCPageTemplatesPool templatesPool] templateForId:PCBasicArticlePageTemplate])  
    {
   /*   if (self.bodyViewController.view.frame.size.height - self.mainScrollView.bounds.size.height > 3)//3 is a magic number!
        self.mainScrollView.scrollEnabled = YES;  */
    }
    [HUD hide:YES];
  }
    
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.mainScrollView];
    NSArray* actions = [self activeZonesAtPoint:point];
    if (actions&&[actions count]>0)
        return YES;
    
    return NO;
}

#pragma mark GalleryViewControllerDelegate methods

- (void) galleryViewControllerWillDismiss
{
    if (!self.page.isComplete || ![self.page isSecondaryElementsComplete]) 
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:PCBoostPageNotification object:self.page userInfo:nil];
        [self showHUD];
    }
    if ([self.page hasPageActiveZonesOfType:PCPDFActiveZoneVideo] && ![self.page hasPageActiveZonesOfType:PCPDFActiveZoneActionVideo])
    {
        CGRect videoRect = [self activeZoneRectForType:PCPDFActiveZoneVideo];
        PCPageElementVideo *videoElement = (PCPageElementVideo*)[self.page firstElementForType:PCPageElementTypeVideo];
        if (videoElement.stream)
            [self showVideoWebView:videoElement.stream inRect:videoRect];
        
        else if (videoElement.resource)
            [self showVideoWebView:[page.revision.contentDirectory stringByAppendingPathComponent:videoElement.resource] inRect:videoRect];
    }
    [self.magazineViewController dismissGalleryViewController];
}

-(void) observeValueForKeyPath: (NSString *)keyPath ofObject: (id) object
                        change: (NSDictionary *) change context: (void *) context
{
	if([change objectForKey:NSKeyValueChangeNewKey] != [NSNull null]) 
	{
		 BOOL newValue = [[change objectForKey: NSKeyValueChangeNewKey] boolValue];
		if (newValue) [self hideHUD];
		else [self showHUD];
	}
		
   
}

@end
