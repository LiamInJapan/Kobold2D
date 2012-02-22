/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "CCAlphaTestSpriteBatchNode.h"


@interface CCAlphaTestSpriteBatchNode (Private)
@end

@implementation CCAlphaTestSpriteBatchNode


-(void) draw
{
	glEnable(GL_ALPHA_TEST);
	glAlphaFunc(GL_GREATER, 0.0f);
	
	[super draw];
	
	glDisable(GL_ALPHA_TEST);
}


@end
