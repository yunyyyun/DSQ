//
//  lua.m
//  lua
//
//  Created by mengyun on 16/9/24.
//  Copyright © 2016年 mengyun. All rights reserved.
//
#import "LuaFunction.h"

@implementation LuaFunc

static int justForTest(lua_State *L){
    int a=121;
    printf("this %d is print from c!\n",a);
    return 0;
}

static int getTableFromLua(lua_State *L, int* result){
    int t = lua_type(L, 1);
    switch (t) {
        case LUA_TNUMBER:
            printf("lua not support!");
            break;
        case LUA_TTABLE:
        {
            lua_pushnil(L);   //tb
            
            while(lua_next(L, 1)!=0){  //tb,k,v
                lua_pushvalue(L, -2);  //tb,k,v,k
                
                int key=lua_tonumber(L, -1);
                int value=lua_tonumber(L, -2);
                //printf("%d   %d----\n",key-1,value);
                result[key-1]=value;
                lua_pop(L, 2);      //tb,k
            }
            lua_pop(L, 1);
            return 1;
        }
            break;
        default:
            printf("lua error!");
            return -1;
            break;
    }
     return 0;
}

- (void)runLuaCode:(NSString*)path{
    luaL_dostring(_L, [path UTF8String]);
}

- (id)init{

    //lua_State *_L;
    NSLog(@"inited!!!!!!");
    self = [super init];
    _L=luaL_newstate();
    if (_L==NULL){
        NSLog(@"lua init failed!");
        abort();
    }
    luaL_openlibs(_L);
    luaL_requiref(_L,"clientsocket",luaopen_clientsocket,1);
    luaL_requiref(_L,"sprotoCore",luaopen_sproto_core,1);
    luaL_requiref(_L,"lpeg",luaopen_lpeg,1);
    
    NSString *appPath = [[NSBundle mainBundle] resourcePath];
    [self runLuaCode:[NSString stringWithFormat:@"appPath = '%@/?.lua'",appPath]];
    
    NSString * tagsString = @"client";
    NSArray * tagsArray = [tagsString componentsSeparatedByString:@","];
    
    for (NSString* luaFileName in tagsArray) {
        NSString *path = [[NSBundle mainBundle] pathForResource:luaFileName ofType:@"lua"];
        printf("-------%s\n",[path UTF8String]);
        if (luaL_loadfile(_L, [path UTF8String])!=0){
            NSLog(@"luaL_loadfile error:%s",lua_tostring(_L, -1));
        }

        if (lua_pcall(_L, 0, 0, 0)!=0){
            NSLog(@"lua_pcall error？:%s",lua_tostring(_L, -1));
        }
    }
    return self;
}

- (void)luaClose
{
    lua_close(_L);
}

- (void)dealloc
{
    if (_L){
        lua_close(_L);
    }
}

- (int)executeLuaFuncWithName:(char *)functionName andArgs:(int *)args andLength:(int)len andResult:(int *)result{

    lua_pushcfunction(_L, justForTest);
    lua_setglobal(_L, "justForTest");
    NSLog(@"%s.......0303",functionName);
    functionName="test008";  //test
    lua_getglobal(_L, functionName);
    lua_newtable(_L);
    lua_pushnumber(_L, -1); //push -1 into stack
    lua_rawseti(_L, -2, 0); //set array[0] by -1
    for(int i = 0; i < len; i++)
    {
        //NSLog(@"%d.......",args[i]);
        lua_pushnumber(_L, args[i]); //push
        lua_rawseti(_L, -2, i+1); //
    }
    
    if (lua_pcall(_L, 1, 1,0)!=0){
        printf("--luaerror--\n");
        NSLog(@"lua_pcall error？:%s",lua_tostring(_L, -1));
    }
    
    //int reslut[]={0,0,0,0,0,0};
    //int* reslut=(int *)calloc(len,sizeof(int));
    //getTableFromLua(_L, result);
    
//    for (int i=0;i<len;++i){
//        printf("--------%d__%d\n",i,result[i]);
//    }
    //lua_close(_L);
//    lua_pushnumber(_L, arg[0]);
//    lua_pushnumber(_L, arg[1]);
//    lua_pushnumber(_L, arg[2]);
//    lua_pushnumber(_L, arg[3]);
//    
//    if (lua_pcall(_L, 4, 4, 0)!=0){
//        NSLog(@"error running function: %s",lua_tostring(_L, -1));
//    }
//    NSLog(@"result of running function: %s %s",lua_tostring(_L, -2),lua_tostring(_L, -1));
//    arg[0] = (double)lua_tonumber(_L, -4);
//    arg[1] = (double)lua_tonumber(_L, -3);
//    arg[2] = (double)lua_tonumber(_L, -2);
//    arg[3] = (double)lua_tonumber(_L, -1);
//    
//    NSLog(@"%lf..%lf...%lf..%lf",arg[0],arg[1],arg[2],arg[3]);
//    lua_pop(_L,1);
//    lua_pop(_L,1);
//    lua_pop(_L,1);
//    lua_pop(_L,1);
    //int *b = new int[3];
    return 0;//getTableFromLua(_L, result);
}

- (int)lConnectWithAddr:(const char*)addr andPort:(int)port{
    lua_getglobal(_L, "luaconnect");
    lua_pushstring(_L, addr);
    lua_pushnumber(_L, port);
    if (lua_pcall(_L, 2, 1,0)!=0){
        printf("--luasetqwerror--\n");
        printf("lua_pcall error？:%s\n",lua_tostring(_L, -1));
    }
    
    return 1;
}

- (int)lSetKey:(const char*)key with:(const char*)value{
    lua_getglobal(_L, "set");
    lua_pushstring(_L, key);
    lua_pushstring(_L, value);
    if (lua_pcall(_L, 2, 1,0)!=0){
        printf("--luaseterror--\n");
        NSLog(@"lua_pcall error？:%s",lua_tostring(_L, -1));
    }
    return 0;
}

- (const char*)lGetValueByKey:(const char*)key{
    lua_getglobal(_L, "get");
    lua_pushstring(_L, key);
    if (lua_pcall(_L, 1, 1,0)!=0){
        printf("--luageterror--\n");
        NSLog(@"lua_pcall error？:%s",lua_tostring(_L, -1));
    }
    const char* s = lua_tostring(_L, -1);
    return s;
}

@end
