/*
 * CC3Layer.m
 *
 * cocos3d 0.6.5
 * Author: Bill Hollings
 * Copyright (c) 2010-2011 The Brenwill Workshop Ltd. All rights reserved.
 * http://www.brenwill.com
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
 *
 * http://en.wikipedia.org/wiki/MIT_License
 * 
 * See header file CC3Layer.h for full API documentation.
 */

#import "CC3Layer.h"
#import "CC3OpenGLES11Foundation.h"
	
@interface CC3Layer (TemplateMethods)
-(void) drawWorld;
-(int) touchPriority;
-(BOOL) handleTouch: (UITouch*) touch ofType: (uint) touchType;
-(BOOL) handleTouchType: (uint) touchType at: (CGPoint) touchPoint;
@end

@implementation CC3Layer

@synthesize cc3World, shouldAlwaysUpdateViewport;

- (void)dealloc {
	self.cc3World = nil;			// Invoke wasRemoved and release
    [super dealloc];
}

/**
 * Links the world back here as well, update the viewport of the new world,
 * and to start and stop actions.
 */
 -(void) setCc3World: (CC3World*) aWorld {
	 if (aWorld != cc3World) {
		 cc3World.cc3Layer = nil;				// Detach this layer from old world.
		 [cc3World wasRemoved];					// Stop actions in old world.
		 [cc3World release];					// Release old world

		 cc3World = [aWorld retain];			// Retain the new world.
		 cc3World.cc3Layer = self;				// Point the world back here
		 [self updateViewport];					// Set the camera viewport
		 cc3World.isRunning = self.isRunning;	// Updates the world, and starts actions in new world.
	 }
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@", [self class]];
}


#pragma mark Allocation and initialization

/** Overridden to invoke the initializeControls template method. */
-(void) initInitialState {
	[super initInitialState];
	shouldAlwaysUpdateViewport = NO;
	[self initializeControls];
}

// Spelling mistake on initial API...left in for backwards compatibility
-(void) initializeContols {}

/**
 * For backwards compatibility, default invokes misspelled API method, which in turn does nothing.
 * Subclasses will override, and do not need to invoke this superclass implementation.
 */
-(void) initializeControls {
	[self initializeContols];
}


#pragma mark Transforming

-(void) setPosition: (CGPoint) newPosition {
	[super setPosition: newPosition];
	[self updateViewport];
}

-(void) setPositionInPixels: (CGPoint) newPosition {
	[super setPositionInPixels: newPosition];
	[self updateViewport];
}

-(void) setScale: (float) s {
	[super setScale: s];
	[self updateViewport];
}

-(void) setScaleX: (float) newScaleX {
	[super setScaleX: newScaleX];
	[self updateViewport];
}

-(void) setScaleY: (float) newScaleY {
	[super setScaleY: newScaleY];
	[self updateViewport];
}

-(BOOL) isOpaque {
	return self.isColored && self.opacity == 255;
}


#pragma mark Updating layer

-(void) update: (ccTime)dt {
	[cc3World updateWorld: dt];
}


#pragma mark Drawing

/**
 * CCNode template method to draw this layer. Overridden to draw the colored backdrop and
 * then delegates 3D drawing to the contained CC3World instance.
 *
 * This method is invoked asynchronously to the update: loop, to keep the OpenGL ES drawing
 * separate from the processing from model updates.
 */
-(void) draw {
	[self drawBackdrop];
	[self drawWorld];
}

/** Delegates to the superclass to draw a colored backdrop if it has been established */
-(void) drawBackdrop {
	LogTrace(@"%@ drawing backdrop", self);
	[super draw];
}

/**
 * Draws the 3D world by delegating to the visit method of the contained CC3World instance.
 * If the shouldAlwaysUpdateViewport property is set to YES, then the viewport is updated first.
 */
-(void) drawWorld {
	if (shouldAlwaysUpdateViewport) {
		[self updateViewport];
	}
	[cc3World drawWorld];
}


#pragma mark ControllableCCLayer support

/**
 * Invoked from cocos2d when this layer is first displayed.
 * Updates the device orientation in the 3D world, and starts it running.
 */
-(void) onEnter {
	[super onEnter];
	[self updateViewport];
	[cc3World play];
}

