/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */


/**! kkUserConfig.h
 This file contains Kobold2D compile time settings the user might want to enable or disable.
 For example you can disable support for AdMob if you don't use it, to save about 900 KB 
 of the app's size (archive build). */


#ifndef Kobold2D_Libraries_kkUserConfig_h
#define Kobold2D_Libraries_kkUserConfig_h

/** @def KK_ADMOB_SUPPORT_ENABLED
 If this macro is defined, then Google AdMob Ad Banners are supported.
 App will then be about 900 KB larger (archive build) with AdMob ad support enabled.
 */
#define KK_ADMOB_SUPPORT_ENABLED 1

#endif
