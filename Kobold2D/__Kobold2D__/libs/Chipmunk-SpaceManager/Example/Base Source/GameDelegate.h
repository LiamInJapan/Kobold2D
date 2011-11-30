/*********************************************************************
 *	
 *	SpaceManager
 *
 *	GameDelegate.h
 *
 *	game delegate for initializing sequence
 *
 *	http://www.mobile-bros.com
 *
 *	Created by matt on 5/11/09.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import <UIKit/UIKit.h>
#import "cocos2d.h"

#pragma mark GameDelegate Class
@interface GameDelegate : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow *window;
}

#pragma mark GameDelegate Methods
// go here!

@end
