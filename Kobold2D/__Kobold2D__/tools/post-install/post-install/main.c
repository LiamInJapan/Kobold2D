//
//  main.c
//  post-install
//
//  Created by Steffen Itterheim on 22.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#include <stdio.h>
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

void showAlertWithError(NSError* error);	// avoid warning
void showAlertWithError(NSError* error)
{
	NSLog(@"ERROR: %@", error);
	NSAlert* alert = [NSAlert alertWithError:error];
	[alert runModal];
}

int main (int argc, const char * argv[])
{
	NSError* error = nil;
	NSFileManager* fileManager = [NSFileManager defaultManager];
	
	NSLog(@"username = %@ - %@", NSUserName(), NSFullUserName());
	
	for (int i = 0; i < argc; i++)
	{
		NSString* arg = [NSString stringWithCString:argv[i] encoding:NSASCIIStringEncoding];
		NSLog(@"arg %i = '%@'", i, arg);
	}
	
	NSString* koboldPath = nil;
	if (argc >= 2)
	{
		koboldPath = [NSString stringWithCString:argv[1] encoding:NSASCIIStringEncoding];
	}

	if (koboldPath == nil)
	{
		NSLog(@"KoboldPath is nil");
		return -1;
	}
	else if ([fileManager fileExistsAtPath:koboldPath] == NO)
	{
		NSLog(@"Path does not exist! Path: '%@'", koboldPath);
		return -1;
	}
	
	NSString* koboldLibProject = nil;
	NSString* schemeManageFile = nil;
	koboldLibProject = [NSString stringWithFormat:@"%@/__Kobold2D__/Kobold2D-Libraries.xcodeproj", koboldPath];
	schemeManageFile = [NSString stringWithFormat:@"%@/__Kobold2D__/templates/workspace/xcschememanagement.plist", koboldPath];
	
	if ([fileManager fileExistsAtPath:koboldLibProject])
	{
		NSString* schemesPath = [NSString stringWithFormat:@"%@/xcuserdata/%@.xcuserdatad/xcschemes", koboldLibProject, NSUserName()];
		if ([fileManager fileExistsAtPath:schemesPath] == NO)
		{
			if ([fileManager createDirectoryAtPath:schemesPath
					   withIntermediateDirectories:YES
										attributes:nil
											 error:&error] == NO)
				showAlertWithError(error);
		}
		
		NSString* schemeManageTargetFile = [NSString stringWithFormat:@"%@/xcschememanagement.plist", schemesPath];
		if ([fileManager fileExistsAtPath:schemeManageTargetFile])
		{
			if ([fileManager removeItemAtPath:schemeManageTargetFile error:&error] == NO)
				showAlertWithError(error);
		}
		
		if ([fileManager copyItemAtPath:schemeManageFile toPath:schemeManageTargetFile error:&error] == NO)
			 showAlertWithError(error);
	}
	
    return 0;
}
