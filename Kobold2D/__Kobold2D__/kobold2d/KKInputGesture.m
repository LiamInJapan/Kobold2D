/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "KKInputGesture.h"

@interface KKInputGesture (PrivateMethods)
-(void) determineGestureRecognizersAvailable;
-(void) scheduleOrUnscheduleUpdateAsNeeded;
#if KK_PLATFORM_IOS
-(void) removeGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer;
#endif
@end


@implementation KKInputGesture

@synthesize gesturesAvailable;

// tap & double tap
@dynamic gestureTapEnabled, gestureDoubleTapEnabled;
@synthesize gestureTapRecognizedThisFrame, gestureTapLocation, gestureDoubleTapRecognizedThisFrame, gestureDoubleTapLocation;

// swipe
@dynamic gestureSwipeEnabled;
@synthesize gestureSwipeRecognizedThisFrame, gestureSwipeLocation, gestureSwipeDirection;

// long press
@dynamic gestureLongPressEnabled;
@synthesize gestureLongPressBegan, gestureLongPressLocation;

// pan
@dynamic gesturePanEnabled;
@synthesize gesturePanBegan, gesturePanLocation, gesturePanTranslation, gesturePanVelocity;

// rotation
@dynamic gestureRotationEnabled;
@synthesize gestureRotationBegan, gestureRotationLocation, gestureRotationAngle, gestureRotationVelocity;

// pinch
@dynamic gesturePinchEnabled;
@synthesize gesturePinchBegan, gesturePinchLocation, gesturePinchScale, gesturePinchVelocity;

-(id) init
{
    if ((self = [super init]))
	{
		director = [CCDirector sharedDirector];

		[self determineGestureRecognizersAvailable];
		[self scheduleOrUnscheduleUpdateAsNeeded];
    }
    
    return self;
}

-(void) dealloc
{
	if (gesturesAvailable)
	{
		if (isUpdateScheduled)
		{
			[[CCScheduler sharedScheduler] unscheduleAllSelectorsForTarget:self];
			isUpdateScheduled = NO;
		}
		
#if KK_PLATFORM_IOS
		[self removeGestureRecognizer:tapGestureRecognizer];
		[self removeGestureRecognizer:doubleTapGestureRecognizer];
		for (int i = 0; i < kNumSwipeGestureRecognizers; i++)
		{
			[self removeGestureRecognizer:swipeGestureRecognizers[i]];
		}
		[self removeGestureRecognizer:longPressGestureRecognizer];
		[self removeGestureRecognizer:panGestureRecognizer];
		[self removeGestureRecognizer:rotationGestureRecognizer];
		[self removeGestureRecognizer:pinchGestureRecognizer];
#endif
	}

	[super dealloc];
}


#if KK_PLATFORM_IOS

-(void) handleGestureDummy:(UIGestureRecognizer*)gestureRecognizer {}
-(void) determineGestureRecognizersAvailable
{
	gesturesAvailable = YES;
	
	// gestures are not available if gestureRecognizer is nil, or does not support the locationInView selector added in iOS 3.2
	UIGestureRecognizer* gestureRecognizer = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureDummy:)];
	gesturesAvailable = [gestureRecognizer respondsToSelector:@selector(locationInView:)];
	[gestureRecognizer release];
}


-(void) removeGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer
{
	if (gestureRecognizer)
	{
		[director.openGLView removeGestureRecognizer:gestureRecognizer];
		gestureRecognizer.delegate = nil;
		[gestureRecognizer release];
		gestureRecognizer = nil;
	}
}

-(void) scheduleOrUnscheduleUpdateAsNeeded
{
	if (gesturesAvailable)
	{
		if (isUpdateScheduled)
		{
			if (tapGestureRecognizer == nil && doubleTapGestureRecognizer == nil && swipeGestureRecognizers[0] == nil)
			{
				[[CCScheduler sharedScheduler] unscheduleUpdateForTarget:self];
				isUpdateScheduled = NO;
			}
		}
		else if (tapGestureRecognizer || doubleTapGestureRecognizer || swipeGestureRecognizers[0])
		{
			[[CCScheduler sharedScheduler] scheduleUpdateForTarget:self priority:INT_MAX paused:NO];
			isUpdateScheduled = YES;
		}
	}
}


#pragma mark Gesture properties

