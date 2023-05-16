#include <stdlib.h>
#include <string.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#define AES128 1
//#define AES192 1
//#define AES256 1

#include "aes.h"

static int aes_new_ctx(lua_State *L) {
	int args_num = lua_gettop(L);
	if (args_num < 1 || args_num > 2) {
		return luaL_error(L, "wrong number of arguments");
	}

	struct AES_ctx* ctx = (struct AES_ctx*)lua_newuserdata(L, sizeof(struct AES_ctx));
	size_t key_sz = 0;
	const uint8_t * key;
	key = (const uint8_t *)luaL_checklstring(L, 1, &key_sz);
	if (key_sz != AES_KEYLEN) {
		return luaL_error(L, "aes key len must be:%d", AES_KEYLEN);
	}
	if (args_num == 1) {
		AES_init_ctx(ctx, key);
	} else {
		size_t iv_sz = 0;
		const uint8_t * iv;
		iv = (const uint8_t *)luaL_checklstring(L, 2, &iv_sz);
		if (iv_sz != AES_BLOCKLEN) {
			return luaL_error(L, "aes iv len must be:%d", AES_BLOCKLEN);
		}
		AES_init_ctx_iv(ctx, key, iv);
	}
	return 1;
}

static int aes_ctr_xcrypt(lua_State *L) {
	struct AES_ctx* ctx = (struct AES_ctx*)lua_touserdata(L, 1);
	size_t sz;
	const uint8_t * in_str = (const uint8_t *)luaL_checklstring(L, 2, &sz);
	if (in_str == NULL) {
		luaL_error(L, "aes_ctr_xcrypt wrong arguments");
	}
	uint8_t tmp[256];
	uint8_t *buffer = tmp;
	if (sz > 256) {
		buffer = malloc(sz);
	}
	memcpy(buffer, in_str, sz);
	AES_CTR_xcrypt_buffer(ctx, buffer, sz);
	lua_pushlstring(L, (const char *)buffer, sz);
	if (sz > 256) {
		free(buffer);
	}
	return 1;
}

static int aes_cbc_encrypt(lua_State *L) {
	struct AES_ctx* ctx = (struct AES_ctx*)lua_touserdata(L, 1);
	size_t sz;
	const uint8_t * in_str = (const uint8_t *)luaL_checklstring(L, 2, &sz);
	if (in_str == NULL) {
		luaL_error(L, "aes_ctr_xcrypt wrong arguments");
	}
	uint8_t tmp[256];
	uint8_t *buffer = tmp;
	if (sz > 256) {
		buffer = malloc(sz);
	}
	memcpy(buffer, in_str, sz);
	AES_CBC_encrypt_buffer(ctx, buffer, sz);
	lua_pushlstring(L, (const char *)buffer, sz);
	if (sz > 256) {
		free(buffer);
	}
	return 1;
}

static int aes_cbc_decrypt(lua_State *L) {
	struct AES_ctx* ctx = (struct AES_ctx*)lua_touserdata(L, 1);
	size_t sz;
	const uint8_t * in_str = (const uint8_t *)luaL_checklstring(L, 2, &sz);
	if (in_str == NULL) {
		luaL_error(L, "aes_ctr_xcrypt wrong arguments");
	}
	uint8_t tmp[256];
	uint8_t *buffer = tmp;
	if (sz > 256) {
		buffer = malloc(sz);
	}
	memcpy(buffer, in_str, sz);
	AES_CBC_decrypt_buffer(ctx, buffer, sz);
	lua_pushlstring(L, (const char *)buffer, sz);
	if (sz > 256) {
		free(buffer);
	}
	return 1;
}

int luaopen_aes_core(lua_State *L) {
    luaL_Reg l[] = {
    	{ "aes_new_ctx", aes_new_ctx },
        { "aes_ctr_xcrypt", aes_ctr_xcrypt },
        { "aes_cbc_encrypt", aes_cbc_encrypt },
        { "aes_cbc_decrypt", aes_cbc_decrypt },
        { NULL, NULL },
    };
    luaL_newlib(L, l);
    return 1;
}