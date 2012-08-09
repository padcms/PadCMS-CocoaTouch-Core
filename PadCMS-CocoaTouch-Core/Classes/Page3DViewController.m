//
//  Page3DViewController.m
//  PadCMS-CocoaTouch-Core
//
//  Created by Alexey Igoshev on 7/25/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "Page3DViewController.h"
#import "PCPage.h"
#import "PC3dView.h"

@interface Page3DViewController ()
{
    PC3dView *_3dView;
}

@end

@implementation Page3DViewController

- (id)initWithPage:(PCPage *)aPage
{
    self = [super initWithPage:aPage];
	
    if (self != nil) {
        _3dView = nil;
    }
    
    return self;
}

-(void)dealloc
{
	[self unloadFullView];
	[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)loadFullView
{
	if (!_page.isComplete) {
        [self showHUD];
        return;
    }
	
	[super loadBackground];
	self.view.userInteractionEnabled = YES;
    self.view.multipleTouchEnabled = YES;
	self.view.backgroundColor = [UIColor grayColor];
    
    CGRect activeZone3dFrame = [self activeZoneRectForType:PCPDFActiveZone3d];
    
    if (CGRectIsEmpty(activeZone3dFrame)) {
        CGFloat left = (self.view.frame.size.width - 500) / 2;
        CGFloat top = (self.view.frame.size.height - 500) / 2;
        activeZone3dFrame = CGRectMake(left, top, 500, 500);
    }
    
    _3dView = [[PC3dView alloc] initWithFrame:activeZone3dFrame];

    [self.view addSubview:_3dView];
    [self loadModel];
//    dispatch_async(dispatch_queue_create("model-loading", NULL), ^{
//        [self loadModel];
//    });
}

- (void)unloadFullView
{
    [_3dView removeFromSuperview];
    [_3dView release];
    _3dView = nil;
}

- (void)didReceiveMemoryWarning
{
    if (_3dView != nil) {
        [_3dView clearGraphicsCache];
    }

    [super didReceiveMemoryWarning];
}

- (void)loadModel
{
    NSArray *elements3D = [_page elementsForType:PCPageElementType3D];
    if (elements3D != nil && elements3D.count > 0) {
        PCPageElement *element3D = [elements3D objectAtIndex:0];
        if (element3D != nil) {
            
            NSString *modelPath = [self.page.revision.contentDirectory stringByAppendingPathComponent:element3D.resource];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:modelPath]) {
                [_3dView loadModel:modelPath];
                return;
            }
        }
    }
    
    NSLog(@"3D element is nil");
}

@end
