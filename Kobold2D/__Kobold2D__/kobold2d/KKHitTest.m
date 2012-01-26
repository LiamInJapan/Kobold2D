/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "KKHitTest.h"

@interface KKHitTest (PrivateMethods)
@end

@implementation KKHitTest

@synthesize isHitTesting;

-(BOOL) hitTestNodeChildren:(CCArray*)children point:(CGPoint)point
{
    BOOL hit = NO;
	
    if ([children count] > 0)
    {
        Class sceneClass = [CCScene class];
        Class layerClass = [CCLayer class];
		
        CCNode* node = nil;
        CCARRAY_FOREACH(children, node)
        {
            // check the node's children first
            hit = [self hitTestNodeChildren:[node children] point:point];
            
            // abort search on first hit
            if (hit) 
            {
                break;
            }
            
            // scenes/layers are always full screen, so do not hitTest them
            if ([node isKindOfClass:sceneClass] || [node isKindOfClass:layerClass]) 
            {
                continue;
            }
			
            // check the node itself
            hit = [node containsPoint:point];
            
            // abort search on first hit
            if (hit)
            {
                break;
            }
        }
    }
    
    return hit;
}

-(BOOL) hitTest:(CGPoint)point
{
	CCScene* runningScene = [CCDirector sharedDirector].runningScene;
	CGPoint glPoint = [[CCDirector sharedDirector] convertToGL:point];
	return [self hitTestNodeChildren:[runningScene children] point:glPoint];
}

#pragma mark Singleton stuff

static KKHitTest *instanceOfHitTest;

+(id) alloc
{
	@synchronized(self)	
	{
		NSAssert(instanceOfHitTest == nil, @"Attempted to allocate a second instance of the singleton: KKHitTest");
		instanceOfHitTest = [[super alloc] retain];
		return instanceOfHitTest;
	}
	
	// to avoid compiler warning
	return nil;
}

+(KKHitTest*) sharedHitTest
{
	@synchronized(self)
	{
		if (instanceOfHitTest == nil)
		{
			instanceOfHitTest = [[KKHitTest alloc] init];
		}
		
		return instanceOfHitTest;
	}
	
	// to avoid compiler warning
	return nil;
}

-(void) dealloc
{
	instanceOfHitTest = nil;
	[super dealloc];
}

@end

#if KK_PLATFORM_IOS
@implementation EAGLView (KoboldExtensions)
-(UIView*) hitTest:(CGPoint)aPoint withEvent:(UIEvent*)event
{
	UIView* hitView = [super hitTest:aPoint withEvent:event];
	if ([instanceOfHitTest isHitTesting] && hitView == self)
    {
		// hit was on the cocos2d GL view, test the nodes for a hit, return nil if no node was hit
		if ([[KKHitTest sharedHitTest] hitTest:aPoint] == NO)
		{
			return nil;
		}
    }
	return hitView;
}
@end
#endif
