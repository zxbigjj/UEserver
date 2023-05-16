
#ifndef LUA_PROFILER_H_
#define LUA_PROFILER_H_


/* All this code should be usable from within C apps. */
#ifdef __cplusplus
extern "C" {
#endif

struct ProfilerOption {
    const char *out_file_name;
    int frequency;
    int control_signal;
    int sample_signal;
    unsigned long luaV_execute_begin;
    unsigned long luaV_execute_size;
    const char* (*cb_lua_getstackinfo)(void* L, int level, int* buff_sz);
    void (*cb_lua_addhook)(void* L);
};

int ProfilerStart(struct ProfilerOption *option, int *tid_list, int tid_count);
int ProfilerStop();
void ProfilerOnLuaHook(void *L);

#ifdef __cplusplus
}  // extern "C"
#endif

#endif  /* LUA_PROFILER_H_ */
