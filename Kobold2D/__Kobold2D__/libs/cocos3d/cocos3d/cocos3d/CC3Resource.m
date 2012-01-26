/*
 * CC3Resource.m
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
 * See header file CC3Resource.h for full API documentation.
 */

#import "CC3Resource.h"


@implementation CC3Resource

@synthesize nodes, directory, wasLoaded;

-(void) dealloc {
	[nodes release];
	[directory release];
	[super dealloc];
}


#pragma mark Allocation and initialization

// Converts a resource file path to an absolute file path.
-(NSString*) filePathFromRezPath: (NSString*) aRezPath {
	NSString* rezDir = [[NSBundle mainBundle] resourcePath];
	return [rezDir stringByAppendingPathComponent: aRezPath];
}

-(id) init {
	if ( (self = [super init]) ) {
		nodes = [[CCArray array] retain];
		directory = nil;
		wasLoaded = NO;
	}
	return self;
}

+(id) resource {
	return [[[self alloc] init] autorelease];
}

-(id) initFromFile: (NSString*) aFilePath {
	if ( (self = [self init]) ) {
		if ( ![self loadFromFile: aFilePath] ) {
			[self release];
			return nil;
		}
	}
	return self;
}

+(id) resourceFromFile: (NSString*) aFilePath {
	return [[[self alloc] initFromFile: aFilePath] autorelease];
}

-(id) initFromResourceFile: (NSString*) aRezPath {
	return [self initFromFile: [self filePathFromRezPath: aRezPath]];
}

+(id) resourceFromResourceFile: (NSString*) aRezPath {
	return [[[self alloc] initFromResourceFile: aRezPath] autorelease];
}

// Subclasses should override this method, but invoke this superclass implementation first.
-(BOOL) loadFromFile: (NSString*) aFilePath {
	if (wasLoaded) {
		LogError(@"%@ has already been loaded from file '%@'", self, self.name);
		return wasLoaded;
	}
	LogCleanRez(@"");
	LogCleanRez(@"--------------------------------------------------");
	LogRez(@"Loading resources from file '%@'", aFilePath);
	if (!name) {
		self.name = [aFilePath lastPathComponent];
	}
	if (!directory) {
		self.directory = [aFilePath stringByDeletingLastPathComponent];
	}
	return NO;
}

-(BOOL) loadFromResourceFile: (NSString*) aRezPath {
	return [self loadFromFile: [self filePathFromRezPath: aRezPath]];
}


#pragma mark Tag allocation

// Class variable tracking the most recent tag value assigned for CC3Nodes.
// This class variable is automatically incremented whenever the method nextTag is called.
static GLuint lastAssignedResourceTag;

-(GLuint) nextTag {
	return ++lastAssignedResourceTag;
}

+(void) resetTagAllocation {
	lastAssignedResourceTag = 0;
}

@end
