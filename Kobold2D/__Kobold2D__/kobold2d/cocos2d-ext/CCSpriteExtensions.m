/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "CCSpriteExtensions.h"
#import "CCAnimationExtensions.h"
#import "CCRemoveFromParentAction.h"

#import "FixCategoryBug.h"
FIX_CATEGORY_BUG(CCSprite)

@implementation CCSprite (KoboldExtensions)

-(void) privatePlayAnimWithFormat:(NSString*)format numFrames:(int)numFrames firstIndex:(int)firstIndex delay:(float)delay animateTag:(int)animateTag looped:(bool)looped remove:(bool)remove
{
	CCAnimation* anim = [CCAnimation animationWithName:format format:format numFrames:numFrames firstIndex:firstIndex delay:delay];
	CCAnimate* animate = [CCAnimate actionWithAnimation:anim];

	id action = nil;
	if (looped)
	{
		CCRepeatForever* repeat = [CCRepeatForever actionWithAction:animate];
		repeat.tag = animateTag;
		action = repeat;
	}
	else
	{
		animate.tag = animateTag;
		action = animate;
		
		if (remove)
		{
			CCRemoveFromParentAction* removeAction = [CCRemoveFromParentAction action];
			CCSequence* sequence = [CCSequence actions:animate, removeAction, nil];
			action = sequence;
		}
	}

	[self runAction:action];
}

-(void) playAnimWithFormat:(NSString*)format numFrames:(int)numFrames firstIndex:(int)firstIndex delay:(float)delay animateTag:(int)animateTag
{
	[self privatePlayAnimWithFormat:format numFrames:numFrames firstIndex:firstIndex delay:delay animateTag:animateTag looped:NO remove:NO];
}

-(void) playAnimLoopedWithFormat:(NSString*)format numFrames:(int)numFrames firstIndex:(int)firstIndex delay:(float)delay animateTag:(int)animateTag
{
	[self privatePlayAnimWithFormat:format numFrames:numFrames firstIndex:firstIndex delay:delay animateTag:animateTag looped:YES remove:NO];
}

-(void) playAnimAndRemoveWithFormat:(NSString*)format numFrames:(int)numFrames firstIndex:(int)firstIndex delay:(float)delay animateTag:(int)animateTag
{
	[self privatePlayAnimWithFormat:format numFrames:numFrames firstIndex:firstIndex delay:delay animateTag:animateTag looped:NO remove:YES];
}

+(id) spriteWithSpriteFrameNameOrFile:(NSString*)nameOrFile
{
	CCSpriteFrame* spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:nameOrFile];
	if (spriteFrame)
	{
		return [CCSprite spriteWithSpriteFrame:spriteFrame];
	}

	return [CCSprite spriteWithFile:nameOrFile];
}

@end
