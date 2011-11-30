/*********************************************************************
 *	
 *	SpaceManager
 *
 *	GameDelegate.m
 *
 *	game delegate for initializing sequence
 *
 *	http://www.mobile-bros.com
 *
 *	Created by matt on 5/11/09.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "GameDelegate.h"

#import "Serialize.h"
#import "Retina.h"
#import "GameLayer.h"

@interface GameDelegate (PrivateMethods)

@end

@implementation GameDelegate

#pragma mark GameDelegate Methods
- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	[application setIdleTimerDisabled:YES];
	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	//if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
	//	[CCDirector setDirectorType:kCCDirectorTypeNSTimer];
	[CCDirector setDirectorType:CCDirectorTypeThreadMainLoop];
	
	CCDirector *director = [CCDirector sharedDirector];
	
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
	[director setDisplayFPS:NO];
	[director setAnimationInterval:1.0/60];
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
									 pixelFormat:kEAGLColorFormatRGB565
									 depthFormat:0 /* GL_DEPTH_COMPONENT24_OES */
							  preserveBackbuffer:NO
									  sharegroup:nil
								   multiSampling:NO
								 numberOfSamples:0
						  ];
	[director setOpenGLView:glView];
	[window addSubview:glView];																
	[window makeKeyAndVisible];		
	
	//[window setUserInteractionEnabled:YES];
	//[window setMultipleTouchEnabled:YES];

	[director setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	[director setDisplayFPS:YES];

	CCScene *game = [CCScene node];
#if SERIALIZE_TEST
	Serialize *layer = [Serialize node];
#elif RETINA_TEST
	[director enableRetinaDisplay:YES];
	Retina *layer = [Retina node];
#else
    [glView setMultipleTouchEnabled:YES];
	GameLayer *layer = [GameLayer node];
#endif
	[game addChild:layer z:0 tag:1];
	[director runWithScene:game];
}

- (void)applicationWillTerminate:(UIApplication*)application
{
	[[CCDirector sharedDirector] end];
}

-(void)dealloc
{
	[window release];
	[super dealloc];
}

-(void) applicationWillResignActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] pause];
}

-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCTextureCache sharedTextureCache] removeAllTextures];
}

@end
