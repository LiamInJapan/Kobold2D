/*
 * CC3OpenGLES11VertexArrays.m
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
 * See header file CC3OpenGLES11VertexArrays.h for full API documentation.
 */

#import "CC3OpenGLES11VertexArrays.h"


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerArrayBufferBinding

@implementation CC3OpenGLES11StateTrackerArrayBufferBinding

@synthesize queryName;

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnceAndRestore;
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker {
	if ( (self = [self initWithParent: aTracker
							 forState: GL_ARRAY_BUFFER]) ) {
		self.queryName = GL_ARRAY_BUFFER_BINDING;
	}
	return self;
}

-(void) setGLValue {
	glBindBuffer(name, value);
}

-(void) getGLValue {
	glGetIntegerv(queryName, &originalValue);
}

-(void) logGetGLValue {
	LogTrace("%@ %@ read GL value %i (was tracking %@)",
			 [self class], NSStringFromGLEnum(queryName), originalValue,
			 (valueIsKnown ? [NSString stringWithFormat: @"%i", value] : @"UNKNOWN"));
}

-(void) unbind {
	self.value = 0;
}

-(void) loadBufferData: (GLvoid*) buffPtr  ofLength: (GLsizeiptr) buffLen forUse: (GLenum) buffUsage {
	glBufferData(name, buffLen, buffPtr, buffUsage);
}

-(void) updateBufferData: (GLvoid*) buffPtr
			  startingAt: (GLintptr) offset
			   forLength: (GLsizeiptr) length {
	glBufferSubData(name, offset, length, buffPtr);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerElementArrayBufferBinding

@implementation CC3OpenGLES11StateTrackerElementArrayBufferBinding

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker {
	if ( (self = [self initWithParent: aTracker forState: GL_ELEMENT_ARRAY_BUFFER]) ) {
		self.queryName = GL_ELEMENT_ARRAY_BUFFER_BINDING;
	}
	return self;
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexPointer

@interface CC3OpenGLES11StateTrackerInteger (VertexPointer)
-(void) setValueRaw:(GLint) value;
@end

@interface CC3OpenGLES11StateTrackerEnumeration (VertexPointer)
-(void) setValueRaw:(GLenum) value;
@end

@interface CC3OpenGLES11StateTrackerPointer (VertexPointer)
-(void) setValueRaw:(GLvoid*) value;
@end

@implementation CC3OpenGLES11StateTrackerVertexPointer

@synthesize elementSize, elementType, elementStride, elementPointer;

-(void) dealloc {
	[elementSize release];
	[elementType release];
	[elementStride release];
	[elementPointer release];
	[super dealloc];
}

+(BOOL) defaultShouldAlwaysSetGL {
	return YES;
}

-(void) initializeTrackers {}

-(void) setOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling {
	[super setOriginalValueHandling: origValueHandling];
	elementSize.originalValueHandling = origValueHandling;
	elementType.originalValueHandling = origValueHandling;
	elementStride.originalValueHandling = origValueHandling;
	elementPointer.originalValueHandling = origValueHandling;
} 

-(BOOL) valueIsKnown {
	return elementPointer.valueIsKnown
			&& elementStride.valueIsKnown
			&& elementSize.valueIsKnown
			&& elementType.valueIsKnown;
}

-(void) setValueIsKnown:(BOOL) aBoolean {
	elementSize.valueIsKnown = aBoolean;
	elementType.valueIsKnown = aBoolean;
	elementStride.valueIsKnown = aBoolean;
	elementPointer.valueIsKnown = aBoolean;
}

// Set the values in the GL engine if either we should always do it, or if something has changed
-(void) useElementsAt: (GLvoid*) pData
			 withSize: (GLint) elemSize
			 withType: (GLenum) elemType
		   withStride: (GLsizei) elemStride {
	BOOL shouldSetGL = self.shouldAlwaysSetGL;
	shouldSetGL |= (!elementPointer.valueIsKnown || pData != elementPointer.value);
	shouldSetGL |= (!elementSize.valueIsKnown || elemSize != elementSize.value);
	shouldSetGL |= (!elementType.valueIsKnown || elemType != elementType.value);
	shouldSetGL |= (!elementStride.valueIsKnown || elemStride != elementStride.value);
	if (shouldSetGL) {
		[elementPointer setValueRaw: pData];
		[elementSize setValueRaw: elemSize];
		[elementType setValueRaw: elemType];
		[elementStride setValueRaw: elemStride];
		[self setGLValues];
		[self notifyGLChanged];
		self.valueIsKnown = YES;
	}
	[self logSetGLValues: shouldSetGL];
}

-(void) useElementsAt: (GLvoid*) pData withType: (GLenum) elemType withStride: (GLsizei) elemStride {
	[self useElementsAt: pData withSize: 0 withType: elemType withStride: elemStride];
}

-(void) setGLValues {}

-(void) logSetGLValues: (BOOL) wasChanged {
	if (elementSize.value != 0) {
		// GL function uses element size
		LogTrace("%@ %@ %@ = %i, %@ = %@, %@ = %i and %@ = %p", [self class], (wasChanged ? @"applied" : @"reused"),
				 NSStringFromGLEnum(elementSize.name), elementSize.value,
				 NSStringFromGLEnum(elementType.name), NSStringFromGLEnum(elementType.value),
				 NSStringFromGLEnum(elementStride.name), elementStride.value,
				 @"POINTER", elementPointer.value);
	} else {
		// GL function doesn't use element size
		LogTrace("%@ %@ %@ = %@, %@ = %i and %@ = %p", [self class], (wasChanged ? @"applied" : @"reused"),
				 NSStringFromGLEnum(elementType.name), NSStringFromGLEnum(elementType.value),
				 NSStringFromGLEnum(elementStride.name), elementStride.value,
				 @"POINTER", elementPointer.value);
	}
}

/** Invoked when dynamically instantiated (specifically with texture units. */
-(void) open {
	[super open];
	[elementSize open];
	[elementType open];
	[elementStride open];
	[elementPointer open];
}

-(void) close {
	[super close];
	if (self.shouldRestoreOriginalOnClose) {
		[elementPointer restoreOriginalValue];
		[elementSize restoreOriginalValue];
		[elementType restoreOriginalValue];
		[elementStride restoreOriginalValue];
		[self setGLValues];
	}
	self.valueIsKnown = self.valueIsKnownOnClose;
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 400];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@ ", elementSize];
	[desc appendFormat: @"\n    %@ ", elementType];
	[desc appendFormat: @"\n    %@ ", elementStride];
	[desc appendFormat: @"\n    %@ ", elementPointer];
	return desc;
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexLocationsPointer

@implementation CC3OpenGLES11StateTrackerVertexLocationsPointer

-(void) initializeTrackers {
	self.elementSize = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self
																  forState: GL_VERTEX_ARRAY_SIZE];
	self.elementType = [CC3OpenGLES11StateTrackerEnumeration trackerWithParent: self
																	  forState: GL_VERTEX_ARRAY_TYPE];
	self.elementStride = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self
																	forState: GL_VERTEX_ARRAY_STRIDE];
	self.elementPointer = [CC3OpenGLES11StateTrackerPointer trackerWithParent: self];
}

