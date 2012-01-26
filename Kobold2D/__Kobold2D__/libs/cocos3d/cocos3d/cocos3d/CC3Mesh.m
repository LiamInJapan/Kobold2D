/*
 * CC3Mesh.m
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
 * See header file CC3Mesh.h for full API documentation.
 */

#import "CC3Mesh.h"

@interface CC3Mesh (TemplateMethods)
-(void) bindGLWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) drawVerticesWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) drawVerticesFrom: (GLuint) vertexIndex
				forCount: (GLuint) vertexCount
			 withVisitor: (CC3NodeDrawingVisitor*) visitor;
-(BOOL) switchingMesh;
@end

@implementation CC3Mesh

-(BOOL) hasNormals {
	return NO;
}

-(BOOL) hasColors {
	return NO;
}

-(CC3BoundingBox) boundingBox {
	return kCC3BoundingBoxNull;
}

#pragma mark Allocation and initialization

+(id) mesh {
	return [[[self alloc] init] autorelease];
}

+(id) meshWithTag: (GLuint) aTag {
	return [[[self alloc] initWithTag: aTag] autorelease];
}

+(id) meshWithName: (NSString*) aName {
	return [[[self alloc] initWithName: aName] autorelease];
}

+(id) meshWithTag: (GLuint) aTag withName: (NSString*) aName {
	return [[[self alloc] initWithTag: aTag withName: aName] autorelease];
}

-(void) createGLBuffers {}

-(void) deleteGLBuffers {}

-(void) releaseRedundantData {}

-(void) retainVertexLocations {}

-(void) retainVertexNormals {}

-(void) retainVertexColors {}

-(void) retainVertexTextureCoordinates {}

-(void) retainVertexIndices {}

-(void) doNotBufferVertexLocations {}

-(void) doNotBufferVertexNormals {}

-(void) doNotBufferVertexColors {}

-(void) doNotBufferVertexTextureCoordinates {}

-(void) doNotBufferVertexIndices {}

-(void) alignWithTexturesIn: (CC3Material*) aMaterial {}

-(void) alignWithInvertedTexturesIn: (CC3Material*) aMaterial {}

-(void) repeatTexture: (ccTex2F) repeatFactor {}

-(CGRect) textureRectangle { return CGRectNull; }

-(void) setTextureRectangle: (CGRect) aRect {}

-(CGRect) textureRectangleForTextureUnit: (GLuint) texUnit { return CGRectNull; }

-(void) setTextureRectangle: (CGRect) aRect forTextureUnit: (GLuint) texUnit {}


#pragma mark Tag allocation

// Class variable tracking the most recent tag value assigned for CC3MeshModels.
// This class variable is automatically incremented whenever the method nextTag is called.
static GLuint lastAssignedMeshTag;

-(GLuint) nextTag {
	return ++lastAssignedMeshTag;
}

+(void) resetTagAllocation {
	lastAssignedMeshTag = 0;
}


#pragma mark Drawing

-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (self.switchingMesh) {
		[self bindGLWithVisitor: visitor];
	} else {
		LogTrace(@"Reusing currently bound %@", self);
	}
	[self drawVerticesWithVisitor: visitor];
}

-(void) drawFrom: (GLuint) vertexIndex
		forCount: (GLuint) vertexCount
	 withVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (self.switchingMesh) {
		[self bindGLWithVisitor: visitor];
	} else {
		LogTrace(@"Reusing currently bound %@", self);
	}
	[self drawVerticesFrom: vertexIndex forCount: vertexCount withVisitor: visitor];
}

/**
 * Template method that binds the mesh arrays to the GL engine prior to drawing.
 * The specified visitor encapsulates the frustum of the currently active camera,
 * and certain drawing options.
 *
 * This method does not create GL buffers, which are created with the createGLBuffers method.
 * This method binds the buffer or data pointers to the GL engine, prior to each draw call.
 */
-(void) bindGLWithVisitor: (CC3NodeDrawingVisitor*) visitor {}

/** 
 * Draws the mesh vertices to the GL engine.
 * Default implementation does nothing. Subclasses will override.
 */
-(void) drawVerticesWithVisitor: (CC3NodeDrawingVisitor*) visitor {}

/** 
 * Draws a portion of the mesh vertices to the GL engine.
 * Default implementation does nothing. Subclasses will override.
 */
-(void) drawVerticesFrom: (GLuint) vertexIndex
				forCount: (GLuint) vertexCount
			 withVisitor: (CC3NodeDrawingVisitor*) visitor {}

