
#ifdef __cplusplus
extern "C" {
#endif

#include <stdlib.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#include <pthread.h>
#include "luaprofiler.h"

#define MAX_LSBUFF 2047
#define MAX_HOOK_SAVER 128

struct HookSaver {
    bool used;
    lua_State* L;
    lua_Hook hook;
    int hookcount;
    int hookmask;
};

static char LSBUFF[MAX_LSBUFF+1];

static pthread_mutex_t lock;
static HookSaver hook_saver_list[MAX_HOOK_SAVER];
static int hook_saver_count = 0;

static void
on_hook_easy(lua_State* L, lua_Debug *ar)
{
    lua_sethook(L, 0, 0, 0);
    ProfilerOnLuaHook(L);
}

static void
on_hook(lua_State* L, lua_Debug *ar)
{
    // restore
    {
        pthread_mutex_lock(&lock);
        for(int i=0; i<hook_saver_count; ++i)
        {
            if(hook_saver_list[i].used == false) continue;
            if(hook_saver_list[i].L != L) continue;

            hook_saver_list[i].used = false;
            lua_sethook(L, 
                hook_saver_list[i].hook, 
                hook_saver_list[i].hookcount, 
                hook_saver_list[i].hookmask);
            if(i+1 == hook_saver_count)
            {
                while(hook_saver_count > 1)
                {
                   if(hook_saver_list[hook_saver_count-1].used) break;
                   hook_saver_count -= 1; 
                }
            }
            break;
        }
        pthread_mutex_unlock(&lock);
    }
    ProfilerOnLuaHook(L);
}

static void
cb_lua_addhook(void* _L)
{
    lua_State *L = (lua_State *)_L;

    if(lua_gethook(L))
    {
        bool got_save = false;

        pthread_mutex_lock(&lock);

        for(int i=0; i<hook_saver_count; ++i)
        {
            if(hook_saver_list[i].used && hook_saver_list[i].L == L)
            {
                got_save = true;
                break;
            }
        }

        if(!got_save)
        {
            for(int i=0; i<MAX_HOOK_SAVER; ++i)
            {
                if(hook_saver_list[i].used) continue;

                hook_saver_list[i].used = true;
                hook_saver_list[i].L = L;
                hook_saver_list[i].hook = lua_gethook(L);
                hook_saver_list[i].hookcount = lua_gethookcount(L);
                hook_saver_list[i].hookmask = lua_gethookmask(L);
                got_save = true;
                if(i+1 > hook_saver_count)
                {
                    hook_saver_count = i+1;
                }
                break;
            }
        }
        
        pthread_mutex_unlock(&lock);

        if(!got_save) return;
        // 不要用LUA_MASKLINE，有个bug， oldpc值是任意的， luaG_traceexec中使用时会crash
        // 已修改lua， 可以使用LUA_MASKLINE
        lua_sethook(L, on_hook, LUA_MASKCALL | LUA_MASKRET | LUA_MASKLINE, 0);
    }
    else
    {
        lua_sethook(L, on_hook_easy, LUA_MASKCALL | LUA_MASKRET | LUA_MASKLINE, 0);
    }  
}

static const char*
cb_lua_getstackinfo(void* _L, int level, int* buff_size)
{
    lua_Debug ar;
    lua_State *L = (lua_State *)_L;
    int sz = 0;

    if(L == 0) return NULL;
    if(lua_getstack(L, level, &ar) == 0) return NULL;
    lua_getinfo(L, "Slnt", &ar);
    sz += snprintf(LSBUFF+sz, MAX_LSBUFF - sz, "%s:", ar.short_src);
    if (ar.currentline > 0)
        sz += snprintf(LSBUFF+sz, MAX_LSBUFF - sz, "%d=>", ar.currentline);
    else
        sz += snprintf(LSBUFF+sz, MAX_LSBUFF - sz, "=>");

    if (*ar.namewhat != '\0')  /* is there a name from code? */
        sz += snprintf(LSBUFF+sz, MAX_LSBUFF - sz, "%s <%s:%d>", ar.namewhat, ar.name, ar.linedefined);
    else if (*ar.what == 'm')  /* main? */
        sz += snprintf(LSBUFF+sz, MAX_LSBUFF - sz, "main chunk");
    else if (*ar.what != 'C')  /* for Lua functions, use <file:line> */
        sz += snprintf(LSBUFF+sz, MAX_LSBUFF - sz, "function <%s:%d>", ar.short_src, ar.linedefined);
    else  /* nothing left... */
        sz += snprintf(LSBUFF+sz, MAX_LSBUFF - sz, "?");

    *buff_size = sz;
    return LSBUFF;
}

static int
lstart(lua_State *L) {
    struct ProfilerOption option;
    int *tid_list;
    int tid_count;
    int i;

    if(!lua_istable(L, -1))
    {
        return luaL_argerror(L, 1, "need a table");
        return 0;
    }

    lua_len(L, -1);
    tid_count = lua_tointeger(L, -1);
    lua_pop(L, 1);
    tid_list = (int*)malloc(tid_count * sizeof(int));
    for(i=1; i<=tid_count; i++)
    {
        lua_geti(L, -1, i);
        if(lua_isinteger(L, -1))
            tid_list[i-1] = lua_tointeger(L, -1);
        else
            tid_list[i-1] = 0;
        lua_pop(L, 1);
    }

    option.control_signal = 0;
    option.sample_signal = 0;
    option.frequency = 100;

    lua_getfield(L, -1, "out_file_name");
    if(lua_isstring(L, -1))
    {
        option.out_file_name = lua_tostring(L, -1);
    }
    else
        option.out_file_name = "profiler.sample";
    lua_pop(L, 1);
    

    lua_getfield(L, -1, "luaV_execute_begin");
    if(lua_isinteger(L, -1))
    {
        option.luaV_execute_begin = lua_tointeger(L, -1);
    }
    else
        option.luaV_execute_begin = 0;
    lua_pop(L, 1);

    lua_getfield(L, -1, "luaV_execute_size");
    if(lua_isinteger(L, -1))
    {
        option.luaV_execute_size = lua_tointeger(L, -1);
    }
    else
        option.luaV_execute_size = 0;
    lua_pop(L, 1);

    option.cb_lua_getstackinfo = cb_lua_getstackinfo;
    option.cb_lua_addhook = cb_lua_addhook;

    ProfilerStart(&option, tid_list, tid_count);

    free(tid_list);
    return 0;
}

static int
lstop(lua_State *L) {
    ProfilerStop();
    return 0;
}

int
luaopen_luaprofiler(lua_State *L) {

    pthread_mutex_init(&lock, NULL);

    luaL_Reg l[] = {
        { "start", lstart },
        { "stop", lstop },
        { NULL, NULL },
    };
    luaL_newlib(L, l);
    return 1;
}

#ifdef __cplusplus
}
#endif