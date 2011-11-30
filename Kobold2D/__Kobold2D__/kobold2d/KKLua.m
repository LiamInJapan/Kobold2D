/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "KKLua.h"
#import "wax_helpers.h"

@interface KKLua (PrivateMethods)
+(void) internalLoadSubTableWithKey:(NSString*)key luaState:(lua_State*)state dictionary:(NSMutableDictionary*)dict;
+(NSMutableDictionary*) internalRecursivelyLoadTable:(lua_State*)state index:(int)index;

typedef enum
{
	kStructType_INVALID = 0,
	kStructTypePoint,
	kStructTypeSize,
	kStructTypeRect,
} EStructTypes;
@end

@implementation KKLua

+(void) logLuaError
{
	NSLog(@"Lua error: %s", lua_tostring(wax_currentLuaState(), -1));
}

+(id) returnValue
{
	id retval = nil;

	/*
	if (lua_istable(wax_currentLuaState(), 1))
	{
		id* objc = wax_copyToObjc(wax_currentLuaState(), @encode(id), 1, nil);
		retval = *objc;
		lua_pop(wax_currentLuaState(), 1);
		wax_printStack(wax_currentLuaState());
	}
	 */
	
	return retval;
}

+(id) doFile:(NSString*)file
{
	NSAssert1(file != nil, @"%@: file is nil", NSStringFromSelector(_cmd));
	
#ifndef KK_PLATFORM_IOS
	file = [NSString stringWithFormat:@"Contents/Resources/%@", file];
#endif
	const char* cfile = [file cStringUsingEncoding:NSUTF8StringEncoding];
	NSAssert1(cfile != nil, @"%@: C file is nil, possible encoding failure", NSStringFromSelector(_cmd));
	
	bool success = (luaL_dofile(wax_currentLuaState(), cfile) == 0);
	if (success == NO)
	{
		[KKLua logLuaError];
	}
	
	return [self returnValue];
}

+(id) doFile:(NSString *)file prefixCode:(NSString*)prefix suffixCode:(NSString*)suffix
{
	NSAssert1(file != nil, @"%@: file is nil", NSStringFromSelector(_cmd));

#ifndef KK_PLATFORM_IOS
	file = [NSString stringWithFormat:@"Contents/Resources/%@", file];
#endif

	if (prefix == nil)
	{
		prefix = @"";
	}
	if (suffix == nil)
	{
		suffix = @"";
	}
	
	NSString* script = [NSString stringWithFormat:@"%@;%@\n%@", prefix, [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil], suffix];
	[KKLua doString:script];

	return [self returnValue];
}

+(id) doString:(NSString*)string
{
	NSAssert1(string != nil, @"%@: string is nil", NSStringFromSelector(_cmd));

	const char* cstring = [string cStringUsingEncoding:NSUTF8StringEncoding];
	NSAssert1(cstring != nil, @"%@: C string is nil, possible encoding failure", NSStringFromSelector(_cmd));

	//LOG_EXPR(cstring);
	bool success = (luaL_dostring(wax_currentLuaState(), cstring) == 0);
	if (success == NO)
	{
		[KKLua logLuaError];
	}
	
	return [self returnValue];
}

+(float) getFloatFromTable:(lua_State*)state index:(int)index
{
	lua_pushinteger(state, index);
	lua_gettable(state, -2);
	float f = (float)lua_tonumber(state, -1);
	lua_pop(state, 1);
	return f;
}

+(void) internalLoadSubTableWithKey:(NSString*)key luaState:(lua_State*)state dictionary:(NSMutableDictionary*)dict
{
	// check if the table contains a "magic marker"
	lua_getfield(state, -1, "structType");
	int structType = (int)lua_tointeger(state, -1);
	lua_pop(state, 1);

	// create the appropriate NSValue type
	switch (structType)
	{
		case kStructTypePoint:
		{
			float x = [KKLua getFloatFromTable:state index:1];
			float y = [KKLua getFloatFromTable:state index:2];
#ifdef KK_PLATFORM_IOS
			[dict setObject:[NSValue valueWithCGPoint:CGPointMake(x, y)] forKey:key];
#else
			[dict setObject:[NSValue valueWithPoint:NSMakePoint(x, y)] forKey:key];
#endif
			break;
		}
		case kStructTypeSize:
		{
			float width = [KKLua getFloatFromTable:state index:1];
			float height = [KKLua getFloatFromTable:state index:2];
#ifdef KK_PLATFORM_IOS
			[dict setObject:[NSValue valueWithCGSize:CGSizeMake(width, height)] forKey:key];
#else
			[dict setObject:[NSValue valueWithSize:NSMakeSize(width, height)] forKey:key];
#endif
			break;
		}
		case kStructTypeRect:
		{
			float x = [KKLua getFloatFromTable:state index:1];
			float y = [KKLua getFloatFromTable:state index:2];
			float width = [KKLua getFloatFromTable:state index:3];
			float height = [KKLua getFloatFromTable:state index:4];
#ifdef KK_PLATFORM_IOS
			[dict setObject:[NSValue valueWithCGRect:CGRectMake(x, y, width, height)] forKey:key];
#else
			[dict setObject:[NSValue valueWithRect:NSMakeRect(x, y, width, height)] forKey:key];
#endif
			break;
		}
			
		default:
		case kStructType_INVALID:
		{
			// assume it's a user table, recurse into it
			NSMutableDictionary* tableDict = [KKLua internalRecursivelyLoadTable:state index:-1];
			if (tableDict != nil)
			{
				[dict setObject:tableDict forKey:key];
			}
			break;
		}
	}
}

