/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "kobold2d.h"

typedef enum 
{
	kAccelerometerValuesRaw,
	kAccelerometerValuesSmoothed,
	kAccelerometerValuesInstantaneous,
	kGyroscopeRotationRate,
	kDeviceMotion,
	
	kInputTypes_End,
} InputTypes;

@interface HelloWorldLayer : CCLayer
{
	CCSprite* ship;
	CCParticleSystem* particleFX;
	InputTypes inputType;
}

@end
