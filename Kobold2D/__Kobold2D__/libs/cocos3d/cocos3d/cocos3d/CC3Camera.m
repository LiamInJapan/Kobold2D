/*
 * CC3Camera.m
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
 * See header file CC3Camera.h for full API documentation.
 */

#import "CC3Camera.h"
#import "CC3World.h"
#import "CC3Math.h"
#import "CC3OpenGLES11Engine.h"
#import "CC3ActionInterval.h"
#import "CGPointExtension.h"
#import "ccMacros.h"


#pragma mark CC3Camera implementation

@interface CC3Node (TemplateMethods)
-(void) transformMatrixChanged;
-(void) updateGlobalScale;
-(void) populateFrom: (CC3Node*) another;
@property(nonatomic, readonly) CC3GLMatrix* globalRotationMatrix;
@end

@interface CC3Camera (TemplateMethods)
@property(nonatomic, readonly) CC3ViewportManager* viewportManager;
-(void) buildModelViewMatrix;
-(void) buildProjectionMatrix;
-(void) buildFrustumPlanes;
-(void) openProjection;
-(void) closeProjection;
-(void) openModelView;
-(void) closeModelView;
-(void) loadProjectionMatrix;
-(void) loadModelViewMatrix;
-(void) ensureAtRootAncestor;
-(void) ensureWorldUpdated: (BOOL) checkWorld;
-(void) moveToShowAllOf: (CC3Node*) aNode
		  fromDirection: (CC3Vector) aDirection
			withPadding: (GLfloat) padding
			 checkWorld: (BOOL) checkWorld;
-(void) moveWithDuration: (ccTime) t
			 toShowAllOf: (CC3Node*) aNode
		   fromDirection: (CC3Vector) aDirection
			 withPadding: (GLfloat) padding
			  checkWorld: (BOOL) checkWorld;
-(CC3Vector) calculateLocationToShowAllOf: (CC3Node*) aNode
							fromDirection: (CC3Vector) aDirection
							  withPadding: (GLfloat) padding
							   checkWorld: (BOOL) checkWorld;
@property(nonatomic, readonly) CGSize fovRatios;
@property(nonatomic, readonly) BOOL isProjectionDirty;
@end


@implementation CC3Camera

@synthesize fieldOfView, nearClippingPlane, farClippingPlane;
@synthesize frustum, modelviewMatrix;

-(void) dealloc {
	[modelviewMatrix release];
	[frustum release];
	[super dealloc];
}

-(CC3GLMatrix*) projectionMatrix {
	return frustum.projectionMatrix;
}

-(void) setFieldOfView:(GLfloat) anAngle {
	fieldOfView = anAngle;
	[self markProjectionDirty];
}

-(void) setNearClippingPlane:(GLfloat) aDistance {
	nearClippingPlane = aDistance;
	[self markProjectionDirty];
}

-(void) setFarClippingPlane:(GLfloat) aDistance {
	farClippingPlane = aDistance;
	[self markProjectionDirty];
}

// Overridden to mark the frustum's projectionMatrix dirty instead of the
// transformMatrix. This is because for a camera, scale acts as a zoom to change
// the effective FOV, which is a projection quality, not a transformation quality.
-(void) setScale: (CC3Vector) aScale {
	scale = aScale;
	[self markProjectionDirty];
}

-(BOOL) isUsingParallelProjection {
	return frustum.isUsingParallelProjection;
}

-(void) setIsUsingParallelProjection: (BOOL) shouldUseParallelProjection {
	frustum.isUsingParallelProjection = shouldUseParallelProjection;
	[self markProjectionDirty];
}

// The CC3World's viewport manager.
-(CC3ViewportManager*) viewportManager {
	return self.world.viewportManager;
}

/** Since scale is not used by cameras, only consider ancestors. */
-(BOOL) isTransformRigid {
	return (parent ? parent.isTransformRigid : YES);
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		modelviewMatrix = [[CC3GLMatrix identity] retain];
		self.frustum = [CC3Frustum frustum];
		isProjectionDirty = NO;		// start with identity everywhere
		fieldOfView = kCC3DefaultFieldOfView;
		nearClippingPlane = kCC3DefaultNearClippingPlane;
		farClippingPlane = kCC3DefaultFarClippingPlane;
	}
	return self;
}

