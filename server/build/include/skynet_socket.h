#ifndef skynet_socket_h
#define skynet_socket_h

#include "socket_info.h"

struct skynet_context;

#define SKYNET_SOCKET_TYPE_DATA 1
#define SKYNET_SOCKET_TYPE_CONNECT 2
#define SKYNET_SOCKET_TYPE_CLOSE 3
#define SKYNET_SOCKET_TYPE_ACCEPT 4
#define SKYNET_SOCKET_TYPE_ERROR 5
#define SKYNET_SOCKET_TYPE_UDP 6
#define SKYNET_SOCKET_TYPE_WARNING 7

struct skynet_socket_message {
	int type;
	int id;
	int ud;
	char * buffer;
};

void skynet_socket_init();
void skynet_socket_exit();
void skynet_socket_free();
int skynet_socket_poll();
void skynet_socket_updatetime();

int skynet_socket_send(struct skynet_context *ctx, int id, void *buffer, int sz);
int skynet_socket_send_lowpriority(struct skynet_context *ctx, int id, void *buffer, int sz);
int skynet_socket_listen(struct skynet_context *ctx, const char *host, int port, int backlog);
int skynet_socket_connect(struct skynet_context *ctx, const char *host, int port);
int skynet_socket_bind(struct skynet_context *ctx, int fd);
void skynet_socket_close(struct skynet_context *ctx, int id);
void skynet_socket_shutdown(struct skynet_context *ctx, int id);
void skynet_socket_start(struct skynet_context *ctx, int id);
void skynet_socket_nodelay(struct skynet_context *ctx, int id);

int skynet_socket_udp(struct skynet_context *ctx, const char * addr, int port);
int skynet_socket_udp_connect(struct skynet_context *ctx, int id, const char * addr, int port);
int skynet_socket_udp_send(struct skynet_context *ctx, int id, const char * address, const void *buffer, int sz);
const char * skynet_socket_udp_address(struct skynet_socket_message *, int *addrsz);

struct socket_info * skynet_socket_info();
////////////////////////////////采用引用计数管理的buffer
struct buffer_auto {
    void * raw_buff;    // 正在的buffer
    int sz;             // 有效的buffer size, 可能是buffer的前一段
    int ref_count;      // 引用计数
    struct spinlock * lock; // 加锁
};


// 创建完后引用计数为1
struct buffer_auto * buffer_auto_create(void* raw_buff, int sz);
void buffer_auto_use(void * p);
void buffer_auto_free(void * p);
void * buffer_auto_get_raw(void * p);
int buffer_auto_get_sz(void * p);
//////////////////////////////////////////////////////

#endif
