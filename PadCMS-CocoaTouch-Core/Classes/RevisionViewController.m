//
//  RevisionViewController.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Petrosyan on 7/4/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "RevisionViewController.h"
#import "PCMagazineViewControllersFactory.h"
#import "PCPageViewController.h"
#import "RRComplexScrollView.h"

@interface RevisionViewController ()

@end

@implementation RevisionViewController
@synthesize mainScroll=_mainScroll;
@synthesize revision=_revision;
@synthesize currentPageController=_currentPageController;
@synthesize previousPageController=_previousPageController;
@synthesize onScreenPage=_onScreenPage;

-(id)initWithRevision:(PCRevision *)revision
{
	self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _revision = [revision retain];
		_onScreenPage = [revision.coverPage retain];
    }
    return self;
}

/*-(void)loadView
{
	RRComplexScrollView* mainScroll = [[RRComplexScrollView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	mainScroll.delegate = self;
	mainScroll.datasource = self;
	self.view = mainScroll;
	self.mainScroll = mainScroll;
	[mainScroll release];
}*/

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _mainScroll = [[RRComplexScrollView alloc] initWithFrame:self.view.bounds];
    
//	self.view.backgroundColor = [UIColor greenColor];
	PCPageViewController* initialPageController = [[PCMagazineViewControllersFactory factory] viewControllerForPage:self.onScreenPage];
    [self.mainScroll setCurrentElementView:initialPageController.view];
    [self.view addSubview:self.mainScroll];
	 [initialPageController.view setFrame:self.view.bounds];
//	[self.view addSubview:initialPageController.view];
	self.currentPageController = initialPageController;
	[initialPageController unloadFullView];
	[initialPageController loadFullView];
	
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{	
    [super viewDidUnload];
	[self releaseViews];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)releaseViews
{
	self.mainScroll = nil;
	self.currentPageController = nil;
	self.previousPageController = nil;
}
-(void)dealloc
{
	[_onScreenPage release], _onScreenPage = nil;
	[self releaseViews];
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(UIView *)viewForConnection:(RRConnectionType)coonectionType
{
	PCPage* nextPage;
	switch (coonectionType) {
		case TOP:
			nextPage = _onScreenPage.topPage; 
			break;
		case BOTTOM:
			nextPage = _onScreenPage.bottomPage; 
			break;
		case RIGHT:
			nextPage = _onScreenPage.rightPage; 
			break;
		case LEFT:
			nextPage = _onScreenPage.leftPage; 
			break;
			
		default:
			break;
	}
	
	PCPageViewController* nextPageController = [[PCMagazineViewControllersFactory factory] viewControllerForPage:nextPage];
	self.previousPageController = _currentPageController;
	self.currentPageController = nextPageController;
	self.onScreenPage = nextPage;
	return nextPageController.view;
}

-(void)viewDidMoved
{
	self.previousPageController = nil;
}

@end
