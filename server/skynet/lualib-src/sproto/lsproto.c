/*
添加字典类型， 类似 array
*integer 	整数数组
i$integer   以整数为key的整数字典, integer可以换成任意内置或自定义类型
s$integer   以字符串为key的整数字典, integer可以换成任意内置或自定义类型
*/
#define LUA_LIB

#include <string.h>
#include <stdlib.h>
#include <math.h>
#include "msvcint.h"

#include "lua.h"
#include "lauxlib.h"
#include "sproto.h"

#define MAX_GLOBALSPROTO 16
#define ENCODE_BUFFERSIZE 2050

#define ENCODE_MAXSIZE 0x1000000
#define ENCODE_DEEPLEVEL 64

#ifndef LUAMOD_API
	#define LUAMOD_API LUALIB_API
#endif

#ifndef luaL_newlib /* using LuaJIT */
/*
** set functions from list 'l' into table at top - 'nup'; each
** function gets the 'nup' elements at the top as upvalues.
** Returns with only the table at the stack.
*/
LUALIB_API void luaL_setfuncs (lua_State *L, const luaL_Reg *l, int nup) {
#ifdef luaL_checkversion
	luaL_checkversion(L);
#endif
	luaL_checkstack(L, nup, "too many upvalues");
	for (; l->name != NULL; l++) {  /* fill the table with given functions */
		int i;
		for (i = 0; i < nup; i++)  /* copy upvalues to the top */
			lua_pushvalue(L, -nup);
		lua_pushcclosure(L, l->func, nup);  /* closure with those upvalues */
		lua_setfield(L, -(nup + 2), l->name);
	}
	lua_pop(L, nup);  /* remove upvalues */
}

#define luaL_newlibtable(L,l) \
  lua_createtable(L, 0, sizeof(l)/sizeof((l)[0]) - 1)

#define luaL_newlib(L,l)  (luaL_newlibtable(L,l), luaL_setfuncs(L,l,0))
#endif

#if LUA_VERSION_NUM < 503

#if LUA_VERSION_NUM < 502
static int64_t lua_tointegerx(lua_State *L, int idx, int *isnum) {
	if (lua_isnumber(L, idx)) {
		if (isnum) *isnum = 1;
		return (int64_t)lua_tointeger(L, idx);
	}
	else {
		if (isnum) *isnum = 0;
		return 0;
	}
}

static int lua_absindex(lua_State *L, int idx) {
	if(idx < 0)
	{
		return lua_gettop(L) + 1 + idx;
	}
	else
	{
		return idx;
	}
}
#endif

static void lua_copy(lua_State *L, int fromidx, int toindx) {
	lua_pushvalue(L, fromidx);
	lua_replace(L, toindx-1);
}

// work around , use push & lua_gettable may be better
#define lua_geti lua_rawgeti
#define lua_seti lua_rawseti

#endif

static int
lnewproto(lua_State *L) {
	struct sproto * sp;
	size_t sz;
	void * buffer = (void *)luaL_checklstring(L,1,&sz);
	sp = sproto_create(buffer, sz);
	if (sp) {
		lua_pushlightuserdata(L, sp);
		return 1;
	}
	return 0;
}

static int
ldeleteproto(lua_State *L) {
	struct sproto * sp = lua_touserdata(L,1);
	if (sp == NULL) {
		return luaL_argerror(L, 1, "Need a sproto object");
	}
	sproto_release(sp);
	return 0;
}

static int
lquerytype(lua_State *L) {
	const char * type_name;
	struct sproto *sp = lua_touserdata(L,1);
	struct sproto_type *st;
	if (sp == NULL) {
		return luaL_argerror(L, 1, "Need a sproto object");
	}
	type_name = luaL_checkstring(L,2);
	st = sproto_type(sp, type_name);
	if (st) {
		lua_pushlightuserdata(L, st);
		return 1;
	}
	return 0;
}

struct encode_ud {
	lua_State *L;
	struct sproto_type *st;
	int tbl_index;
	const char * array_tag;
	int deep;
	int has_pairs_meta;
	int iter_enter_index;
};

static int encode(struct sproto_arg *args);
static int decode(struct sproto_arg *args);

// n is int64_t
#define ZigZagEncode64(n) (uint64_t)((((uint64_t)n) << 1) ^ ((int64_t)n >> 63))

