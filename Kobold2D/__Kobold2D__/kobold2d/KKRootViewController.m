/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

/*
 * License for original source:
 *
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "KKRootViewController.h"
#import "KKAdBanner.h"

#ifdef KK_PLATFORM_IOS

@interface KKRootViewController (PrivateMethods)
@end

@implementation KKRootViewController

@synthesize autorotationType;
@synthesize shouldAutorotateToLandscapeOrientations, shouldAutorotateToPortraitOrientations;

-(void) loadView
{
	self.view = [CCDirector sharedDirector].openGLView;
}

-(void) viewDidLoad
{
	[super viewDidLoad];
	[[KKAdBanner sharedAdBanner] loadBanner];
}

-(void) viewDidUnload
{
	[[KKAdBanner sharedAdBanner] unloadBanner];
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	NSAssert1(autorotationType >= 0 && autorotationType <= KKAutorotationUIViewController, @"autorotationType %i is undefined!", autorotationType);

	// get the default (rotate to portrait only) from the super implementation
	BOOL shouldRotate = [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];

	if (autorotationType == KKAutorotationNone)
	{
		// do nothing, no autorotation
	}
	else if (autorotationType == KKAutorotationCCDirector)
	{
		if (shouldAutorotateToLandscapeOrientations && interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
		{
			[[CCDirector sharedDirector] setDeviceOrientation: kCCDeviceOrientationLandscapeRight];
		}
		else if (shouldAutorotateToLandscapeOrientations && interfaceOrientation == UIInterfaceOrientationLandscapeRight) 
		{
			[[CCDirector sharedDirector] setDeviceOrientation: kCCDeviceOrientationLandscapeLeft];
		}
		else if (shouldAutorotateToPortraitOrientations && interfaceOrientation == UIInterfaceOrientationPortrait)
		{
			[[CCDirector sharedDirector] setDeviceOrientation: kCCDeviceOrientationPortrait];
		}
		else if (shouldAutorotateToPortraitOrientations && interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
		{
			[[CCDirector sharedDirector] setDeviceOrientation: kCCDeviceOrientationPortraitUpsideDown];
		}
	}
	else if (autorotationType == KKAutorotationUIViewController)
	{
		shouldRotate = ((UIInterfaceOrientationIsLandscape(interfaceOrientation) && shouldAutorotateToLandscapeOrientations) ||
						(UIInterfaceOrientationIsPortrait(interfaceOrientation) && shouldAutorotateToPortraitOrientations));
		
		// save fallback in case user sets both orientations to NO but specifies a UIViewController to be responsible for autorotation
		if (UIInterfaceOrientationIsPortrait(interfaceOrientation) && 
			shouldAutorotateToLandscapeOrientations == NO && 
			shouldAutorotateToPortraitOrientations == NO)
		{
			shouldRotate = YES;
		}
	}

	return shouldRotate;
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (autorotationType == KKAutorotationUIViewController)
	{
		//
		// Assuming that the main window has the size of the screen
		// BUG: This won't work if the EAGLView is not fullscreen
		///
		CGRect screenRect = [[UIScreen mainScreen] bounds];
		CGRect rect = CGRectZero;
		
		if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
		{
			rect = screenRect;
		}
		else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
		{
			rect.size = CGSizeMake(screenRect.size.height, screenRect.size.width);
		}
		
		CCDirector* director = [CCDirector sharedDirector];
		EAGLView* glView = [director openGLView];

		float contentScaleFactor = [director contentScaleFactor];
		rect.size.width *= contentScaleFactor;
		rect.size.height *= contentScaleFactor;
		
		glView.frame = rect;
		
		[[KKAdBanner sharedAdBanner] loadBanner:toInterfaceOrientation];
	}
}

@end

#endif
