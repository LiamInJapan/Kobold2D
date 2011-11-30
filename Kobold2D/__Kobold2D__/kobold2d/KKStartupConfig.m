/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */


#import "KKStartupConfig.h"
#import "KKConfig.h"
#import "KKRootViewController.h"

@implementation KKStartupConfig

@synthesize gLViewColorFormat, gLViewDepthFormat, gLViewNumberOfSamples, directorType, directorTypeFallback, deviceOrientation, maxFrameRate;
@synthesize defaultTexturePixelFormat;
@synthesize gLViewMultiSampling, displayFPS, enableStatusBar;
@synthesize enableUserInteraction, enableMultiTouch, enable2DProjection, enableRetinaDisplaySupport, enableGLViewNodeHitTesting;

// root view controller config
@synthesize autorotationType;
@synthesize shouldAutorotateToLandscapeOrientations, shouldAutorotateToPortraitOrientations, allowAutorotateOnFirstAndSecondGenerationDevices;

// Ad stuff
@synthesize enableAdBanner, loadOnlyPortraitBanners, loadOnlyLandscapeBanners, placeBannerOnBottom;
@synthesize adProviders, adMobPublisherID, adMobFirstAdDelay, adMobRefreshRate, adMobTestMode;

// first scene
@synthesize firstSceneClassName;

// Mac OS specific
@synthesize autoScale, acceptsMouseMovedEvents, enableFullScreen;
@synthesize windowFrame;

-(id) init
{
	if ((self = [super init]))
	{
		// in case anything goes wrong with enum values set them to safe defaults here:
		autorotationType = KKAutorotationNone;
		directorTypeFallback = 0;
		adProviders = @"iAd, AdMob";
		
		[KKConfig injectPropertiesFromKeyPath:NSStringFromClass([self class]) target:self];
		
#if NDEBUG
		adMobTestMode = NO;
#endif
	}
	return self;
}

+(id) config
{
	return [[[self alloc] init] autorelease];
}

-(void) dealloc
{
	[firstSceneClassName release]; firstSceneClassName = nil;
	
	[super dealloc];
}

@end