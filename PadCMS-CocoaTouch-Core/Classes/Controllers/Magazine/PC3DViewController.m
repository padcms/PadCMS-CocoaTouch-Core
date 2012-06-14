//
//  PCPageViewController.m
//  Pad CMS
//
//  Created by Maxim Pervushin on 5/29/12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import "PC3DViewController.h"
#import "PCPage.h"
#import "PC3DLayer.h"
#import "PC3DScene.h"
#import "CC3EAGLView.h"
#import "PCScrollView.h"

@interface PC3DViewController ()
{
    UIView *_graphicsContainerView;
    PC3DLayer *_layer;
    PC3DScene *_scene;
    EAGLView *_glView;
    
    BOOL _graphicsLoaded;
    
    UIPinchGestureRecognizer *_pinchGestureRecognizer;
    UIPanGestureRecognizer *_panGestureRecognizer;
}

- (void)loadModel;
- (void)setUpGraphics;
- (void)tearDownGraphics;
- (void)clearGraphicsCache;
- (void)setUpGestureRecognizers;
- (void)tearDownGestureRecognizers;
- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer;
- (void)panGesture:(UIPanGestureRecognizer *)recognizer;

@end

@implementation PC3DViewController

- (id)initWithPage:(PCPage *)aPage
{
    self = [super initWithPage:aPage];

    if (self != nil)
    {
        _graphicsContainerView = nil;
        _layer = nil;
        _scene = nil;
        
        _graphicsLoaded = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.userInteractionEnabled = YES;
    self.view.multipleTouchEnabled = YES;
	self.view.backgroundColor = [UIColor grayColor];
    
    CGFloat left = (self.view.frame.size.width - 500) / 2;
    CGFloat top = (self.view.frame.size.height - 500) / 2;
    CGRect backgroundImageFrame = CGRectMake(left, top, 500, 500);
    _graphicsContainerView = [[UIView alloc] initWithFrame:backgroundImageFrame];
    _graphicsContainerView.backgroundColor = [UIColor greenColor];
    _graphicsContainerView.userInteractionEnabled = YES;
    _graphicsContainerView.multipleTouchEnabled = YES;
    _graphicsContainerView.tag = 111;
    [self.view addSubview:_graphicsContainerView];
    
    [self setUpGestureRecognizers];
}

- (void)viewDidUnload
{
    [_graphicsContainerView removeFromSuperview];
    [_graphicsContainerView release];

    [super viewDidUnload];
}

- (void)loadFullView
{
    if (!_graphicsLoaded && 
        self.magazineViewController.currentColumnViewController.currentPageViewController == self)
    {
        [self setUpGraphics];
        [self loadModel];
        
        _graphicsLoaded = YES;
    }
    [super loadFullView];
}

- (void)unloadFullView
{
    if (_graphicsLoaded)
    {
        [self tearDownGraphics];
        _graphicsLoaded = NO;
    }
    
    [super unloadFullView];
}

- (void)didReceiveMemoryWarning
{
    [self clearGraphicsCache];
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)endDownloadingPCPageOperation:(NSNotification*)notif
{
    [super endDownloadingPCPageOperation:notif];
    
    [self loadModel];
}

- (void)setUpGraphics
{
    // Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if (![CCDirector setDirectorType:kCCDirectorTypeDisplayLink])
    {
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	}
    
	CCDirector *director = [CCDirector sharedDirector];
    
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
    
	[director setAnimationInterval:(1.0 / 60)];
	[director setDisplayFPS:YES];
	
	// Alloc & init the EAGLView
	//  1. Transparency (alpha blending), and device camera overlay requires an alpha channel,
	//     so must use RGBA8 color format. If not using device overlay or alpha blending
	//     (transparency) in any 3D or 2D graphics this can be changed to kEAGLColorFormatRGB565.
	//	2. 3D rendering requires a depth format of 16 or 24 bits
	//     (GL_DEPTH_COMPONENT16_OES or GL_DEPTH_COMPONENT24_OES).
	//  3. If a stencil buffer is required (for shadow volumes, for instance), it must be
	//     combined with the depth buffer by using a depth format of GL_DEPTH24_STENCIL8_OES.
	//  4. For highest performance, multisampling antialiasing is disabled by default.
	//     To enable multisampling antialiasing, set the multiSampling parameter to YES.
	//     You can also change the number of samples used with the numberOfSamples parameter.
	//  5. If you are using BOTH multisampling antialiasing AND node picking from touch events,
	//     use the CC3EAGLView class instead of EAGLView. When using EAGLView, multisampling
	//     antialiasing interferes with the color-testing algorithm used for touch-event node picking.
	_glView = [CC3EAGLView viewWithFrame:_graphicsContainerView.bounds
									  pixelFormat:kEAGLColorFormatRGBA8
									  depthFormat:GL_DEPTH_COMPONENT16_OES
							   preserveBackbuffer:NO
									   sharegroup:nil
									multiSampling:NO
								  numberOfSamples:4];
	
    [PCScrollView addViewToIgnoreTouches:_glView];
	// Turn on multiple touches if needed
	[_glView setMultipleTouchEnabled:YES];
	
	// attach the openglView to the director
	[director setOpenGLView:_glView];
    
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if(![director enableRetinaDisplay:YES])
    {
		CCLOG(@"Retina Display Not supported");
    }
	
	// make the GL view a child of the main window and present it
    //	[self.view addSubview: glView];
    [_graphicsContainerView addSubview:_glView];
    
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// ******** START OF COCOS3D SETUP CODE... ********
	
	// Create the customized CC3Layer that supports 3D rendering,
	// and schedule it for automatic updates
	_layer = [PC3DLayer node];
	[_layer scheduleUpdate];
	
	// Create the customized 3D scene, attach it to the layer, and start it playing.
    _layer.cc3Scene = [PC3DScene scene];
    _scene = (PC3DScene *)_layer.cc3Scene;
    
	ControllableCCLayer* mainLayer = _layer;
	
	// The 3D layer can run either direcly in the scene, or it can run as a smaller "sub-window"
	// within any standard CCLayer. So you can have a mostly 2D window, with a smaller 3D window
	// embedded in it. To experiment with this smaller embedded 3D window, uncomment the following lines:
    //	CGSize winSize = [[CCDirector sharedDirector] winSize];
    //	cc3Layer.position = CGPointMake(30.0, 40.0);
    //	cc3Layer.contentSize = CGSizeMake(winSize.width - 70.0, winSize.width - 40.0);
    //	cc3Layer.alignContentSizeWithDeviceOrientation = YES;
    //	mainLayer = [ControllableCCLayer layerWithColor: ccc4(0, 0, 0, 255)];
    //	[mainLayer addChild: cc3Layer];
	
	// When it is smaller, you can even move the 3D layer around on the screen dyanmically.
	// To see this in action, uncomment the lines above as described, and also uncomment
	// the following two lines. The shouldAlwaysUpdateViewport property ensures that the
	// 3D scene tracks the updated position of the 3D layer within its parent layer.
    //	cc3Layer.shouldAlwaysUpdateViewport = YES;
    //	[cc3Layer runAction: [CCMoveTo actionWithDuration: 10.0 position: ccp(100.0, 200.0)]];
	
	// The controller is optional. If you want to auto-rotate the view when the device orientation
	// changes, or if you want to display a device camera behind a combined 3D & 2D scene
	// (augmented reality), use a controller. Otherwise you can simply remove the following lines
	// and uncomment the lines below these lines that uses the traditional CCDirector scene startup.
    //	_viewController = [[CCNodeController controller] retain];
    //	_viewController.doesAutoRotate = YES;
    //    //	viewController.isOverlayingDeviceCamera = YES;	// Uncomment for 3D overlay on device camera for AR
    //	[_viewController runSceneOnNode:mainLayer];		// attach the layer to the controller and run a scene with it
	
    // If a controller is NOT used, uncomment the following standard CCDirector scene startup lines,
	// and remove the lines above that reference viewContoller.
	CCScene *scene = [CCScene node];
	[scene addChild: mainLayer];
    if ([CCDirector sharedDirector].runningScene != nil)
    {
        [[CCDirector sharedDirector] replaceScene:scene];
    }
    else
    {
        [[CCDirector sharedDirector] runWithScene:scene];
    }
	
    
    
	// If dropping to 40fps is not an issue, remove above, and uncomment the following to avoid delay.
    [[CCDirector sharedDirector] resume];
    
    [[CCDirector sharedDirector] startAnimation];
}

- (void)tearDownGraphics
{
//    [PCScrollView removeViewFromIgnoreTouches:_glView];
    CCDirector* director = [CCDirector sharedDirector];
    [director pause];
    [director stopAnimation];
    
	EAGLView *openGLView = [director openGLView];
    [openGLView removeFromSuperview];
	
	[director end];	
}

- (void)clearGraphicsCache
{
    [[CCDirector sharedDirector] purgeCachedData];
}

- (void)setUpGestureRecognizers
{
    _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self 
                                                                        action:@selector(pinchGesture:)];
    [_graphicsContainerView addGestureRecognizer:_pinchGestureRecognizer];
    
    //    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self 
    //                                                                    action:@selector(panGesture:)];
    //    [_graphicsContainerView addGestureRecognizer:_panGestureRecognizer];
}

- (void)tearDownGestureRecognizers
{
    [_graphicsContainerView removeGestureRecognizer:_pinchGestureRecognizer];
    [_pinchGestureRecognizer release];
    
    //    [_graphicsContainerView removeGestureRecognizer:_panGestureRecognizer];
    //    [_panGestureRecognizer release];
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    [_scene pinchGesture:recognizer];
}

- (void)panGesture:(UIPanGestureRecognizer *)recognizer
{
//    [_scene panGesture:recognizer];
}

- (void)loadModel
{
    NSArray *elements3D = [page elementsForType:PCPageElementType3D];
    if (elements3D != nil && elements3D.count > 0)
    {
        PCPageElement *element3D = [elements3D objectAtIndex:0];
        if (element3D != nil)
        {
            NSString *modelPath = [self.page.revision.contentDirectory stringByAppendingPathComponent:element3D.resource];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:modelPath])
            {
                [_scene loadModel:modelPath];
                return;
            }
        }
    }
    
    NSLog(@"3D element is nil");
}

@end
