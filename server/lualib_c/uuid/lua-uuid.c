#include <lua.h>
#include <lauxlib.h>

#include <stdio.h>
#include <stdint.h>

#define UUID_SPLIT '_'
#define UUID_BASE 36
#define UUID_MAXLEN 128
#define UUID_HEADER_MAXLEN 64

static char g_header_str[UUID_HEADER_MAXLEN]; // uuid struct:type_id:action_id:idx
static int g_header_len = 0; // length of struct:type_id:action_id:
static uint64_t g_idx = 0; // 该进程的计数器, 所有线程共享

// base(2~36)
static char *CHAR_MAP = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
static int 
num2str(uint64_t num, int base, char *ret, int max_len) {
  int start_pos = max_len;
  while(num >= base) {
    start_pos--;
    ret[start_pos] = CHAR_MAP[num % base];
    num = num / base;
  };
  
  start_pos--;
  ret[start_pos] = CHAR_MAP[num];

  /* printf("num2str:<%lu>", num); */
  /* int i; */
  /* for(i=start_pos; i < max_len; i++) { */
  /*   printf("%c", ret[i]); */
  /* } */
  /* printf("\n"); */

  return start_pos;
}

static int
luuid_init(lua_State *L) {
  if(g_header_len != 0) {
    return luaL_error(L, "already init");
  }

  int isnum;
  uint64_t type_id = (uint64_t)lua_tointegerx(L, 1, &isnum);
  if(!isnum) {
    return luaL_argerror(L, 1, "type_id not integer");
  }

  if(type_id > 0xffffffff) {
    return luaL_argerror(L, 1, "type_id too large");
  }

  uint64_t action_id = (uint64_t)lua_tointegerx(L, 2, &isnum);
  if(!isnum) {
    return luaL_argerror(L, 2, "action_id not integer");
  }

  if(action_id > 0xffffffff) {
    return luaL_argerror(L, 1, "action_id too large");
  }

  int header_start = UUID_HEADER_MAXLEN;

  // header = split
  header_start--;
  g_header_str[header_start] = UUID_SPLIT;

  // header = action_id + split
  header_start = num2str(action_id, UUID_BASE, g_header_str, header_start);

  // header = split + action_id + split
  header_start--;
  g_header_str[header_start] = UUID_SPLIT;

  // header = type_id + split + start_pos + split
  header_start = num2str(type_id, UUID_BASE, g_header_str, header_start);

  int header_len = UUID_HEADER_MAXLEN - header_start;
  int i;
  if(header_start > 0) {
    for(i=0;i<header_len;i++) {
      g_header_str[i] = g_header_str[i+header_start];
    }
  }
  g_header_len = header_len;

  // --- debug
  printf("header:<");
  for(i=0;i<g_header_len;i++) {
    printf("%c", g_header_str[i]);
  }
  printf(">, len:<%d>\n", g_header_len);

  lua_pushlstring(L, g_header_str, g_header_len);
  return 1;
}

static int
luuid_apply(lua_State *L) {
  int isnum;
  int count = (uint64_t)lua_tointegerx(L, 1, &isnum);
  if(!isnum) {
		return luaL_argerror(L, 1, "not integer");
  }

  if(count <= 0) {
		return luaL_argerror(L, 1, "not postive integer");
  }

  uint64_t begin_idx = __sync_fetch_and_add(&g_idx, count);
  lua_pushinteger(L, begin_idx);
  return 1;
}

static int
luuid_new(lua_State *L) {
  if(g_header_len == 0) {
    return luaL_error(L, "not init");
  }

  int isnum;
  int idx_num = (uint64_t)lua_tointegerx(L, 1, &isnum);
  if(!isnum) {
		return luaL_argerror(L, 1, "not integer");
  }

  char uuid_str[UUID_MAXLEN];
  int uuid_str_start = num2str(idx_num, UUID_BASE, uuid_str, UUID_MAXLEN) - g_header_len;
  if(uuid_str_start < 0) {
    return luaL_error(L, "uuid out of range!!!");
  }

  int i;
  for(i=0; i<g_header_len; i++) {
    uuid_str[uuid_str_start+i] = g_header_str[i];
  }

  lua_pushlstring(L, uuid_str + uuid_str_start, UUID_MAXLEN - uuid_str_start);
  return 1;
}

int
luaopen_luuid(lua_State *L) {
  luaL_checkversion(L);
  luaL_Reg l[] = {
    { "init", luuid_init },
    { "apply", luuid_apply },
    { "new", luuid_new },
    { NULL,  NULL },
  };

  luaL_newlib(L, l);
  return 1;
}
