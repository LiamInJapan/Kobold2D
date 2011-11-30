/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Copyright (c) 2011 Simon Jewell (http://blog.sygem.com)
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

/*
 * iAd code is originally based on this tutorial by @AzamSharp:
 * http://highoncoding.com/Articles/751_Implementing_iAd_on_Cocos2d_Application.aspx
 */

#import "KKAdBanner.h"
#import "KKAppDelegate.h"
#import "KKRootViewController.h"
#import "KKStartupConfig.h"

#ifdef KK_PLATFORM_IOS

@interface KKAdBanner (PrivateMethods)
-(void) unloadBanner;
-(CGPoint) getBannerPosition;
-(void)fadeAdIn:(UIView*)view;
-(void)fadeAdOut:(UIView*)view;

#ifdef KK_ADMOB_SUPPORT_ENABLED
-(void) performAdMobRequest;
-(void) scheduleAdMobRequestWithInterval:(int)interval;
#endif // KK_ADMOB_SUPPORT_ENABLED
@end


@implementation KKAdBanner

@synthesize iAdBannerView;

#ifdef KK_ADMOB_SUPPORT_ENABLED
@synthesize adMobBannerView;
#endif

static NSString* kiAdClassName = @"ADBannerView";
-(BOOL) iAdSupported
{
	return (NSClassFromString(kiAdClassName) != nil);
}

-(NSString*) landscapeContentSizeIdentifier
{
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.2)
		return ADBannerContentSizeIdentifierLandscape;
	else
		return ADBannerContentSizeIdentifier480x32;
}

-(NSString*) portraitContentSizeIdentifier
{
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.2)
		return ADBannerContentSizeIdentifierPortrait;
	else
		return ADBannerContentSizeIdentifier320x50;
}


-(void) loadBanner
{
	KKAppDelegate* appDelegate = (KKAppDelegate*)[UIApplication sharedApplication].delegate;
	KKStartupConfig* config = appDelegate.config;
	NSArray* providers = [config.adProviders componentsSeparatedByString:@","];
	
	for (NSString* provider in providers) 
	{
		provider = [provider stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		provider = [provider uppercaseString];
		
		if ([provider isEqualToString:@"IAD"])
		{
			// iAd: only if supported, and only if AdMob isn't already initialized (AdMob takes precedence because it's available on all devices)
			isIAdEnabled = (isAdMobEnabled == NO && [self iAdSupported]);
		}
		else if ([provider isEqualToString:@"ADMOB"])
		{
			// AdMob: only if iAd hasn't been initialized yet (it's either unavailable, or user said AdMob should take precedence)
			isAdMobEnabled = (isIAdEnabled == NO);
		}
	}
	
	ccDeviceOrientation orientation = [[CCDirector sharedDirector] deviceOrientation];
	if (orientation == CCDeviceOrientationLandscapeLeft || orientation == CCDeviceOrientationLandscapeRight)
	{
		[self loadBanner:UIInterfaceOrientationLandscapeLeft];
	}
	else
	{
		[self loadBanner:UIInterfaceOrientationPortrait];
	}
}

-(void) loadBanner:(UIInterfaceOrientation)interfaceOrientation
{
	KKAppDelegate* appDelegate = (KKAppDelegate*)[UIApplication sharedApplication].delegate;
	KKStartupConfig* config = appDelegate.config;
	bannerOnBottom = config.placeBannerOnBottom;

	// check if iAD is even supported
	if (config.enableAdBanner)
	{
		[self unloadBanner];
		
		if (isIAdEnabled)
		{
			iAdBannerView = [[ADBannerView alloc] initWithFrame:CGRectZero];
			iAdBannerView.hidden = YES;

			// If requested, restrict loading of banners to either portrait or landscape.
			// If your App only supports one orientation you should do so to save resources.
			if (config.loadOnlyPortraitBanners == NO && config.loadOnlyLandscapeBanners == YES)
			{
				iAdBannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:[self landscapeContentSizeIdentifier], nil];
			}
			else if (config.loadOnlyPortraitBanners == YES && config.loadOnlyLandscapeBanners == NO)
			{
				iAdBannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:[self portraitContentSizeIdentifier], nil];
			}
			else
			{
				// support both orientations
				iAdBannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:[self portraitContentSizeIdentifier], [self landscapeContentSizeIdentifier], nil];
			}
			
			// Set the default banner size according to the current device orientation
			if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
			{
                iAdBannerView.currentContentSizeIdentifier = [self landscapeContentSizeIdentifier];
			}
			else
			{
                iAdBannerView.currentContentSizeIdentifier = [self portraitContentSizeIdentifier];
			}
			
			// self provides a default implementation, you can provide your own by changing the delegate later
			[iAdBannerView setDelegate:self];
			
			[appDelegate.rootViewController.view addSubview:self.iAdBannerView];
		}
