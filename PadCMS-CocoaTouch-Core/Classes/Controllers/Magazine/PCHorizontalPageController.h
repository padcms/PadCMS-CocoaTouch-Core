//
//  PCHorizontalPageController.h
//  Pad CMS
//
//  Created by Oleg Zhitnik on 27.03.12.
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
#import "PCIssue.h"


@class PCRevision;
@class PCRevisionViewController;
@class PCHorizontalPage;
@class MBProgressHUD;

@interface PCHorizontalPageController : UIViewController <UIScrollViewDelegate>
{
    UIImageView        *imageView;
	MBProgressHUD      *HUD;
	BOOL                isLoaded;
    UIScrollView       *innerScroll;
    UIView             *innerView;
}

@property (nonatomic, assign) PCRevisionViewController *revisionViewController; // TODO: Maybe remove later? 

@property (nonatomic, retain) PCRevision* revision; 
@property (nonatomic, assign) NSInteger pageIdentifier; 
@property (nonatomic, retain) NSString* resource;
@property (nonatomic, assign) BOOL selected; 
@property (nonatomic, retain) NSNumber* identifier;
@property (nonatomic, retain) PCHorizontalPage* horizontalPage;

- (void) loadFullView;
- (void) unloadFullView;
- (void) showHUD;

@end
