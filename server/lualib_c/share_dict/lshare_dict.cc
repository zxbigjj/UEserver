#include <string>
#include <unordered_map>

static std::unordered_map<std::string, std::string> CACHE;

#ifdef __cplusplus
extern "C" {
#endif

#include <stdlib.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#include "rwlock.h"
#include "skynet_malloc.h"
#include "atomic.h"

static struct rwlock lock;

static int lput(lua_State *L) {
    luaL_argcheck(L, lua_type(L, 1) == LUA_TSTRING, 1, "param 1 expected string");
    luaL_argcheck(L, lua_type(L, 2) == LUA_TSTRING, 2, "param 2 expected string");

    size_t sz1 = 0;
    const char * key = lua_tolstring(L, 1, &sz1);
    size_t sz2 = 0;
    const char * value = lua_tolstring(L, 2, &sz2);

    rwlock_wlock(&lock);
    CACHE[std::string(key, sz1)] = std::string(value, sz2);
    rwlock_wunlock(&lock);
    return 0;
}

static int lget(lua_State *L) {
    luaL_argcheck(L, lua_type(L, 1) == LUA_TSTRING, 1, "param 1 expected string");
    size_t sz1 = 0;
    const char * key = lua_tolstring(L, 1, &sz1);

    int find = 0;
    std::string temp;

    rwlock_rlock(&lock);
    auto search = CACHE.find(std::string(key, sz1));
    if(search != CACHE.end()) {
        find = 1;
        temp = search->second;
    } else {
        find = 0;
    }
    rwlock_runlock(&lock);

    if(find == 1) {
        lua_pushlstring(L, temp.c_str(), temp.size());
    } else {
        lua_pushnil(L);
    }

    return 1;
}

static int lhas(lua_State *L) {
    luaL_argcheck(L, lua_type(L, 1) == LUA_TSTRING, 1, "param 1 expected string");
    size_t sz1 = 0;
    const char * key = lua_tolstring(L, 1, &sz1);

    int find = 0;

    rwlock_rlock(&lock);
    auto search = CACHE.find(std::string(key, sz1));
    if(search != CACHE.end()) {
        find = 1;
    } else {
        find = 0;
    }
    rwlock_runlock(&lock);

    if(find == 1) {
        lua_pushboolean(L, 1);
    } else {
        lua_pushboolean(L, 0);
    }

    return 1;
}

static int linit(lua_State *L) {
    rwlock_init(&lock);
    return 0;
}

int luaopen_share_dict(lua_State *L) {
    luaL_Reg l[] = {
        { "put", lput },
        { "get", lget },
        { "has", lhas },
        { "init", linit },
        { NULL, NULL },
    };
    luaL_newlib(L, l);
    return 1;
}


#ifdef __cplusplus
}
#endif