#ifdef KK_ADMOB_SUPPORT_ENABLED
		else if (isAdMobEnabled)
		{
			adMobBannerView = [[GADBannerView alloc] init];
			adMobBannerView.hidden = YES;
			
			[adMobBannerView setFrame:CGRectMake(0, 0, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
			[adMobBannerView setDelegate:self];
			adMobBannerView.adUnitID = config.adMobPublisherID;
			
			adMobBannerView.rootViewController = appDelegate.rootViewController;
			[appDelegate.rootViewController.view addSubview:adMobBannerView];
			
			int delay = 0;
			if (isVeryFirstAd)
			{
				isVeryFirstAd = NO;
				delay = config.adMobFirstAdDelay;
			}
			
			[self scheduleAdMobRequestWithInterval:delay];
		}
#endif // KK_ADMOB_SUPPORT_ENABLED
	}
}

-(void) unloadBanner
{
	if (isIAdEnabled)
	{
		[iAdBannerView setDelegate:nil];
		[iAdBannerView removeFromSuperview];
		[iAdBannerView release];
		iAdBannerView = nil;
	}
#ifdef KK_ADMOB_SUPPORT_ENABLED
	else if (isAdMobEnabled)
	{
		[adMobBannerView setDelegate:nil];
		[adMobBannerView removeFromSuperview];
		[adMobBannerView release];
		adMobBannerView = nil;
	}
#endif // KK_ADMOB_SUPPORT_ENABLED
}

-(CGPoint) getBannerPosition
{
	float bannerHeight = 50;

	if (isIAdEnabled)
	{
		BOOL isIPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
		
		if (iAdBannerView.currentContentSizeIdentifier == [self landscapeContentSizeIdentifier])
		{
			bannerHeight = isIPad ? 66 : 32;
		}
		else
		{
			bannerHeight = isIPad ? 66 : 50;
		}
	}
	
	CCDirector* director = [CCDirector sharedDirector];
	CGSize size = [director.openGLView bounds].size;
	if (bannerOnBottom)
	{
		bannerHeight = size.height - bannerHeight * 0.5f;
	}
	else
	{
		bannerHeight = bannerHeight * 0.5f;
	}
	
	return CGPointMake(size.width * 0.5f, bannerHeight);
}


#pragma mark iAd related

-(void) bannerViewDidLoadAd:(ADBannerView *)banner
{
	if (isAdShowing == NO)
	{
        [self fadeAdIn:iAdBannerView];
    }
}

-(void) bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	CCLOG(@"%@ error: %@", NSStringFromSelector(_cmd), error);
	
	if (isAdShowing == YES)
	{
        [self fadeAdOut:iAdBannerView];
    }
}

-(BOOL) bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
	[[CCDirector sharedDirector] stopAnimation];
	return YES;
}

-(void) bannerViewActionDidFinish:(ADBannerView *)banner
{
	[[CCDirector sharedDirector] startAnimation];
}


#pragma mark AdMob related

#ifdef KK_ADMOB_SUPPORT_ENABLED

-(void) adViewDidReceiveAd:(GADBannerView*)bannerView 
{
    if (isAdShowing == NO)
	{
        [self fadeAdIn:adMobBannerView];
    }

	// schedule next ad request
	KKAppDelegate* appDelegate = (KKAppDelegate*)[UIApplication sharedApplication].delegate;
	[self scheduleAdMobRequestWithInterval:appDelegate.config.adMobRefreshRate];
}

-(void) adView:(GADBannerView*)bannerView didFailToReceiveAdWithError:(GADRequestError*)error
{
	CCLOG(@"adView:didFailToReceiveAdWithError:%@", [error localizedDescription]);
    
	if (isAdShowing)
	{
        [self fadeAdOut:adMobBannerView];
    }

	// schedule next ad request
	KKAppDelegate* appDelegate = (KKAppDelegate*)[UIApplication sharedApplication].delegate;
	[self scheduleAdMobRequestWithInterval:appDelegate.config.adMobRefreshRate];
}

-(void) adViewWillPresentScreen:(GADBannerView*)adView 
{
	[self fadeAdOut:adMobBannerView];
    [[CCDirector sharedDirector] stopAnimation];
}

