//
//  Retina.m
//  Example
//
//  Created by Robert Blackwood on 11/1/10.
//  Copyright Mobile Bros 2010. All rights reserved.
//


// Import the interfaces
#import "Retina.h"
#import "cpShapeNode.h"
#import "cpConstraintNode.h"

@interface Retina (OtherTests)
- (void) raycastTest:(CGPoint)ballPos boxPos:(CGPoint)boxPos;
- (void) shapeQueryTest:(CGPoint)ballPos boxPos:(CGPoint)boxPos;
- (void) pulleyTest;
@end


@implementation Retina

-(id) init
{
	if( (self=[super init])) 
	{
		smgr = [[SpaceManagerCocos2d alloc] init];
		[smgr addWindowContainmentWithFriction:1.0 elasticity:1.0 inset:cpv(0,0)];
		
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
		
		self.isAccelerometerEnabled = YES;
		[[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0/30.0f];
		
		cpShapeNode *ball = [cpShapeNode nodeWithShape:[smgr addCircleAt:ccp(240,160) mass:50 radius:14]];
		ball.color = ccRED;
		[self addChild:ball];
		
		cpShapeNode *box = [cpShapeNode nodeWithShape:[smgr addRectAt:ccp(300,200) mass:50 width:28 height:28 rotation:0]];
		box.color = ccBLUE;
		[self addChild:box];
		
		cpConstraintNode *pin = [cpConstraintNode nodeWithConstraint:[smgr addPinToBody:ball.shape->body
																			   fromBody:box.shape->body]];
		pin.color = ccORANGE;
		[self addChild:pin];
		
		cpConstraintNode *gear = [cpConstraintNode nodeWithConstraint:[smgr addGearToBody:ball.shape->body
																				 fromBody:box.shape->body
																					ratio:2]];
		gear.color = ccGREEN;
		[self addChild:gear];
		
		[smgr addMotorToBody:ball.shape->body rate:3];
		
		//// Quick Shape Query test
		[self shapeQueryTest:ball.position boxPos:box.position];
		//// Ray test
		[self raycastTest:ball.position boxPos:box.position];
		
		[self pulleyTest];
		
		[self schedule: @selector(step:)];
	}
	
	return self;
}

-(void) dealloc
{
	[smgr release];
	[super dealloc];
}

-(void) raycastTest:(CGPoint)ballPos boxPos:(CGPoint)boxPos
{
	//Have to step first to get shape's initialized in space I guess
	[smgr step:1/60.0];
	
	CGPoint dir = ccpNormalize(ccpSub(ballPos, boxPos));
	CGPoint pt1 = ccpAdd(ballPos, ccpMult(dir, -100));
	CGPoint pt2 = ccpAdd(boxPos, ccpMult(dir, 100));
	
	NSArray *array = [smgr getShapesFromRayCastSegment:pt1 end:pt2];
	NSAssert([array count] == 2, @"Raycast did not find ball and box (count: %d)", [array count]);
	
	array = [smgr getInfosFromRayCastSegment:pt1 end:pt2];
	NSAssert([array count] == 2, @"Raycast did not find ball and box infos (count: %d)", [array count]);	
}

-(void) shapeQueryTest:(CGPoint)ballPos boxPos:(CGPoint)boxPos
{
	NSArray *array = [smgr getShapesAt:ballPos radius:ccpDistance(ballPos, boxPos)];
	
	NSAssert([array count] == 2, @"Shape Query did not find ball and box (count: %d)", [array count]);
}

- (void) pulleyTest
{
	cpShape *b1 = [smgr addCircleAt:cpv(190,220) mass:1.0 radius:10];
	cpCCSprite *three = [cpCCSprite spriteWithFile:@"ball.png"];
    three.shape = b1;
	[self addChild:three z:100];		
	
	cpShape *b2 = [smgr addCircleAt:cpv(350,220) mass:1.0 radius:10];
	cpCCSprite *four = [cpCCSprite spriteWithFile:@"ball.png"];
    four.shape = b2;
	[self addChild:four z:100];		
	
	cpConstraint *pulley = [smgr addPulleyToBody:three.body fromBody:four.body 
									toBodyAnchor:cpvzero fromBodyAnchor:cpvzero
							 toPulleyWorldAnchor:cpv(200,270) fromPulleyWorldAnchor:cpv(300,270) ratio:1];
	cpConstraintNode *pulleyn = [cpConstraintNode nodeWithConstraint:pulley];
	pulleyn.color = ccORANGE;
	[self addChild:pulleyn];
}

-(void) onEnter
{
	[super onEnter];
	
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 60)];
}

-(void) step: (ccTime) delta
{
	[smgr step:delta];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint pt = [self convertTouchToNodeSpace:touch];
	
	_lastPt = pt;
	
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint pt = [self convertTouchToNodeSpace:touch];
	
	[self drawTerrainAt:pt];
}

- (BOOL) drawTerrainAt:(CGPoint)pt
{
	float r2 = ccpLengthSQ(ccpSub(pt, _lastPt));
	
	if (r2 > 25)
	{
		cpShape* shape = [smgr addSegmentToBody:smgr.staticBody 
                                fromLocalAnchor:_lastPt
                                  toLocalAnchor:pt 
                                         radius:5];
		
		cpShapeNode* node = [cpShapeNode nodeWithShape:shape];
		node.spaceManager = smgr;
		node.autoFreeShapeAndBody = YES;
		node.color = ccWHITE;
		[self addChild:node];
		
		_lastPt = pt;
		
		return YES;
	}
	
	return NO;
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	static float prevX=0, prevY=0;
	
#define kFilterFactor 0.05f
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
	
	CGPoint v = ccp( -accelY, accelX);
	
	smgr.gravity = ccpMult(v, 200);
}
@end
