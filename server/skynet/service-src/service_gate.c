#include "skynet.h"
#include "skynet_socket.h"
#include "databuffer.h"
#include "hashid.h"
#include "spinlock.h"

#include <pthread.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdarg.h>
#include <sys/syscall.h>
#include <unistd.h>
#include <errno.h>

#define BACKLOG 128

struct RequestSendNode {
	int id;
	int sz;
	char * buffer;
	struct RequestSendNode * next;
	char op;
};

struct SendWorkerCtx {
	struct skynet_context *sk_ctx;
	int pipe_out;
	int pipe_in;
	struct spinlock *lock;
	struct RequestSendNode * req_list_head;
	struct RequestSendNode * req_list_tail;
};

struct connection {
	int id;	// skynet_socket id
	uint32_t agent;
	uint32_t client;
	int discard_income;
	int user_id;
	char remote_name[32];
	struct databuffer buffer;
};

struct gate {
	struct skynet_context *ctx;
	int listen_id;
	uint32_t watchdog;
	uint32_t broker;
	int client_tag;
	int header_size;
	int max_connection;
	struct hashid hash;
	struct hashid user_id_hash;
	struct connection *conn;
	int * user_id_map;
	// todo: save message pool ptr for release
	struct messagepool mp;

	// 多线程发送
	int sender_worker_count;
	pthread_t *send_worker_pids;
	struct SendWorkerCtx *send_worker_ctx;
};

static int gettid()
{
    return syscall(SYS_gettid);
}

static void sharding_close(struct gate *g, int id);

static void sharding_send(struct gate *g, int id, const void * buffer, int sz);

struct gate *
gate_create(void) {
	struct gate * g = skynet_malloc(sizeof(*g));
	memset(g,0,sizeof(*g));
	g->listen_id = -1;
	return g;
}

void
gate_release(struct gate *g) {
	int i;
	struct skynet_context *ctx = g->ctx;
	for (i=0;i<g->max_connection;i++) {
		struct connection *c = &g->conn[i];
		if (c->id >=0) {
			skynet_socket_close(ctx, c->id);
		}
	}
	if (g->listen_id >= 0) {
		skynet_socket_close(ctx, g->listen_id);
	}
	messagepool_free(&g->mp);
	hashid_clear(&g->hash);
	hashid_clear(&g->user_id_hash);
	skynet_free(g->conn);
	skynet_free(g->user_id_map);

	for (i=0;i<g->sender_worker_count;i++) {
		close(g->send_worker_ctx[i].pipe_in);
		// sender线程会close pipe_out
	}
	for (i=0;i<g->sender_worker_count;i++) {
		pthread_join(g->send_worker_pids[i], NULL);
		spinlock_destroy(g->send_worker_ctx[i].lock);
		skynet_free(g->send_worker_ctx[i].lock);
	}
	skynet_free(g->send_worker_ctx);
	skynet_free(g->send_worker_pids);
	skynet_free(g);
}

static void
_parm(char *msg, int sz, int command_sz) {
	while (command_sz < sz) {
		if (msg[command_sz] != ' ')
			break;
		++command_sz;
	}
	int i;
	for (i=command_sz;i<sz;i++) {
		msg[i-command_sz] = msg[i];
	}
	msg[i-command_sz] = '\0';
}

static void
_forward_agent(struct gate * g, int fd, uint32_t agentaddr, uint32_t clientaddr) {
	int id = hashid_lookup(&g->hash, fd);
	if (id >=0) {
		struct connection * agent = &g->conn[id];
		agent->agent = agentaddr;
		agent->client = clientaddr;
	}
}

