//
//  PCPageElementView.h
//  the_reader
//
//  Created by User on 01.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCResourceView, MBProgressHUD, PCPageElement;

@interface PCPageElementViewController : UIViewController
{
@private // Instance variables
    MBProgressHUD* HUD;
  
    CGFloat targetWidth;
    
    NSString *_resource;
    
    NSString *_resourceBQ;
    
	BOOL isLoaded;

@protected
    PCResourceView *imageView;
	
}

@property (retain) NSString *resource;
@property (retain) NSString *resourceBQ;
@property (retain) PCPageElement* element;
@property (nonatomic, assign) MBProgressHUD* HUD;

@property          CGFloat   targetWidth;

- (id)initWithResource:(NSString *)aResource;
- (id)initWithResource:(NSString *)aResource resourceBadQuality:(NSString *)aResourceBQ;

- (void) loadFullView;
- (void) loadFullViewImmediate;
- (void) unloadView;

- (void) correctSize;
-(void)showHUD;

@end
