//
//  Retina.h
//  Example
//
//  Created by Robert Blackwood on 11/1/10.
//  Copyright Mobile Bros 2010. All rights reserved.
//

#import "SpaceManagerCocos2d.h"

@interface Retina : CCLayer
{
	SpaceManagerCocos2d *smgr;
	CGPoint _lastPt;
}

-(void) step: (ccTime) dt;
-(BOOL) drawTerrainAt:(CGPoint)pt;

@end
