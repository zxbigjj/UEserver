rm *o
INCLUDE=../../skynet/3rd/lua
gcc -O0 -g -fpic -I $INCLUDE -c -o lua-uuid.o lua-uuid.c
gcc -O0 -g -shared -fpic -I$INCLUDE -o luuid.so lua-uuid.o -lm
../../bin/lua test.lua
