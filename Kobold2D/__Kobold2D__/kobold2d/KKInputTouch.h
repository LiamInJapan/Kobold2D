/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"
#import "cocos2d-extensions.h"
#import "ccMoreMacros.h"

#import "KKTouches.h"

@interface KKInputTouch : NSObject 
#if KK_PLATFORM_IOS
	<CCStandardTouchDelegate>
#elif KK_PLATFORM_MAC
	<CCTouchEventDelegate>
#endif
{
@private
	KKTouches* touches;
}

@property (nonatomic, readonly) CCArray* touches;

-(BOOL) anyTouchBeganThisFrame;
-(BOOL) anyTouchEndedThisFrame;

-(CGPoint) locationOfAnyTouchInPhase:(KKTouchPhase)touchPhase;
-(BOOL) isAnyTouchOnNode:(CCNode*)node touchPhase:(KKTouchPhase)touchPhase;

@end
