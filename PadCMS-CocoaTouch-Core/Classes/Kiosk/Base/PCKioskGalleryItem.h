//
//  PCKioskGalleryItem.h
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