-(void) setGesturePanTranslation:(CGPoint)translation
{
	[panGestureRecognizer setTranslation:translation inView:director.openGLView];
}

-(void) setGestureRotationAngle:(float)angle
{
	[rotationGestureRecognizer setRotation:CC_DEGREES_TO_RADIANS(angle)];
}

-(void) setGesturePinchScale:(float)scale
{
	[pinchGestureRecognizer setScale:scale];
}


#pragma mark Gesture delegate methods

-(BOOL) gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer
{
	Class recognizerClass = [gestureRecognizer class];
	Class otherClass = [otherGestureRecognizer class];
	Class panClass = [UIPanGestureRecognizer class];
	Class swipeClass = [UISwipeGestureRecognizer class];
	Class rotationClass = [UIRotationGestureRecognizer class];
	Class pinchClass = [UIPinchGestureRecognizer class];
	
	return ((recognizerClass == panClass && otherClass == swipeClass) || (recognizerClass == swipeClass && otherClass == panClass) ||
			(recognizerClass == rotationClass && otherClass == pinchClass) || (recognizerClass == pinchClass && otherClass == rotationClass));
}


#pragma mark Gesture Handlers

-(KKSwipeGestureDirection) convertSwipeDirection:(UISwipeGestureRecognizerDirection)uiDirection
{
	// portrait mode direction remains unchanged
	KKSwipeGestureDirection direction = (KKSwipeGestureDirection)uiDirection;
	
	switch (uiDirection)
	{
		case UISwipeGestureRecognizerDirectionRight:
		{
			switch (director.deviceOrientation)
			{
				case CCDeviceOrientationPortraitUpsideDown:
					direction = KKSwipeGestureDirectionLeft;
					break;
				case CCDeviceOrientationLandscapeLeft:
					direction = KKSwipeGestureDirectionUp;
					break;
				case CCDeviceOrientationLandscapeRight:
					direction = KKSwipeGestureDirectionDown;
					break;
				default:
					break;
			}
			break;
		}
			
		case UISwipeGestureRecognizerDirectionLeft:
		{
			switch (director.deviceOrientation)
			{
				case CCDeviceOrientationPortraitUpsideDown:
					direction = KKSwipeGestureDirectionRight;
					break;
				case CCDeviceOrientationLandscapeLeft:
					direction = KKSwipeGestureDirectionDown;
					break;
				case CCDeviceOrientationLandscapeRight:
					direction = KKSwipeGestureDirectionUp;
					break;
				default:
					break;
			}
			break;
		}
			
		case UISwipeGestureRecognizerDirectionUp:
		{
			switch (director.deviceOrientation)
			{
				case CCDeviceOrientationPortraitUpsideDown:
					direction = KKSwipeGestureDirectionDown;
					break;
				case CCDeviceOrientationLandscapeLeft:
					direction = KKSwipeGestureDirectionLeft;
					break;
				case CCDeviceOrientationLandscapeRight:
					direction = KKSwipeGestureDirectionRight;
					break;
				default:
					break;
			}
			break;
		}
			
		case UISwipeGestureRecognizerDirectionDown:
		{
			switch (director.deviceOrientation)
			{
				case CCDeviceOrientationPortraitUpsideDown:
					direction = KKSwipeGestureDirectionUp;
					break;
				case CCDeviceOrientationLandscapeLeft:
					direction = KKSwipeGestureDirectionRight;
					break;
				case CCDeviceOrientationLandscapeRight:
					direction = KKSwipeGestureDirectionLeft;
					break;
				default:
					break;
			}
			break;
		}
	}
	
	return direction;
}

-(void) handleTapGesture:(UIGestureRecognizer*)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateEnded)
	{
		gestureTapRecognizedThisFrame = YES;
		gestureTapLocation = [director convertToGL:[recognizer locationInView:director.openGLView]];
	}
}

-(void) handleDoubleTapGesture:(UIGestureRecognizer*)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateEnded)
	{
		gestureDoubleTapRecognizedThisFrame = YES;
		gestureDoubleTapLocation = [director convertToGL:[recognizer locationInView:director.openGLView]];
	}
}

-(void) handleSwipeGesture:(UIGestureRecognizer*)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateEnded)
	{
		gestureSwipeRecognizedThisFrame = YES;
		gestureSwipeLocation = [director convertToGL:[recognizer locationInView:director.openGLView]];
		gestureSwipeDirection = [self convertSwipeDirection:[(UISwipeGestureRecognizer*)recognizer direction]];
	}
}

