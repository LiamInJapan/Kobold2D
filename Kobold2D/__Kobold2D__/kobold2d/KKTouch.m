/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "KKTouch.h"

@interface KKTouch (PrivateMethods)
@end

@implementation KKTouch

@synthesize location, previousLocation, tapCount, timestamp, phase, touchID;

-(id) init
{
    if ((self = [super init]))
	{
		phase = KKTouchPhaseLifted;
		didPhaseChange = NO;
		isInvalid = YES;
    }
    
    return self;
}

-(void) setTouchWithLocation:(CGPoint)loc previousLocation:(CGPoint)prevLoc tapCount:(NSUInteger)taps timestamp:(NSTimeInterval)ts phase:(KKTouchPhase)ph
{
	location = loc;
	previousLocation = prevLoc;
	tapCount = taps;
	timestamp = ts;
	didPhaseChange = (phase != ph);
	phase = ph;
	isInvalid = NO;
}

-(void) setValidWithID:(NSUInteger)ID
{
	isInvalid = NO;
	touchID = ID;
}

-(void) invalidate
{
	isInvalid = YES;
	touchID = 0;
	phase = KKTouchPhaseLifted;
}

@end