// n is uint64_t
#define ZigZagDecode64(n) (int64_t)(((uint64_t)n >> 1) ^ -(int64_t)(n & 1))

// protobuf varint格式
static int
write_int64(struct sproto_arg *args, int64_t v) {
	uint64_t uv = ZigZagEncode64(v);
	uint8_t * bytes = args->value;
	int sz=0;

	// 最多10字节
	if(args->length < 10) 
	{
		return SPROTO_CB_ERROR;
	}
	while (uv > 0x7F) {
		bytes[sz++] = ((uint8_t)(uv) & 0x7F) | 0x80;
		uv >>= 7;
	}
	bytes[sz++] = (uint8_t)(uv) & 0x7F;

	args->value += sz;
	args->length -= sz;
	return sz;
}

// 0成功-1失败
static int
read_int64(struct sproto_arg *args, int64_t* value) {
	uint64_t uv = 0;
	uint8_t * bytes = args->value;
	int length = args->length;
	uint8_t b = 0;
	int sz = 0;

	while(length > sz && sz < 10)
	{
		b = bytes[sz];
		uv |= (uint64_t)(b & 0x7F) << (7*sz);
		sz++;
		if(!(b & 0x80))
		{
			args->length -= sz;
			args->value += sz;
			*value = ZigZagDecode64(uv);
			return 0;
		}
	}
	return -1;
}

static int
_write(struct sproto_arg *args, int type, lua_State *L, int stack_index) {
	switch(type)
	{
		case SPROTO_TINTEGER: {
			lua_Number num;
			if (!lua_isnumber(L, stack_index)) {
				return luaL_error(L, ".%s[%d] is not an integer (Is a %s)", 
					args->tagname, args->index, lua_typename(L, lua_type(L, stack_index)));
			}
			num = lua_tonumber(L, stack_index);
			return write_int64(args, (lua_Integer)(num));
		}
		case SPROTO_TFLOAT: {
			union {
				double d;
				int64_t i;
			} v;
			if (!lua_isnumber(L, stack_index)) {
				return luaL_error(L, ".%s[%d] is not an number (Is a %s)", 
					args->tagname, args->index, lua_typename(L, lua_type(L, stack_index)));
			}
			v.d = lua_tonumber(L, stack_index);
			return write_int64(args, v.i);
		}
		case SPROTO_TSTRING: {
			size_t sz;
			int head_sz;
			const char* str;
			if (lua_type(L, stack_index) != LUA_TSTRING) {
				return luaL_error(L, ".%s[%d] is not a string (Is a %s)", 
					args->tagname, args->index, lua_typename(L, lua_type(L, stack_index)));
			}
			str = lua_tolstring(L, stack_index, &sz);
			head_sz = write_int64(args, sz);
			if(head_sz < 0) return SPROTO_CB_ERROR;
			if (sz > args->length) return SPROTO_CB_ERROR;
			memcpy(args->value, str, sz);
			args->value += sz;
			args->length -= sz;
			return head_sz + sz;
		}
		case SPROTO_TBOOLEAN: {
			int v = lua_toboolean(L, stack_index);
			uint8_t * bytes = args->value;
			if(args->length < 1) return SPROTO_CB_ERROR;
			bytes[0] = v;
			args->value += 1;
			args->length -= 1;
			return 1;
		}
		case SPROTO_TSTRUCT: {
			struct encode_ud *ud = args->ud;
			struct encode_ud sub;
			int sz;
			uint8_t * bytes = args->value;
			int save_top = lua_gettop(L);
			if (!lua_istable(L, stack_index)) {
				return luaL_error(L, ".%s[%d] is not a table (Is a %s)", 
					args->tagname, args->index, lua_typename(L, lua_type(L, stack_index)));
			}
			if(args->length < 4) return SPROTO_CB_ERROR;
			sub.L = L;
			sub.st = args->subtype;
			sub.tbl_index = lua_absindex(L, stack_index);
			sub.array_tag = NULL;
			sub.deep = ud->deep + 1;
			luaL_checkstack(L, 8, NULL);
			sz = sproto_encode(args->subtype, bytes+4, args->length-4, encode, &sub);
			lua_settop(L, save_top);	// pop the value
			if(sz < 0) return SPROTO_CB_ERROR;
			// header
			bytes[0] = sz & 0xff;
			bytes[1] = (sz >> 8) & 0xff;
			bytes[2] = (sz >> 16) & 0xff;
			bytes[3] = (sz >> 24) & 0xff;
			args->value += 4+sz;
			args->length -= 4+sz;
			return 4+sz;
		}
	}
	return luaL_error(L, "unknown sproto type:%d", type);
}