// Protected properties for copying
-(BOOL) isProjectionDirty { return isProjectionDirty; }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3Camera*) another {
	[super populateFrom: another];
	
	self.frustum = [another.frustum copyAutoreleased];		// retained

	[modelviewMatrix release];
	modelviewMatrix = [another.modelviewMatrix copy];		// retained

	fieldOfView = another.fieldOfView;
	nearClippingPlane = another.nearClippingPlane;
	farClippingPlane = another.farClippingPlane;
	isProjectionDirty = another.isProjectionDirty;
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@, FOV: %.2f, near: %.2f, far: %.2f",
			[super fullDescription], fieldOfView, nearClippingPlane, farClippingPlane];
}


#pragma mark Transformations

-(void) markProjectionDirty {
	isProjectionDirty = YES;
}

/**
 * Scaling the camera is a null operation because it scales everything, including the size
 * of objects, but also the distance from the camera to those objects. The effects cancel
 * out, and visually, it appears that nothing has changed. Therefore, the scale property
 * is not applied to the transform matrix of the camera. Instead it is used to adjust the
 * field of view to create a zooming effect. See the description of the fieldOfView property.
 *
 * This implementation sets the globalScale to that of the parent node, or to unit scaling
 * if no parent. The globalScale is then used to unwind all scaling from the camera, globally,
 * because any inherited scaling will scale the frustum, and cause undesirable clipping
 * artifacts, particularly at the near clipping plane.
 *
 * For example, if the camera is mounted on another node that is scaled to ten times, the
 * near clipping plane of the camera will be scaled away from the camera by ten times,
 * resulting in unwanted clipping around the fringes of the view. For this reason, an inverse
 * scale of 1/10 is applied to the transform to counteract this effect.
 */
-(void) applyScaling {
	[self updateGlobalScale];	// Make sure globalScale is current first.
	[transformMatrix scaleBy: CC3VectorInvert(globalScale)];
	LogTrace(@"%@ scaled back by global %@ to counter parent scaling %@",
			 self, NSStringFromCC3Vector(globalScale), transformMatrix);
}

/**
 * Scaling does not apply to cameras. Sets the globalScale to that of the parent node,
 * or to unit scaling if no parent.
 */
-(void) updateGlobalScale {
	globalScale = parent ? parent.globalScale : kCC3VectorUnitCube;
}

-(void) buildPerspective {
	[self buildProjectionMatrix];
	[self buildFrustumPlanes];
}

/** Overridden to also build the modelview matrix. */
-(void) transformMatrixChanged {
	[super transformMatrixChanged];
	[self buildModelViewMatrix];
}

/**
 * Template method to rebuild the modelviewMatrix from the deviceRotationMatrix, which
 * is managed by the CC3World's viewportManager, and the inverse of the transformMatrix.
 * Invoked automatically whenever the transformMatrix or device orientation are changed.
 */
-(void) buildModelViewMatrix {
	[modelviewMatrix populateFrom: self.viewportManager.deviceRotationMatrix];
	LogTrace(@"%@ applied device rotation matrix %@", self, modelviewMatrix);

	[modelviewMatrix multiplyByMatrix: self.transformMatrixInverted];
	LogTrace(@"%@ inverted transform applied to modelview matrix %@", self, modelviewMatrix);

	[frustum markPlanesDirty];
}

/**
 * Template method to rebuild the frustum's projectionMatrix if the
 * projection parameters have been changed since the last rebuild.
 */
-(void) buildProjectionMatrix  {
	if(isProjectionDirty) {
		CC3Viewport vp = self.viewportManager.viewport;
		NSAssert(vp.h, @"Camera projection matrix cannot be updated before setting the viewport");

		[frustum populateFrom: fieldOfView
					andAspect: ((GLfloat) vp.w / (GLfloat) vp.h)
				  andNearClip: nearClippingPlane
				   andFarClip: farClippingPlane
					  andZoom: self.uniformScale];

		isProjectionDirty = NO;
	}
}

/** Template method to rebuild the frustum planes. */
-(void) buildFrustumPlanes {
	[frustum buildPlanes: modelviewMatrix];
}


#pragma mark Drawing

-(void) open {
	LogTrace(@"Opening %@", self);
	[self openProjection];
	[self openModelView];
}

-(void) close {
	LogTrace(@"Closing %@", self);
	[self closeModelView];
	[self closeProjection];
}

