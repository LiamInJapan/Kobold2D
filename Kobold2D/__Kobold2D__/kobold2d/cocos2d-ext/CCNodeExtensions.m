/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "CCNodeExtensions.h"
#import "ccMoreTypes.h"

#import "FixCategoryBug.h"
FIX_CATEGORY_BUG(CCNode)


@implementation CCNode (KoboldExtensions)

-(CGPoint) relativePosition
{
	return CGPointToRelativePoint(position_);
}

-(void) setRelativePosition:(CGPoint)relativePosition
{
	self.position = CGRelativePointToPoint(relativePosition);
}

-(CGPoint) relativePositionInPixels
{
	return CGPointToRelativePointInPixels(positionInPixels_);
}

-(void) setRelativePositionInPixels:(CGPoint)relativePositionInPixels
{
	self.position = CGRelativePointToPointInPixels(relativePositionInPixels);
}


-(BOOL) containsPoint:(CGPoint)point
{
	CGRect bbox = CGRectMake(0, 0, contentSize_.width, contentSize_.height);
	CGPoint locationInNodeSpace = [self convertToNodeSpace:point];
	return CGRectContainsPoint(bbox, locationInNodeSpace);
}

#if KK_PLATFORM_IOS
-(BOOL) containsTouch:(UITouch*)touch
{
	CCDirector* director = [CCDirector sharedDirector];
	CGPoint locationGL = [director convertToGL:[touch locationInView:director.openGLView]];
	return [self containsPoint:locationGL];
}
#endif

+(id) nodeWithScene
{
	CCScene* scene = [CCScene node];
	[scene addChild:[self node]];
	return scene;
}

@end