static int
_ctrl(struct gate * g, const void * msg, int sz) {
	struct skynet_context * ctx = g->ctx;
	char tmp[sz+1];
	memcpy(tmp, msg, sz);
	tmp[sz] = '\0';
	char * command = tmp;
	int i;
	if (sz == 0)
		return -1;
	for (i=0;i<sz;i++) {
		if (command[i]==' ') {
			break;
		}
	}
	if (memcmp(command,"kick",i)==0) {
		_parm(tmp, sz, i);
		int uid = strtol(command , NULL, 10);
		int id = hashid_lookup(&g->hash, uid);
		if (id>=0) {
			sharding_close(g, uid);
		}
		return 0;
	}
	if (memcmp(command,"forward",i)==0) {
		_parm(tmp, sz, i);
		char * client = tmp;
		char * idstr = strsep(&client, " ");
		if (client == NULL) {
			return -1;
		}
		int id = strtol(idstr , NULL, 10);
		char * agent = strsep(&client, " ");
		if (client == NULL) {
			return -2;
		}
		uint32_t agent_handle = strtoul(agent+1, NULL, 16);
		uint32_t client_handle = strtoul(client+1, NULL, 16);
		_forward_agent(g, id, agent_handle, client_handle);
		return 0;
	}
	if (memcmp(command,"broker",i)==0) {
		_parm(tmp, sz, i);
		g->broker = skynet_queryname(ctx, command);
		return 0;
	}
	if (memcmp(command,"bind",i) == 0) {
		_parm(tmp, sz, i);
		int sock_id, user_id;
		int n = sscanf(command, "%d %d", &sock_id, &user_id);
		if (n<2) {
			return -1;
		}
		int id = hashid_lookup(&g->hash, sock_id);
		if (id>=0) {
			struct connection *c = &g->conn[id];
			if (c->user_id > 0) {
				// unbind old
				hashid_remove(&g->user_id_hash, c->user_id);
			}
			if (user_id > 0) {
				int new_id = hashid_insert(&g->user_id_hash, user_id);
				g->user_id_map[new_id] = sock_id;
				c->user_id = user_id;
			}
			else {
				c->user_id = 0;
			}
		}
		return 0;
	}
	if (memcmp(command,"discard_income_on",i) == 0) {
		_parm(tmp, sz, i);
		int uid = strtol(command , NULL, 10);
		int id = hashid_lookup(&g->hash, uid);
		if (id>=0) {
			struct connection *c = &g->conn[id];
			c->discard_income = 1;
		}
		return 0;
	}
	if (memcmp(command,"discard_income_off",i) == 0) {
		_parm(tmp, sz, i);
		int uid = strtol(command , NULL, 10);
		int id = hashid_lookup(&g->hash, uid);
		if (id>=0) {
			struct connection *c = &g->conn[id];
			c->discard_income = 0;
		}
		return 0;
	}
	if (memcmp(command,"connect",i) == 0) {
		_parm(tmp, sz, i);
		char * p = tmp;
		char * host = strsep(&p, " ");
		if (host == NULL) {
			return -1;
		}
		char * port = strsep(&p, " ");
		if (port == NULL) {
			return -2;
		}
		int i_port = strtol(port, NULL, 10);
		if (i_port == 0) {
			return -3;
		}
		int id = skynet_socket_connect(ctx, host, i_port);
		if (id <= 0) {
			return -4;
		}

		struct connection *c = &g->conn[hashid_insert(&g->hash, id)];
		int host_len = strlen(host);
		if (host_len >= sizeof(c->remote_name)) {
			host_len = sizeof(c->remote_name) - 1;
		}
		c->id = id;
		c->discard_income = 0;
		c->user_id = 0;
		memcpy(c->remote_name, host, host_len);
		c->remote_name[host_len] = '\0';
		return id;
	}
	if (memcmp(command,"start",i) == 0) {
		_parm(tmp, sz, i);
		int uid = strtol(command , NULL, 10);
		int id = hashid_lookup(&g->hash, uid);
		if (id>=0) {
			skynet_socket_start(ctx, uid);
		}
		return 0;
	}
	if (memcmp(command, "close", i) == 0) {
		if (g->listen_id >= 0) {
			skynet_socket_close(ctx, g->listen_id);
			g->listen_id = -1;
		}
		return 0;
	}
	skynet_error(ctx, "[gate] Unkown command : %s", command);
	return -1;
}

