/*********************************************************************
 *	
 *	cpCCNode.m
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 02/22/2009.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "cpCCNode.h"


@implementation cpCCNode

+ (id) nodeWithShape:(cpShape*)shape
{
	return [[[self alloc] initWithShape:shape] autorelease];
}

- (id) initWithShape:(cpShape*)shape
{
	CPCCNODE_MEM_VARS_SHAPE_INIT(shape)

	[self init];
	
	CPCCNODE_SYNC_POS_ROT(self);
	
	return self;
}

+ (id) nodeWithBody:(cpBody*)body
{
	return [[[self alloc] initWithBody:body] autorelease];
}

- (id) initWithBody:(cpBody*)body
{
	CPCCNODE_MEM_VARS_BODY_INIT(body)
    
	[self init];
	
	CPCCNODE_SYNC_POS_ROT(self);
	
	return self;
}

CPCCNODE_FUNC_SRC

@end

