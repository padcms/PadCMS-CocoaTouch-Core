//
//  PCGalleryWithOverlaysViewController.h
//  PadCMS-CocoaTouch-Core
//
//  Created by Oleg Zhitnik on 04.07.12.
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
@class PCScrollView;

@protocol PCGalleryWithOverlaysViewControllerDelegate <NSObject>

@required

- (void)galleryWithOverlayViewControllerWillDismiss;

@end

@interface PCGalleryWithOverlaysViewController : UIViewController <UIScrollViewDelegate>
{
    PCPage *_page;
    PCScrollView *_mainScrollView;
    NSInteger _galleryID;
    BOOL _horizontalOrientation;
    NSMutableArray *_galleryElements;
  	NSUInteger _currentIndex;
}

@property (nonatomic, retain) PCScrollView *mainScrollView;
@property (nonatomic, retain) PCPage *page;
@property (nonatomic, assign) NSInteger galleryID;
@property (nonatomic, assign) BOOL horizontalOrientation;
@property (nonatomic, retain) NSMutableArray *galleryElements;
@property (nonatomic, retain) NSMutableArray *galleryImageViews;
@property (nonatomic, retain) NSMutableArray *zoomableViews;    // view for zumming, or NSNull if gallery element can't support zooming
@property (nonatomic, retain) NSMutableArray *galleryPopupImageViews; // each galleryImageViews element has appropriate element, or NSNull if no popups for this gallery element
@property (nonatomic, retain) NSMutableArray *popupsIndexes; // NSNumber indexes popups, taked from active zone
@property (nonatomic, retain) NSMutableArray *popupsGalleryElementLinks; // NSNumber indexes of gallery elements, that owns popup
@property (nonatomic, retain) NSMutableArray *popupsZones;
@property (nonatomic, assign) NSInteger currentPage;

- (id) initWithPage: (PCPage *)initialPage;

@end
