#include <stdlib.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

static void pack_int32(char * buffer, int i) {
    buffer[0] = (char)((i) & 0xff);
    buffer[1] = (char)((i >> 8) & 0xff);
    buffer[2] = (char)((i >> 16) & 0xff);
    buffer[3] = (char)((i >> 24) & 0xff);
}

static int unpack_int32(const char * buffer) {
    const unsigned char * p = (const unsigned char *)buffer;
    int i = p[0] | p[1] << 8 | p[2] << 16 | p[3] << 24;
    return i;
}

// pack_int32_list(table, from_pos, to_pos)
static int lpack_int32_list(lua_State *L) {
    luaL_argcheck(L, lua_type(L, 1) == LUA_TTABLE, 1, "expected table");
    lua_Integer len = luaL_len(L, 1);
    lua_Integer i = luaL_optinteger(L, 2, 1);
    lua_Integer last = luaL_optinteger(L, 3, len);
    if (last > len) {
        last = len;
    }
    len = last - i + 1;
    if (len < 0) {
        len = 0;
    }

    char * buffer = malloc(4*len);
    int isinteger;
    lua_Integer elem;
    lua_Integer lim = (lua_Integer)1 << (32 - 1);
    char * p = buffer;
    for (; i <= last; i++) {
        lua_geti(L, 1, i);
        elem = lua_tointegerx(L, -1, &isinteger);
        if (!isinteger) {
            free(buffer);
            luaL_error(L, "invalid value (%s) at index %d in table for 'pack_int32_list'",
                    luaL_typename(L, -1), i);
            return 0;
        }
        if (elem >= lim || elem < -lim) {
            free(buffer);
            luaL_error(L, "integer overflow (%I) at index %d in table for 'pack_int32_list'",
                    elem, i);
            return 0;
        }
        pack_int32(p, (int)elem);
        p += 4;
        lua_pop(L, 1);
    }
    lua_pushlstring(L, buffer, 4*len);
    free(buffer);
    return 1;
}

static int lunpack_int32_list(lua_State *L) {
    luaL_argcheck(L, lua_type(L, 1) == LUA_TSTRING, 1, "expected string");

    size_t sz = 0;
    const char * buffer = lua_tolstring(L, 1, &sz);
    int cnt = sz / 4;

    lua_createtable(L, cnt, 0);  /* create result table */
    for(int i=0; i<cnt; i++)
    {
        lua_pushinteger(L, unpack_int32(buffer + i*4));
        lua_seti(L, -2, i+1);
    }
    return 1;  /* return table */
}

int luaopen_bin_utils(lua_State *L) {
    luaL_Reg l[] = {
        { "pack_int32_list", lpack_int32_list },
        { "unpack_int32_list", lunpack_int32_list },
        { NULL, NULL },
    };
    luaL_newlib(L, l);
    return 1;
}