-(void) adViewDidDismissScreen:(GADBannerView*)adView 
{
    [[CCDirector sharedDirector] startAnimation];

	// schedule next ad request
	KKAppDelegate* appDelegate = (KKAppDelegate*)[UIApplication sharedApplication].delegate;
	[self scheduleAdMobRequestWithInterval:appDelegate.config.adMobRefreshRate];
}

-(GADRequest*) createAdMobRequest 
{
    GADRequest* request = [GADRequest request];
    
	KKAppDelegate* appDelegate = (KKAppDelegate*)[UIApplication sharedApplication].delegate;
	if (appDelegate.config.adMobTestMode)
	{
		request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, [[UIDevice currentDevice] uniqueIdentifier], nil];
	}
	
    return request;
}

-(void) performAdMobRequest
{
    [adMobBannerView loadRequest:[self createAdMobRequest]];
}

-(void) scheduleAdMobRequestWithInterval:(int)interval
{
	if (adMobTimer)
	{
		[adMobTimer invalidate];
		[adMobTimer release];
		adMobTimer = nil;
	}

	if (interval == 0)
	{
		[self performAdMobRequest];
	}
	else
	{
		adMobTimer = [[NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(performAdMobRequest) userInfo:nil repeats:NO] retain];
	}
}

#endif // KK_ADMOB_SUPPORT_ENABLED

# pragma mark - Fade Animations

-(void) fadeAdIn:(UIView*)view
{
	view.hidden = NO;
	float offsetY = view.frame.size.height * (bannerOnBottom ? 1 : -1);

	CGPoint pos = [self getBannerPosition];
	view.center = CGPointMake(pos.x, pos.y + offsetY);

	[UIView beginAnimations:@"AdIn" context:nil];
	[UIView setAnimationDuration:1.0];
	view.center = pos;
	[UIView commitAnimations];
	
	isAdShowing = YES;
}

-(void) fadeAdOutStopped:(NSString*)animID finished:(NSNumber*)finished context:(void*)context
{
	if (isIAdEnabled)
	{
		iAdBannerView.hidden = YES;
	}
#ifdef KK_ADMOB_SUPPORT_ENABLED
	else if (isAdMobEnabled)
	{
		adMobBannerView.hidden = YES;
	}
#endif
}

-(void) fadeAdOut:(UIView*)view
{
	/*
	float offsetY = view.frame.size.height * (bannerOnBottom ? 1 : -1);
	
	CGPoint pos = [self getBannerPosition];
	view.center = pos;
	
	[UIView beginAnimations:@"AdIn" context:nil];
	[UIView setAnimationDidStopSelector:@selector(fadeAdOutStopped:finished:context:)];
	[UIView setAnimationDuration:1.0];
	view.center = CGPointMake(pos.x, pos.y + offsetY);
	[UIView commitAnimations];
	*/

	isAdShowing = NO;
	view.hidden = YES;
}


#pragma mark Orientation change

-(void) didRotate:(NSNotification *)notification
{
	if (isAdShowing)
	{
		if (isIAdEnabled)
		{
			//[self fadeAdOut:iAdBannerView];
			iAdBannerView.hidden = YES;
			isAdShowing = NO;
		}
#ifdef KK_ADMOB_SUPPORT_ENABLED
		else if (isAdMobEnabled)
		{
			//[self fadeAdOut:adMobBannerView];
			adMobBannerView.hidden = YES;
			isAdShowing = NO;
		}
#endif
	}
} 


#pragma mark Singleton stuff

static KKAdBanner *instanceOfAdBanner;

+(id) alloc
{
	@synchronized(self)	
	{
		NSAssert(instanceOfAdBanner == nil, @"Attempted to allocate a second instance of the singleton: KKAdBanner");
		instanceOfAdBanner = [[super alloc] retain];
		return instanceOfAdBanner;
	}
	
	// to avoid compiler warning
	return nil;
}

+(KKAdBanner*) sharedAdBanner
{
	@synchronized(self)
	{
		if (instanceOfAdBanner == nil)
		{
			instanceOfAdBanner = [[KKAdBanner alloc] init];
		}
		
		return instanceOfAdBanner;
	}
	
	// to avoid compiler warning
	return nil;
}

-(id) init
{
	if ((self = [super init]))
	{
		isVeryFirstAd = YES;
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(didRotate:)
													 name:@"UIDeviceOrientationDidChangeNotification" 
												   object:nil];
	}
	return self;
}

-(void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[self unloadBanner];
	instanceOfAdBanner = nil;
	
	[super dealloc];
}

@end

#endif