//
//  lua.h
//  lua
//
//  Created by mengyun on 16/9/24.
//  Copyright © 2016年 mengyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "lua.hpp"

extern int luaopen_clientsocket(lua_State *L);
extern int luaopen_sproto_core(lua_State *L);
extern int luaopen_lpeg(lua_State *L);

@interface LuaFunc : NSObject
@property(nonatomic, assign)lua_State *L;

- (id)init;
- (void)dealloc;
- (void)luaClose;
- (int)lConnectWithAddr:(const char*)addr andPort:(int)port;
- (int)lSetKey:(const char*)key with:(const char*)value;
- (const char*)lGetValueByKey:(const char*)key;
- (int)executeLuaFuncWithName:(char *)functionName andArgs:(int *)args andLength:(int)len andResult:(int *)result;
    
@end