static int
_prepare_table_iter(struct sproto_arg *args, struct encode_ud *self, lua_State *L) {
	luaL_checkstack(L, 8, NULL);
	self->array_tag = args->tagname;
	lua_getfield(L, self->tbl_index, args->tagname);
	if (lua_isnil(L, -1)) {
		return SPROTO_CB_NOARRAY;
	}
	if (!lua_istable(L, -1)) {
		lua_pop(L, 1);
		return luaL_error(L, ".*%s(%d) should be a table (Is a %s)",
			args->tagname, args->index, lua_typename(L, lua_type(L, -1)));
	}
	if (luaL_getmetafield(L, -1, "__pairs") != LUA_TNIL) {
		// 有pairs
		lua_insert(L, -2);
		lua_call(L, 1, 3);
		// 栈上分别是nextfunc, table, iter_key
		self->has_pairs_meta = 1;
		self->iter_enter_index = lua_gettop(L) - 2;
	}
	else {
		// 栈上分别是table, iter_key
		lua_pushnil(L);
		self->has_pairs_meta = 0;
		self->iter_enter_index = lua_gettop(L) - 1;
	}
	return 0;
}

static void
_table_iter_end(struct encode_ud *self, lua_State *L)
{
	lua_settop(L, self->iter_enter_index - 1);
}

static int
_table_iter(struct encode_ud *self, lua_State *L) {
	if (self->has_pairs_meta) {
		lua_pushvalue(L, -2);
		lua_pushvalue(L, -2);
		lua_copy(L, -5, -3);
		lua_call(L, 2, 2);
		if(lua_isnil(L, -2))
		{
			// iterate end
			_table_iter_end(self, L);
			return SPROTO_CB_NIL;
		}
	}
	else {
		if (!lua_next(L, -2)) {
			// iterate end
			_table_iter_end(self, L);
			return SPROTO_CB_NIL;
		}
	}
	return 0;
}

static int
write_dict(struct sproto_arg *args) {
	struct encode_ud *self = args->ud;
	lua_State *L = self->L;
	int sz;
	int ret = 0;
	int err = 0;
	if (args->tagname != self->array_tag) {
		//prepare new table
		err = _prepare_table_iter(args, self, L);
		if (err) return err;
	}
	// 迭代
	err = _table_iter(self, L);
	if (err) return err;
	// 编码key
	switch(args->array_type)
	{
		case SPROTO_TIDICT:
			sz = _write(args, SPROTO_TINTEGER, L, -2);
			break;
		case SPROTO_TSDICT:
			sz = _write(args, SPROTO_TSTRING, L, -2);
			break;
		default:
			return luaL_error(L, "unknown dict type:%d", args->array_type);
	}
	if(sz < 0)
	{
		_table_iter_end(self, L);
		return sz;
	}
	ret += sz;
	// 编码value
	sz = _write(args, args->type, L, -1);
	if(sz < 0)
	{
		_table_iter_end(self, L);
		return sz;
	}
	ret += sz;
	// 弹出value， 保存key
	lua_pop(L, 1);
	return ret;
}

