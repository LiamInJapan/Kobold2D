/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

/*
 * License for original source:
 *
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "KKAppDelegate.h"

#import "kobold2d_version.h"
#import "KKStartupConfig.h"
#import "KKHitTest.h"

@implementation KKAppDelegate

/* ********************************************************************************************************************* */
// AppDelegate code for both iOS & Mac OS X targets
/* ********************************************************************************************************************* */

-(void) initializationComplete
{
	// does nothing, supposed to be overridden
}

-(id) alternateRootViewController
{
	// does nothing, supposed to be overridden
	return nil;
}

-(id) alternateView
{
	// does nothing, supposed to be overridden
	return nil;
}

-(void) tryToRunFirstScene
{
	CCDirector* director = [CCDirector sharedDirector];
	
	// try to run first scene
	if (director.isSceneStackEmpty)
	{
		Class firstSceneClass = NSClassFromString(config.firstSceneClassName);
		if (firstSceneClass)
		{
			id scene = [[[firstSceneClass alloc] init] autorelease];
			if ([scene isKindOfClass:[CCScene class]])
			{
				// TODO: remove startup flicker here
				[director runWithScene:scene];
			}
			else if ([scene isKindOfClass:[CCLayer class]])
			{
				// TODO: remove startup flicker here
				CCScene* dummyScene = [CCScene node];
				[dummyScene addChild:scene];
				[director runWithScene:dummyScene];
			}
		}
	}
	
	// if still empty, create a dummy scene
	if (director.isSceneStackEmpty)
	{
		CCLOG(@"Unable to run first scene! Check that in config.lua FirstSceneClassName matches with the name of a class inherited from CCScene.");
		CGSize screenSize = director.winSize;
		CCScene* dummyScene = [CCScene node];
		NSString* string = [NSString stringWithFormat:@"ERROR in config.lua\n\nFirstSceneClassName = '%@'\n\nThis class does not exist or\ndoes not inherit from CCScene!", config.firstSceneClassName];
		CCLabelTTF* label = [CCLabelTTF labelWithString:string dimensions:screenSize alignment:CCTextAlignmentCenter lineBreakMode:CCLineBreakModeWordWrap fontName:@"Arial" fontSize:24];
		label.position = CGPointMake(screenSize.width / 2, screenSize.height / 4);
		label.color = ccRED;
		[dummyScene addChild:label];
		[director runWithScene:dummyScene];
		glClearColor(1, 1, 1, 1);
	}
}

/* ********************************************************************************************************************* */
// iOS AppDelegate
/* ********************************************************************************************************************* */
#ifdef KK_PLATFORM_IOS

#import <UIKit/UIKit.h>

#pragma mark iOS AppDelegate

@synthesize window, rootViewController, config;

-(void) applicationDidFinishLaunching:(UIApplication*)application
{
	config = [[KKStartupConfig config] retain];

	if ([application respondsToSelector:@selector(setStatusBarHidden:withAnimation:)])
	{
        [application setStatusBarHidden:!config.enableStatusBar withAnimation:UIStatusBarAnimationFade];
	}
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 30200
    else
	{
        [application setStatusBarHidden:!config.enableStatusBar animated:YES];
	}
#endif
	
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	// Init the View Controller
	rootViewController = [self alternateRootViewController];
	if (rootViewController == nil)
	{
		rootViewController = [[KKRootViewController alloc] initWithNibName:nil bundle:nil];
	}
	else if ([rootViewController isKindOfClass:[KKRootViewController class]] == NO)
	{
		[NSException raise:@"alternate RootViewController not of class KKRootViewController" format:@""];
	}

	rootViewController.wantsFullScreenLayout = !config.enableStatusBar;

#if defined(__ARM_NEON__) || TARGET_IPHONE_SIMULATOR
	rootViewController.autorotationType = config.autorotationType;
#else
	rootViewController.autorotationType = (config.allowAutorotateOnFirstAndSecondGenerationDevices ? config.autorotationType : KKAutorotationNone);
#endif
	rootViewController.shouldAutorotateToLandscapeOrientations = config.shouldAutorotateToLandscapeOrientations;
	rootViewController.shouldAutorotateToPortraitOrientations = config.shouldAutorotateToPortraitOrientations;
	
	NSString* colorFormat = nil;
	switch (config.gLViewColorFormat)
	{
		default:
			CCLOG(@"invalid color format specified, using default RGBA8");
		case 8888:
			colorFormat = kEAGLColorFormatRGBA8;
			break;
		case 565:
			colorFormat = kEAGLColorFormatRGB565;
			break;
	}
	
	// Create an EAGLView with a RGB8 color buffer, and a depth buffer of 24-bits
	EAGLView* glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:colorFormat
								   depthFormat:config.gLViewDepthFormat
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:config.gLViewMultiSampling
							   numberOfSamples:config.gLViewNumberOfSamples];
	
	// director type must be set before any call to the director
	if (![CCDirector setDirectorType:config.directorType])
	{
		[CCDirector setDirectorType:config.directorTypeFallback];
	}

	CCLOG(@"%@", kobold2dVersion());

	// Setup director
	CCDirector* director = [CCDirector sharedDirector];
	[director setDeviceOrientation:config.deviceOrientation];
	[director setAnimationInterval:1.0f / config.maxFrameRate];
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:[director animationInterval]];

	[director setDisplayFPS:config.displayFPS];
	
	if (config.autorotationType == KKAutorotationUIViewController)
	{
		// If the rotation is going to be controlled by a UIViewController then the device orientation should be "Portrait".
		[director setDeviceOrientation:kCCDeviceOrientationPortrait];
	}
	else
	{
		[director setDeviceOrientation:config.deviceOrientation];
	}
	
	// required for cc_vertexz property to work properly (if not set, cc_vertexz layers will be zoomed out!)
	if (config.enable2DProjection)
	{
		[director setProjection:kCCDirectorProjection2D];
	}
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	[CCTexture2D setDefaultAlphaPixelFormat:config.defaultTexturePixelFormat];
	
	// attach the OpenGLView
	[director setOpenGLView:glView];
	
	// viewController's view will be the Director's glView, unless an alternate View is available
	UIView* alternateView = [[self alternateView] retain];
	if (alternateView)
	{
		rootViewController.view = alternateView;
		[alternateView release];
		
		// rootViewController's view is no longer nil, in this case we must call viewDidLoad manually
		[rootViewController viewDidLoad];
	}

	// by letting the viewController.view property be nil up to this point we follow Apple's normal procedure of having
	// the viewController's loadView method add the Director's glView via loadView. Failing to do so will not call viewDidLoad in the controller.
	// See: http://stackoverflow.com/questions/1479576/viewdidload-not-called-in-subclassed-uiviewcontroller
	[window addSubview:rootViewController.view];
	
	// this must be called AFTER the glView has been attached to the director!
	BOOL usesRetina = [director enableRetinaDisplay:config.enableRetinaDisplaySupport];
	NSLog(@"Retina Display enabled: %@", usesRetina ? @"YES" : @"NO");
	
	// Must add the root view controller for GameKitHelper to work!
	// Also generally a good idea because it allows you to access the rootViewController from anywhere
	// via: [UIApplication sharedApplication].keyWindow.rootViewController
	// Otherwise you'd use:
	// ((KKAppDelegate*)[UIApplication sharedApplication].delegate).rootViewController;
	if ([window respondsToSelector:@selector(setRootViewController:)])
	{
		window.rootViewController = rootViewController;
	}
	
	[glView setUserInteractionEnabled:config.enableUserInteraction];
	[glView setMultipleTouchEnabled:config.enableMultiTouch];
	
	[window makeKeyAndVisible];
	
	[KKHitTest sharedHitTest].isHitTesting = config.enableGLViewNodeHitTesting;
	
	// this may cause a scene to be run by the user ...
	[self initializationComplete];
	[self tryToRunFirstScene];
}

