/*
 *  SpaceManagerCocos2d.m
 *  Example
 *
 *  Created by Robert Blackwood on 1/4/11.
 *  Copyright 2011 Mobile Bros. All rights reserved.
 *
 */

#import "SpaceManagerCocos2d.h"

void smgrBasicIterateShapesFunc(cpSpace *space, smgrEachFunc func)
{
    cpSpaceEachShape(space, (cpSpaceShapeIteratorFunc)func, NULL);
}

void smgrBasicIterateActiveShapesOnlyFunc(cpSpace *space, smgrEachFunc func)
{
    cpSpatialIndexEach(space->CP_PRIVATE(activeShapes), func, NULL);
}

/* Look into position_func off of cpBody for more efficient sync */
void smgrBasicEachShape(void *shape_ptr, void* data)
{
	cpShape *shape = (cpShape*)shape_ptr;
	CCNode *node = (CCNode*)shape->data;
	
	if(node) 
	{
		cpBody *body = shape->body;
		[node setPosition:body->p];
		[node setRotation:CC_RADIANS_TO_DEGREES(-body->a)];
	}
}

void smgrBasicEachShapeOrBody(void *shape_ptr, void *data)
{
    cpShape *shape = (cpShape*)shape_ptr;
	CCNode *node = (CCNode*)shape->data;
    cpBody *body = shape->body;
    
    if (!node)
        node = (CCNode*)body->data;
	
	if(node) 
	{
		[node setPosition:body->p];
		[node setRotation:CC_RADIANS_TO_DEGREES(-body->a)];
	}
}

void smgrEachShapeAsChildren(void *shape_ptr, void* data)
{
	cpShape *shape = (cpShape*)shape_ptr;
	
	CCNode *node = (CCNode*)shape->data;
	if(node) 
	{
		cpBody *body = shape->body;
		CCNode *parent = node.parent;
		if (parent)
		{
			[node setPosition:[node.parent convertToNodeSpace:body->p]];
			
			cpVect zPt = [node convertToWorldSpace:cpvzero];
			cpVect dPt = [node convertToWorldSpace:cpvforangle(body->a)];
			cpVect rPt = cpvsub(dPt,zPt);
			float angle = cpvtoangle(rPt);
			[node setRotation: CC_RADIANS_TO_DEGREES(-angle)];
		}
		else
		{
			[node setPosition:body->p];
			[node setRotation: CC_RADIANS_TO_DEGREES( -body->a )];
		}
	}
}

void smgrBasicIterateBodiesFunc(cpSpace* space, smgrEachFunc func)
{
    cpSpaceEachBody(space, (cpSpaceBodyIteratorFunc)func, NULL);
}

void smgrBasicEachBody(void *body_ptr, void* data)
{
    cpBody *body = (cpBody*)body_ptr;
	CCNode *node = (CCNode*)body->data;
	
	if(node) 
	{
		[node setPosition:body->p];
		[node setRotation:CC_RADIANS_TO_DEGREES(-body->a)];
	}
}

static void drawShape(cpShape *shape, void* data)
{
    cpShapeNodeEfficientDrawAt(shape, cpBodyGetPos(shape->body), cpBodyGetRot(shape->body));
}

static void drawConstraint(cpConstraint *constraint, void* data)
{
    cpConstraintNodeEfficientDraw(constraint);
}

@interface SmgrDebugLayer : CCLayer 
{
    cpSpace *_space;
    ccColor4B _color;
}
+(id) layerWithSpace:(cpSpace*)space color:(ccColor4B)color;
-(id) initWithSpace:(cpSpace*)space color:(ccColor4B)color;

@end

@implementation SmgrDebugLayer

+(id) layerWithSpace:(cpSpace*)space color:(ccColor4B)color
{
    return [[[self alloc] initWithSpace:space color:color] autorelease];
}

-(id) initWithSpace:(cpSpace*)space color:(ccColor4B)color
{
    [super init];
    _space = space;
    _color = color;
    return self;
}

-(void) draw
{
    cpShapeNodePreDrawState();
    glLineWidth(1);
    glPointSize(1);
    
    if( _color.a != 255 )
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);	
    
    glColor4ub(_color.r, _color.g, _color.b, _color.a);
    
    cpSpaceEachShape(_space, drawShape, NULL);
    cpSpaceEachConstraint(_space, drawConstraint, NULL);
    
    if( _color.a != 255 )
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);

    cpShapeNodePostDrawState();
}

@end

@implementation SpaceManagerCocos2d

-(id) initWithSpace:(cpSpace*)space
{
	[super initWithSpace:space];
	
	_iterateFunc = &smgrBasicIterateShapesFunc;
    _eachFunc = &smgrBasicEachShapeOrBody;
	
	return self;
}

-(void) dealloc
{
	[self stop];
	
	[super dealloc];
}

-(void) start:(ccTime)dt
{	
	[[CCScheduler sharedScheduler] scheduleSelector:@selector(step:) forTarget:self interval:dt paused:NO];
}

-(void) start
{
	[self start:0];
}

-(void) stop
{
	[[CCScheduler sharedScheduler] unscheduleSelector:@selector(step:) forTarget:self];
}

-(CCLayer*) createDebugLayer
{
    return [self createDebugLayerWithColor:ccc4(0, 100, 255, 255)];
}

-(CCLayer*) createDebugLayerWithColor:(ccColor4B)color;
{
	CCLayer *layer = [SmgrDebugLayer layerWithSpace:_space color:color];
	return layer;
}

+(cpShapeNode*) createShapeNode:(cpShape*)shape
{
	cpShapeNode *node = nil;
	
	if (shape)
	{		
		node = [cpShapeNode nodeWithShape:shape];
		node.color = ccc3(rand()%256, rand()%256, rand()%256);
	}
	
	return node;
}

+(cpConstraintNode*) createConstraintNode:(cpConstraint*)constraint
{
	cpConstraintNode *node = nil;
	
	if (constraint)
	{
		node = [cpConstraintNode nodeWithConstraint:constraint];
		node.color = ccc3(rand()%256, rand()%256, rand()%256);
	}
	
	return node;
}

-(void) addWindowContainmentWithFriction:(cpFloat)friction elasticity:(cpFloat)elasticity inset:(cpVect)inset
{
	[self addWindowContainmentWithFriction:friction elasticity:elasticity inset:inset radius:1.0f];
}

-(void) addWindowContainmentWithFriction:(cpFloat)friction elasticity:(cpFloat)elasticity inset:(cpVect)inset radius:(cpFloat)radius
{
	CGSize wins = [[CCDirector sharedDirector] winSize];
	
	[self addWindowContainmentWithFriction:friction elasticity:elasticity size:wins inset:inset radius:radius];
}

@end