-(void) setGLValues {
	glVertexPointer(elementSize.value, elementType.value, elementStride.value, elementPointer.value);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexNormalsPointer

@implementation CC3OpenGLES11StateTrackerVertexNormalsPointer

-(void) initializeTrackers {
	self.elementSize = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self];		// no-op tracker
	self.elementType = [CC3OpenGLES11StateTrackerEnumeration trackerWithParent: self
																	  forState: GL_NORMAL_ARRAY_TYPE];
	self.elementStride = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self
																	forState: GL_NORMAL_ARRAY_STRIDE];
	self.elementPointer = [CC3OpenGLES11StateTrackerPointer trackerWithParent: self];
}

-(void) setGLValues {
	glNormalPointer(elementType.value, elementStride.value, elementPointer.value);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexColorsPointer

@implementation CC3OpenGLES11StateTrackerVertexColorsPointer

-(void) initializeTrackers {
	self.elementSize = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self
																  forState: GL_COLOR_ARRAY_SIZE];
	self.elementType = [CC3OpenGLES11StateTrackerEnumeration trackerWithParent: self
																	  forState: GL_COLOR_ARRAY_TYPE];
	self.elementStride = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self
																	forState: GL_COLOR_ARRAY_STRIDE];
	self.elementPointer = [CC3OpenGLES11StateTrackerPointer trackerWithParent: self];
}

-(void) setGLValues {
	glColorPointer(elementSize.value, elementType.value, elementStride.value, elementPointer.value);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexPointSizesPointer

@implementation CC3OpenGLES11StateTrackerVertexPointSizesPointer

-(void) initializeTrackers {
	self.elementSize = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self];		// no-op tracker
	self.elementType = [CC3OpenGLES11StateTrackerEnumeration trackerWithParent: self
																	  forState: GL_POINT_SIZE_ARRAY_TYPE_OES];
	self.elementStride = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self
																	forState: GL_POINT_SIZE_ARRAY_STRIDE_OES];
	self.elementPointer = [CC3OpenGLES11StateTrackerPointer trackerWithParent: self];
}

