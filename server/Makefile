.PHONY: all clean build lua53_Build skynet build-skynet

PLATFORM?=linux

ROOT=$(PWD)
BIN_DIR=./bin
BUILD_DIR=./build

INCLUDE_DIR=$(BUILD_DIR)/include
SPROTO_DIR=$(BUILD_DIR)/sproto
BUILD_CLUALIB_DIR=$(BUILD_DIR)/clualib
BUILD_LOCAL_CLUALIB_DIR = $(BUILD_DIR)/lclualib
BUILD_LUALIB_DIR=$(BUILD_DIR)/lualib
BUILD_CSERVICE_DIR=$(BUILD_DIR)/cservice
BUILD_CLIB_DIR=$(BUILD_DIR)/clib
BUILD_STATIC_LIB=$(BUILD_DIR)/static_lib

mini: proto

mini: data

all: build

build:
	-mkdir $(BUILD_DIR)
	-mkdir $(BIN_DIR)
	-mkdir $(BUILD_CSERVICE_DIR)
	-mkdir $(BUILD_CLIB_DIR)
	-mkdir $(INCLUDE_DIR)

# Build Lua 5.3 begin
all: lua53_Build

LUA_LIB = $(BUILD_STATIC_LIB)/liblua.a
LUA_INC = $(INCLUDE_DIR)

lua53_Build:
	cd skynet/3rd/lua/ && $(MAKE) MYCFLAGS="-O2 -fPIC -g -I../../skynet-src" $(PLATFORM)
	install -p -m 0755 skynet/3rd/lua/lua $(BIN_DIR)/lua
	install -p -m 0755 skynet/3rd/lua/luac $(BIN_DIR)/luac
	install -p -m 0644 skynet/3rd/lua/liblua.a $(BUILD_STATIC_LIB)
	install -p -m 0644 skynet/3rd/lua/lua.h $(INCLUDE_DIR)
	install -p -m 0644 skynet/3rd/lua/lauxlib.h $(INCLUDE_DIR)
	install -p -m 0644 skynet/3rd/lua/lualib.h $(INCLUDE_DIR)
	install -p -m 0644 skynet/3rd/lua/luaconf.h $(INCLUDE_DIR)

# Build Lua 5.3 end

# Build Skynet begin
all: skynet
SKYNET_MAKEFILE=skynet/Makefile

skynet: build-skynet
	cp skynet/skynet-src/skynet_malloc.h $(INCLUDE_DIR)
	cp skynet/skynet-src/skynet.h $(INCLUDE_DIR)
	cp skynet/skynet-src/skynet_env.h $(INCLUDE_DIR)
	cp skynet/skynet-src/skynet_socket.h $(INCLUDE_DIR)

SKYNET_DEP_PATH = SKYNET_BUILD_PATH=../$(BIN_DIR) \
		LUA_CLIB_PATH=../$(BUILD_CLUALIB_DIR) \
		CSERVICE_PATH=../$(BUILD_CSERVICE_DIR)

build-skynet: | $(SKYNET_MAKEFILE)
	cd skynet && $(MAKE) PLAT=$(PLATFORM) $(SKYNET_DEP_PATH)
# Build Skynet end

# Build CService Begin
CFLAGS = -g3 -O2 -rdynamic -Wall -I$(INCLUDE_DIR) 
WEAK_CFLAGS = -g3 -O2 -rdynamic -Wall -I$(INCLUDE_DIR)
LDFLAGS = -L$(BUILD_CLIB_DIR) -Wl,-rpath $(BUILD_CLIB_DIR) -pthread -lm -ldl -lrt
LUALIB_CFLAGS = -g -O2 -Wall -I$(LUA_INC) $(MYCFLAGS) --std=c99

ifeq ($(PLATFORM), linux)
SHARED = -fPIC --shared
LUALIB_CPPFLAGS = -g -O2 -Wall -I$(LUA_INC) $(MYCFLAGS) --std=c++11
else
SHARED = -fPIC -dynamiclib -Wl,-undefined,dynamic_lookup
LUALIB_CPPFLAGS = -g -O2 -Wall -I$(LUA_INC) $(MYCFLAGS) -std=c++11 -stdlib=libstdc++ -Wno-error=c++11-narrowing
endif

# Build CLualib begin
CLUALIB=luuid lfs skiplist cjson LuaXML_lib luaprofiler snapshot bin_utils aes
CLUALIB_TARGET=$(patsubst %, $(BUILD_CLUALIB_DIR)/%.so, $(CLUALIB))

all: clualib

clualib: $(CLUALIB_TARGET)

$(BUILD_CLUALIB_DIR)/luuid.so : lualib_c/uuid/lua-uuid.c
	gcc $(LUALIB_CFLAGS) $(SHARED) $^ -o $@

$(BUILD_CLUALIB_DIR)/lfs.so : lualib_c/lfs/lfs.c
	gcc $(LUALIB_CFLAGS) $(SHARED) $^ -Ilualib_c/lfs -o $@

