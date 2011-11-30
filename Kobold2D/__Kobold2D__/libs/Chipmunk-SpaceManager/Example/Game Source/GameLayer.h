//
//  GameLayer.h
//  Example For Example
//
//  Created by Rob Blackwood on 5/11/09.
//

#import "SpaceManagerCocos2d.h"

#pragma mark GameLayer Class
@interface GameLayer : CCLayer
{
	SpaceManagerCocos2d *smgr;
	cpCCSprite *ballSprite;
	CCLabelTTF *label;
}

@property (readonly) CCLabelTTF *label;

@end

