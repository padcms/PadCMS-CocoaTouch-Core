//
//  PCMSKioskSubviewGallery.m
//  Pad CMS
//
//  Created by Oleg Zhitnik on 27.04.12.
//  Copyright (c) 2012 Adyax. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PCKioskBaseGalleryView.h"
#import "PCKioskGalleryItem.h"

@interface PCKioskBaseGalleryView ()
- (void) moveBy:(float)add duration:(float)duration;
- (void) adjustCurrentRevisionIndex;
- (void) onCurrentRevisionIndexChanged;
- (void) createGalleryView;
- (void) createGalleryItems;
- (void) createControlElement;
@end

@implementation PCKioskBaseGalleryView

@synthesize disabled = _disabled;
@synthesize currentRevisionIndex = _currentRevisionIndex;
@synthesize controlElement = _controlElement;
@synthesize galleryView = _galleryView;

+ (NSInteger) subviewTag
{
    return 1001;
}

- (PCKioskAbstractControlElement*) newControlElementWithFrame:(CGRect) frame
{
    return [[PCKioskAbstractControlElement alloc] initWithFrame:frame];
}

- (void) createView
{
    [super createView];
    [self createGalleryView];
    self.currentRevisionIndex = [self.dataSource numberOfRevisions]-1;
    [self createControlElement];
    [self onCurrentRevisionIndexChanged];
}

- (void) createGalleryView
{
    self.galleryView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)] autorelease];
    self.galleryView.clipsToBounds = YES;
    self.galleryView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.galleryView.autoresizesSubviews = YES;
    
    [self createGalleryItems];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(handleSingleTap:)];
	[singleTap setNumberOfTapsRequired:1];
	[self.galleryView addGestureRecognizer:singleTap];
	[singleTap release];
    
    [self addSubview:self.galleryView];
}

- (void) createGalleryItems
{
    float   fImageHeight = IMAGE_HEIGHT;
    float   fImageWidth  = IMAGE_WIDTH;
    int     numberOfRevisions = [self.dataSource numberOfRevisions]-1;
    
    if(numberOfRevisions >= 0)
    {
        CALayer* transformed = self.galleryView.layer;
        CATransform3D initialTransform = transformed.sublayerTransform;
        initialTransform.m34 = 1.0 / DEEP;
        transformed.sublayerTransform = initialTransform;
        transformed.anchorPoint = CGPointMake(0.5, 0.5);
        
        [CATransaction begin];
        [CATransaction setValue:[NSNumber numberWithFloat:0.0f] forKey:kCATransactionAnimationDuration];
        
        for (int i=0; i<numberOfRevisions; i++) {
            PCKioskGalleryItem* layer = [PCKioskGalleryItem layer];
            
            layer.dataSource = self.dataSource;
            layer.revisionIndex = i;
            
            layer.position = CGPointMake(self.galleryView.bounds.size.width / 2 - DISTANCE_FROM_CENTER_X - numberOfRevisions * GAP + i * GAP, (self.galleryView.bounds.size.height - IMAGE_HEIGHT) / 2);
            layer.bounds   = CGRectMake(0, 0, fImageWidth, fImageHeight * 5 / 3);
            
            layer.anchorPoint = CGPointMake(0.0, ANCHOR_POINT_Y);
            layer.angle = RADIANS(ANGLE);			
            
            CATransform3D transform = CATransform3DMakeTranslation(0, DISTANCE_FROM_CENTER_Y, DISTANCE_FROM_CENTER_Z);
            layer.transform = CATransform3DRotate(transform, layer.angle, 0.0f, 1.0f, 0.0);			
            
            [self.galleryView.layer addSublayer:layer];
            [layer setNeedsDisplay];
        }
        
        PCKioskGalleryItem* layer = [PCKioskGalleryItem layer];
        layer.dataSource = self.dataSource;
        layer.revisionIndex = numberOfRevisions;
        
        layer.position = CGPointMake(self.galleryView.bounds.size.width / 2 - DISTANCE_FROM_CENTER_X, (self.galleryView.bounds.size.height - IMAGE_HEIGHT) / 2);
        layer.bounds   = CGRectMake(0, 0, fImageWidth, fImageHeight * 5 / 3);
        
        layer.anchorPoint = CGPointMake(0.5, ANCHOR_POINT_Y);
        
        CATransform3D transform = CATransform3DMakeTranslation(DISTANCE_FROM_CENTER_X, DISTANCE_FROM_CENTER_Y, DISTANCE_FROM_CENTER_Z + IN_FRONT);
        layer.transform = transform;
        
        [self.galleryView.layer addSublayer:layer];
        [layer setNeedsDisplay];		
        
        [CATransaction commit];
    }
}