static int
encode(struct sproto_arg *args) {
	struct encode_ud *self = args->ud;
	lua_State *L = self->L;
	int err = 0;
	if (self->deep >= ENCODE_DEEPLEVEL)
		return luaL_error(L, "The table is too deep");
	if (args->array_type) {
		switch(args->array_type)
		{
			case SPROTO_TIDICT:
			case SPROTO_TSDICT:
				return write_dict(args);
			case SPROTO_TARRAY:
				if (args->tagname != self->array_tag) {
					// a new array
					err = _prepare_table_iter(args, self, L);
					if (err) return err;
				}
				err = _table_iter(self, L);
				if (err) return err;
		}
	}
	else {
		lua_getfield(L, self->tbl_index, args->tagname);
	}
	
	if (lua_isnil(L, -1)) {
		lua_pop(L,1);
		return SPROTO_CB_NIL;
	}
	switch (args->type) {
	case SPROTO_TFLOAT: {
		lua_Number num;
		if (!lua_isnumber(L, -1)) {
			return luaL_error(L, ".%s[%d] is not an number (Is a %s)", 
				args->tagname, args->index, lua_typename(L, lua_type(L, -1)));
		} else {
			num = lua_tonumber(L, -1);
		}
		lua_pop(L,1);
		uint64_t uv = ZigZagEncode64((int64_t)(num * FLOAT_PRECISE + 0.5));
		if ((uv >> 32) == 0) {
			*(uint32_t *)args->value = (uint32_t)uv;
			return 4;
		}
		else {
			*(uint64_t *)args->value = (uint64_t)uv;
			return 8;
		}
	}
	case SPROTO_TINTEGER: {
		uint64_t uv;
		lua_Number num;
		if (!lua_isnumber(L, -1)) {
			return luaL_error(L, ".%s[%d] is not an integer (Is a %s)", 
				args->tagname, args->index, lua_typename(L, lua_type(L, -1)));
		} else {
			num = lua_tonumber(L, -1);
		}
		if (args->extra) {
			// It's decimal.
			uv = ZigZagEncode64((lua_Integer)round(num * args->extra));
		} else {
			uv = ZigZagEncode64((lua_Integer)(num));
		}
		lua_pop(L,1);
		if ((uv >> 32) == 0) {
			*(uint32_t *)args->value = (uint32_t)uv;
			return 4;
		}
		else {
			*(uint64_t *)args->value = (uint64_t)uv;
			return 8;
		}
	}
	case SPROTO_TBOOLEAN: {
		int v = lua_toboolean(L, -1);
		if (!lua_isboolean(L,-1)) {
			return luaL_error(L, ".%s[%d] is not a boolean (Is a %s)",
				args->tagname, args->index, lua_typename(L, lua_type(L, -1)));
		}
		*(int *)args->value = v;
		lua_pop(L,1);
		return 4;
	}
	case SPROTO_TSTRING: {
		size_t sz = 0;
		const char * str;
		if (!lua_isstring(L, -1)) {
			return luaL_error(L, ".%s[%d] is not a string (Is a %s)", 
				args->tagname, args->index, lua_typename(L, lua_type(L, -1)));
		} else {
			str = lua_tolstring(L, -1, &sz);
		}
		if (sz > args->length)
			return SPROTO_CB_ERROR;
		memcpy(args->value, str, sz);
		lua_pop(L,1);
		return sz;
	}
	case SPROTO_TSTRUCT: {
		struct encode_ud sub;
		int r;
		int top = lua_gettop(L);
		if (!lua_istable(L, top)) {
			return luaL_error(L, ".%s[%d] is not a table (Is a %s)", 
				args->tagname, args->index, lua_typename(L, lua_type(L, -1)));
		}
		sub.L = L;
		sub.st = args->subtype;
		sub.tbl_index = top;
		sub.array_tag = NULL;
		sub.deep = self->deep + 1;
		luaL_checkstack(L, 8, NULL);
		r = sproto_encode(args->subtype, args->value, args->length, encode, &sub);
		lua_settop(L, top-1);	// pop the value
		if (r < 0) 
			return SPROTO_CB_ERROR;
		return r;
	}
	default:
		return luaL_error(L, "Invalid field type %d", args->type);
	}
}

static void *
expand_buffer(lua_State *L, int osz, int nsz) {
	void *output;
	do {
		osz *= 2;
	} while (osz < nsz);
	if (osz > ENCODE_MAXSIZE) {
		luaL_error(L, "object is too large (>%d)", ENCODE_MAXSIZE);
		return NULL;
	}
	output = lua_newuserdata(L, osz);
	lua_replace(L, lua_upvalueindex(1));
	lua_pushinteger(L, osz);
	lua_replace(L, lua_upvalueindex(2));

	return output;
}

/*
	lightuserdata sproto_type
	table source

	return string
 */
static int
lencode(lua_State *L) {
	struct encode_ud self;
	void * buffer = lua_touserdata(L, lua_upvalueindex(1));
	int sz = lua_tointeger(L, lua_upvalueindex(2));
	int tbl_index = 2;
	struct sproto_type * st = lua_touserdata(L, 1);
	if (st == NULL) {
		luaL_checktype(L, tbl_index, LUA_TNIL);
		lua_pushstring(L, "");
		return 1;	// response nil
	}
	luaL_checktype(L, tbl_index, LUA_TTABLE);
	luaL_checkstack(L, 64, NULL);
	self.L = L;
	self.st = st;
	self.tbl_index = tbl_index;
	for (;;) {
		int r;
		self.array_tag = NULL;
		self.deep = 0;

		lua_settop(L, tbl_index);

		r = sproto_encode(st, buffer, sz, encode, &self);
		if (r<0) {
			buffer = expand_buffer(L, sz, sz*2);
			sz *= 2;
		} else {
			lua_pushlstring(L, buffer, r);
			return 1;
		}
	}
}