/** Template method that pushes the GL projection matrix stack, and loads the projectionMatrix into it. */
-(void) openProjection {
	LogTrace(@"Opening %@ 3D projection", self);
	[[CC3OpenGLES11Engine engine].matrices.projection push];
	[self loadProjectionMatrix];
}

/** Template method that pops the projectionMatrix from the GL projection matrix stack. */
-(void) closeProjection {
	LogTrace(@"Closing %@ 3D projection", self);
	[[CC3OpenGLES11Engine engine].matrices.projection pop];
}

/** Template method that pushes the GL modelview matrix stack, and loads the modelviewMatrix into it. */
-(void) openModelView {
	LogTrace(@"Opening %@ modelview", self);
	[[CC3OpenGLES11Engine engine].matrices.modelview push];
	[self loadModelViewMatrix];
}

/** Template method that pops the modelviewMatrix from the GL modelview matrix stack. */
-(void) closeModelView {
	LogTrace(@"Closing %@ modelview", self);
	[[CC3OpenGLES11Engine engine].matrices.modelview pop];
}

/** Template method that loads the modelviewMatrix into the current GL projection matrix. */
-(void) loadModelViewMatrix {
	LogTrace(@"%@ loading modelview matrix into GL: %@", self, modelviewMatrix);
	[[CC3OpenGLES11Engine engine].matrices.modelview load: modelviewMatrix.glMatrix];
}

/** Template method that loads the projectionMatrix into the current GL projection matrix. */
-(void) loadProjectionMatrix {
	LogTrace(@"%@ loading projection matrix into GL: %@", self, frustum.projectionMatrix);
	[[CC3OpenGLES11Engine engine].matrices.projection load: frustum.projectionMatrix.glMatrix];
}


#pragma mark Viewing nodes

-(void) moveToShowAllOf: (CC3Node*) aNode {
	[self moveToShowAllOf: aNode withPadding: kCC3DefaultFrustumFitPadding];
}

-(void) moveToShowAllOf: (CC3Node*) aNode withPadding: (GLfloat) padding {
	[self ensureWorldUpdated: YES];
	CC3Vector moveDir = CC3VectorDifference(self.globalLocation, aNode.globalLocation);
	[self moveToShowAllOf: aNode fromDirection: moveDir withPadding: padding checkWorld: NO];
}

-(void) moveToShowAllOf: (CC3Node*) aNode fromDirection: (CC3Vector) aDirection {
	[self moveToShowAllOf: aNode fromDirection: aDirection withPadding: kCC3DefaultFrustumFitPadding];
}

-(void) moveToShowAllOf: (CC3Node*) aNode
		  fromDirection: (CC3Vector) aDirection
			withPadding: (GLfloat) padding {
	[self moveToShowAllOf: aNode fromDirection: aDirection withPadding: padding checkWorld: YES];
}

-(void) moveToShowAllOf: (CC3Node*) aNode
		  fromDirection: (CC3Vector) aDirection
			withPadding: (GLfloat) padding
			 checkWorld: (BOOL) checkWorld {
	self.location = [self calculateLocationToShowAllOf: aNode
										 fromDirection: aDirection
										   withPadding: padding
											checkWorld: checkWorld];
	self.forwardDirection = CC3VectorNegate(aDirection);
	[self ensureAtRootAncestor];
	[self updateTransformMatrices];
}

-(void) moveWithDuration: (ccTime) t toShowAllOf: (CC3Node*) aNode {
	[self moveWithDuration: t toShowAllOf: aNode withPadding: kCC3DefaultFrustumFitPadding];
}

-(void) moveWithDuration: (ccTime) t
			 toShowAllOf: (CC3Node*) aNode
			 withPadding: (GLfloat) padding {
	[self ensureWorldUpdated: YES];
	CC3Vector moveDir = CC3VectorDifference(self.globalLocation, aNode.globalLocation);
	[self moveWithDuration: t toShowAllOf: aNode fromDirection: moveDir withPadding: padding checkWorld: NO];
}

-(void) moveWithDuration: (ccTime) t
			 toShowAllOf: (CC3Node*) aNode
		   fromDirection: (CC3Vector) aDirection {
	[self moveWithDuration: t
			   toShowAllOf: aNode
			 fromDirection: aDirection
			   withPadding: kCC3DefaultFrustumFitPadding];
}