- (void) createControlElement
{
    self.controlElement = [[self newControlElementWithFrame:CGRectMake(self.bounds.size.width/2 - 220, self.bounds.size.height - 200, 440, 195)] autorelease];
    self.controlElement.dataSource = self.dataSource;
    self.controlElement.delegate = self;
    [self addSubview:self.controlElement];
    [self bringSubviewToFront:self.controlElement];
    [self.controlElement load];
    self.controlElement.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin| UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleTopMargin;
    if([self.dataSource numberOfRevisions]>0)
    {
        self.controlElement.hidden = NO;
    } else {
        self.controlElement.hidden = YES;
    }
}

- (void)dealloc
{
    self.galleryView = nil;
    self.controlElement = nil;
    [super dealloc];
}

- (void) reloadRevisions
{
    [self.galleryView removeFromSuperview];
    self.galleryView = nil;
    [self createGalleryView];
    self.currentRevisionIndex = [self.dataSource numberOfRevisions]-1;
    [self onCurrentRevisionIndexChanged];
    [self bringSubviewToFront:self.controlElement];
    if([self.dataSource numberOfRevisions]>0)
    {
        self.controlElement.hidden = NO;
    } else {
        self.controlElement.hidden = YES;
    }
}


- (void)layoutSubviews
{
    UIInterfaceOrientation curOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    // relayout gallery
    if(self.galleryView)
    {
        float               deltaX = 0.0f, destinationY = (self.galleryView.bounds.size.height - IMAGE_HEIGHT) / 2;
        float               centerDestinationX = self.galleryView.bounds.size.width / 2 - DISTANCE_FROM_CENTER_X;
  
        if(UIInterfaceOrientationIsLandscape(curOrientation))
        {
            destinationY = (self.galleryView.bounds.size.height - IMAGE_HEIGHT) / 2 - 50;
        } else if(UIInterfaceOrientationIsPortrait(curOrientation)) {
            destinationY = (self.galleryView.bounds.size.height - IMAGE_HEIGHT) / 2;
        }

        for (PCKioskGalleryItem* layer in self.galleryView.layer.sublayers)
        {
            if(layer.angle==0.0)
            {
                deltaX = centerDestinationX - layer.position.x;
                break;
            }
        }

        for (PCKioskGalleryItem* layer in self.galleryView.layer.sublayers)
        {
            CGPoint     newPosition = layer.position;

            newPosition.x += deltaX;
            newPosition.y = destinationY;
            layer.position = newPosition;
        }
    }
}

- (void) deviceOrientationDidChange;
{
    [self setNeedsLayout];
}

- (void) selectIssueWithIndex:(NSInteger)index
{
    if(self.currentRevisionIndex==index) return;   // already selected
    
    PCKioskGalleryItem      *neededLayer = nil;
    
    for (PCKioskGalleryItem* layer in self.galleryView.layer.sublayers)
    {
        
        if (layer.revisionIndex==index)
        {
            neededLayer = layer;
            break;
        }
    }
    
    if(neededLayer)
    {
        float add = self.galleryView.bounds.size.width / 2 - DISTANCE_FROM_CENTER_X - neededLayer.position.x;
        [self moveBy:add duration:DURATION_ANIMATE];
    }
}