struct decode_ud {
	lua_State *L;
	const char * array_tag;
	int array_index;
	int result_index;
	int deep;
	int mainindex_tag;
	int key_index;
};

static int
_read(struct sproto_arg *args, int type, lua_State* L) {
	switch(type)
	{
		case SPROTO_TINTEGER: {
			int64_t v;
			if(read_int64(args, &v))
			{
				return -1;
			}
			lua_pushinteger(L, v);
			return 0;
		}
		case SPROTO_TFLOAT: {
			union {
				double d;
				int64_t i;
			} v;
			if(read_int64(args, &(v.i)))
			{
				return -1;
			}
			lua_pushnumber(L, v.d);
			return 0;
		}
		case SPROTO_TBOOLEAN: {
			uint8_t* byte = args->value;
			if(args->length < 1)
			{
				return -1;
			}
			lua_pushboolean(L, byte[0]);
			args->value += 1;
			args->length -= 1;
			return 0;
		}
		case SPROTO_TSTRING: {
			int64_t sz;
			if(read_int64(args, &sz))
			{
				return -1;
			}
			if(args->length < sz)
			{
				return -1;
			}
			lua_pushlstring(L, args->value, sz);
			args->value += sz;
			args->length -= sz;
			return 0;
		}
		case SPROTO_TSTRUCT: {
			struct decode_ud * ud = args->ud;
			struct decode_ud sub;
			int r;
			uint32_t sz = 0;
			uint8_t * bytes = args->value;

			if(args->length < 4)
			{
				return -1;
			}
			sz = bytes[0] | bytes[1]<<8 | bytes[2]<<16 | bytes[3]<<24;
			if(args->length < 4+sz)
			{
				return -1;
			}
			luaL_checkstack(L, 8, NULL);
			lua_newtable(L);
			sub.L = L;
			sub.result_index = lua_gettop(L);
			sub.deep = ud->deep + 1;
			sub.array_index = 0;
			sub.array_tag = NULL;
			sub.mainindex_tag = -1;
			sub.key_index = 0;
			r = sproto_decode(args->subtype, bytes+4, sz, decode, &sub);
			if (r < 0 || r != sz)
			{
				lua_settop(L, sub.result_index-1);
				return -1;
			}
			lua_settop(L, sub.result_index);
			args->length -= 4+sz;
			args->value += 4+sz;
			return 0;
		}
		default:
			return luaL_error(L, "Invalid type:%d", type);
	}
}

static int
read_dict(struct sproto_arg *args) {
	struct decode_ud * self = args->ud;
	lua_State *L = self->L;
	if (args->tagname != self->array_tag) {
		// new table
		self->array_tag = args->tagname;
		lua_newtable(L);
		lua_pushvalue(L, -1);
		lua_setfield(L, self->result_index, args->tagname);
		if (self->array_index) {
			lua_replace(L, self->array_index);
		} else {
			self->array_index = lua_gettop(L);
		}
	}
	if(args->length == 0)
	{
		//end
		return 0;
	}
	switch(args->array_type)
	{
		case SPROTO_TIDICT:
			if(_read(args, SPROTO_TINTEGER, L))
			{
				return -1;
			}
			break;
		case SPROTO_TSDICT:
			if(_read(args, SPROTO_TSTRING, L))
			{
				return -1;
			}
			break;
		default:
			return luaL_error(L, "Invalid type:%d", args->array_type);

	}
	if(_read(args, args->type, L))
	{
		// pop key
		lua_pop(L, 1);
		return -1;
	}
	// set
	lua_settable(L, self->array_index);
	return 0;
}

