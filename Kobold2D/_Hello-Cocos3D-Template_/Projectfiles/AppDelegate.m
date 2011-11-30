/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "AppDelegate.h"

#import "Hello3DLayer.h"
#import "Hello3DWorld.h"
#import "HelloWorldLayer.h"

@implementation AppDelegate

// Note: only override the UI/NSApplicationDelegate methods that you absolutely must handle yourself.
// In most cases you will still want to call the [super ..] implementation,
// unless you want to override the KKAppDelegate behavior entirely.

// Called when Cocos2D is fully setup and you are able to run the first scene
-(void) initializationComplete
{
#ifdef KK_ARC_ENABLED
	CCLOG(@"ARC is enabled");
#else
	CCLOG(@"ARC is either not available or not enabled");
#endif
	
	// ******** START OF COCOS3D SETUP CODE... ********
	
	// Create the customized 3D world.
	CC3World* cc3World = [Hello3DWorld world];
	
	// Create the customized CC3 layer that supports 3D rendering
	CC3Layer* cc3Layer = [Hello3DLayer node];
	cc3Layer.cc3World = cc3World;		// attach 3D world to 3D layer
	
	// Start the 3D world model and schedule its periodic updates.
	[cc3World play];
	[cc3Layer scheduleUpdate];
	
	ControllableCCLayer* mainLayer = cc3Layer;
	
	// The 3D layer can run either direcly in the scene, or it can run as a smaller "sub-window"
	// within any standard CCLayer. So you can have a mostly 2D window, with a smaller 3D window
	// embedded in it. To experiment with this smaller embedded 3D window, uncomment the following lines:
	/*
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	cc3Layer.position = CGPointMake(winSize.width / 3, winSize.height / 3);
	cc3Layer.contentSize = CGSizeMake(winSize.width / 3, winSize.height / 3);
	cc3Layer.alignContentSizeWithDeviceOrientation = YES;
	mainLayer = [ControllableCCLayer node];
	[mainLayer addChild: cc3Layer];
	*/

	BOOL useNodeController = NO;

	if (useNodeController)
	{
		// The controller is optional. If you want to auto-rotate the view when the device orientation
		// changes, or if you want to display a device camera behind a combined 3D & 2D scene
		// (augmented reality), use a controller.
		
		// If desired make the 2D scene a child of the 3D layer and place it behind the 3D layer (z = -1).
		// Note that this way only allows you to have the entire 2D scene either in front of or behind the 3D layer,
		// unless you add individual nodes directly to the 3D layer.
		CCLayer* layer = [HelloWorldLayer node];
		[mainLayer addChild:layer z:-1];
		
		nodeController = [CCNodeController controller];
#ifndef KK_ARC_ENABLED
		[nodeController retain];
#endif
		nodeController.doesAutoRotate = YES;
		[nodeController runSceneOnNode: mainLayer];		// attach the layer to the controller and run a scene with it
		
		// Let's have some fun with the camera
		nodeController.isOverlayingDeviceCamera = nodeController.isDeviceCameraAvailable;
	}
	else
	{
		// Make the 2D scene the parent of the 3D layer, allowing 2D elements to be both in front of and behind
		// the 3D layer by utilizing the z parameter of the addChild method. Z values of 1 or greater will place
		// 2D nodes in front, otherwise they'll be behind the 3D layer.
		CCScene* scene = [CCScene node];
		CCLayer* layer = [HelloWorldLayer node];
		[scene addChild:layer];
		[layer addChild:mainLayer];
		[[CCDirector sharedDirector] runWithScene:scene];
		
		// Note: autorotation with ViewController in combination with cocos3d is not fully supported. The view will be 
		// stretched if you allow rotation from portrait to landscape and vice versa.
	}
}

-(id) alternateRootViewController
{
	return nil;
}

-(id) alternateView
{
	return nil;
}

@end
