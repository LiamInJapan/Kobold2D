/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Copyright (c) 2011 Bill Hollings
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */


#import "Hello3DLayer.h"
#import "Hello3DWorld.h"

#import "HelloWorldLayer.h"

@implementation Hello3DLayer

-(void) updatePausePlay:(ccTime)dt
{
	if (cc3World.isRunning) 
	{
		[cc3World pause];
		for (CC3Node* node in cc3World.children)
		{
			[[CCActionManager sharedManager] pauseTarget:node];
		}
	}
	else
	{
		[cc3World play];
		for (CC3Node* node in cc3World.children)
		{
			[[CCActionManager sharedManager] resumeTarget:node];
		}
	}
}

/**
 * Template method that is invoked automatically during initialization, regardless
 * of the actual init* method that was invoked. Subclasses can override to set up their
 * 2D controls and other initial state without having to override all of the possible
 * superclass init methods.
 *
 * The default implementation does nothing. It is not necessary to invoke the
 * superclass implementation when overriding in a subclass.
 */
-(void) initializeControls 
{
	// uncomment the next line to see what happens if you call CC3World pause/play
	//[self schedule:@selector(updatePausePlay:) interval:0.5f];
}

 // The ccTouchMoved:withEvent: method is optional for the <CCTouchDelegateProtocol>.
 // The event dispatcher will not dispatch events for which there is no method
 // implementation. Since the touch-move events are both voluminous and seldom used,
 // the implementation of ccTouchMoved:withEvent: has been left out of the default
 // CC3Layer implementation. To receive and handle touch-move events for object
 // picking,uncomment the following method implementation. To receive touch events,
 // you must also set the isTouchEnabled property of this instance to YES.
/*
 // Handles intermediate finger-moved touch events. 
-(void) ccTouchMoved: (UITouch *)touch withEvent: (UIEvent *)event {
	[self handleTouch: touch ofType: kCCTouchMoved];
}
*/

@end
