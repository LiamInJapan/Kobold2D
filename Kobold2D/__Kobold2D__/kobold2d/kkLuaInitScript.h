/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */


#import "cocos2d-extensions.h"

#ifdef KK_PLATFORM_IOS
#import <Foundation/Foundation.h>
#else
#import <Cocoa/Cocoa.h>
#endif

/** this Lua script can't be in a resource file because libraries can't add resources */
static NSString* const kLuaInitScript = @"\
YES = 1; NO = 0; TRUE = 1; FALSE = 0; \
\
DirectorType = { \
NSTimer = 0, \
MainLoop = 1, \
ThreadMainLoop = 2, \
DisplayLink = 3, \
} \
\
TexturePixelFormat = { \
Automatic = 0, \
RGBA8888 = 1, \
RGB565 = 2, \
A8 = 3, \
I8 = 4, \
AI88 = 5, \
RGBA4444 = 6, \
RGB5A1 = 7, \
PVRTC4 = 8, \
PVRTC2 = 9, \
} \
\
GLViewColorFormat = { \
RGBA8888 = 8888, \
RGB565 = 565, \
} \
\
GLViewDepthFormat = { \
DepthNone = 0, \
Depth16Bit = 33189, --[[ GL_DEPTH_COMPONENT16_OES 0x81A5 --]] \
Depth24Bit = 33190, --[[ GL_DEPTH_COMPONENT24_OES 0x81A6 --]] \
} \
\
DeviceOrientation = { \
Portrait = 1, \
PortraitUpsideDown = 2, \
LandscapeLeft = 3, \
LandscapeRight = 4, \
} \
\
Autorotation = { \
None = 0, \
CCDirector = 1, \
UIViewController = 2, \
} \
\
StructType = { \
Point = 1, \
Size = 2, \
Rect = 3, \
} \
\
function PointMake(x, y) \
 return {x, y, structType = StructType.Point} \
end \
function MakePoint(x, y) return PointMake(x, y) end \
\
function SizeMake(width, height) \
 return {width, height, structType = StructType.Size} \
end \
function MakeSize(width, height) return SizeMake(width, height) end \
\
function RectMake(x, y, width, height) \
 return {x, y, width, height, structType = StructType.Rect} \
end \
function MakeRect(x, y, width, height) return RectMake(x, y, width, height) end \
";

#ifdef KK_PLATFORM_IOS
static NSString* const kLuaInitScriptPlatformSpecific = @"\
";
#else
static NSString* const kLuaInitScriptPlatformSpecific = @"\
local old_dofile = dofile \
dofile = function(file) local f = 'Contents/Resources/' .. tostring(file); return old_dofile(f); end \
";
#endif

static NSString* const kLuaInitScriptForWax = @"\
setmetatable(_G, { \
__index = function(self, key) \
local class = wax.class[key] \
if class then self[key] = class end \
 \
if not class and key:match('^[A-Z][A-Z][A-Z]') then \
 print('WARNING: No object named \"' .. key .. '\" found.') \
end \
\
return class \
end \
}) \
\
function waxClass(options) \
local className = options[1] \
local superclassName = options[2] \
local class = wax.class(className, superclassName) \
 \
if options.protocols then \
if type(options.protocols) ~= 'table' then options.protocols = {options.protocols} end \
if #options.protocols == 0 then error(\"empty protocol table for class: \" .. className .. \" and\") end \
	end \
	 \
	for i, protocol in ipairs(options.protocols or {}) do \
		wax.class.addProtocols(class, protocol) \
		end  \
		 \
		local _M = setmetatable({}, { \
			__newindex = function(self, key, value)  \
			class[key] = value \
			end, \
			 \
			__index = function(self, key)  \
			return class[key] or _G[key] \
			end, \
			 \
		} \
	) \
\
		_G[className] = class \
		package.loaded[className] = class \
		setfenv(2, _M) \
		 \
		return class \
		end \
 \
wax.struct.create(\"CGSize\", \"ff\", \"width\", \"height\") \
wax.struct.create(\"CGPoint\", \"ff\", \"x\", \"y\") \
wax.struct.create(\"UIEdgeInsets\", \"ffff\", \"top\", \"left\", \"bottom\", \"right\") \
wax.struct.create(\"CGRect\", \"ffff\", \"x\", \"y\", \"width\", \"height\") \
 \
wax.struct.create(\"NSRange\", \"II\", \"location\", \"length\") \
 \
wax.struct.create(\"CLLocationCoordinate2D\", \"dd\", \"latitude\", \"longitude\") \
wax.struct.create(\"MKCoordinateSpan\", \"dd\", \"latitudeDelta\", \"longitudeDelta\") \
wax.struct.create(\"MKCoordinateRegion\", \"dddd\", \"latitude\", \"longitude\", \"latitudeDelta\", \"longitudeDelta\") \
wax.struct.create(\"CGAffineTransform\", \"ffffff\", \"a\", \"b\", \"c\", \"d\", \"tx\", \"ty\") \
";