+(NSMutableDictionary*) internalRecursivelyLoadTable:(lua_State*)state index:(int)index
{
	NSString* error = nil;
	NSMutableDictionary* dict = nil;

	if (lua_istable(state, index))
	{
		dict = [NSMutableDictionary dictionaryWithCapacity:10];
		
		lua_pushnil(state);  // first key
		while (lua_next(state, -2) != 0)
		{
			/*
			CCLOG(@"%@ - %@\n",
				  [NSString stringWithCString:lua_typename(state, lua_type(state, -2)) encoding:NSUTF8StringEncoding],
				  [NSString stringWithCString:lua_typename(state, lua_type(state, -1)) encoding:NSUTF8StringEncoding]);
			 */
			
			NSString* key = nil;
			if (lua_isnumber(state, -2))
			{
				int number = (int)lua_tonumber(state, -2);
				key = [NSString stringWithFormat:@"%i", number];
			}
			else if (lua_isstring(state, -2))
			{
				key = [NSString stringWithCString:lua_tostring(state, -2) encoding:NSUTF8StringEncoding];
			}
			else
			{
				error = @"key in table is neither string nor number!";
				break;
			}
			
			int luaTypeOfValue = lua_type(state, -1);
			switch (luaTypeOfValue)
			{
				case LUA_TNUMBER:
					[dict setObject:[NSNumber numberWithFloat:(float)lua_tonumber(state, -1)] forKey:key];
					break;
				case LUA_TSTRING:
					[dict setObject:[NSString stringWithCString:lua_tostring(state, -1) encoding:NSUTF8StringEncoding] forKey:key];
					break;
				case LUA_TBOOLEAN:
					[dict setObject:[NSNumber numberWithBool:lua_toboolean(state, -1)] forKey:key];
					break;
				case LUA_TTABLE:
				{
					[KKLua internalLoadSubTableWithKey:key luaState:state dictionary:dict];
					break;
				}

				default:
					CCLOG(@"Unknown value type %i in table ignored.", luaTypeOfValue);
					break;
			}
			
			lua_pop(state, 1);
		}
	}
	else
	{
		error = @"not a Lua table!";
	}

	if (error != nil)
	{
		NSLog(@"\n\nERROR in %@: %@\n\n", NSStringFromSelector(_cmd), error);
    }

	return dict;
}

+(NSDictionary*) loadLuaTableFromFile:(NSString*)file
{
	NSMutableDictionary* dict = nil;
	[KKLua doFile:file];
		
	if (lua_istable(wax_currentLuaState(), -1))
	{
		dict = [KKLua internalRecursivelyLoadTable:wax_currentLuaState() index:-1];
		//LOG_EXPR(dict);
	}
	else
	{
		NSString* error = [NSString stringWithCString:lua_tostring(wax_currentLuaState(), -1) encoding:NSUTF8StringEncoding];
		NSLog(@"\n\nERROR in %@: %@\n\n", NSStringFromSelector(_cmd), error);
	}
	
	lua_pop(wax_currentLuaState(), 1);

	return dict;
}

+(Class) classFromLuaScriptWithName:(NSString*)scriptName superClass:(NSString*)superClass
{
	Class scriptClass = nil;
	if (scriptName)
	{
		scriptClass = NSClassFromString(scriptName);

		// create the Class object if needed
		if (scriptClass == nil)
		{
			NSString* scriptFile = [NSString stringWithFormat:@"%@.lua", scriptName];
			if ([[NSFileManager defaultManager] fileExistsAtPath:scriptFile])
			{
				// The waxClass line must be prefixed to the same Lua pcall, otherwise it won't register the file's functions as part of the class.
				// This is why a simple doString of waxClass followed by a doFile of the scriptFile won't work.
				NSString* waxClass = [NSString stringWithFormat:@"waxClass{'%@', %@}", scriptName, superClass];
				[KKLua doFile:scriptFile prefixCode:waxClass suffixCode:nil];
				
				scriptClass = NSClassFromString(scriptName);
				NSAssert2(scriptClass != nil, @"%@ - could not create class from script '%@'", NSStringFromSelector(_cmd), scriptFile);
			}
			else
			{
				CCLOG(@"%@ - lua script file '%@' not found in bundle!", NSStringFromSelector(_cmd), scriptFile);
			}
		}
	}

	return scriptClass;
}

@end
