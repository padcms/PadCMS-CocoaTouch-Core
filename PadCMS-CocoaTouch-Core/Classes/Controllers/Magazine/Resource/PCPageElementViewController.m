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

#import "PCResourceLoadRequest.h"

#import "PCResourceView.h"

#import "PCResourceCache.h"

#import "PCResourceQueue.h"

#import "Helper.h"

#import "MBProgressHUD.h"

#import "PCPageElement.h"

#import "PCPage.h"


@interface  PCPageElementViewController(ForwardDeclaration)

-(void) showHUD;
-(void) hideHUD;

@end

@implementation PCPageElementViewController

#pragma mark Properties

@synthesize resource   = _resource;
@synthesize resourceBQ = _resourceBQ;
@synthesize element=_element;

@synthesize targetWidth, HUD;

#pragma mark PCPageElementViewController instance methods

- (id)init
{
    self = [super init];
    if (self)
    {
        self.view = nil;
        imageView = nil;
        
        targetWidth = [[UIScreen mainScreen] bounds].size.width; //default application width
        
        _resource = nil;
        
        _resourceBQ = nil;
        
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
  @try{
    if (_element && [self.element.fieldTypeName isEqualToString:PCPageElementTypeMiniArticle]) {
      [_element removeObserver:self forKeyPath:@"isComplete"];
    }
  }@catch(id anException){
    NSLog(@"Exception");
  }
  
  

    [self unloadView];
    
  
    [_element release], _element = nil;
    
    [_resource release], _resource = nil;
    
    [_resourceBQ release], _resourceBQ = nil;
    
    [super dealloc];
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
    PCResourceLoadRequest *resourceRequest = [PCResourceLoadRequest forView:imageView
                                                                    fileURL:self.resource
                                                          fileBadQualityURL:self.resourceBQ];
    
    return resourceRequest;
}

- (void) loadFullView
{
	isLoaded = YES;
    [self correctSize];
	//[self showHUD];
    
    if(imageView != nil)
        return;
    
    imageView = [[PCResourceView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:imageView];
    [imageView release];
   
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		UIImage *image = [[PCResourceCache sharedInstance] resourceLoadBadQualityRequest:[self request]]; 
		
		if ([image isKindOfClass:[UIImage class]])
		{
			dispatch_async(dispatch_get_main_queue(), ^{
				[imageView showImage:image];
			});
			
		}

	});
}

- (void) loadFullViewImmediate
{
	isLoaded = YES;
    [self correctSize];
	//[self showHUD];
    
    if(imageView != nil)
    {
        if([imageView isLoaded] || ![[PCResourceQueue sharedInstance] cancelNotStartedOperationWithObject:imageView])
        {
            return;
        }
    }
    else
    {
        imageView = [[PCResourceView alloc] initWithFrame:self.view.bounds];
        
        [self.view addSubview:imageView];
        
        [imageView release];
    }
     UIImage *image = [[PCResourceCache sharedInstance] resourceLoadRequestImmediate:[self request]];
    
    if ([image isKindOfClass:[UIImage class]])
    {
        [imageView showImage:image];
    }
  }

- (void) unloadView
{
	isLoaded = NO;
	[self hideHUD];
    if(imageView)
    {
        [[PCResourceQueue sharedInstance] cancelNotStartedOperationWithObject:imageView];
        
        [imageView removeFromSuperview], imageView = nil;
    }

}

- (void) correctSize
{
    CGSize imageSize = [Helper getSizeForImage:self.resource];
    
    if(!CGSizeEqualToSize(imageSize, CGSizeZero))
    {
        CGFloat scale = self.targetWidth / imageSize.width;
        
        CGSize newSize = CGSizeMake(imageSize.width * scale, imageSize.height * scale);
        
        [self.view setFrame:CGRectMake(self.view.frame.origin.x,
                                       self.view.frame.origin.y, 
                                       newSize.width,
                                       newSize.height)];
        
        if(imageView != nil)
        {
            [imageView setFrame:CGRectMake(0, 0, newSize.width, newSize.height)];
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
	if(!isLoaded) return;
	
	if (!_element) return;
	BOOL isGallery = [_element.fieldTypeName isEqualToString:PCPageElementTypeGallery];
	if (!_element.page.isComplete && !isGallery) return; 
	if (_element.isComplete) return;
  
	if (HUD)
	{
		[HUD removeFromSuperview];
		[HUD release];
		HUD = nil;
	}
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
  //[HUD setFrame:self.view.bounds];
	HUD.mode = MBProgressHUDModeAnnularDeterminate;
	_element.progressDelegate = HUD;
	[HUD show:YES];
	
}

-(void)hideHUD
{
	if (HUD)
	{
		[HUD hide:YES];
		_element.progressDelegate = nil;
		[HUD removeFromSuperview];
		[HUD release];
		HUD = nil;
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
