/**
 *  PC3DScene.h
 *  Pad CMS
 *
 *  Created by Maxim Pervushin on 5/21/12.
 *  Copyright __MyCompanyName__ 2012. All rights reserved.
 */


#import "CC3Scene.h"

/**
 @class PC3DScene
 @brief Scene that presents 3d model and manages basic manipulations with it. 
 */
@interface PC3DScene : CC3Scene

/**
 @brief Perform pinch gesture on scene 
 */
- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer;

/**
 @brief Load 3d model to scene from file named modelName
 */
- (void)loadModel:(NSString *)modelName;

@end