static void
_report(struct gate * g, const char * data, ...) {
	if (g->watchdog == 0) {
		return;
	}
	struct skynet_context * ctx = g->ctx;
	va_list ap;
	va_start(ap, data);
	char tmp[1024];
	int n = vsnprintf(tmp, sizeof(tmp), data, ap);
	va_end(ap);

	skynet_send(ctx, 0, g->watchdog, PTYPE_TEXT,  0, tmp, n);
}

static void
_forward(struct gate *g, struct connection * c, int size) {
	struct skynet_context * ctx = g->ctx;
	if (c->id <= 0 || c->discard_income) {
		// todo: 有时间可以优化掉拷贝
		char temp[4096];
		for(;;) {
			if(size > 4096) {
				databuffer_read(&c->buffer,&g->mp,temp, 4096);
				size -= 4096;
			} else {
				databuffer_read(&c->buffer,&g->mp,temp, size);
				break;
			}
		}
		return;
	}
	if (g->broker) {
		void * temp = skynet_malloc(size);
		databuffer_read(&c->buffer,&g->mp,temp, size);
		skynet_send(ctx, 0, g->broker, g->client_tag | PTYPE_TAG_DONTCOPY, c->id, temp, size);
		return;
	}
	if (c->agent) {
		void * temp = skynet_malloc(size);
		databuffer_read(&c->buffer,&g->mp,temp, size);
		skynet_send(ctx, c->client, c->agent, g->client_tag | PTYPE_TAG_DONTCOPY, c->id, temp, size);
	} else if (g->watchdog) {
		void * temp = skynet_malloc(size);
		databuffer_read(&c->buffer,&g->mp,temp,size);
		skynet_send(ctx, 0, g->watchdog, g->client_tag | PTYPE_TAG_DONTCOPY, c->id, temp, size);
	}
}

static void
dispatch_message(struct gate *g, struct connection *c, int id, void * data, int sz) {
	databuffer_push(&c->buffer,&g->mp, data, sz);
	for (;;) {
		int size = databuffer_readheader(&c->buffer, &g->mp, g->header_size);
		if (size < 0) {
			return;
		} else if (size > 0) {
			if (size >= 0x1000000) {
				struct skynet_context * ctx = g->ctx;
				databuffer_clear(&c->buffer,&g->mp);
				sharding_close(g, id);
				skynet_error(ctx, "Recv socket message > 16M");
				return;
			} else {
				_forward(g, c, size);
				databuffer_reset(&c->buffer);
			}
		}
	}
}

static void
dispatch_socket_message(struct gate *g, const struct skynet_socket_message * message, int sz) {
	struct skynet_context * ctx = g->ctx;
	switch(message->type) {
	case SKYNET_SOCKET_TYPE_DATA: {
		int id = hashid_lookup(&g->hash, message->id);
		if (id>=0) {
			struct connection *c = &g->conn[id];
			dispatch_message(g, c, message->id, message->buffer, message->ud);
		} else {
			skynet_error(ctx, "Drop unknown connection %d message", message->id);
			sharding_close(g, message->id);
			skynet_free(message->buffer);
		}
		break;
	}
	case SKYNET_SOCKET_TYPE_CONNECT: {
		if (message->id == g->listen_id) {
			// start listening
			break;
		}
		int id = hashid_lookup(&g->hash, message->id);
		if (id<0) {
			skynet_error(ctx, "Close unknown connection %d", message->id);
			sharding_close(g, message->id);
		} else {
			_report(g, "sock_connect %d", message->id);
		}
		break;
	}
	case SKYNET_SOCKET_TYPE_CLOSE: 
	case SKYNET_SOCKET_TYPE_ERROR: {
		int id = hashid_remove(&g->hash, message->id);
		if (id>=0) {
			struct connection *c = &g->conn[id];
			if (c->user_id) {
				hashid_remove(&g->user_id_hash, c->user_id);
			}
			databuffer_clear(&c->buffer,&g->mp);
			memset(c, 0, sizeof(*c));
			c->id = -1;
			if (message->type == SKYNET_SOCKET_TYPE_ERROR) {
				_report(g, "sock_error %d", message->id);
			}
			else {
				_report(g, "close_sock %d", message->id);
			}
		}
		break;
	}
	case SKYNET_SOCKET_TYPE_ACCEPT:
		// report accept, then it will be get a SKYNET_SOCKET_TYPE_CONNECT message
		assert(g->listen_id == message->id);
		if (hashid_full(&g->hash)) {
			sharding_close(g, message->ud);
		} else {
			struct connection *c = &g->conn[hashid_insert(&g->hash, message->ud)];
			if (sz >= sizeof(c->remote_name)) {
				sz = sizeof(c->remote_name) - 1;
			}
			c->id = message->ud;
			c->discard_income = 0;
			c->user_id = 0;
			memcpy(c->remote_name, message+1, sz);
			c->remote_name[sz] = '\0';
			_report(g, "accept_sock %d %s", c->id, c->remote_name);
			skynet_error(ctx, "socket open: %x", c->id);
		}
		break;
	case SKYNET_SOCKET_TYPE_WARNING:
		skynet_error(ctx, "fd (%d) send buffer (%d)K", message->id, message->ud);
		break;
	}
}