-(void)handleSingleTap:(UITapGestureRecognizer*)sender
{
    if(self.disabled) return;
    
	CGPoint location = [sender locationInView:self.galleryView];
	PCKioskGalleryItem* touchedLayer = (PCKioskGalleryItem*)[self.galleryView.layer hitTest:location];
	
	while (touchedLayer && touchedLayer.superlayer != self.galleryView.layer)
	{
		touchedLayer = (PCKioskGalleryItem*)touchedLayer.superlayer;
	}
    
	// we won't do anything if this is not the picture layer
	if (touchedLayer)
	{
		if (touchedLayer.angle == RADIANS(0.0) || touchedLayer.angle == RADIANS(180.0)) {
            if([self.dataSource isRevisionDownloadedWithIndex:self.currentRevisionIndex])
            {
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
                float duration = 0.2;
                animation.toValue = [NSValue valueWithCATransform3D:CATransform3DScale(touchedLayer.transform, 1.3, 1.3, 1.0)];
                animation.duration = duration;
                animation.delegate = touchedLayer;
                animation.fillMode = kCAFillModeForwards;
                animation.removedOnCompletion = NO;
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                
                [touchedLayer addAnimation:animation forKey:@""];
                               
                [self performSelector:@selector(readMagazineAfterAnimation:) withObject:touchedLayer afterDelay:duration];
            }
            
		} else if (!self.disabled) {
			// animate this layer to center
			float add = self.galleryView.bounds.size.width / 2 - DISTANCE_FROM_CENTER_X - touchedLayer.position.x;
			
			[self moveBy:add duration:DURATION_ANIMATE];
		}
	}
}

- (void)readMagazineAfterAnimation:(CALayer*)layerToInverse
{
    [self.delegate readButtonTappedWithRevisionIndex:self.currentRevisionIndex];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DScale(layerToInverse.transform, 1, 1, 1.0)];
    animation.duration = 0;
    animation.delegate = layerToInverse;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [layerToInverse addAnimation:animation forKey:@""];    
}

-(void)moveBy:(float)add duration:(float)duration {
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
	
	int layers = [self.galleryView.layer.sublayers count] - 1;
	int current = 0;
	
	for (PCKioskGalleryItem* layer in self.galleryView.layer.sublayers) {
		float x = layer.position.x + add;
		
		layer.position = CGPointMake(x, layer.position.y);
		
		if (x < self.galleryView.layer.bounds.size.width / 2 - DISTANCE_FROM_CENTER_X) {
			if (layers != current) {
				if (layer.angle != RADIANS(ANGLE)) {
					layer.angle = RADIANS(ANGLE);
					
					// CENTER -> LEFT
					[CATransaction begin];
					[CATransaction setValue:[NSNumber numberWithFloat:DURATION_CHANGE] forKey:kCATransactionAnimationDuration];
					CATransform3D transform = CATransform3DMakeTranslation(0, DISTANCE_FROM_CENTER_Y, DISTANCE_FROM_CENTER_Z);
					
					layer.transform   = CATransform3DRotate(transform, layer.angle, 0.0f, 1.0f, 0.0);
					layer.anchorPoint = CGPointMake(0.0, ANCHOR_POINT_Y);
					
					[CATransaction commit];
				}
			}
		} else if (x >= self.galleryView.layer.bounds.size.width / 2 - DISTANCE_FROM_CENTER_X + GAP) {
			if (0 < current) {
				if (layer.angle != RADIANS(-ANGLE)) {
					layer.angle = RADIANS(-ANGLE);
					
					// CENTER -> RIGHT
					[CATransaction begin];
					[CATransaction setValue:[NSNumber numberWithFloat:DURATION_CHANGE] forKey:kCATransactionAnimationDuration];
					
					CATransform3D transform = CATransform3DMakeTranslation(DISTANCE_FROM_CENTER_X * 2, DISTANCE_FROM_CENTER_Y, DISTANCE_FROM_CENTER_Z);
					
					layer.transform = CATransform3DRotate(transform, layer.angle, 0.0f, 1.0f, 0.0);
					layer.anchorPoint = CGPointMake(1.0, ANCHOR_POINT_Y);
					
					[CATransaction commit];
				}
			}
		} else if (layer.angle != 0.0) {
			// LEFT -> CENTER <- RIGHT
			layer.angle = 0.0;
			
			[CATransaction begin];
			[CATransaction setValue:[NSNumber numberWithFloat:DURATION_CHANGE * 2] forKey:kCATransactionAnimationDuration];
			
			layer.anchorPoint = CGPointMake(0.5, ANCHOR_POINT_Y);
			layer.transform   = CATransform3DMakeTranslation(DISTANCE_FROM_CENTER_X, DISTANCE_FROM_CENTER_Y, DISTANCE_FROM_CENTER_Z + IN_FRONT);
			
			[CATransaction commit];			
		}
		
		++current;
	}
	
	[CATransaction commit];
    
    [self adjustCurrentRevisionIndex];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self touchesMoved:nil withEvent:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self touchesMoved:touches withEvent:event];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!self.disabled) {
		float add      = 0;
		float duration = 0.0;
        
		if (touches) {
			UITouch *touch = [[event allTouches] anyObject];
			CGPoint fromLocation = [touch previousLocationInView:self.galleryView];
			CGPoint toLocation = [touch locationInView:self.galleryView];
            
			add = (toLocation.x - fromLocation.x) * ANGLE_COEFF;
		} else {
			// move back to the center
			PCKioskGalleryItem* layer = [self.galleryView.layer.sublayers objectAtIndex:0];
			int layers       = [self.galleryView.layer.sublayers count];
            
			float center     = self.galleryView.bounds.size.width / 2 - DISTANCE_FROM_CENTER_X;
			
			if (layer.position.x > center)
			{
				add = center - layer.position.x;
			}
			else if (layer.position.x <= center - (layers - 1) * GAP)
                {
                    add = center - layer.position.x - (layers - 1) * GAP;
                }
			duration = 0.5f;
		}
        
		[self moveBy:add duration:duration];
	}
    [self adjustCurrentRevisionIndex];
}

