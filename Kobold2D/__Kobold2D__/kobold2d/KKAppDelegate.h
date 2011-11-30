/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import <Availability.h>
#import "cocos2d.h"
#import "cocos2d-extensions.h"

#import "KKRootViewController.h"
#import "KKStartupConfig.h"

/** Performs common UIApplicationDelegate methods. You're supposed to subclass from it in your own project. Unless you need to react to
 any UIApplicationDelegate event, you only need to implement the initializationComplete method. Everything else is handled in this class.
 When subclassing and overriding UIApplicationDelegate methods you should also call the [super ..] implementation. */

#ifdef KK_PLATFORM_IOS
@interface KKAppDelegate : NSObject <UIApplicationDelegate>
{
@protected
	UIWindow* window;
	KKRootViewController* rootViewController;
	KKStartupConfig* config;
}

/** The App's UIWindow object. */
@property (nonatomic, retain) UIWindow* window;
/** Gives you access to the root view controller object */
@property (nonatomic, readonly) KKRootViewController* rootViewController;
/** Gives you access to the startup properties defined in startup-config.lua */
@property (nonatomic, readonly) KKStartupConfig* config;

#else // Mac OS AppDelegate
@interface KKAppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow* window;
	MacGLView* glView;
	KKStartupConfig* config;
}

/** The App's NSWindow object */
@property (assign) IBOutlet NSWindow* window;
/** The MacGLView */
@property (assign) IBOutlet MacGLView* glView;

/** Call this to enter or leave fullscreen mode. */
-(IBAction) toggleFullScreen:(id)sender;

#endif

/** Called when Cocos2D is initialized and the App is ready to run the first scene. 
 You should override this method in your AppDelegate implementation. */
-(void) initializationComplete;

/** Called before the root ViewController is initialized. Override this method to provide your own, customized
 root ViewController if you need to. Note that the custom controller MUST be derived from KKRootViewController, and
 you may have to call the super implementation of any overriden methods to ensure that standard Kobold2D behavior remains
 functional, in particular autorotation and ad banners.
 
 Note: this function isn't called when building for Mac OS.
 */
-(id) alternateRootViewController;

/** Called before the (root ViewController's) view is initialized. Override and return a UIView to use a different
 view for the root ViewController instead of the Director's glView. If you use an alternate view, you are responsible
 for adding the glView somewhere to the view hierarchy. Primarily used for integration with UIKit/AppKit views to change the
 view hierarchy from: window -> glView to window -> overarching view -> subviews (glView plus n UIKit/AppKit views).*/
-(id) alternateView;

@end
