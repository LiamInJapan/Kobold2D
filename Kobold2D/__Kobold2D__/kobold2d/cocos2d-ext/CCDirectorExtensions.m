/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "CCDirectorExtensions.h"
#import "ccMoreMacros.h"

#import "FixCategoryBug.h"
FIX_CATEGORY_BUG(CCDirector)

@implementation CCDirector (KoboldExtensions)

-(CGPoint) screenCenter
{
	CGSize screenSize = [self winSize];
	return CGPointMake(screenSize.width * 0.5f, screenSize.height * 0.5f);
}

-(CGPoint) screenCenterInPixels
{
	CGSize screenSize = [self winSizeInPixels];
	return CGPointMake(screenSize.width * 0.5f, screenSize.height * 0.5f);
}

-(CGRect) screenRect
{
	CGSize screenSize = [self winSize];
	return CGRectMake(0, 0, screenSize.width, screenSize.height);
}

-(CGRect) screenRectInPixels
{
	CGSize screenSize = [self winSizeInPixels];
	return CGRectMake(0, 0, screenSize.width, screenSize.height);
}

-(CGSize) screenSize
{
	return [self winSize];
}

-(CGSize) screenSizeInPixels
{
	return [self winSizeInPixels];
}

-(CGPoint) screenSizeAsPoint
{
	CGSize winSize = [self winSize];
	return CGPointMake(winSize.width, winSize.height);
}

-(CGPoint) screenSizeAsPointInPixels
{
	CGSize winSizeInPixels = [self winSizeInPixels];
	return CGPointMake(winSizeInPixels.width, winSizeInPixels.height);
}

-(BOOL) isSceneStackEmpty
{
	return ([scenesStack_ count] == 0);
}

-(BOOL) currentPlatformIsIOS
{
#if KK_PLATFORM_IOS
	return YES;
#endif
	return NO;
}

-(BOOL) currentPlatformIsMac
{
#if KK_PLATFORM_MAC
	return YES;
#endif
	return NO;
}

-(BOOL) currentDeviceIsSimulator
{
#if KK_PLATFORM_IOS_SIMULATOR
	return YES;
#else
	return NO;
#endif
}

-(BOOL) currentDeviceIsIPad
{
#ifdef KK_PLATFORM_IOS
	return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif
	return NO;
}

@end

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@implementation CCDirectorIOS (KoboldExtensions)

-(bool) isRetinaDisplayEnabled
{
	return ([self contentScaleFactor] == 2.0f);
}

-(float) contentScaleFactorInverse
{
	return (1.0f / [self contentScaleFactor]);
}

-(float) contentScaleFactorHalved
{
	return ([self contentScaleFactor] * 0.5f);
}

@end
#endif
