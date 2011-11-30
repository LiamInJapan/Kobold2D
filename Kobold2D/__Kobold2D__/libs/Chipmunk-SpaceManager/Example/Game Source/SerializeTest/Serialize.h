//
//  Serialize.h
//  Example For Example
//
//  Created by Rob Blackwood on 5/30/10.
//

#import "SpaceManagerCocos2d.h"

#pragma mark Serialize Class
@interface Serialize : CCLayer<SpaceManagerSerializeDelegate>
{
	SpaceManagerCocos2d *smgr;
	NSMutableArray *balls;
}

-(BOOL) aboutToReadShape:(cpShape*)shape shapeId:(long)id;

@end

