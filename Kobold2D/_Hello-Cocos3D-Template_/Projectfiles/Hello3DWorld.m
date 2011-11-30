/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Copyright (c) 2011 Bill Hollings
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */


#import "Hello3DWorld.h"
#import "CC3PODResourceNode.h"
#import "CC3ActionInterval.h"
#import "CC3MeshNode.h"
#import "CC3Camera.h"
#import "CC3Light.h"


@implementation Hello3DWorld

/**
 * Constructs the 3D world.
 *
 * Adds 3D objects to the world, loading a 3D 'hello, world' message
 * from a POD file, and creating the camera and light programatically.
 *
 * When adapting this template to your application, remove all of the content
 * of this method, and add your own to construct your 3D model world.
 *
 * NOTE: The POD file used for the 'hello, world' message model is fairly large,
 * because converting a font to a mesh results in a LOT of triangles. When adapting
 * this template project for your own application, REMOVE the POD file 'hello-world.pod'
 * from the Resources folder of your project!!
 */
-(void) initializeWorld
{
	// Create the camera, place it back a bit
	CC3Camera* cam = [CC3Camera nodeWithName: @"Camera"];
	cam.location = cc3v(0.0, 0.0, 5.0);
	[self addChild:cam];

	// Create a light, place it and make it shine in all directions (not directional)
	CC3Light* lamp = [CC3Light nodeWithName: @"Lamp"];
	lamp.location = cc3v(0.0, 1.0, -2.0);
	lamp.isDirectionalOnly = YES;
	[cam addChild:lamp];

	// This is the simplest way to load a POD resource file and add the nodes to the CC3World
	[self addContentFromPODResourceFile: @"hello-world.pod"];
	
	// Create OpenGL ES buffers for the vertex arrays to keep things fast and efficient,
	// and to save memory, release the vertex data in main memory because it is now redundant.
	[self createGLBuffers];
	[self releaseRedundantData];
	
	// That's it! The model world is now constructed and is good to go.
	
	// ------------------------------------------

	// But to add some dynamism, we'll animate the 'hello, world' message
	// using a couple of cocos2d actions...
	
	// Fetch the 'hello, world' 3D text object that was loaded from the
	// POD file and start it rotating
	CC3MeshNode* helloTxt = (CC3MeshNode*)[self getNodeNamed: @"Hello"];
	CCActionInterval* partialRot = [CC3RotateBy actionWithDuration:1.0f
														  rotateBy:cc3v(0.0f, 60.0f, 10.0f)];
	[helloTxt runAction: [CCRepeatForever actionWithAction: partialRot]];

	CC3MeshNode* camNode = (CC3MeshNode*)[self getNodeNamed: @"Camera"];
	CCActionInterval* camMove1 = [CC3MoveBy actionWithDuration:4 moveBy:cc3v(0, 0, 8)];
	id camEase1 = [CCEaseBackInOut actionWithAction:camMove1];
	CCActionInterval* camMove2 = [CC3MoveBy actionWithDuration:2 moveBy:cc3v(0, 0, -8)];
	id camEase2 = [CCEaseElasticOut actionWithAction:camMove2 period:0.25f];
	id sequence = [CCSequence actions:camEase1, camEase2, nil];
	[camNode runAction:[CCRepeatForever actionWithAction:sequence]];

	// To make things a bit more appealing, set up a repeating up/down cycle to
	// change the color of the text from the original red to blue, and back again.
	GLfloat tintTime = 8.0f;
	ccColor3B startColor = ccc3(255, 0, 255);
	ccColor3B endColor = ccc3(255, 255, 0);
	CCActionInterval* tintDown = [CCTintTo actionWithDuration:tintTime
														  red:endColor.r
														green:endColor.g
														 blue:endColor.b];
	CCActionInterval* tintUp = [CCTintTo actionWithDuration:tintTime
														red:startColor.r
													  green:startColor.g
													   blue:startColor.b];
	CCActionInterval* tintCycle = [CCSequence actionOne:tintDown two:tintUp];
	[helloTxt runAction:[CCRepeatForever actionWithAction:tintCycle]];
}


/**
 * This template method is invoked periodically whenever the 3D nodes are to be updated.
 *
 * This method provides this node with an opportunity to perform update activities before
 * any changes are applied to the transformMatrix of the node. The similar and complimentary
 * method updateAfterTransform: is automatically invoked after the transformMatrix has been
 * recalculated. If you need to make changes to the transform properties (location, rotation,
 * scale) of the node, or any child nodes, you should override this method to perform those
 * changes.
 *
 * The global transform properties of a node (globalLocation, globalRotation, globalScale)
 * will not have accurate values when this method is run, since they are only valid after
 * the transformMatrix has been updated. If you need to make use of the global properties
 * of a node (such as for collision detection), override the udpateAfterTransform: method
 * instead, and access those properties there.
 *
 * The specified visitor encapsulates the CC3World instance, to allow this node to interact
 * with other nodes in its world.
 *
 * The visitor also encapsulates the deltaTime, which is the interval, in seconds, since
 * the previous update. This value can be used to create realistic real-time motion that
 * is independent of specific frame or update rates. Depending on the setting of the
 * maxUpdateInterval property of the CC3World instance, the value of dt may be clamped to
 * an upper limit before being passed to this method. See the description of the CC3World
 * maxUpdateInterval property for more information about clamping the update interval.
 *
 * As described in the class documentation, in keeping with best practices, updating the
 * model state should be kept separate from frame rendering. Therefore, when overriding
 * this method in a subclass, do not perform any drawing or rending operations. This
 * method should perform model updates only.
 *
 * This method is invoked automatically at each scheduled update. Usually, the application
 * never needs to invoke this method directly.
 */
-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {}

/**
 * This template method is invoked periodically whenever the 3D nodes are to be updated.
 *
 * This method provides this node with an opportunity to perform update activities after
 * the transformMatrix of the node has been recalculated. The similar and complimentary
 * method updateBeforeTransform: is automatically invoked before the transformMatrix
 * has been recalculated.
 *
 * The global transform properties of a node (globalLocation, globalRotation, globalScale)
 * will have accurate values when this method is run, since they are only valid after the
 * transformMatrix has been updated. If you need to make use of the global properties
 * of a node (such as for collision detection), override this method.
 *
 * Since the transformMatrix has already been updated when this method is invoked, if
 * you override this method and make any changes to the transform properties (location,
 * rotation, scale) of any node, you should invoke the updateTransformMatrices method of
 * that node, to have its transformMatrix, and those of its child nodes, recalculated.
 *
 * The specified visitor encapsulates the CC3World instance, to allow this node to interact
 * with other nodes in its world.
 *
 * The visitor also encapsulates the deltaTime, which is the interval, in seconds, since
 * the previous update. This value can be used to create realistic real-time motion that
 * is independent of specific frame or update rates. Depending on the setting of the
 * maxUpdateInterval property of the CC3World instance, the value of dt may be clamped to
 * an upper limit before being passed to this method. See the description of the CC3World
 * maxUpdateInterval property for more information about clamping the update interval.
 *
 * As described in the class documentation, in keeping with best practices, updating the
 * model state should be kept separate from frame rendering. Therefore, when overriding
 * this method in a subclass, do not perform any drawing or rending operations. This
 * method should perform model updates only.
 *
 * This method is invoked automatically at each scheduled update. Usually, the application
 * never needs to invoke this method directly.
 */
-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor {}

@end