static int
decode(struct sproto_arg *args) {
	struct decode_ud * self = args->ud;
	lua_State *L = self->L;
	if (self->deep >= ENCODE_DEEPLEVEL)
		return luaL_error(L, "The table is too deep");
	switch(args->array_type)
	{
		case SPROTO_TIDICT:
		case SPROTO_TSDICT:
			return read_dict(args);
	}
	if (args->index != 0) {
		// It's array
		if (args->tagname != self->array_tag) {
			self->array_tag = args->tagname;
			lua_newtable(L);
			lua_pushvalue(L, -1);
			lua_setfield(L, self->result_index, args->tagname);
			if (self->array_index) {
				lua_replace(L, self->array_index);
			} else {
				self->array_index = lua_gettop(L);
			}
			if (args->index < 0) {
				// It's a empty array, return now.
				return 0;
			}
		}
	}
	switch (args->type) {
	case SPROTO_TFLOAT: {
		int64_t v = ZigZagDecode64(*(uint64_t*)args->value);
		lua_pushnumber(L, v / FLOAT_PRECISE);
		break;
	}
	case SPROTO_TINTEGER: {
		// notice: in lua 5.2, 52bit integer support (not 64)
		if (args->extra) {
			// lua_Integer is 32bit in small lua.
			int64_t v = ZigZagDecode64(*(uint64_t*)args->value);
			lua_Number vn = (lua_Number)v;
			vn /= args->extra;
			lua_pushnumber(L, vn);
		} else {
			lua_pushinteger(L, ZigZagDecode64(*(uint64_t*)args->value));
		}
		break;
	}
	case SPROTO_TBOOLEAN: {
		int v = *(uint64_t*)args->value;
		lua_pushboolean(L,v);
		break;
	}
	case SPROTO_TSTRING: {
		lua_pushlstring(L, args->value, args->length);
		break;
	}
	case SPROTO_TSTRUCT: {
		struct decode_ud sub;
		int r;

		luaL_checkstack(L, 8, NULL);
		lua_newtable(L);
		sub.L = L;
		sub.result_index = lua_gettop(L);
		sub.deep = self->deep + 1;
		sub.array_index = 0;
		sub.array_tag = NULL;
		if (args->mainindex >= 0) {
			// This struct will set into a map, so mark the main index tag.
			sub.mainindex_tag = args->mainindex;
			lua_pushnil(L);
			sub.key_index = lua_gettop(L);

			r = sproto_decode(args->subtype, args->value, args->length, decode, &sub);
			if (r < 0)
				return SPROTO_CB_ERROR;
			if (r != args->length)
				return r;
			lua_pushvalue(L, sub.key_index);
			if (lua_isnil(L, -1)) {
				luaL_error(L, "Can't find main index (tag=%d) in [%s]", args->mainindex, args->tagname);
			}
			lua_pushvalue(L, sub.result_index);
			lua_settable(L, self->array_index);
			lua_settop(L, sub.result_index-1);
			return 0;
		} else {
			sub.mainindex_tag = -1;
			sub.key_index = 0;
			r = sproto_decode(args->subtype, args->value, args->length, decode, &sub);
			if (r < 0)
				return SPROTO_CB_ERROR;
			if (r != args->length)
				return r;
			lua_settop(L, sub.result_index);
			break;
		}
	}
	default:
		luaL_error(L, "Invalid type");
	}
	if (args->index > 0) {
		lua_seti(L, self->array_index, args->index);
	} else {
		if (self->mainindex_tag == args->tagid) {
			// This tag is marked, save the value to key_index
			// assert(self->key_index > 0);
			lua_pushvalue(L,-1);
			lua_replace(L, self->key_index);
		}
		lua_setfield(L, self->result_index, args->tagname);
	}

	return 0;
}

static const void *
getbuffer(lua_State *L, int index, size_t *sz) {
	const void * buffer = NULL;
	int t = lua_type(L, index);
	if (t == LUA_TSTRING) {
		buffer = lua_tolstring(L, index, sz);
	} else {
		if (t != LUA_TUSERDATA && t != LUA_TLIGHTUSERDATA) {
			luaL_argerror(L, index, "Need a string or userdata");
			return NULL;
		}
		buffer = lua_touserdata(L, index);
		*sz = luaL_checkinteger(L, index+1);
	}
	return buffer;
}

/*
	lightuserdata sproto_type
	string source	/  (lightuserdata , integer)
	return table
 */
