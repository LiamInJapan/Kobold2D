/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import <Foundation/Foundation.h>

/** @file kobold2d_version.h */

/** Returns the Kobold2D Version string. */
NSString* kobold2dVersion();

/** Returns the major Mac OS X version. For example, for Mac OS X 10.7.2 it will return 10. Returns 0 on iOS. */
int macOSVersionMajor();
/** Returns the minor Mac OS X version. For example, for Mac OS X 10.7.2 it will return 7. Returns 0 on iOS. */
int macOSVersionMinor();
/** Returns the bugfix Mac OS X version. For example, for Mac OS X 10.7.2 it will return 2. Returns 0 on iOS. */
int macOSVersionBugFix();