-(void) moveWithDuration: (ccTime) t
			 toShowAllOf: (CC3Node*) aNode
		   fromDirection: (CC3Vector) aDirection
			 withPadding: (GLfloat) padding {
	[self moveWithDuration: t
			   toShowAllOf: aNode
			 fromDirection: aDirection
			   withPadding: padding
				checkWorld: YES ];
}

-(void) moveWithDuration: (ccTime) t
			 toShowAllOf: (CC3Node*) aNode
		   fromDirection: (CC3Vector) aDirection
			 withPadding: (GLfloat) padding
			  checkWorld: (BOOL) checkWorld {
	CC3Vector newLoc = [self calculateLocationToShowAllOf: aNode
											fromDirection: aDirection
											  withPadding: padding
											   checkWorld: checkWorld];
	CC3Vector newFwdDir = CC3VectorNegate(aDirection);
	[self ensureAtRootAncestor];
	[self runAction: [CC3MoveTo actionWithDuration: t moveTo: newLoc]];
	[self runAction: [CC3RotateToLookTowards actionWithDuration: t forwardDirection: newFwdDir]];
}

/**
 * Padding to add to the far clipping plane when it is adjusted as a result of showing
 * all of a node, to ensure that all of the node is within the far end of the frustum.
 */
#define kCC3FrustumFitFarPadding 0.01

-(CC3Vector) calculateLocationToShowAllOf: (CC3Node*) aNode
							fromDirection: (CC3Vector) aDirection
							  withPadding: (GLfloat) padding {
	return [self calculateLocationToShowAllOf: aNode
								fromDirection: aDirection
								  withPadding: padding
								   checkWorld: YES];
}

-(CC3Vector) calculateLocationToShowAllOf: (CC3Node*) aNode
							fromDirection: (CC3Vector) aDirection
							  withPadding: (GLfloat) padding
							   checkWorld: (BOOL) checkWorld {

	[self ensureWorldUpdated: checkWorld];
	
	// Complementary unit vectors pointing towards camera from node, and vice versa
	CC3Vector camDir = CC3VectorNormalize(aDirection);
	CC3Vector viewDir = CC3VectorNegate(camDir);
	
	// The camera's new forward direction will be viewDir. Use a matrix to detrmine
	// the camera's new up and right directions assuming the same world up direction. 
	CC3GLMatrix* rotMtx = [CC3GLMatrix identity];
	[rotMtx populateToPointTowards: viewDir withUp: self.worldUpDirection];
	CC3Vector upDir = [rotMtx extractUpDirection];
	CC3Vector rtDir = [rotMtx extractRightDirection];
	
	// Determine the center eight vertices, plus the center, of the node's
	// bounding box, in the global coordinate system
	CC3BoundingBox gbb = aNode.globalBoundingBox;
	CC3Vector bbCtr = CC3BoundingBoxCenter(gbb);
	CC3Vector bbMin = gbb.minimum;
	CC3Vector bbMax = gbb.maximum;
	CC3Vector bbVertices[8];
	bbVertices[0] = cc3v(bbMin.x, bbMin.y, bbMin.z);
	bbVertices[1] = cc3v(bbMin.x, bbMin.y, bbMax.z);
	bbVertices[2] = cc3v(bbMin.x, bbMax.y, bbMin.z);
	bbVertices[3] = cc3v(bbMin.x, bbMax.y, bbMax.z);
	bbVertices[4] = cc3v(bbMax.x, bbMin.y, bbMin.z);
	bbVertices[5] = cc3v(bbMax.x, bbMin.y, bbMax.z);
	bbVertices[6] = cc3v(bbMax.x, bbMax.y, bbMin.z);
	bbVertices[7] = cc3v(bbMax.x, bbMax.y, bbMax.z);
	
	// Express the camera's FOV in terms of ratios of the near clip bounds to
	// the near clip distance, so we can determine distances using similar triangles.
	CGSize fovRatios = self.fovRatios;
	
	// Iterate through all eight vertices of the node's bounding box, and calculate
	// the largest distance required to place the camera away from the center of the
	// node in order to fit all eight vertices within the camera's frustum.
	// Simultaneously, calculate the extra distance from the center of the node to
	// the vertex that will be farthest from the camera, so we can ensure that all
	// vertices will fall within the frustum's far end.
	GLfloat maxCtrDist = 0;
	GLfloat maxVtxDeltaDist = 0;
	for (int i = 0; i < 8; i++) {
		
		// Get a vector from the center of the bounding box to the vertex 
		CC3Vector relVtx = CC3VectorDifference(bbVertices[i], bbCtr);
		
		// Project that vector onto each of the camera's new up and right directions,
		// and use similar triangles to determine the distance at which to place the
		// camera so that the vertex will fit in both the up and right directions.
		GLfloat vtxDistUp = ABS(CC3VectorDot(relVtx, upDir) / fovRatios.height);
		GLfloat vtxDistRt = ABS(CC3VectorDot(relVtx, rtDir) / fovRatios.width);
		GLfloat vtxDist = MAX(vtxDistUp, vtxDistRt);
		
		// Calculate how far along the view direction the vertex is from the center
		GLfloat vtxDeltaDist = CC3VectorDot(relVtx, viewDir);
		GLfloat ctrDist = vtxDist - vtxDeltaDist;
		
		// Accumulate the maximum distance from the node's center to the camera
		// required to fit all eight points, and the distance from the node's
		// center to the vertex that will be farthest away from the camera. 
		maxCtrDist = MAX(maxCtrDist, ctrDist);
		maxVtxDeltaDist = MAX(maxVtxDeltaDist, vtxDeltaDist);
	}
	
	// Add some padding so we will have a bit of space around the node when it fills the view.
	maxCtrDist *= (1 + padding);
	
	// Determine if we need to move the far end of the camera frustum farther away
	GLfloat farClip = CC3VectorLength(CC3VectorScaleUniform(viewDir, maxCtrDist + maxVtxDeltaDist));
	farClip *= (1 + kCC3FrustumFitFarPadding);		// Include a little bit of padding
	if (farClip > self.farClippingPlane) {
		self.farClippingPlane = farClip;
	}
	
	LogTrace(@"%@ moving to %@ to show %@ at %@ within %@ with new farClip: %.3f", self,
			 NSStringFromCC3Vector(CC3VectorAdd(bbCtr, CC3VectorScaleUniform(camDir, maxCtrDist))),
			 aNode, NSStringFromCC3Vector(bbCtr), frustum, self.farClippingPlane);
	
	// Return the new location of the camera,
	return CC3VectorAdd(bbCtr, CC3VectorScaleUniform(camDir, maxCtrDist));
}