static int
ldecode(lua_State *L) {
	struct sproto_type * st = lua_touserdata(L, 1);
	const void * buffer;
	struct decode_ud self;
	size_t sz;
	int r;
	if (st == NULL) {
		// return nil
		return 0;
	}
	sz = 0;
	buffer = getbuffer(L, 2, &sz);
	if (!lua_istable(L, -1)) {
		lua_newtable(L);
	}
	luaL_checkstack(L, 64, NULL);
	self.L = L;
	self.result_index = lua_gettop(L);
	self.array_index = 0;
	self.array_tag = NULL;
	self.deep = 0;
	self.mainindex_tag = -1;
	self.key_index = 0;
	r = sproto_decode(st, buffer, (int)sz, decode, &self);
	if (r < 0) {
		return luaL_error(L, "decode error");
	}
	lua_settop(L, self.result_index);
	lua_pushinteger(L, r);
	return 2;
}

static int
ldumpproto(lua_State *L) {
	struct sproto * sp = lua_touserdata(L, 1);
	if (sp == NULL) {
		return luaL_argerror(L, 1, "Need a sproto_type object");
	}
	sproto_dump(sp);

	return 0;
}


/*
	string source	/  (lightuserdata , integer)
	return string
 */
static int
lpack(lua_State *L) {
	size_t sz=0;
	const void * buffer = getbuffer(L, 1, &sz);
	// the worst-case space overhead of packing is 2 bytes per 2 KiB of input (256 words = 2KiB).
	size_t maxsz = (sz + 2047) / 2048 * 2 + sz + 2;
	void * output = lua_touserdata(L, lua_upvalueindex(1));
	int bytes;
	int osz = lua_tointeger(L, lua_upvalueindex(2));
	if (osz < maxsz) {
		output = expand_buffer(L, osz, maxsz);
	}
	bytes = sproto_pack(buffer, sz, output, maxsz);
	if (bytes > maxsz) {
		return luaL_error(L, "packing error, return size = %d", bytes);
	}
	lua_pushlstring(L, output, bytes);

	return 1;
}

static int
lunpack(lua_State *L) {
	size_t sz=0;
	const void * buffer = getbuffer(L, 1, &sz);
	void * output = lua_touserdata(L, lua_upvalueindex(1));
	int osz = lua_tointeger(L, lua_upvalueindex(2));
	int r = sproto_unpack(buffer, sz, output, osz);
	if (r < 0)
		return luaL_error(L, "Invalid unpack stream");
	if (r > osz) {
		output = expand_buffer(L, osz, r);
		r = sproto_unpack(buffer, sz, output, r);
		if (r < 0)
			return luaL_error(L, "Invalid unpack stream");
	}
	lua_pushlstring(L, output, r);
	return 1;
}

static void
pushfunction_withbuffer(lua_State *L, const char * name, lua_CFunction func) {
	lua_newuserdata(L, ENCODE_BUFFERSIZE);
	lua_pushinteger(L, ENCODE_BUFFERSIZE);
	lua_pushcclosure(L, func, 2);
	lua_setfield(L, -2, name);
}

static int
lprotocol(lua_State *L) {
	struct sproto * sp = lua_touserdata(L, 1);
	struct sproto_type * request;
	struct sproto_type * response;
	int t;
	int tag;
	if (sp == NULL) {
		return luaL_argerror(L, 1, "Need a sproto_type object");
	}
	t = lua_type(L,2);
	if (t == LUA_TNUMBER) {
		const char * name;
		tag = lua_tointeger(L, 2);
		name = sproto_protoname(sp, tag);
		if (name == NULL)
			return 0;
		lua_pushstring(L, name);
	} else {
		const char * name = lua_tostring(L, 2);
		if (name == NULL) {
			return luaL_argerror(L, 2, "Should be number or string");
		}
		tag = sproto_prototag(sp, name);
		if (tag < 0)
			return 0;
		lua_pushinteger(L, tag);
	}
	request = sproto_protoquery(sp, tag, SPROTO_REQUEST);
	if (request == NULL) {
		lua_pushnil(L);
	} else {
		lua_pushlightuserdata(L, request);
	}
	response = sproto_protoquery(sp, tag, SPROTO_RESPONSE);
	if (response == NULL) {
		if (sproto_protoresponse(sp, tag)) {
			lua_pushlightuserdata(L, NULL);	// response nil
		} else {
			lua_pushnil(L);
		}
	} else {
		lua_pushlightuserdata(L, response);
	}
	return 3;
}

