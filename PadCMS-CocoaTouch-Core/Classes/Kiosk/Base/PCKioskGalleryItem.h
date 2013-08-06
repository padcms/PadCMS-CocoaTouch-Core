//
//  PCKioskGalleryItem.h
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

#import <Foundation/Foundation.h>
#import "PCKioskDataSourceProtocol.h"

#define RADIANS(degrees) (float)( degrees * M_PI / 180 )

#define K              1.0

#define IMAGE_HEIGHT   (260 * K)
#define IMAGE_WIDTH    (180 * K)

#define DEEP           -700
#define GAP            (40 * K)
#define IN_FRONT       120.0

#define ANGLE_COEFF     0.75
#define FRONT_COEFF     0.75
#define ROTATE_COEFF    0.9

#define DURATION_CHANGE         0.3
#define DURATION_ROTATE         0.5
#define DURATION_ANIMATE        0.7

#define ANCHOR_POINT_Y          0.1

#define DISTANCE_FROM_CENTER_Y (20.0  * K)
#define DISTANCE_FROM_CENTER_X (160.0 * K)
#define DISTANCE_FROM_CENTER_Z  100.0

#define ANGLE          60

/**
 @class PCKioskGalleryItem
 @brief This class show revision cover in gallery subview
 */
@interface PCKioskGalleryItem : CALayer <PCKioskCoverImageProcessingProtocol>
{
	UIImage     *image;
	float       angle;
}

/**
 @brief Data source that provide information about revisions
 */
@property (retain, nonatomic) id<PCKioskDataSourceProtocol> dataSource;

/**
 @brief Flag indicating that kiosk gallery item should be drawn with reflection. YES by default. 
 */
@property (assign, nonatomic) BOOL drawReflection;

/**
 @brief Revision index
 */
@property (assign, nonatomic) NSInteger revisionIndex;

/**
 @brief Revision cover image
 */
@property (retain) UIImage *image;

/**
 @brief Cover image angle
 */
@property (assign) float angle;

@end
