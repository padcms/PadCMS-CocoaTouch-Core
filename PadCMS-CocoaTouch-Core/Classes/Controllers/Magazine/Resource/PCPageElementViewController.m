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
#import "PCResourceView.h"

@interface PCPageElementViewController()
{
@private
    MBProgressHUD* _HUD;
    CGFloat _targetWidth;
    NSString *_resource;
	BOOL _loaded;
}

- (void)hideHUD;
- (void)applicationDidChangeStatusBarOrientationNotification;

@end

@implementation PCPageElementViewController
@synthesize resource = _resource;
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
        _resourceView = nil;
        
        if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
            _targetWidth = [UIScreen mainScreen].bounds.size.width;
        } else {
            _targetWidth = [UIScreen mainScreen].bounds.size.height;
        }
        
        _resource = nil;
        
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

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    @try {
        if (_element && [self.element.fieldTypeName isEqualToString:PCPageElementTypeMiniArticle]) {
            [_element removeObserver:self forKeyPath:@"isComplete"];
        }
    }
    @catch (id anException) {
    }
  
  

    [self unloadView];
    
  
    [_element release], _element = nil;
    
    [_resource release], _resource = nil;
    
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

- (void) loadFullView
{
    [self correctSize];
    
    if (_resourceView != nil) {
        _loaded = YES;
        return;
    }
    
    _resourceView = [[PCResourceView alloc] initWithFrame:self.view.bounds];
    _resourceView.resourceName = self.resource;
    [self.view addSubview:_resourceView];
    _loaded = YES;
}

- (void) loadFullViewImmediate
{
    [self correctSize];
    
    if (_resourceView != nil) {
        _loaded = YES;
        return;
    }
    
    _resourceView = [[PCResourceView alloc] initWithFrame:self.view.bounds];
    _resourceView.resourceName = self.resource;
    
    _loaded = YES;
    
    [self.view addSubview:_resourceView];
}

- (void) unloadView
{
	_loaded = NO;
	[self hideHUD];
    if (_resourceView != nil) {
        _resourceView.resourceName = nil;
        [_resourceView removeFromSuperview], 
        [_resourceView release];
        _resourceView = nil;
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
        
        if(_resourceView != nil)
        {
            [_resourceView setFrame:CGRectMake(0, 0, newSize.width, newSize.height)];
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
		if (newValue)  {
            [self hideHUD];
        } else {
            if ([self.element.fieldTypeName isEqualToString:PCPageElementTypeMiniArticle])[self showHUD];
        }
	}
	
	
}


@end
