/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2012 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "Cocos3DDummyClass.h"


// This class only exists to be able to be able to link the cocos3d static library.
// Currently cocos3d does not build any of the cocos3d code because it is incompatible with cocos2d 2.x.
// But since a static library is required to contain at least some code, this dummy class was added.
// I could have removed the cocos3d library entirely, but decided against it because it'll make it easier
// to add cocos3d back in once it is compatible with cocos2d 2.x.

@implementation Cocos3DDummyClass

@end