/* global sproto pointer for multi states
   NOTICE : It is not thread safe
 */
static struct sproto * G_sproto[MAX_GLOBALSPROTO];

static int
lsaveproto(lua_State *L) {
	struct sproto * sp = lua_touserdata(L, 1);
	int index = luaL_optinteger(L, 2, 0);
	if (index < 0 || index >= MAX_GLOBALSPROTO) {
		return luaL_error(L, "Invalid global slot index %d", index);
	}
	/* TODO : release old object (memory leak now, but thread safe)*/
	G_sproto[index] = sp;
	return 0;
}

static int
lloadproto(lua_State *L) {
	int index = luaL_optinteger(L, 1, 0);
	struct sproto * sp;
	if (index < 0 || index >= MAX_GLOBALSPROTO) {
		return luaL_error(L, "Invalid global slot index %d", index);
	}
	sp = G_sproto[index];
	if (sp == NULL) {
		return luaL_error(L, "nil sproto at index %d", index);
	}

	lua_pushlightuserdata(L, sp);

	return 1;
}

static void
push_default(const struct sproto_arg *args, int array) {
	lua_State *L = args->ud;
	switch(args->type) {
	case SPROTO_TINTEGER:
		if (args->extra)
			lua_pushnumber(L, 0.0);
		else
			lua_pushinteger(L, 0);
		break;
	case SPROTO_TFLOAT:
			lua_pushnumber(L, 0.0);
			break;
	case SPROTO_TBOOLEAN:
		lua_pushboolean(L, 0);
		break;
	case SPROTO_TSTRING:
		lua_pushliteral(L, "");
		break;
	case SPROTO_TSTRUCT:
		if (array) {
			lua_pushstring(L, sproto_name(args->subtype));
		} else {
			lua_createtable(L, 0, 1);
			lua_pushstring(L, sproto_name(args->subtype));
			lua_setfield(L, -2, "__type");
		}
		break;
	default:
		luaL_error(L, "Invalid type %d", args->type);
		break;
	}
}

static int
encode_default(struct sproto_arg *args) {
	lua_State *L = args->ud;
	lua_pushstring(L, args->tagname);
	if (args->array_type) {
		lua_newtable(L);
		push_default(args, 1);
		lua_setfield(L, -2, "__array");
		lua_rawset(L, -3);
		return SPROTO_CB_NOARRAY;
	} else {
		push_default(args, 0);
		lua_rawset(L, -3);
		return SPROTO_CB_NIL;
	}
}

/*
	lightuserdata sproto_type
	return default table
 */
static int
ldefault(lua_State *L) {
	int ret;
	// 64 is always enough for dummy buffer, except the type has many fields ( > 27).
	char dummy[64];
	struct sproto_type * st = lua_touserdata(L, 1);
	if (st == NULL) {
		return luaL_argerror(L, 1, "Need a sproto_type object");
	}
	lua_newtable(L);
	ret = sproto_encode(st, dummy, sizeof(dummy), encode_default, L);
	if (ret<0) {
		// try again
		int sz = sizeof(dummy) * 2;
		void * tmp = lua_newuserdata(L, sz);
		lua_insert(L, -2);
		for (;;) {
			ret = sproto_encode(st, tmp, sz, encode_default, L);
			if (ret >= 0)
				break;
			sz *= 2;
			tmp = lua_newuserdata(L, sz);
			lua_replace(L, -3);
		}
	}
	return 1;
}

LUAMOD_API int
luaopen_sproto_core(lua_State *L) {
#ifdef luaL_checkversion
	luaL_checkversion(L);
#endif
	luaL_Reg l[] = {
		{ "newproto", lnewproto },
		{ "deleteproto", ldeleteproto },
		{ "dumpproto", ldumpproto },
		{ "querytype", lquerytype },
		{ "decode", ldecode },
		{ "protocol", lprotocol },
		{ "loadproto", lloadproto },
		{ "saveproto", lsaveproto },
		{ "default", ldefault },
		{ NULL, NULL },
	};
#if LUA_VERSION_NUM < 502
	const char* libName = "sproto.core";
	luaL_register(L, libName, l);
#else
	luaL_newlib(L, l);
#endif
	pushfunction_withbuffer(L, "encode", lencode);
	pushfunction_withbuffer(L, "pack", lpack);
	pushfunction_withbuffer(L, "unpack", lunpack);
	return 1;
}