-(void) handleLongPressGesture:(UIGestureRecognizer*)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateEnded || 
		recognizer.state == UIGestureRecognizerStateCancelled ||
		recognizer.state == UIGestureRecognizerStateFailed)
	{
		gestureLongPressBegan = NO;
	}
	else
	{
		gestureLongPressBegan = YES;
		gestureLongPressLocation = [director convertToGL:[recognizer locationInView:director.openGLView]];
	}
}

-(void) handlePanGesture:(UIGestureRecognizer*)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateEnded || 
		recognizer.state == UIGestureRecognizerStateCancelled ||
		recognizer.state == UIGestureRecognizerStateFailed)
	{
		gesturePanBegan = NO;
	}
	else
	{
		UIPanGestureRecognizer* panRecognizer = (UIPanGestureRecognizer*)recognizer;
		UIView* glView = director.openGLView;
		
		gesturePanBegan = YES;
		gesturePanLocation = [director convertToGL:[recognizer locationInView:glView]];
		gesturePanTranslation = [panRecognizer translationInView:glView];
		gesturePanTranslation.y *= -1.0f;
		gesturePanVelocity = [director convertToGL:[panRecognizer velocityInView:glView]];
		gesturePanVelocity = ccpMult(gesturePanVelocity, director.animationInterval);
	}
}

-(void) handleRotationGesture:(UIGestureRecognizer*)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateEnded || 
		recognizer.state == UIGestureRecognizerStateCancelled ||
		recognizer.state == UIGestureRecognizerStateFailed)
	{
		gestureRotationBegan = NO;
	}
	else
	{
		UIRotationGestureRecognizer* rotationRecognizer = (UIRotationGestureRecognizer*)recognizer;
		UIView* glView = director.openGLView;
		
		gestureRotationBegan = YES;
		gestureRotationLocation = [director convertToGL:[recognizer locationInView:glView]];
		gestureRotationAngle = CC_RADIANS_TO_DEGREES([rotationRecognizer rotation]);
		gestureRotationVelocity = CC_RADIANS_TO_DEGREES([rotationRecognizer velocity]) * director.animationInterval;
	}
}

-(void) handlePinchGesture:(UIGestureRecognizer*)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateEnded || 
		recognizer.state == UIGestureRecognizerStateCancelled ||
		recognizer.state == UIGestureRecognizerStateFailed)
	{
		gesturePinchBegan = NO;
	}
	else
	{
		UIPinchGestureRecognizer* pinchRecognizer = (UIPinchGestureRecognizer*)recognizer;
		UIView* glView = director.openGLView;
		
		gesturePinchBegan = YES;
		gesturePinchLocation = [director convertToGL:[recognizer locationInView:glView]];
		gesturePinchScale = [pinchRecognizer scale];
		gesturePinchVelocity = [pinchRecognizer velocity] * director.animationInterval;
	}
}

#endif // KK_PLATFORM_IOS


#pragma mark Gesture Enablers

