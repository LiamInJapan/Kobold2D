/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "KKInputTouch.h"

@interface KKInputTouch (PrivateMethods)
@end

@implementation KKInputTouch

@dynamic touches;

-(id) init
{
    if ((self = [super init]))
	{
		touches = [[KKTouches alloc] init];
		
#if KK_PLATFORM_IOS
		[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:0];
#endif
    }
    
    return self;
}

-(void) dealloc
{
#if KK_PLATFORM_IOS
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
#endif
	
	[touches release];
	[super dealloc];
}

#if KK_PLATFORM_IOS
-(void) resetInputStates
{
	[touches removeAllTouches];
}

-(void) ccTouchesBegan:(NSSet*)touchesSet withEvent:(UIEvent*)event
{
	//CCLOG(@"touch began...");
	[touches addTouches:touchesSet];
}

-(void) ccTouchesEnded:(NSSet*)touchesSet withEvent:(UIEvent*)event
{
	//CCLOG(@"touch ended...");
	[touches removeTouches:touchesSet];
}

-(void) ccTouchesCancelled:(NSSet*)touchesSet withEvent:(UIEvent*)event
{
	[touches removeTouches:touchesSet];
}

#endif // KK_PLATFORM_IOS


-(BOOL) anyTouchBeganThisFrame
{
	NSUInteger currentFrame = [CCDirector sharedDirector].frameCount;
	KKTouch* touch;
	CCARRAY_FOREACH(touches.touches, touch)
	{
		if (touch && touch->touchBeganFrame == currentFrame)
		{
			return YES;
		}
	}

	return NO;
}

-(BOOL) anyTouchEndedThisFrame
{
	KKTouch* touch;
	CCARRAY_FOREACH(touches.touches, touch)
	{
		if (touch && touch->didPhaseChange && [touch phase] == KKTouchPhaseEnded)
		{
			return YES;
		}
	}

	return NO;
}

-(CGPoint) locationOfAnyTouchInPhase:(KKTouchPhase)touchPhase
{
	KKTouch* touch;
	CCARRAY_FOREACH(touches.touches, touch)
	{
		if (touch && (touchPhase == KKTouchPhaseAny || [touch phase] == touchPhase))
		{
			return touch.location;
		}
	}

	return CGPointZero;
}

-(BOOL) isAnyTouchOnNode:(CCNode*)node touchPhase:(KKTouchPhase)touchPhase
{
	if (node)
	{
		KKTouch* touch;
		CCARRAY_FOREACH(touches.touches, touch)
		{
			if (touch && (touchPhase == KKTouchPhaseAny || [touch phase] == touchPhase) && [node containsPoint:touch.location])
			{
				return YES;
			}
		}
	}
	
	return NO;
}

-(CCArray*) touches
{
	return [touches touches];
}

@end
