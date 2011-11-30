/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

/** @file KKRootViewController.h */

/** Autorotation modes */
typedef enum
{
	KKAutorotationNone, /**< do not autorotate at all */
	KKAutorotationCCDirector,/**< autorotate the OpenGL view (will not rotate UIKit objects) */
	KKAutorotationUIViewController,/**< autorotate using the view controller (will also properly rotate UIKit objects) */
} KKAutorotationType;


#import "cocos2d.h"
#import "cocos2d-extensions.h"

#ifdef KK_PLATFORM_IOS

#import <UIKit/UIKit.h>

/** Kobold2D root view controller implementation. If you need more than the default functionality, 
 you should prefer to subclass KKRootViewController rather than writing your own implementation.
 Remember to always call [super (overridden method)] in your implementation to allow KKRootViewController
 to do its job. */
@interface KKRootViewController : UIViewController
{
@protected
	KKAutorotationType autorotationType;
	bool shouldAutorotateToLandscapeOrientations, shouldAutorotateToPortraitOrientations;
}

@property (nonatomic) KKAutorotationType autorotationType;
@property (nonatomic) bool shouldAutorotateToLandscapeOrientations, shouldAutorotateToPortraitOrientations;

@end

#endif
