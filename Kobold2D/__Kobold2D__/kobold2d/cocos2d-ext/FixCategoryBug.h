/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

// FIX_CATEGORY_BUG fixes the "undeclared selector sent to instance" bug that can occur in static libraries containing some files with only categories.
// The solution to -all_load can often cause duplicate symbols and generally increases the App size.
// The alternative using -force_load causes the targeted library to not be debuggable (breakpoints don't work, no source code is shown).
// The ultimate fix is to create a dummy class in each implementation file defining only an Objective-C category.
// This fix was proposed by Jamie Briant here: http://blog.binaryfinery.com/universal-static-library-problem-in-iphone-sd

#ifndef FIX_CATEGORY_BUG
#define FIX_CATEGORY_BUG(name) @interface FIXCATEGORYBUG ## name; @end @implementation FIXCATEGORYBUG ## name; @end
#endif
