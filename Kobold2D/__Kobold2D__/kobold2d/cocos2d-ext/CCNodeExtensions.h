/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"
#import "ccMoreMacros.h"

/** extends CCNode */
@interface CCNode (KoboldExtensions)

/** experimental: should allow placement of nodes in percentage of the screen size. Helpful for
 Apps that should work on both iPhone & iPad screens without too many #ifdef and other conditionals.
 (1.0f, 1.0f) would place the node on the upper right corner of the screen, 
 (0.5f, 0.5f) would place the node in the center of the screen, regardless of screen size.
 Relative positions are converted to screen coordinates with this simple formula:
 (X * screen width, Y * screen height) */
@property (nonatomic) CGPoint relativePosition;



/** Returns true if the point is contained in (is on) the node. Respects rotation and scaling of the node. */
-(BOOL) containsPoint:(CGPoint)point;

#if KK_PLATFORM_IOS
/** Returns true if the UITouch is contained in (is on) the node. Respects rotation and scaling of the node. */
-(BOOL) containsTouch:(UITouch*)touch;
#endif

/** Returns true if the node's boundingBox intersects with the boundingBox of another node. */
-(BOOL) intersectsNode:(CCNode*)other;

/** Calls the node's "node" method to initialize it, then adds it to a CCScene object and returns that CCScene.
 Useful as a convenience method for creating a CCLayer instance wrapped in a scene, so that you can write:
 
 [[CCDirector sharedDirector] replaceScene:[MyGameLayer nodeWithScene]];
 */
+(id) nodeWithScene;

@end