/**
 * If the checkWorld arg is YES, and the world is not running, force an update
 * to ensure that all nodes are transformed to their global coordinates.
 */
-(void) ensureWorldUpdated: (BOOL) checkWorld {
	if (checkWorld) {
		CC3World* myWorld = self.world;
		if ( !myWorld.isRunning ) {
			[myWorld updateWorld];
		}
	}
}

/**
 * Returns the camera's FOV in terms of ratios of the near clip bounds
 * (width & height) to the near clip distance.
 */
-(CGSize) fovRatios {
	switch([[CCDirector sharedDirector]deviceOrientation]) {
		case kCCDeviceOrientationLandscapeLeft:
		case kCCDeviceOrientationLandscapeRight:
			return CGSizeMake(frustum.top / frustum.near, frustum.right / frustum.near);
		case kCCDeviceOrientationPortrait:
			case kCCDeviceOrientationPortraitUpsideDown:
		default:
			return CGSizeMake(frustum.right / frustum.near, frustum.top / frustum.near);
	}
}


/**
 * Ensures that this camera is a direct child of its root ancestor, which in almost all
 * cases will be CC3World. This is done by simply adding this camera to the root ancestor.
 * The request will be ignored if this camera is already a direct child of the root ancestor.
 */
-(void) ensureAtRootAncestor {
	[self.rootAncestor addChild: self];
}


#pragma mark 3D <-> 2D mapping functionality

-(CC3Vector) projectNode: (CC3Node*) aNode {
	NSAssert(aNode, @"Camera cannot project a nil node.");
	CC3Vector pLoc = [self projectLocation: aNode.globalLocation];
	aNode.projectedLocation = pLoc;
	return pLoc;
}