static int unpack_int32(const char * buffer) {
    const unsigned char * p = (const unsigned char *)buffer;
    int i = p[0] | p[1] << 8 | p[2] << 16 | p[3] << 24;
    return i;
}

static int
_cb(struct skynet_context * ctx, void * ud, int type, int session, uint32_t source, const void * msg, size_t sz) {
	struct gate *g = ud;
	switch(type) {
	case PTYPE_TEXT: {
		int ret = _ctrl(g , msg , (int)sz);
		if(session > 0) {
			char resp[20];
			int sz = snprintf(resp, 20, "%d", ret);
			if(sz < 0) {
				skynet_send(ctx, 0, source, PTYPE_RESPONSE, session , "-1", 2);
			} else {
				skynet_send(ctx, 0, source, PTYPE_RESPONSE, session , resp, sz);
			}
		}
		break;
	}
	case PTYPE_CLIENT: {
		if (session != 0) {
			if (sz <= 0 ) {
				skynet_error(ctx, "Invalid client message from %x",source);
				break;
			}
			// 非广播
			// session就是sock_id
			uint32_t uid = session;
			int id = hashid_lookup(&g->hash, uid);
			if (id>=0) {
				// don't send id (last 4 bytes)
				sharding_send(g, uid, (void*)msg, sz);
				// return 1 means don't free msg
				return 1;
			} else {
				skynet_error(ctx, "Invalid client id %d from %x",(int)uid,source);
				// return 0 means free msg
				return 0;
			}
		} else {
			// 广播, 格式显示userid列表， 然后是userid总数量, 最后是要排除的userid
			// 全是<i4编码
			if (sz < 8 ) {
				skynet_error(ctx, "Invalid client message from %x",source);
				break;
			}
			int exclude_user_id = unpack_int32(msg+sz-4);
			int user_cnt = unpack_int32(msg+sz-8);
			int data_sz = sz - 8 - 4 * user_cnt;
			int i = 0;

			struct buffer_auto * p_auto = buffer_auto_create((void*)msg, data_sz);
			for(; i<user_cnt; i++)
			{
				int user_id = unpack_int32(msg + data_sz + i*4);
				if (user_id == 0 || user_id == exclude_user_id) {continue;}
				int id = hashid_lookup(&g->user_id_hash, user_id);
				if (id < 0) {
					continue;
				}
				int sock_id = g->user_id_map[id];
				id = hashid_lookup(&g->hash, sock_id);
				if (id < 0) {
					continue;
				}
				// -1表明使用自定义的buffer类型
				buffer_auto_use(p_auto);
				sharding_send(g, sock_id, (void*)p_auto, -1);
			}
			buffer_auto_free(p_auto);
			// return 1 means don't free msg
			return 1;
		}
	}
	case PTYPE_SOCKET:
		// recv socket message from skynet_socket
		dispatch_socket_message(g, msg, (int)(sz-sizeof(struct skynet_socket_message)));
		break;
	}
	return 0;
}