-(CC3NodeBoundingVolume*) defaultBoundingVolume {
	return nil;
}

-(GLsizei) faceCountFromVertexCount: (GLsizei) vc {
	NSAssert(NO, @"Override me!");
	return 0;
}

-(GLsizei) vertexCountFromFaceCount: (GLsizei) fc {
	NSAssert(NO, @"Override me!");
	return 0;
}


#pragma mark Accessing vertex data

-(void) movePivotTo: (CC3Vector) aLocation {}

-(void) movePivotToCenterOfGeometry {}

-(GLsizei) vertexCount { return 0; }

-(CC3Vector) vertexLocationAt: (GLsizei) index { return kCC3VectorZero; }

-(void) setVertexLocation: (CC3Vector) aLocation at: (GLsizei) index {}

-(CC3Vector) vertexNormalAt: (GLsizei) index { return kCC3VectorZero; }

-(void) setVertexNormal: (CC3Vector) aNormal at: (GLsizei) index {}

-(ccColor4F) vertexColor4FAt: (GLsizei) index { return kCCC4FBlackTransparent; }

-(void) setVertexColor4F: (ccColor4F) aColor at: (GLsizei) index {}

-(ccColor4B) vertexColor4BAt: (GLsizei) index { return (ccColor4B){ 0, 0, 0, 0 }; }

-(void) setVertexColor4B: (ccColor4B) aColor at: (GLsizei) index {}

-(ccTex2F) vertexTexCoord2FForTextureUnit: (GLuint) texUnit at: (GLsizei) index {
	return (ccTex2F){ 0.0, 0.0 };
}

-(void) setVertexTexCoord2F: (ccTex2F) aTex2F forTextureUnit: (GLuint) texUnit at: (GLsizei) index {}

-(ccTex2F) vertexTexCoord2FAt: (GLsizei) index {
	return [self vertexTexCoord2FForTextureUnit: 0 at: index];
}

-(void) setVertexTexCoord2F: (ccTex2F) aTex2F at: (GLsizei) index {
	[self setVertexTexCoord2F: aTex2F forTextureUnit: 0 at: index];
}

// Deprecated
-(ccTex2F) vertexTexCoord2FAt: (GLsizei) index forTextureUnit: (GLuint) texUnit {
	return [self vertexTexCoord2FForTextureUnit: texUnit at: index];
}

// Deprecated
-(void) setVertexTexCoord2F: (ccTex2F) aTex2F at: (GLsizei) index forTextureUnit: (GLuint) texUnit {
	[self setVertexTexCoord2F: aTex2F forTextureUnit: texUnit at: index];
}

-(GLushort) vertexIndexAt: (GLsizei) index { return 0; }

-(void) setVertexIndex: (GLushort) vertexIndex at: (GLsizei) index {}

-(void) updateVertexLocationsGLBuffer {}

-(void) updateVertexNormalsGLBuffer {}

-(void) updateVertexColorsGLBuffer {}

-(void) updateVertexTextureCoordinatesGLBufferForTextureUnit: (GLuint) texUnit {}

-(void) updateVertexTextureCoordinatesGLBuffer {
	[self updateVertexTextureCoordinatesGLBufferForTextureUnit: 0];
}

-(void) updateVertexIndicesGLBuffer {}


#pragma mark Mesh context switching

// The tag of the mesh that was most recently drawn to the GL engine.
// The GL engine is only updated when a mesh with a different tag is presented.
// This allows for optimization by ordering the drawing of objects so that objects with
// the same mesh are drawn together, to minimize context switching within the GL engine.
static GLuint currentMeshTag = 0;

/**
 * Returns whether this mesh is different than the mesh that was most recently
 * drawn to the GL engine. To improve performance, meshes are only bound if they need to be.
 *
 * If appropriate, the application can arrange CC3MeshNodes in the CC3World so that nodes
 * using the same mesh are drawn together, to minimize the number of mesh binding
 * changes in the GL engine.
 *
 * This method is invoked automatically by the draw method to test whether this mesh needs
 * to be bound to the GL engine before drawing.
 */
-(BOOL) switchingMesh {
	BOOL shouldSwitch = currentMeshTag != tag;
	currentMeshTag = tag;		// Set anyway - either it changes or it doesn't.
	return shouldSwitch;
}

+(void) resetSwitching {
	currentMeshTag = 0;
}

@end


#pragma mark -
#pragma mark Deprecated CC3MeshModel

@implementation CC3MeshModel
@end
