//
//  PCGalleryViewController.h
//  Pad CMS
//
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

#import <UIKit/UIKit.h>
@class PCPage;
@class PCCustomPageControll;
@class PCScrollView, PCPageElementGallery, PCGalleryViewController;

@protocol PCGalleryViewControllerDelegate <NSObject>

@required

- (void)galleryViewControllerWillDismiss;

@optional

- (void) galleryViewController:(PCGalleryViewController*)galleryController didChangeCurrentPage:(NSInteger)currentPage;

@end

@interface PCGalleryViewController : UIViewController <UIScrollViewDelegate/*, UIGestureRecognizerDelegate*/>
{
	PCScrollView *_mainScrollView;
    PCCustomPageControll *_pageControll;
    PCPage *_page;
    NSMutableArray *_images;
    NSMutableArray *_progressBarsArray;
    CGRect _currentViewRect;
	NSUInteger _currentIndex;
    NSInteger _galleryID;
	
}

@property (nonatomic, retain) PCScrollView *mainScrollView;
@property (nonatomic, retain) PCCustomPageControll *pageControll;
@property (nonatomic, retain) PCPage *page;
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) NSMutableArray *progressBarsArray;
@property (nonatomic) CGRect currentViewRect;
@property (nonatomic, assign, readwrite) id <PCGalleryViewControllerDelegate> delegate;
@property (nonatomic, retain) NSMutableArray* imageViews;
@property (nonatomic, assign) BOOL horizontalOrientation;
@property (nonatomic, assign) NSInteger galleryID;

- (id) initWithPage: (PCPage *)initialPage;
- (void) showPhotoAtIndex:(NSInteger)currentIndex;
- (void) setCurrentPhoto:(int)index;

- (NSArray*) activeZonesForElement:(PCPageElementGallery*)element atPoint:(CGPoint)point;

@end