static int
start_listen(struct gate *g, char * listen_addr) {
	struct skynet_context * ctx = g->ctx;
	char * portstr = strrchr(listen_addr,':');
	const char * host = "";
	int port;
	if (portstr == NULL) {
		port = strtol(listen_addr, NULL, 10);
		if (port <= 0) {
			skynet_error(ctx, "Invalid gate address %s",listen_addr);
			return 1;
		}
	} else {
		port = strtol(portstr + 1, NULL, 10);
		if (port <= 0) {
			skynet_error(ctx, "Invalid gate address %s",listen_addr);
			return 1;
		}
		portstr[0] = '\0';
		host = listen_addr;
	}
	g->listen_id = skynet_socket_listen(ctx, host, port, BACKLOG);
	if (g->listen_id < 0) {
		return 1;
	}
	skynet_socket_start(ctx, g->listen_id);
	return 0;
}


// 线程安全
static void _sharding_send(struct gate *g, int id, char op, const void * buffer, int sz) {
	int index = id % g->sender_worker_count;
	struct SendWorkerCtx * ctx = &(g->send_worker_ctx[index]);
	int need_notify = 0;

	struct RequestSendNode * req_node = skynet_malloc(sizeof(struct RequestSendNode));
	req_node->id = id;
	req_node->op = op;
	req_node->sz = sz;
	req_node->buffer = (char *)buffer;
	req_node->next = NULL;

	spinlock_lock(ctx->lock);
	if (ctx->req_list_head == NULL) {
		need_notify = 1;
		ctx->req_list_head = req_node;
		ctx->req_list_tail = req_node;
	} else {
		ctx->req_list_tail->next = req_node;
		ctx->req_list_tail = req_node;
	}
	spinlock_unlock(ctx->lock);

	if (need_notify) {
		for (;;) {
			ssize_t n = write(ctx->pipe_in, "w", 1);
			if (n<0) {
				if (errno != EINTR) {
					fprintf(stderr, "socket-server : send ctrl command error %s.\n", strerror(errno));
				}
				continue;
			}
			assert(n == 1);
			return;
		}
	}
}

static void sharding_close(struct gate *g, int id) {
	_sharding_send(g, id, 'c', NULL, 0);
}

// 线程安全
static void sharding_send(struct gate *g, int id, const void * buffer, int sz) {
	_sharding_send(g, id, 's', buffer, sz);
}

static void * send_thread_worker(void * args) {
	printf("CreateThread: %d, socket_send_worker\n", gettid());
	struct SendWorkerCtx * ctx = (struct SendWorkerCtx *) args;
	int fd = ctx->pipe_out;
	
	struct RequestSendNode * head;
	struct RequestSendNode * next;

	char buffer[10];	// 不重要
	for (;;) {
		int n = read(fd, buffer, 10);
		if (n <= 0) {
			if (n == 0) {
				break;
			}
			if (errno == EINTR) {
				continue;
			} else {
				fprintf(stderr, "socket-server : read pipe error %s.\n",strerror(errno));
				break;
			}
		}
		// got to work
		for(;;) {
			spinlock_lock(ctx->lock);
			head = ctx->req_list_head;
			ctx->req_list_head = NULL;
			ctx->req_list_tail = NULL;
			spinlock_unlock(ctx->lock);
			if (head == NULL) {
				break;
			}
			while (head != NULL)
			{
				if (head->op == 's') {
					skynet_socket_send(ctx->sk_ctx, head->id, head->buffer, head->sz);
				} else if (head->op == 'c') {
					skynet_socket_close(ctx->sk_ctx, head->id);
				} else {
					// never got here
				}
				
				next = head->next;
				skynet_free(head);
				head = next;
			}
		}
	}

	// clear
	spinlock_lock(ctx->lock);
	head = ctx->req_list_head;
	ctx->req_list_head = NULL;
	ctx->req_list_tail = NULL;
	while (head != NULL)
	{
		if (head->op == 's') {
			skynet_socket_send(ctx->sk_ctx, head->id, head->buffer, head->sz);
		} else if (head->op == 'c') {
			skynet_socket_close(ctx->sk_ctx, head->id);
		} else {
			// never got here
		}
		next = head->next;
		skynet_free(head);
		head = next;
	}
	spinlock_unlock(ctx->lock);
	close(fd);
	return 0;
}