-(CC3Vector) projectLocation: (CC3Vector) a3DLocation {
	
	// Convert specified location to a 4D homogeneous location vector
	// and transform it using the modelview and projection matrices.
	CC3Vector4 hLoc = CC3Vector4FromCC3Vector(a3DLocation, 1.0);
	hLoc = [modelviewMatrix transformHomogeneousVector: hLoc];
	hLoc = [frustum.projectionMatrix transformHomogeneousVector: hLoc];
	
	// Convert projected 4D vector back to 3D.
	CC3Vector projectedLoc = CC3VectorFromHomogenizedCC3Vector4(hLoc);

	// The projected vector is in a projection coordinate space between -1 and +1 on all axes.
	// Normalize the vector so that each component is between 0 and 1 by calculating ( v = (v + 1) / 2 ).
	projectedLoc = CC3VectorAverage(projectedLoc, kCC3VectorUnitCube);
	
	// Map the X & Y components of the projected location (now between 0 and 1) to viewport coordinates.
	CC3Viewport vp = self.viewportManager.viewport;
	projectedLoc.x = vp.x + (vp.w * projectedLoc.x);
	projectedLoc.y = vp.y + (vp.h * projectedLoc.y);
	
	// Using the vector from the camera to the 3D location, determine whether or not the
	// 3D location is in front of the camera by using the dot-product of that vector and
	// the direction the camera is pointing. Set the Z-component of the projected location
	// to be the signed distance from the camera to the 3D location, with a positive sign
	// indicating the location is in front of the camera, and a negative sign indicating
	// the location is behind the camera.
	CC3Vector camToLocVector = CC3VectorDifference(a3DLocation, self.globalLocation);
	GLfloat camToLocDist = CC3VectorLength(camToLocVector);
	GLfloat frontOrBack = SIGN(CC3VectorDot(camToLocVector, self.globalForwardDirection));
	projectedLoc.z = frontOrBack * camToLocDist;
	
	// Map the projected point to the device orientation then return it
	CGPoint ppt = [self.viewportManager cc2PointFromGLPoint: ccp(projectedLoc.x, projectedLoc.y)];
	CC3Vector orientedLoc = cc3v(ppt.x, ppt.y, projectedLoc.z);
	
	LogTrace(@"%@ projecting location %@ to %@ and orienting with device to %@ using viewport %@",
			 self, NSStringFromCC3Vector(a3DLocation), NSStringFromCC3Vector(projectedLoc),
			 NSStringFromCC3Vector(orientedLoc), NSStringFromCC3Viewport(self.viewportManager.viewport));
	return orientedLoc;
}

-(CC3Ray) unprojectPoint: (CGPoint) cc2Point {

	// CC_CONTENT_SCALE_FACTOR = 2.0 if Retina display active, or 1.0 otherwise.
	CGPoint glPoint = ccpMult(cc2Point, CC_CONTENT_SCALE_FACTOR());
	
	// Express the glPoint X & Y as proportion of the layer dimensions, based
	// on an origin in the center of the layer (the center of the camera's view).
	CGSize lb = self.viewportManager.layerBounds.size;
	GLfloat xp = ((2.0 * glPoint.x) / lb.width) - 1;
	GLfloat yp = ((2.0 * glPoint.y) / lb.height) - 1;
	
	// Now that we have the location of the glPoint proportional to the layer dimensions,
	// we need to map the layer dimensions onto the frustum near clipping plane.
	// The layer dimensions change as device orientation changes, but the viewport
	// dimensions remain the same. The field of view is always measured relative to the
	// viewport height, independent of device orientation. We can find the top-right
	// corner of the view on the near clipping plane (top-right is positive X & Y from
	// the center of the camera's view) by multiplying by an orientation aspect in each
	// direction. This orientation aspect depends on the device orientation, which can
	// be expressed in terms of the relationship between the layer width and height and
	// the constant viewport height. The Z-coordinate at the near clipping plane is
	// negative since the camera points down the negative Z axis in its local coordinates.
	CGFloat vph = self.viewportManager.viewport.h;
	GLfloat xNearTopRight = frustum.top * (lb.width / vph);
	GLfloat yNearTopRight = frustum.top * (lb.height / vph);
	GLfloat zNearTopRight = -frustum.near;
	
	LogTrace(@"%@ view point %@ mapped to proportion (%.3f, %.3f) of view bounds %@ and viewport %@",
			 [self class], NSStringFromCGPoint(glPoint), xp, yp,
			 NSStringFromCGSize(lb), NSStringFromCC3Viewport(self.viewportManager.viewport));
	
	// We now have the location of the the top-right corner of the view, at the near
	// clipping plane, taking into account device orientation. We can now map the glPoint
	// onto the near clipping plane by multiplying by the glPoint's proportional X & Y
	// location, relative to the top-right corner of the view, which was calculated above.
	CC3Vector pointLocNear = cc3v(xNearTopRight * xp,
								  yNearTopRight * yp,
								  zNearTopRight);
	CC3Ray ray;
	if (self.isUsingParallelProjection) {
		// The location on the near clipping plane is relative to the camera's
		// local coordinates. Convert it to global coordinates before returning.
		// The ray direction is straight out from that global location in the 
		// camera's globalForwardDirection.
		ray.startLocation =  [transformMatrix transformLocation: pointLocNear];
		ray.direction = self.globalForwardDirection;
	} else {
		// The location on the near clipping plane is relative to the camera's local
		// coordinates. Since the camera's origin is zero in its local coordinates,
		// this point on the near clipping plane forms a directional vector from the
		// camera's origin. Rotate this directional vector with the camera's rotation
		// matrix to convert it to a global direction vector in global coordinates.
		// Thanks to cocos3d forum user Rogs for suggesting the use of the globalRotationMatrix.
		ray.startLocation = self.globalLocation;
		ray.direction = [self.globalRotationMatrix transformDirection: pointLocNear];
	}
	
	// Ensure the direction component is normalized before returning.
	ray.direction = CC3VectorNormalize(ray.direction);
	
	LogTrace(@"%@ unprojecting point %@ to near plane location %@ and to ray starting at %@ and pointing towards %@",
			[self class], NSStringFromCGPoint(glPoint), NSStringFromCC3Vector(pointLocNear),
			NSStringFromCC3Vector(ray.startLocation), NSStringFromCC3Vector(ray.direction));

	return ray;
}

