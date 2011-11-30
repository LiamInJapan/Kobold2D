/*********************************************************************
 *	
 *	Particles
 *
 *	main.m
 *
 *	main entry point for the application
 *
 *	http://www.mobile-bros.com
 *
 *	Created by matt on 5/11/09.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) 
{	
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"GameDelegate");
    [pool release];
    return retVal;
}