-(void) setGLValues {
	glPointSizePointerOES(elementType.value, elementStride.value, elementPointer.value);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexWeightsPointer

@implementation CC3OpenGLES11StateTrackerVertexWeightsPointer

-(void) initializeTrackers {
	self.elementSize = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self
																  forState: GL_WEIGHT_ARRAY_SIZE_OES];
	self.elementType = [CC3OpenGLES11StateTrackerEnumeration trackerWithParent: self
																	  forState: GL_WEIGHT_ARRAY_TYPE_OES];
	self.elementStride = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self
																	forState: GL_WEIGHT_ARRAY_STRIDE_OES];
	self.elementPointer = [CC3OpenGLES11StateTrackerPointer trackerWithParent: self];
}

-(void) setGLValues {
	glWeightPointerOES(elementSize.value, elementType.value, elementStride.value, elementPointer.value);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexMatrixIndicesPointer

@implementation CC3OpenGLES11StateTrackerVertexMatrixIndicesPointer

-(void) initializeTrackers {
	self.elementSize = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self
																  forState: GL_MATRIX_INDEX_ARRAY_SIZE_OES];
	self.elementType = [CC3OpenGLES11StateTrackerEnumeration trackerWithParent: self
																	  forState: GL_MATRIX_INDEX_ARRAY_TYPE_OES];
	self.elementStride = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self
																	forState: GL_MATRIX_INDEX_ARRAY_STRIDE_OES];
	self.elementPointer = [CC3OpenGLES11StateTrackerPointer trackerWithParent: self];
}

-(void) setGLValues {
	glMatrixIndexPointerOES(elementSize.value, elementType.value, elementStride.value, elementPointer.value);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11VertexArrays

@implementation CC3OpenGLES11VertexArrays

@synthesize arrayBuffer;
@synthesize indexBuffer;
@synthesize locations;
@synthesize matrixIndices;
@synthesize normals;
@synthesize colors;
@synthesize pointSizes;
@synthesize weights;

-(void) dealloc {
	[arrayBuffer release];
	[indexBuffer release];
	[locations release];
	[matrixIndices release];
	[normals release];
	[colors release];
	[pointSizes release];
	[weights release];
	[super dealloc];
}

-(void) initializeTrackers {
	self.arrayBuffer = [CC3OpenGLES11StateTrackerArrayBufferBinding trackerWithParent: self];
	self.indexBuffer = [CC3OpenGLES11StateTrackerElementArrayBufferBinding trackerWithParent: self];
	self.locations = [CC3OpenGLES11StateTrackerVertexLocationsPointer trackerWithParent: self];
	self.matrixIndices = [CC3OpenGLES11StateTrackerVertexMatrixIndicesPointer trackerWithParent: self];
	self.normals = [CC3OpenGLES11StateTrackerVertexNormalsPointer trackerWithParent: self];
	self.colors = [CC3OpenGLES11StateTrackerVertexColorsPointer trackerWithParent: self];
	self.pointSizes = [CC3OpenGLES11StateTrackerVertexPointSizesPointer trackerWithParent: self];
	self.weights = [CC3OpenGLES11StateTrackerVertexWeightsPointer trackerWithParent: self];
}

-(CC3OpenGLES11StateTrackerArrayBufferBinding*) bufferBinding: (GLenum) bufferTarget {
	switch (bufferTarget) {
		case GL_ARRAY_BUFFER:
			return arrayBuffer;
		case GL_ELEMENT_ARRAY_BUFFER:
			return indexBuffer;
		default:
			NSAssert1(NO, @"Illegal buffer target %u", bufferTarget);
			return nil;
	}
}

-(GLuint) generateBuffer {
	GLuint buffID;
	glGenBuffers(1, &buffID);
	return buffID;
}

-(void) deleteBuffer: (GLuint) buffID  {
	glDeleteBuffers(1, &buffID);
}

-(void) drawVerticiesAs: (GLenum) drawMode startingAt: (GLuint) start withLength: (GLuint) len {
	LogTrace(@"GL drawing %u vertices as %@ starting from %u",
			 len, NSStringFromGLEnum(drawMode), start);
	glDrawArrays(drawMode, start, len);
} 

-(void) drawIndicies: (GLvoid*) indicies ofLength: (GLuint) len andType: (GLenum) type as: (GLenum) drawMode {
	LogTrace(@"GL drawing %u indices of type %@ as %@ starting from %u",
			 len, NSStringFromGLEnum(type), NSStringFromGLEnum(drawMode), indicies);
	glDrawElements(drawMode, len, type, indicies);
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 600];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@ ", arrayBuffer];
	[desc appendFormat: @"\n    %@ ", indexBuffer];
	[desc appendFormat: @"\n    %@ ", locations];
	[desc appendFormat: @"\n    %@ ", matrixIndices];
	[desc appendFormat: @"\n    %@ ", normals];
	[desc appendFormat: @"\n    %@ ", colors];
	[desc appendFormat: @"\n    %@ ", pointSizes];
	[desc appendFormat: @"\n    %@ ", weights];
	return desc;
}

@end
