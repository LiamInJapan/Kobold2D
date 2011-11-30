/*
 * CCCCVideoPlayer
 *
 * cocos2d-extensions
 * https://github.com/cocos2d/cocos2d-iphone-extensions
 *
 * Copyright (c) 2010-2011 Stepan Generalov
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
 *
 */

#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED

#import "MyMovieView.h"
#import "CCVideoPlayer.h"


@implementation MyMovieView

- (void)rightMouseDown:(NSEvent *)theEvent
{
	[CCVideoPlayer userCancelPlaying];
}

- (void)otherMouseDown:(NSEvent *)theEvent
{
	[CCVideoPlayer userCancelPlaying];
}

- (void)scrollWheel:(NSEvent *)theEvent
{
}

- (void) mouseDown:(NSEvent *)theEvent
{
	[CCVideoPlayer userCancelPlaying];
}

- (void) keyDown:(NSEvent *)theEvent
{
	if ( ![theEvent isARepeat] )
		[CCVideoPlayer userCancelPlaying];
}

-(BOOL) ccKeyDown:(NSEvent*)event
{
	if ( ![event isARepeat] && [CCVideoPlayer isPlaying] )
	{
		[CCVideoPlayer userCancelPlaying];
		return YES;
	}
	
	return NO;
}

- (void)viewDidMoveToWindow
{	
	NSWindow *window = [self window];
	if ( window )
	{
		[[self window] makeFirstResponder: self];
	}
}

-(BOOL) becomeFirstResponder
{
	return YES;
}

-(BOOL) acceptsFirstResponder
{
	return YES;
}

-(BOOL) resignFirstResponder
{
	return YES;
}

@end

#endif