-(void) applicationWillResignActive:(UIApplication *)application 
{
	[[CCDirector sharedDirector] pause];
}

-(void) applicationDidBecomeActive:(UIApplication *)application 
{
	[[CCDirector sharedDirector] resume];
}

-(void) applicationDidReceiveMemoryWarning:(UIApplication *)application 
{
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application 
{
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application 
{
	[[CCDirector sharedDirector] startAnimation];
}

-(void) applicationWillTerminate:(UIApplication *)application 
{
	CCDirector* director = [CCDirector sharedDirector];
	[[director openGLView] removeFromSuperview];
	[rootViewController release];
	[window release];
	[director end];	
}

-(void) applicationSignificantTimeChange:(UIApplication *)application 
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

/** Note: dealloc of the AppDelegate is never called!
 This is normal behavior, see: http://stackoverflow.com/questions/2075069/iphone-delegate-controller-dealloc
 The App's memory is wiped anyway so the App doesn't go through to effort to call object's dealloc on App terminate.
 Still it's good practice to still write the dealloc code, in case that ever were to change
 */
-(void) dealloc
{
	[config release];
	[window release];
	[super dealloc];
}

/* ********************************************************************************************************************* */
#elif KK_PLATFORM_MAC // Mac AppDelegate
/* ********************************************************************************************************************* */

#pragma mark Mac AppDelegate

@synthesize window, glView;

-(void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
	config = [[KKStartupConfig config] retain];

	CCDirectorMac* director = (CCDirectorMac*)[CCDirector sharedDirector];
	[director setDisplayFPS:config.displayFPS];
	[director setOpenGLView:glView];
	
	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	// Use kCCDirectorResize_NoScale if you don't want auto-scaling.
	if (config.autoScale == YES)
	{
		[director setResizeMode:kCCDirectorResize_AutoScale];
	}
	else
	{
		[director setResizeMode:kCCDirectorResize_NoScale];
	}

	// required for cc_vertexz property to work properly (if not set, cc_vertexz layers will be zoomed out!)
	if (config.enable2DProjection)
	{
		[director setProjection:kCCDirectorProjection2D];
	}

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	[CCTexture2D setDefaultAlphaPixelFormat:config.defaultTexturePixelFormat];

	[window setAcceptsMouseMovedEvents:config.acceptsMouseMovedEvents];

	if (NSIsEmptyRect(config.windowFrame) == NO)
	{
		// the user will usually want to set the OpenGL view's size, not the window size
		NSRect windowFrame = [window frameRectForContentRect:config.windowFrame];
		[window setFrame:windowFrame display:YES];
	}
	
	NSWindow* alternateView = [[self alternateView] retain];
	if (alternateView)
	{
		[window addChildWindow:alternateView ordered:NSWindowAbove];
		//[window setContentView:alternateView];
		[alternateView release];
	}

	[(CCDirectorMac*)[CCDirector sharedDirector] setFullScreen:config.enableFullScreen];

	CCLOG(@"cocos2d: window frame: origin {%.0f, %.0f}, size {%.0f, %.0f}", [window frame].origin.x, [window frame].origin.y, [window frame].size.width, [window frame].size.height);

	[self initializationComplete];
	[self tryToRunFirstScene];
}

-(BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)theApplication
{
	return YES;
}

-(void) dealloc
{
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}

-(IBAction) toggleFullScreen:(id)sender
{
	CCDirectorMac* director = (CCDirectorMac*)[CCDirector sharedDirector];
	bool toggleFullScreen = !([director isFullScreen]);
	[director setFullScreen:toggleFullScreen];
}

#endif

@end
