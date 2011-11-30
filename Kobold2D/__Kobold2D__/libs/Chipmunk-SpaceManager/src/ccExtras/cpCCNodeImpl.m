/*********************************************************************
 *	
 *	cpCCNodeImpl.m
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 02/22/2009.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "cpCCNode.h"


@implementation cpCCNodeImpl

@synthesize ignoreRotation = _ignoreRotation;
@synthesize integrationDt = _integrationDt;
@synthesize spaceManager = _spaceManager;
@synthesize autoFreeShapeAndBody = _autoFreeShapeAndBody;

- (id) init
{
	return [self initWithShape:nil];
}

- (id) initWithShape:(cpShape*)s
{	
    [super init];
    
	_integrationDt = 0; //This should be off by default
    self.shape = s;
	
	return self;
}

- (id) initWithBody:(cpBody*)b
{
    [super init];
    
    _integrationDt = 0;
    self.body = b;
    
    return self;
}

-(void) setShape:(cpShape*)shape
{
    _shape = shape;
    if (shape)
        _body = shape->body;
    else
        _body = NULL;
}

-(cpShape*) shape
{
    return _shape;
}

-(void) setBody:(cpBody*)body
{
    _shape = nil;
    _body = body;
}

-(cpBody*) body
{
    return _body;
}

-(void) dealloc
{
	if (_shape)
	{
		_shape->data = NULL;
		if (_autoFreeShapeAndBody)
		{
			assert(_spaceManager != nil);
			[_spaceManager removeAndFreeShape:_shape];
		}
	}
    else if (_body)
    {
        _body->data = NULL;
		if (_autoFreeShapeAndBody)
		{
			assert(_spaceManager != nil);
			[_spaceManager removeAndFreeBody:_body];
		}
    }
	_shape = nil;
    _body = nil;
		
	[super dealloc];
}

-(BOOL)setRotation:(float)rot
{	
	if (!_ignoreRotation)
	{	
		//Needs a calculation for angular velocity and such
		if (_body != nil)
			cpBodySetAngle(_body, -CC_DEGREES_TO_RADIANS(rot));
	}
	
	return !_ignoreRotation;
}

-(void)setPosition:(cpVect)pos
{	
    //cpAssert(_shape == nil || _shape->body == _body, "Body must be the same as Shape's");
	if (_body != nil)
	{
		/* 
			A bit worried doing a != here but apparently copying around
			floats allows accurate comparisons.
		 */
		
		//If we're out of sync with chipmunk
		if (_body->p.x != pos.x || _body->p.y != pos.y)
		{
			//(Basic Euler integration)
			if (_integrationDt)
			{
				cpBodyActivate(_body);
				cpBodySetVel(_body, cpvmult(cpvsub(pos, cpBodyGetPos(_body)), 1.0f/_integrationDt));
			}
			
			//update position
			_body->p = pos;
			
            
			//If we're a static shape, we need to tell our space that we've changed
			if (_spaceManager && _body->m == STATIC_MASS)
			{
                if (_shape != nil)
                    [_spaceManager rehashShape:_shape];
			}
            //else activate!, could be sleeping
            else
				cpBodyActivate(_body);
		}
	}
}

-(void) applyImpulse:(cpVect)impulse offset:(cpVect)offset
{
	if (_body != nil)
		cpBodyApplyImpulse(_body, impulse, offset);
}

-(void) applyForce:(cpVect)force offset:(cpVect)offset
{
	if (_body != nil)
		cpBodyApplyForce(_body, force, offset);	
}

-(void) resetForces
{
	if (_body != nil)
		cpBodyResetForces(_body);
}

@end