-(void) setGestureTapEnabled:(BOOL)enabled
{
#if KK_PLATFORM_IOS
	if (gesturesAvailable)
	{
		gestureTapEnabled = enabled;

		if (enabled && tapGestureRecognizer == nil)
		{
			tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
			[director.openGLView addGestureRecognizer:tapGestureRecognizer];

			if (doubleTapGestureRecognizer)
			{
				[tapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
			}
		}
		else if (enabled == NO && tapGestureRecognizer)
		{
			[self removeGestureRecognizer:tapGestureRecognizer];
			tapGestureRecognizer = nil;
		}
		
		[self scheduleOrUnscheduleUpdateAsNeeded];
	}
#endif
}

-(void) setGestureDoubleTapEnabled:(BOOL)enabled
{
#if KK_PLATFORM_IOS
	if (gesturesAvailable)
	{
		gestureDoubleTapEnabled = enabled;
		
		if (enabled && doubleTapGestureRecognizer == nil)
		{
			doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
			doubleTapGestureRecognizer.numberOfTapsRequired = 2;
			[director.openGLView addGestureRecognizer:doubleTapGestureRecognizer];
			
			[tapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
		}
		else if (enabled == NO && doubleTapGestureRecognizer)
		{
			[tapGestureRecognizer requireGestureRecognizerToFail:nil];
			[self removeGestureRecognizer:doubleTapGestureRecognizer];
			doubleTapGestureRecognizer = nil;
		}

		[self scheduleOrUnscheduleUpdateAsNeeded];
	}
#endif
}

-(void) setGestureSwipeEnabled:(BOOL)enabled
{
#if KK_PLATFORM_IOS
	if (gesturesAvailable)
	{
		gestureSwipeEnabled = enabled;
		
		if (enabled && swipeGestureRecognizers[0] == nil)
		{
			for (int i = 0; i < kNumSwipeGestureRecognizers; i++)
			{
				swipeGestureRecognizers[i] = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
				swipeGestureRecognizers[i].direction = (UISwipeGestureRecognizerDirection)(1 << i);
				swipeGestureRecognizers[i].delegate = self;
				[director.openGLView addGestureRecognizer:swipeGestureRecognizers[i]];
			}
		}
		else if (enabled == NO && swipeGestureRecognizers[0])
		{
			for (int i = 0; i < kNumSwipeGestureRecognizers; i++)
			{
				[self removeGestureRecognizer:swipeGestureRecognizers[i]];
				swipeGestureRecognizers[i] = nil;
			}
		}
		
		[self scheduleOrUnscheduleUpdateAsNeeded];
	}
#endif
}

-(void) setGestureLongPressEnabled:(BOOL)enabled
{
#if KK_PLATFORM_IOS
	if (gesturesAvailable)
	{
		gestureLongPressEnabled = enabled;
		
		if (enabled && longPressGestureRecognizer == nil)
		{
			longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
			[director.openGLView addGestureRecognizer:longPressGestureRecognizer];
		}
		else if (enabled == NO && longPressGestureRecognizer)
		{
			[self removeGestureRecognizer:longPressGestureRecognizer];
			longPressGestureRecognizer = nil;
		}
	}
#endif
}

-(void) setGesturePanEnabled:(BOOL)enabled
{
#if KK_PLATFORM_IOS
	if (gesturesAvailable)
	{
		gesturePanEnabled = enabled;
		
		if (enabled && panGestureRecognizer == nil)
		{
			panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
			panGestureRecognizer.delegate = self;
			[director.openGLView addGestureRecognizer:panGestureRecognizer];
		}
		else if (enabled == NO && panGestureRecognizer)
		{
			[self removeGestureRecognizer:panGestureRecognizer];
			panGestureRecognizer = nil;
		}
	}
#endif
}

-(void) setGestureRotationEnabled:(BOOL)enabled
{
#if KK_PLATFORM_IOS
	if (gesturesAvailable)
	{
		gestureRotationEnabled = enabled;
		
		if (enabled && rotationGestureRecognizer == nil)
		{
			rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotationGesture:)];
			rotationGestureRecognizer.delegate = self;
			[director.openGLView addGestureRecognizer:rotationGestureRecognizer];
		}
		else if (enabled == NO && rotationGestureRecognizer)
		{
			[self removeGestureRecognizer:rotationGestureRecognizer];
			rotationGestureRecognizer = nil;
		}
	}
#endif
}

-(void) setGesturePinchEnabled:(BOOL)enabled
{
#if KK_PLATFORM_IOS
	if (gesturesAvailable)
	{
		gesturePinchEnabled = enabled;
		
		if (enabled && pinchGestureRecognizer == nil)
		{
			pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
			pinchGestureRecognizer.delegate = self;
			[director.openGLView addGestureRecognizer:pinchGestureRecognizer];
		}
		else if (enabled == NO && pinchGestureRecognizer)
		{
			[self removeGestureRecognizer:pinchGestureRecognizer];
			pinchGestureRecognizer = nil;
		}
	}
#endif
}

				 
#pragma mark update

-(void) update:(ccTime)delta
{
	if (gesturesAvailable)
	{
		gestureTapRecognizedThisFrame = NO;
		gestureDoubleTapRecognizedThisFrame = NO;
		gestureSwipeRecognizedThisFrame = NO;
		gesturePanVelocity = CGPointZero;
		gestureRotationVelocity = 0.0f;
		gesturePinchVelocity = 0.0f;
	}
}

@end