/**
 * Invoked from cocos2d when this layer is removed.
 * Pauses the 3D world.
 */
-(void) onExit {
	[super onExit];
	[cc3World pause];
}

/**
 * Invoked automatically when the home content size has changed.
 * Updates the viewport to match the new layer dimensions.
 */
-(void) didUpdateHomeContentSizeFrom: (CGSize) oldHomeSize {
	[super didUpdateHomeContentSizeFrom: oldHomeSize];
	[self updateViewport];
}

/**
 * Invoked from the CCNodeController when the device orientation has changed.
 * Updates the 3D world to match the new device orientation and viewport dimensions, so
 * that 3D world will align itself with the new device orientation and layer dimensions.
 */
-(void) deviceOrientationDidChange: (ccDeviceOrientation) newOrientation {
	[super deviceOrientationDidChange: newOrientation];
	[self updateViewport];
}

/**
 * Updates the viewport of the contained CC3World instance with the dimensions
 * of this layer and the device orientation.
 *
 * Invoked automatically when the position, size, or scale of this layer changes.
 */
-(void) updateViewport {
	[cc3World.viewportManager updateBounds: self.globalBoundingBoxInPixels
					 withDeviceOrientation: [[CCDirector sharedDirector] deviceOrientation]];
	[super updateViewport];
}


#pragma mark Touch handling

// Handle touch events one at a time.
-(void) registerWithTouchDispatcher {
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate: self
													 priority: self.touchPriority
											  swallowsTouches:YES];
}

/**
 * The priority at which touch events are delegated to this layer.
 * Default is zero. Subclasses may override.
 */
-(int) touchPriority {
	return 0;
}

// Handles the initial finger-down touch events.
-(BOOL) ccTouchBegan: (UITouch *)touch withEvent: (UIEvent *)event {
	return [self handleTouch: touch ofType: kCCTouchBegan];
}

// Handles the final finger-up touch events.
-(void) ccTouchEnded: (UITouch *)touch withEvent: (UIEvent *)event {
	[self handleTouch: touch ofType: kCCTouchEnded];
}

// Handles cancelled touch events.
-(void) ccTouchCancelled: (UITouch *)touch withEvent: (UIEvent *)event {
	[self handleTouch: touch ofType: kCCTouchCancelled];
}

/*
// The ccTouchMoved:withEvent: method is optional for the <CCTouchDelegateProtocol>.
// The event dispatcher will not dispatch events for which there is no method
// implementation. Since the touch-move events are both voluminous and seldom used,
// the implementation of ccTouchMoved:withEvent: has been left out of the default
// CC3Layer implementation. To receive and handle touch-move events for object
// picking, copy the following method implementation to your CC3Layer subclass.

// Handles intermediate finger-moved touch events.
-(void) ccTouchMoved: (UITouch *)touch withEvent: (UIEvent *)event {
	[self handleTouch: touch ofType: kCCTouchMoved];
}
*/

/**
 * Invoked when any of the touch event handler methods are invoked.
 * Returns whether the event was handled by this layer.
 *
 * This implementation checks that the touch event is within the bounds of this
 * layer and, if it is, forwards the event to the handleTouchType:at: method.
 */
-(BOOL) handleTouch: (UITouch*) touch ofType: (uint) touchType {
	CGSize cs = self.contentSize;
	CGRect nodeBounds = CGRectMake(0, 0, cs.width, cs.height);
	CGPoint nodeTouchPoint = [self convertTouchToNodeSpace: touch];
	if(CGRectContainsPoint(nodeBounds, nodeTouchPoint)) {
		return [self handleTouchType: touchType at: nodeTouchPoint];
	}
	return NO;
}

/**
 * Invoked when any of the touch event handler methods are invoked, and the touchEvent
 * occurred within the bounds of this layer. Returns whether the event was handled.
 *
 * This implementation forwards all events to the CC3World and always returns YES.
 * Subclasses may override this method to handle some events here instead of in
 * the CC3World.
 */
-(BOOL) handleTouchType: (uint) touchType at: (CGPoint) touchPoint {
	[cc3World touchEvent: touchType at: touchPoint];
	return YES;
}

@end


