//
//  PC3DScene.m
//  Pad CMS
//
//  Created by Maxim Pervushin on 5/21/12.
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

#import "PC3DScene.h"
#import "CC3PODResourceNode.h"
#import "CC3ActionInterval.h"
#import "CC3MeshNode.h"
#import "CC3Camera.h"
#import "CC3Light.h"
#import "CGPointExtension.h"
#import "CCTouchDispatcher.h"

const CGFloat MaxCameraScale = 4.0f;
const CGFloat MinCameraScale = 0.25f;


@interface PC3DScene ()
{
    CC3Node *_modelNode;
    CGPoint _lastTouchEventPoint;
}

@end


@implementation PC3DScene

-(void) dealloc 
{
	[super dealloc];
}

- (void)initializeScene
{
    _modelNode = nil;
    
	// Create the camera, place it back a bit, and add it to the scene
	CC3Camera *camera = [CC3Camera nodeWithName: @"Camera"];
	camera.location = cc3v(0.0, 0.0, 1.0);
	[self addChild:camera];

	// Create a light, place it back and to the left at a specific
	// position (not just directional lighting), and add it to the scene
	CC3Light* light = [CC3Light nodeWithName: @"Light"];
	light.location = cc3v(1.0, 0.0, 0.0 );
	light.isDirectionalOnly = NO;
	[camera addChild:light];
    
    [self createGLBuffers];
    [self releaseRedundantData];
}

- (void)onOpen
{
    [super onOpen];
    
    [self.activeCamera moveToShowAllOf:_modelNode withPadding:0.1];
}

#pragma mark Handling touch events 

- (void)touchEvent:(uint)touchType at:(CGPoint)touchPoint
{
    switch (touchType)
    {
		case kCCTouchBegan:
			break;
		case kCCTouchMoved:
			[self rotateMainNodeFromSwipeAt:touchPoint];
			break;
		case kCCTouchEnded:
			break;
		default:
			break;
	}
	
	_lastTouchEventPoint = touchPoint;
}


#pragma mark - public

/** Set this parameter to adjust the rate of rotation from the length of touch-move swipe. */
#define kSwipeScale 0.6

- (void)rotateMainNodeFromSwipeAt:(CGPoint)touchPoint
{
	CC3Camera *camera = self.activeCamera;
	
	// Get the direction and length of the movement since the last touch move event, in
	// 2D screen coordinates. The 2D rotation axis is perpendicular to this movement.
	CGPoint swipe2d = ccpSub(touchPoint, _lastTouchEventPoint);
	CGPoint axis2d = ccpPerp(swipe2d);
	
	// Project the 2D axis into a 3D axis by mapping the 2D X & Y screen coords
	// to the camera's rightDirection and upDirection, respectively.
	CC3Vector axis = CC3VectorAdd(CC3VectorScaleUniform(camera.rightDirection, axis2d.x),
								  CC3VectorScaleUniform(camera.upDirection, axis2d.y));
	GLfloat angle = ccpLength(swipe2d) * kSwipeScale;
	
	// Rotate the cube under direct finger control, by directly rotating by the angle
	// and axis determined by the swipe. If the die cube is just to be directly controlled
	// by finger movement, and is not to freewheel, this is all we have to do.
	[_modelNode rotateByAngle: angle aroundAxis: axis];
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    static CC3Vector previousScaleVector;
    
    CC3Camera* camera = self.activeCamera;
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        previousScaleVector = camera.scale;
        return;
    }
    
    if (CC3VectorIsZero(previousScaleVector))
    {
        previousScaleVector = CC3VectorMake(1, 1, 1);
    }
    
    CC3Vector scaleVector = CC3VectorMake(previousScaleVector.x * recognizer.scale,
                                          previousScaleVector.y * recognizer.scale, 
                                          previousScaleVector.z * recognizer.scale);
    
    camera.scale = scaleVector;
}

- (void)loadModel:(NSString *)modelName
{
    NSLog(@"RR3DScene loadModel:%@", modelName);
    
    [self removeChild:_modelNode];
    
    _modelNode = [CC3PODResourceNode nodeFromFile:modelName];
    
    [self addChild:_modelNode];
}

@end