static void init_sender_worker(struct gate *g, int sender_worker_count) {
	int fd[2];
	int i;
	g->sender_worker_count = sender_worker_count;
	g->send_worker_ctx = skynet_malloc(sizeof(struct SendWorkerCtx) * (g->sender_worker_count));
	g->send_worker_pids = skynet_malloc(sizeof(pthread_t) * (g->sender_worker_count));
	// 初始化发送线程
	for (i=0; i<g->sender_worker_count; ++i)
	{
		fd[0] = 0;
		fd[1] = 0;
		assert(pipe(fd) == 0);
		g->send_worker_ctx[i].pipe_out = fd[0];
		g->send_worker_ctx[i].pipe_in = fd[1];

		g->send_worker_ctx[i].lock = skynet_malloc(sizeof(struct spinlock));
		spinlock_init(g->send_worker_ctx[i].lock);
		g->send_worker_ctx[i].req_list_head = NULL;
		g->send_worker_ctx[i].req_list_tail = NULL;
		g->send_worker_ctx[i].sk_ctx = g->ctx;
		
		// 启动线程
		if (pthread_create(&(g->send_worker_pids[i]), NULL, send_thread_worker, &(g->send_worker_ctx[i]))) {
			fprintf(stderr, "Create thread failed");
			exit(1);
		}
	}
}

int
gate_init(struct gate *g , struct skynet_context * ctx, char * parm) {
	if (parm == NULL)
		return 1;
	int max = 0;
	int sz = strlen(parm)+1;
	char watchdog[sz];
	char binding[sz];
	int client_tag = 0;
	char header;
	int sender_count;
	int n = sscanf(parm, "%c %s %s %d %d %d", &header, watchdog, binding, &client_tag, &max, &sender_count);
	if (n<6) {
		skynet_error(ctx, "Invalid gate parm %s",parm);
		return 1;
	}
	if (max <=0 ) {
		skynet_error(ctx, "Need max connection");
		return 1;
	}
	if (header != 'S' && header !='L' && header != 'M') {
		skynet_error(ctx, "Invalid data header style");
		return 1;
	}

	if (client_tag == 0) {
		client_tag = PTYPE_CLIENT;
	}
	if (watchdog[0] == '!') {
		g->watchdog = 0;
	} else {
		g->watchdog = skynet_queryname(ctx, watchdog);
		if (g->watchdog == 0) {
			skynet_error(ctx, "Invalid watchdog %s",watchdog);
			return 1;
		}
	}

	g->ctx = ctx;

	hashid_init(&g->hash, max);
	hashid_init(&g->user_id_hash, max);
	g->conn = skynet_malloc(max * sizeof(struct connection));
	memset(g->conn, 0, max * sizeof(struct connection));
	g->user_id_map = skynet_malloc(max * sizeof(int));
	memset(g->user_id_map, 0, max * sizeof(int));
	g->max_connection = max;
	int i;
	for (i=0;i<max;i++) {
		g->conn[i].id = -1;
	}
	
	g->client_tag = client_tag;
	if(header == 'S') {
		g->header_size = 2;
	}
	if(header == 'M') {
		g->header_size = 3;
	}
	if(header == 'L') {
		g->header_size = 4;
	}

	init_sender_worker(g, sender_count);
	skynet_callback(ctx,g,_cb);

	if(binding[0] == '!') {
		// !表示不监听
		return 0;
	}
	return start_listen(g,binding);
}