-(CC3Vector4) unprojectPoint:(CGPoint) cc2Point ontoPlane: (CC3Plane) plane {
	return CC3RayIntersectionWithPlane([self unprojectPoint: cc2Point], plane);
}

@end


#pragma mark -
#pragma mark CC3Frustum implementation

@interface CC3Frustum (TemplateMethods)
-(void) populateProjectionMatrix;
@end

@implementation CC3Frustum

@synthesize projectionMatrix, top, bottom, left, right, near, far;
@synthesize topPlane, bottomPlane, leftPlane, rightPlane, nearPlane, farPlane;
@synthesize isUsingParallelProjection;

-(void) dealloc {
	[projectionMatrix release];
	[super dealloc];
}

-(id) init {
	if ( (self = [super init]) ) {
		projectionMatrix = [[CC3GLMatrix identity] retain];
		isUsingParallelProjection = NO;
		[self markPlanesDirty];		// need to calculate this first time
	}
	return self;
}

+(id) frustum {
	return [[[self alloc] init] autorelease];
}

// Protected properties for copying
-(BOOL) arePlanesDirty { return arePlanesDirty; }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3Frustum*) another {
	
	[projectionMatrix release];
	projectionMatrix = [another.projectionMatrix copy];		// retained
	
	top = another.top;
	bottom = another.bottom;
	left = another.left;
	right = another.right;
	near = another.near;
	far = another.far;
	
	topPlane = another.topPlane;
	bottomPlane = another.bottomPlane;
	leftPlane = another.leftPlane;
	rightPlane = another.rightPlane;
	nearPlane = another.nearPlane;
	farPlane = another.farPlane;

	isUsingParallelProjection = another.isUsingParallelProjection;
	arePlanesDirty = another.arePlanesDirty;
}

-(id) copyWithZone: (NSZone*) zone {
	CC3Frustum* aCopy = [[[self class] allocWithZone: zone] init];
	[aCopy populateFrom: self];
	return aCopy;
}

-(void) markPlanesDirty {
	arePlanesDirty = YES;
}

-(void) populateFrom: (GLfloat) fieldOfView
		   andAspect: (GLfloat) aspect
		 andNearClip: (GLfloat) nearClip
		  andFarClip: (GLfloat) farClip
			 andZoom: (GLfloat) zoomFactor {

	// Field of view measures to the top distance. ZoomFactor modifies the tangent.
	near = nearClip;
	top = (zoomFactor > 0.0)
			? (near * tanf(DegreesToRadians((fieldOfView / 2.0) / zoomFactor)))
			: 0.0;
	bottom = -top;
	right = top * aspect;
	left = bottom * aspect;
	far = farClip;
	
	[self populateProjectionMatrix];
	[self markPlanesDirty];

	LogTrace(@"%@ updated from FOV: %.3f, Aspect: %.3f, Near: %.3f, Far: %.3f, Zoom: %.3f",
			 self, fieldOfView, nearClip, nearClip, farClip, zoomFactor);
}

