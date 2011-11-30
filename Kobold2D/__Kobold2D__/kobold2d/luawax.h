/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */


#import <Availability.h>

// Wax (and Lua) headers
// if compiled as (Objective) C++ code the includes must be inside an extern "C" declaration
#ifdef __cplusplus
extern "C" {
#endif // __cplusplus
	
#import "lauxlib.h"
#import "lobject.h"
#import "lualib.h"
	
#ifdef __cplusplus
}
#endif // __cplusplus

#import "wax.h"

#ifdef KK_PLATFORM_IOS
#import "wax_http.h"
#import "wax_json.h"
#import "wax_xml.h"
#import "wax_CGContext.h"
#import "wax_CGTransform.h"
#endif