- (void) adjustCurrentRevisionIndex
{
	for (PCKioskGalleryItem* layer in self.galleryView.layer.sublayers)
	{
		if (layer.angle == RADIANS(0))
		{
            NSInteger       newIndex = [self.galleryView.layer.sublayers indexOfObject:layer];
            
            if(newIndex != self.currentRevisionIndex)
            {
                self.currentRevisionIndex = newIndex;
                [self onCurrentRevisionIndexChanged];
            }
			return;
		}
	}
	self.currentRevisionIndex = -1;
}

- (void) onCurrentRevisionIndexChanged
{
    self.controlElement.revisionIndex = self.currentRevisionIndex;
    [self.controlElement update];
}

- (void) updateRevisionWithIndex:(NSInteger)index
{
    if(self.currentRevisionIndex == index)
    {
        [self.controlElement update];
    }
}

#pragma mark - PCKioskSubviewDelegateProtocol


- (void) downloadButtonTappedWithRevisionIndex:(NSInteger) index
{
    [self.delegate downloadButtonTappedWithRevisionIndex:index];
}

- (void) readButtonTappedWithRevisionIndex:(NSInteger) index
{
    [self.delegate readButtonTappedWithRevisionIndex:index];
}

- (void) cancelButtonTappedWithRevisionIndex:(NSInteger) index
{
    [self.delegate cancelButtonTappedWithRevisionIndex:index];
}

- (void) deleteButtonTappedWithRevisionIndex:(NSInteger) index
{
    [self.delegate deleteButtonTappedWithRevisionIndex:index];
}

- (void) updateButtonTappedWithRevisionIndex:(NSInteger) index
{
    [self.delegate updateButtonTappedWithRevisionIndex:index];
}

- (void) purchaseButtonTappedWithRevisionIndex:(NSInteger) index
{
    [self.delegate purchaseButtonTappedWithRevisionIndex:index];
}

#pragma mark - Downloading flow

- (void) downloadStartedWithRevisionIndex:(NSInteger)index
{
    [super downloadStartedWithRevisionIndex:index];
    [self.controlElement downloadStarted];
    self.disabled = TRUE;
}

- (void) downloadProgressUpdatedWithRevisionIndex:(NSInteger)index andProgress:(float)progress andRemainingTime:(NSString *)time
{
    [super downloadProgressUpdatedWithRevisionIndex:index
                                        andProgress:progress
                                   andRemainingTime:time];
    
    [self.controlElement downloadProgressUpdatedWithProgress:progress andRemainingTime:time];
}

- (void) downloadFinishedWithRevisionIndex:(NSInteger)index
{
    [super downloadFinishedWithRevisionIndex:index];
    [self.controlElement downloadFinished];
    self.disabled = FALSE;
}

- (void) downloadFailedWithRevisionIndex:(NSInteger)index
{
    [self downloadFailedWithRevisionIndex:index];
    [self.controlElement downloadFailed];
    self.disabled = FALSE;
}

- (void) downloadCanceledWithRevisionIndex:(NSInteger)index
{
    [super downloadCanceledWithRevisionIndex:index];
    [self.controlElement downloadCanceled];
    self.disabled = FALSE;
}

@end