/**
 * Template method that populates the projection matrix from the frustum.
 * Uses either orthographic or perspective projection, depending on the value
 * of the isUsingParallelProjection property.
 */
-(void) populateProjectionMatrix {
	if (isUsingParallelProjection) {
		[projectionMatrix populateOrthoFromFrustumLeft: left andRight: right
											 andBottom: bottom andTop: top  
											   andNear: near andFar: far];
	} else {
		[projectionMatrix populateFromFrustumLeft: left andRight: right
										andBottom: bottom andTop: top  
										  andNear: near andFar: far];
	}
}

-(void) buildPlanes: (CC3GLMatrix*) aModelViewMatrix {
	if (arePlanesDirty) {
		CC3GLMatrix* mvp = [projectionMatrix copyAutoreleased];
		[mvp multiplyByMatrix: aModelViewMatrix];
		
		GLfloat* m = mvp.glMatrix;
		
		bottomPlane = CC3PlaneNormalize(CC3PlaneMake(m[3]+m[1], m[7]+m[5], m[11]+m[9], m[15]+m[13]));
		topPlane    = CC3PlaneNormalize(CC3PlaneMake(m[3]-m[1], m[7]-m[5], m[11]-m[9], m[15]-m[13]));
		
		leftPlane   = CC3PlaneNormalize(CC3PlaneMake(m[3]+m[0], m[7]+m[4], m[11]+m[8], m[15]+m[12]));
		rightPlane  = CC3PlaneNormalize(CC3PlaneMake(m[3]-m[0], m[7]-m[4], m[11]-m[8], m[15]-m[12]));
		
		nearPlane   = CC3PlaneNormalize(CC3PlaneMake(m[3]+m[2], m[7]+m[6], m[11]+m[10], m[15]+m[14]));
		farPlane    = CC3PlaneNormalize(CC3PlaneMake(m[3]-m[2], m[7]-m[6], m[11]-m[10], m[15]-m[14]));
		
		arePlanesDirty = NO;

		LogTrace(@"%@ building planes from projection %@ and modelview %@",
				 self, projectionMatrix, aModelviewMatrix);
	}
}

-(BOOL) doesIntersectPointAt: (CC3Vector) location {
	// Treat the point as a sphere of zero radius.
	return [self doesIntersectSphereAt: location withRadius: 0.0];
}

-(BOOL) doesIntersectSphereAt: (CC3Vector) location withRadius: (GLfloat) radius {
	GLfloat dist;
	
	// The sphere will be outside the frustum if it lies farther behind any one of the
	// planes than its radius.
	// Determine the distance from the location to each plane in the frustum and return NO
	// if the location is farther behind any of the planes by the length of the radius.
	// Test planes in order of likeliness to exclude an object.
	dist = CC3DistanceFromNormalizedPlane(nearPlane, location);
	if (dist + radius < 0) {
		return NO;
	}
	dist = CC3DistanceFromNormalizedPlane(rightPlane, location);
	if (dist + radius < 0) {
		return NO;
	}
	dist = CC3DistanceFromNormalizedPlane(leftPlane, location);
	if (dist + radius < 0) {
		return NO;
	}
	dist = CC3DistanceFromNormalizedPlane(topPlane, location);
	if (dist + radius < 0) {
		return NO;
	}
	dist = CC3DistanceFromNormalizedPlane(bottomPlane, location);
	if (dist + radius < 0) {
		return NO;
	}
	dist = CC3DistanceFromNormalizedPlane(farPlane, location);
	if (dist + radius < 0) {
		return NO;
	}
	
	return YES;		// Not behind any of the planes, so must be inside the frustum
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ top: %.3f, bottom: %.3f, left: %.3f, right: %.3f, near: %.3f, far: %.3f",
			[self class], top, bottom, left, right, near, far];
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ topPlane: %@ bottomPlane: %@ leftPlane: %@ rightPlane: %@ nearPlane: %@ farPlane: %@",
										[self description],
										NSStringFromCC3Plane(topPlane), NSStringFromCC3Plane(bottomPlane),
										NSStringFromCC3Plane(leftPlane), NSStringFromCC3Plane(rightPlane),
										NSStringFromCC3Plane(nearPlane), NSStringFromCC3Plane(farPlane)];
}

@end
