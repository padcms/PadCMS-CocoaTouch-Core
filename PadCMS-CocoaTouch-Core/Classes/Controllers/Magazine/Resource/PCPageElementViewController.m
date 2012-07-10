//
//  PCPageElementView.m
//  the_reader
//
//  Created by User on 01.03.12.
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

#import "PCPageElementViewController.h"

#import "Helper.h"
#import "MBProgressHUD.h"
#import "PCPage.h"
#import "PCPageElement.h"
#import "PCPageElemetTypes.h"
#import "PCResourceCache.h"
#import "PCResourceLoadRequest.h"
#import "PCResourceQueue.h"
#import "PCResourceView.h"

@interface PCPageElementViewController()
{
@private
    MBProgressHUD* _HUD;
    CGFloat _targetWidth;
    NSString *_resource;
    NSString *_resourceBQ;
	BOOL _loaded;
}

- (void)hideHUD;
- (void)applicationDidChangeStatusBarOrientationNotification;

@end

@implementation PCPageElementViewController
@synthesize resource = _resource;
@synthesize resourceBQ = _resourceBQ;
@synthesize element = _element;
@synthesize targetWidth = _targetWidth; 
@synthesize HUD = _HUD;

#pragma mark PCPageElementViewController instance methods

- (id)init
{
    self = [super init];
    if (self)
    {
        self.view = nil;
        _imageView = nil;
        
        if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
            _targetWidth = [UIScreen mainScreen].bounds.size.width;
        } else {
            _targetWidth = [UIScreen mainScreen].bounds.size.height;
        }
        
        _resource = nil;
        
        _resourceBQ = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(applicationDidChangeStatusBarOrientationNotification) 
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
        
    }
    return self;
}

- (id)initWithResource:(NSString *)aResource
{
    self = [self init];
    if (self)
    {
        _resource = [aResource copy];
    }
    return self;
}

- (id)initWithResource:(NSString *)aResource resourceBadQuality:(NSString *)aResourceBQ
{
    self = [self initWithResource:aResource];
    if (self)
    {
        _resource = [aResource copy];
        _resourceBQ = [aResourceBQ copy];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    @try {
        if (_element && [self.element.fieldTypeName isEqualToString:PCPageElementTypeMiniArticle]) {
            [_element removeObserver:self forKeyPath:@"isComplete"];
        }
    }
    @catch (id anException) {
        NSLog(@"Exception = %@", anException);
    }
  
  

    [self unloadView];
    
  
    [_element release], _element = nil;
    
    [_resource release], _resource = nil;
    
    [_resourceBQ release], _resourceBQ = nil;
    
    [super dealloc];
}

- (void)applicationDidChangeStatusBarOrientationNotification
{
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        _targetWidth = [UIScreen mainScreen].bounds.size.width;
    } else {
        _targetWidth = [UIScreen mainScreen].bounds.size.height;
    }
    
    [self correctSize];
}

- (BOOL)isEqual:(id)object
{
    if([super isEqual:object])
        return YES;
    
    if([object class] != [PCPageElementViewController class])
        return NO;
    
    PCPageElementViewController *anotherObject = (PCPageElementViewController *)object;
    
    return [self.resource isEqualToString:anotherObject.resource];
}

- (PCResourceLoadRequest *) request
{
    PCResourceLoadRequest *resourceRequest = [PCResourceLoadRequest forView:_imageView
                                                                    fileURL:self.resource
                                                          fileBadQualityURL:self.resourceBQ];
    
    return resourceRequest;
}

- (void) loadFullView
{
	_loaded = YES;
    [self correctSize];
    
    if(_imageView != nil) {
        return;
    }
    
    _imageView = [[PCResourceView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_imageView];
    [_imageView release];
   
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		UIImage *image = [[PCResourceCache sharedInstance] resourceLoadBadQualityRequest:[self request]]; 
		
		if ([image isKindOfClass:[UIImage class]])
		{
			dispatch_async(dispatch_get_main_queue(), ^{
				[_imageView showImage:image];
			});
			
		}

	});
}

- (void) loadFullViewImmediate
{
	_loaded = YES;
    [self correctSize];
	//[self showHUD];
    
    if(_imageView != nil)
    {
        if([_imageView isLoaded] || ![[PCResourceQueue sharedInstance] cancelNotStartedOperationWithObject:_imageView])
        {
            return;
        }
    }
    else
    {
        _imageView = [[PCResourceView alloc] initWithFrame:self.view.bounds];
        
        [self.view addSubview:_imageView];
        
        [_imageView release];
    }
    UIImage *image = [[PCResourceCache sharedInstance] resourceLoadRequestImmediate:[self request]];
    
    if ([image isKindOfClass:[UIImage class]])
    {
        [_imageView showImage:image];
    }
}

- (void) unloadView
{
	_loaded = NO;
	[self hideHUD];
    if(_imageView)
    {
        [[PCResourceQueue sharedInstance] cancelNotStartedOperationWithObject:_imageView];
        
        [_imageView removeFromSuperview], _imageView = nil;
    }

}

- (void) correctSize
{
    CGSize imageSize = [Helper getSizeForImage:self.resource];
    
    if(!CGSizeEqualToSize(imageSize, CGSizeZero))
    {
        CGFloat scale = _targetWidth / imageSize.width;
        
        CGSize newSize = CGSizeMake(imageSize.width * scale, imageSize.height * scale);
        
        [self.view setFrame:CGRectMake(self.view.frame.origin.x,
                                       self.view.frame.origin.y, 
                                       newSize.width,
                                       newSize.height)];
        
        if(_imageView != nil)
        {
            [_imageView setFrame:CGRectMake(0, 0, newSize.width, newSize.height)];
        }
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self correctSize];
	
	if (_element && [self.element.fieldTypeName isEqualToString:PCPageElementTypeMiniArticle]) {
		[_element addObserver:self forKeyPath:@"isComplete" options:NSKeyValueObservingOptionNew context:NULL];
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self unloadView];
}

-(void)showHUD
{
	if(!_loaded) return;
	
	if (!_element) return;
	BOOL isGallery = [_element.fieldTypeName isEqualToString:PCPageElementTypeGallery];
	if (!_element.page.isComplete && !isGallery) return; 
	if (_element.isComplete) return;
  
	if (_HUD)
	{
		[_HUD removeFromSuperview];
		[_HUD release];
		_HUD = nil;
	}
	_HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:_HUD];
  //[HUD setFrame:self.view.bounds];
	_HUD.mode = MBProgressHUDModeAnnularDeterminate;
	_element.progressDelegate = _HUD;
	[_HUD show:YES];
	
}

-(void)hideHUD
{
	if (_HUD)
	{
		[_HUD hide:YES];
		_element.progressDelegate = nil;
		[_HUD removeFromSuperview];
		[_HUD release];
		_HUD = nil;
	}
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void) observeValueForKeyPath: (NSString *)keyPath ofObject: (id) object
                        change: (NSDictionary *) change context: (void *) context
{
	if([change objectForKey:NSKeyValueChangeNewKey] != [NSNull null]) 
	{
		BOOL newValue = [[change objectForKey: NSKeyValueChangeNewKey] boolValue];
		if (newValue) [self hideHUD];
		else
       if ([self.element.fieldTypeName isEqualToString:PCPageElementTypeMiniArticle])[self showHUD];
	}
	
	
}


@end
