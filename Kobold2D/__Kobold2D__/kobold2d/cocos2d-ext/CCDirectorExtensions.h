/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import <Availability.h>
#import "cocos2d.h"

typedef enum
{
	KKTargetPlatformUnknown = 0,
	KKTargetPlatformIOS,
	KKTargetPlatformMac,
} KKTargetPlatform;

/** extends CCDirector */
@interface CCDirector (KoboldExtensions)

/** Gives you the screen center position (in points), ie half of the screen size */
@property (nonatomic, readonly) CGPoint screenCenter;
/** Gives you the screen center position (in pixels), ie half of the screen size */
@property (nonatomic, readonly) CGPoint screenCenterInPixels;
/** Gives you the screen size as a CGRect (in points) spanning from 0, 0 to screenWidth, screenHeight */
@property (nonatomic, readonly) CGRect screenRect;
/** Gives you the screen size as a CGRect (in pixels) spanning from 0, 0 to screenWidth, screenHeight */
@property (nonatomic, readonly) CGRect screenRectInPixels;
/** Gives you the screen size as a CGSize struct (in points) */
@property (nonatomic, readonly) CGSize screenSize;
/** Gives you the screen size as a CGSize struct (in pixels) */
@property (nonatomic, readonly) CGSize screenSizeInPixels;
/** Gives you the screen size as a CGPoint struct (in points) */
@property (nonatomic, readonly) CGPoint screenSizeAsPoint;
/** Gives you the screen size as a CGPoint struct (in pixels) */
@property (nonatomic, readonly) CGPoint screenSizeAsPointInPixels;
/** Checks if the scene stack is still empty, which means runWithScene hasn't been called yet. */
@property (nonatomic, readonly) BOOL isSceneStackEmpty;
/** Tells you if the app is currently running on iOS. */
@property (nonatomic, readonly) BOOL currentPlatformIsIOS;
/** Tells you if the app is currently running on Mac. */
@property (nonatomic, readonly) BOOL currentPlatformIsMac;
/** Tells you if the app is currently running in the iPhone/iPad Simulator. */
@property (nonatomic, readonly) BOOL currentDeviceIsSimulator;
/** Tells you if the app is currently running on the iPad rather than iPhone or iPod Touch. */
@property (nonatomic, readonly) BOOL currentDeviceIsIPad;

@end

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@interface CCDirectorIOS (KoboldExtensions)

/** Tells you whether Retina Display is currently enabled. It does not tell you if the device you're running has a Retina display. 
 it could be a Retina device but Retina display may simply not be enabled. */
-(bool) isRetinaDisplayEnabled;

/** Gives you the inverse of the scale factor: 1.0f / contentScaleFactor */
-(float) contentScaleFactorInverse;
/** Gives you the scale factor halved: contentScaleFactor * 0.5f */
-(float) contentScaleFactorHalved;

@end
#endif