$(BUILD_CLUALIB_DIR)/skiplist.so : lualib_c/zset/*.c
	gcc $(LUALIB_CFLAGS) $(SHARED) $^ -Ilualib_c/zset -o $@

$(BUILD_CLUALIB_DIR)/cjson.so : lualib_c/cjson/lua_cjson.c lualib_c/cjson/strbuf.c lualib_c/cjson/fpconv.c
	gcc $(LUALIB_CFLAGS) $(SHARED) $^ -Ilualib_c/cjson -o $@

$(BUILD_CLUALIB_DIR)/LuaXML_lib.so : lualib_c/luaxml/LuaXML_lib.c
	gcc $(LUALIB_CFLAGS) $(SHARED) $^ -Ilualib_c/luaxml -o $@

$(BUILD_CLUALIB_DIR)/snapshot.so : lualib_c/snapshot/snapshot.c
	gcc $(LUALIB_CFLAGS) $(SHARED) $^ -Ilualib_c/snapshot -o $@

$(BUILD_CLUALIB_DIR)/bin_utils.so : lualib_c/bin_utils/lbin_utils.c
	gcc $(LUALIB_CFLAGS) $(SHARED) $^ -Ilualib_c/bin_utils -o $@

$(BUILD_CLUALIB_DIR)/aes.so : lualib_c/aes/*.c
	gcc $(LUALIB_CFLAGS) $(SHARED) $^ -Ilualib_c/aes -o $@

ifeq ($(PLATFORM), linux)
$(BUILD_CLUALIB_DIR)/luaprofiler.so : lualib_c/profiler/luaprofiler.cc lualib_c/profiler/lluaprofiler.cc
	g++ $(LUALIB_CPPFLAGS) $(SHARED) $^ -Ilualib_c/profiler -o $@
else
$(BUILD_CLUALIB_DIR)/luaprofiler.so :
	echo "macos profiler need fix type"
endif


# $(BUILD_CLUALIB_DIR)/luuid.so : lualib_c/uuid/lua-uuid.c
#	gcc -O -g -fpic -I$(LUA_INC) -c -o lualib_c/uuid/lua-uuid.o lualib_c/uuid/lua-uuid.c
#	gcc $(CFLAGS) $(SHARED) $^ -o $@ $(LDFLAGS)
# Build CLualib end


# define make clean cmd begin
define CLEAN_SKYNET
	cd skynet && $(MAKE) clean $(SKYNET_DEP_PATH)
endef

CLEAN_ALL += $(CLEAN_SKYNET)

clean:
	-rm -rf build
	$(CLEAN_ALL)

# define make clean cmd end

all: proto

proto:
	-mkdir $(ROOT)/../sharedata/sproto/bin
	cd $(ROOT) && cp $(BUILD_CLUALIB_DIR)/lpeg.so $(ROOT)/3rd/sprotodump/
	chmod +x $(ROOT)/bin/lua
	chmod +x $(ROOT)/bin/skynet
	cd $(ROOT)/3rd/sprotodump/ && $(ROOT)/bin/lua sprotodump.lua -spb `find -L $(ROOT)/../sharedata/sproto/client -name "*.sproto"` `find -L  $(ROOT)/../sharedata/sproto/common -name "*.sproto"` -o $(ROOT)/../sharedata/sproto/bin/c2s.spb
	cd $(ROOT)/3rd/sprotodump/ && $(ROOT)/bin/lua sprotodump.lua -spb `find -L $(ROOT)/../sharedata/sproto/server -name "*.sproto"` `find -L  $(ROOT)/../sharedata/sproto/common -name "*.sproto"` -o $(ROOT)/../sharedata/sproto/bin/s2c.spb
	rm $(ROOT)/3rd/sprotodump/lpeg.so
	cp $(ROOT)/../sharedata/sproto/bin/*.spb $(ROOT)/bin/

all: data


ifeq ($(PLATFORM), linux)
DATA_SH = run.sh
else
DATA_SH = run_mac.sh
endif

data:
	# -rm $(ROOT)/exceldata/*.lua

	# -mkdir $(ROOT)/exceldata
	# -mkdir $(ROOT)/exceldata/AI
	# -mkdir $(ROOT)/exceldata/MapLogic
	# -mkdir $(ROOT)/exceldata/navmeshdata
	# -mkdir $(ROOT)/exceldata/MapPos
	# -mkdir $(ROOT)/exceldata/Timeline
	# -mkdir $(ROOT)/exceldata/Cutscene


	# -rm $(ROOT)/exceldata/AI/*.lua
	# -rm $(ROOT)/exceldata/MapLogic/*.lua
	# -rm $(ROOT)/exceldata/navmeshdata/*.bytes
	# -rm $(ROOT)/exceldata/MapPos/*
	# -rm $(ROOT)/exceldata/Timeline/*
	# -rm $(ROOT)/exceldata/Cutscene/*

	cd $(ROOT)/../sharedata/exceldata/ && sh $(DATA_SH)

	rsync -c $(ROOT)/../sharedata/exceldata/data/server/*.* $(ROOT)/exceldata
	# -cp $(ROOT)/../sharedata/converteddata/AI/*.lua $(ROOT)/exceldata/AI/
	# -cp $(ROOT)/../sharedata/converteddata/*.lua $(ROOT)/exceldata/
	# -cp $(ROOT)/../sharedata/converteddata/MapLogic/*.lua $(ROOT)/exceldata/MapLogic/
	# -cp $(ROOT)/../sharedata/converteddata/MapPos/*.lua $(ROOT)/exceldata/MapPos/
	# -cp $(ROOT)/../sharedata/converteddata/Timeline/*.lua $(ROOT)/exceldata/Timeline/
	# -cp $(ROOT)/../sharedata/converteddata/Cutscene/*.lua $(ROOT)/exceldata/Cutscene/
	# -cp $(ROOT)/../sharedata/navmeshdata/*.bytes $(ROOT)/exceldata/navmeshdata/

all:
	@echo 'make finish!!!'

mac:
	$(MAKE) all PLATFORM=macosx