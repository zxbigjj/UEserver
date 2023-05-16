#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <time.h>
#include <signal.h>
#include <pthread.h>
#include <sys/syscall.h>
#include <unwind.h>
#include <fcntl.h>

#include "luaprofiler.h"

#define MAX_STACK_DEEP 256
#define MAX_THREAD_COUNT 256
#define STR_SIZE 255

static int gettid()
{
    return syscall(SYS_gettid);
}

static void * worker_profiler(void*);
static void handler_control(int);
static void handler_sample(int);

#define CMD_OP_START 1
#define CMD_OP_STOP 2
#define CMD_OP_ADD_FRAME_LIST 3
#define CMD_OP_ON_LUA_HOOK 4

#define NO_INTR(fn)  do {} while ((fn) < 0 && errno == EINTR)

static int FDWrite(int fd, const char* buf, size_t len) {
    while (len > 0) {
        ssize_t r;
        NO_INTR(r = write(fd, buf, len));
        if (r<0) return -1;
        buf += r;
        len -= r;
    }
    return 0;
}

static int FDRead(int fd, char* buf, size_t len) {
    while (len > 0) {
        ssize_t r;
        NO_INTR(r = read(fd, buf, len));
        if (r<0) return -1;
        buf += r;
        len -= r;
    }
    return 0;
}

class LockHolder {
public:
    inline LockHolder(pthread_mutex_t *lock):_lock(lock) {
        pthread_mutex_lock(_lock);
    }
    inline ~LockHolder() {pthread_mutex_unlock(_lock);}
private:
    pthread_mutex_t *_lock;
};

// 管理内存，signal回调不可使用malloc
class BufferCache {
private:
    void *free_head;
    void *raw_head;
public:
    BufferCache(size_t size, int total_count) {
        if(size < sizeof(void*))
            size = sizeof(void*);

        raw_head = malloc(size*total_count);
        free_head = 0;
        char *buff = (char*)raw_head;
        for(int i=0; i<total_count; i++)
        {
            *(unsigned long *)(buff) = (unsigned long)free_head;
            free_head = (void *)buff;
            buff += size;
        }
    }
    ~BufferCache() {
        free_head = 0;
        free(raw_head);
        raw_head = 0;
    }

    void* get() {
        if(free_head)
        {
            void* ret = free_head;
            free_head = (void*)(*(unsigned long *)free_head);
            return ret;
        }
        else
        {
            return 0;
        }
    }

    void put(void* p) {
        *(unsigned long *)(p) = (unsigned long)free_head;
        free_head = p;
    }
};

struct SampleCmd {
    int op;
    unsigned long args;
};

struct TimerInfo {
    int tid;
    int init;
    timer_t timerid;
};

struct StringNode {
    StringNode *next;
    char str[STR_SIZE];
    int sz;

    void copy_from(StringNode* s) {
        memcpy(str, s->str, s->sz+1);
        sz = s->sz;
    }
};

bool StringEqual(StringNode* a, StringNode* b)
{
    if(a==0)
    {
        if(b==0) return true;
        else return false;
    }
    else
    {
        if(b==0) return false;
        if(a->sz != b->sz) return false;
        return memcmp(a->str, b->str, a->sz) == 0;
    }
}

struct FrameInfo {
    void *addr;
    void *lua_state;
    StringNode* lua_frame_list;
};

struct FrameListNode {
    FrameListNode* next;
    void *wait_lua_state;
    int frame_count;
    FrameInfo* frame_list;
};

struct StackNode {
    StackNode *next;
    void *addr;
    StringNode *lua_info;
    int sample_count;
    StackNode* children;
};

class LuaProfiler {
public:
    char out_file_name[STR_SIZE+1];
    int frequency;
    int control_signal;
    int sample_signal;
    unsigned long luaV_execute_begin;
    unsigned long luaV_execute_end;
    const char* (*cb_lua_getstackinfo)(void*, int, int*);
    void (*cb_lua_addhook)(void* L);

    int no_memory;
    StackNode *root_node;
    struct FrameInfo frame_list[MAX_STACK_DEEP];
    int frame_count;
    FrameListNode* cached_frame_list;
    void *last_lua_state;
    bool luaV_execute_flag;


    LuaProfiler();
    ~LuaProfiler();

    int start(struct ProfilerOption *option, int *tid_list, int tid_count);
    int stop();
    void send_cmd(int op, unsigned long args);
    void process_cmd();
    void set_control_timer();
    void _handler_control();
    void _handler_sample();
    void _on_lua_hook(void* L);

    StackNode* new_stack_node(void* addr, StringNode* lua_info);
    void dele_stack_node(StackNode* node);
    StackNode* add_stack_child(StackNode* father, void* addr, StringNode* lua_info);
    void write_stack_node(int out, StackNode* node, int deep);
    void flush_data();
    void init_root_node();
    void merge_frame_list(FrameInfo* fl, int count);
    int _merge_frame_list(FrameInfo* fl, int count);
    int read_lua_frame(void* L, FrameInfo* frame, bool use_malloc);

    inline void dele_lua_frame_list(StringNode* node) {
        StringNode* p;
        while(node)
        {
            p = node;
            node = p->next;
            put_string_node(p);
        }
    }
    void free_all_frame() {
        for(int i=0; i<MAX_STACK_DEEP; i++)
        {
            dele_lua_frame_list(frame_list[i].lua_frame_list);
            frame_list[i].lua_frame_list = NULL;
            frame_list[i].lua_state = 0;
        }
        frame_count = 0;
        {
            FrameListNode* p = cached_frame_list;
            while(p)
            {
                cached_frame_list = p->next;
                for(int i=0; i<p->frame_count; ++i)
                {
                    dele_lua_frame_list(p->frame_list[i].lua_frame_list);
                }
                free(p->frame_list);
                p->frame_list = 0;
                free(p);
                p = cached_frame_list;
            }
        }
    }

    void free_all_cache();
    void init_all_cache();

    inline StackNode* get_stack_node() {
        return (StackNode*)(stack_node_cache->get());
    }
    inline void put_stack_node(StackNode* p) {
        stack_node_cache->put(p);
    }

    inline StringNode* get_string_node() {
        return (StringNode*)(string_node_cache->get());
    }
    inline void put_string_node(StringNode* p) {
        string_node_cache->put(p);
    }

    static LuaProfiler inst;
private:
    int working;
    pthread_t control_thread;
    int fd[2];
    pthread_mutex_t lock;

    BufferCache* string_node_cache;
    BufferCache* stack_node_cache;

    struct TimerInfo timer_array[MAX_THREAD_COUNT];
    int timer_count;

    void free_all_timer();
};

LuaProfiler LuaProfiler::inst;

LuaProfiler::LuaProfiler() {
    working = 0;
    cb_lua_getstackinfo = NULL;
    cb_lua_addhook = NULL;

    no_memory = 0;
    root_node = NULL;
    frame_count = 0;
    cached_frame_list = 0;
    last_lua_state = 0;
    for(int i=0; i<MAX_STACK_DEEP; i++)
    {
        frame_list[i].addr = NULL;
        frame_list[i].lua_state = NULL;
        frame_list[i].lua_frame_list = NULL;
    }
    timer_count = 0;
    for(int i=0; i<MAX_THREAD_COUNT; i++)
    {
        timer_array[i].tid = 0;
        timer_array[i].init = 0;
    }

    string_node_cache = 0;
    stack_node_cache = 0;

    control_thread = 0;
    pthread_mutex_init(&lock, NULL);
    pipe(fd);
}

void LuaProfiler::free_all_timer()
{
    int i;
    for(i=0; i<timer_count; i++)
    {
        timer_array[i].tid = 0;
        if (timer_array[i].init)
        {
            timer_delete(timer_array[i].timerid);
        }
    }
    timer_count = 0;
}

void LuaProfiler::free_all_cache()
{
    if(string_node_cache)
    {
        delete string_node_cache;
        string_node_cache = 0;
    }
    if(stack_node_cache)
    {
        delete stack_node_cache;
        stack_node_cache = 0;
    }
}

void LuaProfiler::init_all_cache()
{
    free_all_cache();
    string_node_cache = new BufferCache(sizeof(struct StringNode), 2048);
    stack_node_cache = new BufferCache(sizeof(struct StackNode), 4096);
}

LuaProfiler::~LuaProfiler() {
    free_all_timer();
    pthread_mutex_destroy(&lock);
    if(root_node)
    {
        dele_stack_node(root_node);
        root_node = NULL;
    }
    free_all_frame();
    free_all_cache();
}

StackNode* LuaProfiler::new_stack_node(void *_addr, StringNode* _lua_info) {
    StackNode* node = get_stack_node();
    if(!node) return 0;
    StringNode* sn = 0;
    if(_lua_info)
    {
        sn = get_string_node();
        if(!sn)
        {
            put_stack_node(node);
            return 0;
        }
        sn->copy_from(_lua_info);
        sn->next = 0;
    }

    node->next = 0;
    node->addr = _addr;
    node->lua_info = sn;
    node->sample_count = 0;
    node->children = 0;
    return node;
}
void LuaProfiler::dele_stack_node(StackNode* node){
    if(node->lua_info)
    {
        put_string_node(node->lua_info);
        node->lua_info = 0;
    }
    StackNode *p;
    while(node->children) {
        p = node->children;
        node->children = p->next;
        dele_stack_node(p);
    }
    put_stack_node(node);
}

StackNode* LuaProfiler::add_stack_child(StackNode* father, void *addr, StringNode* lua_info) {
    StackNode *child = father->children;
    while(child)
    {
        if(lua_info)
        {
            if(child->lua_info && StringEqual(lua_info, child->lua_info)) return child;
        }
        else
        {
            if(addr == child->addr && 0 == child->lua_info) return child;
        }
        child = child->next;
    }
    // new
    child = new_stack_node(addr, lua_info);
    if(!child) return 0;
    child->next = father->children;
    father->children = child;
    return child;
}

static char WRITE_BUFF[2048];
void LuaProfiler::write_stack_node(int out, StackNode* node, int deep)
{
    int sz;
    if(node->lua_info)
    {
        sz = snprintf(WRITE_BUFF, 2048, "lua,%d,%d,%s\n", deep, node->sample_count, node->lua_info->str);
        FDWrite(out, WRITE_BUFF, sz);
    }
    else
    {
        sz = snprintf(WRITE_BUFF, 2048, "c,%d,%d,0x%lx\n", deep, node->sample_count, (unsigned long)(node->addr));
        FDWrite(out, WRITE_BUFF, sz);
    }
    
    StackNode* p = node->children;
    while(p)
    {
        write_stack_node(out, p, deep+1);
        p = p->next;
    }
}

void LuaProfiler::send_cmd(int op, unsigned long args)
{
    struct SampleCmd cmd;
    cmd.op = op;
    cmd.args = args;
    FDWrite(fd[1], (char*)&cmd, sizeof(cmd));
}

void LuaProfiler::init_root_node()
{
    root_node = new_stack_node(0, NULL);

    StringNode *lua_root_s = get_string_node();
    memcpy(lua_root_s->str, "lua root", 8);
    lua_root_s->str[8] = 0;
    lua_root_s->sz = 8;
    add_stack_child(root_node, 0, lua_root_s); // for lua stack
    put_string_node(lua_root_s);

    add_stack_child(root_node, 0, NULL); // for c stack
}

void LuaProfiler::process_cmd()
{   
    struct SampleCmd cmd;
    int sz = sizeof(cmd);
    for(;;)
    {
        int n = FDRead(fd[0], (char*)&cmd, sz);
        if (n<0) {
            perror("process_cmd error");
            return;
        }
        switch(cmd.op)
        {
            case CMD_OP_START:
                printf("profiler cmd:start\n");
                {
                    struct sigevent sev;
                    struct itimerspec its;

                    LockHolder _lock(&lock);

                    free_all_frame();
                    if(root_node)
                    {
                        dele_stack_node(root_node);
                        root_node = 0;
                    }
                    free_all_cache();

                    init_all_cache();
                    init_root_node();

                    its.it_value.tv_sec = 0;
                    its.it_value.tv_nsec = 1;
                    its.it_interval.tv_sec = 0;
                    its.it_interval.tv_nsec = 0;
                    for(int i=0; i<timer_count; ++i)
                    {
                        sev.sigev_signo = control_signal;
                        sev.sigev_notify = SIGEV_THREAD_ID;
                        sev._sigev_un._tid = timer_array[i].tid;
                        if (timer_create(CLOCK_REALTIME, &sev, &timer_array[i].timerid) == -1)
                        {
                            perror("timer_create fail");
                            continue;
                        }
                        timer_array[i].init = 1;
                        timer_settime(timer_array[i].timerid, 0, &its, NULL);
                    }
                }
                break;
            case CMD_OP_ADD_FRAME_LIST:
                {
                    FrameListNode* p;

                    LockHolder _lock(&lock);
                    p = (FrameListNode*)malloc(sizeof(FrameListNode));
                    p->frame_count = cmd.args;
                    p->frame_list = (FrameInfo*)malloc(p->frame_count * sizeof(FrameInfo));
                    FDRead(fd[0], (char*)p->frame_list, p->frame_count * sizeof(FrameInfo));
                    p->wait_lua_state = 0;
                    for(int i=0; i<p->frame_count; ++i)
                    {
                        if(p->frame_list[i].lua_state && p->frame_list[i].lua_frame_list == 0)
                        {
                            p->wait_lua_state = p->frame_list[i].lua_state;
                            break;
                        }
                    }
                    p->next = cached_frame_list;
                    cached_frame_list = p;
                }
                break;
            case CMD_OP_ON_LUA_HOOK:
                {
                    FrameInfo frame;
                    void *L;
                    
                    LockHolder _lock(&lock);
                    FDRead(fd[0], (char*)&frame, sizeof(FrameInfo));
                    L = frame.lua_state;
                    // 
                    {
                        FrameListNode* p;
                        FrameListNode* next = cached_frame_list;

                        cached_frame_list = 0;
                        while(next)
                        {
                            p = next;
                            next = next->next;
                            if(p->wait_lua_state != L)
                            {
                                // back
                                p->next = cached_frame_list;
                                cached_frame_list = p;
                            }
                            else
                            {
                                // merge
                                FrameInfo* f;
                                for(int i=0; i<p->frame_count; ++i)
                                {
                                    f = p->frame_list + i;
                                    if(f->lua_state == L && f->lua_frame_list == 0)
                                    {
                                        f->lua_frame_list = frame.lua_frame_list;
                                        merge_frame_list(p->frame_list, p->frame_count);
                                        f->lua_frame_list = 0;
                                        for(int i=0; i<p->frame_count; ++i)
                                        {
                                            dele_lua_frame_list(p->frame_list[i].lua_frame_list);
                                        }
                                        free(p->frame_list);
                                        p->frame_list = 0;
                                        free(p);
                                        break;
                                    }
                                }
                            }
                        }
                    }


                    // free
                    {
                        StringNode *p = frame.lua_frame_list;
                        while(p)
                        {
                            frame.lua_frame_list = p->next;
                            free(p);
                            p = frame.lua_frame_list;
                        }
                    }
                }
                break;
            case CMD_OP_STOP:
                printf("profiler cmd:stop\n");
                {
                    LockHolder _lock(&lock);
                    free_all_frame();
                    free_all_timer();
                    flush_data();
                    if(root_node)
                    {
                        dele_stack_node(root_node);
                        root_node = 0;
                    }
                    free_all_cache();
                }
                return;
        }
    }
}

void LuaProfiler::flush_data()
{
    if(root_node)
    {
        int out;
        const char* _a = "==sample_begin==\n";
        const char* _b = "==lua_stack==\n";
        const char* _c = "==sample_end==\n";

        out = open(out_file_name, O_CREAT | O_WRONLY | O_APPEND);
        if(out)
        {
            FDWrite(out, _a, strlen(_a));
            write_stack_node(out, root_node->children, 0);
            FDWrite(out, _b, strlen(_b));
            write_stack_node(out, root_node->children->next, 0);
            FDWrite(out, _c, strlen(_c));
            close(out);
        }
        dele_stack_node(root_node);
        root_node = 0;
        init_root_node();
    }

}

void LuaProfiler::_handler_control()
{
    struct sigevent sev;
    struct itimerspec its;

    LockHolder _lock(&lock);

    its.it_value.tv_sec = 0;
    its.it_value.tv_nsec = 1000*1000*1000 / frequency;
    its.it_interval.tv_sec = its.it_value.tv_sec;
    its.it_interval.tv_nsec = its.it_value.tv_nsec;
    for(int i=0; i<timer_count; ++i)
    {
        if(timer_array[i].tid != gettid())
            continue;
        timer_delete(timer_array[i].timerid);
        sev.sigev_signo = sample_signal;
        sev.sigev_notify = SIGEV_THREAD_ID;
        sev._sigev_un._tid = timer_array[i].tid;
        if (timer_create(CLOCK_THREAD_CPUTIME_ID, &sev, &timer_array[i].timerid) == -1)
            break;
        timer_settime(timer_array[i].timerid, 0, &its, NULL);
        break;
    }
}

static _Unwind_Reason_Code
libgcc_backtrace_helper(struct _Unwind_Context *ctx, void *_data) {
    unsigned long ip = _Unwind_GetIP(ctx);
    LuaProfiler *prof = (LuaProfiler*) _data;
    struct FrameInfo *frame;

    if(!ip) return _URC_NO_REASON;
    if(prof->luaV_execute_flag)
    {
        // luaV_execute有四个调用的地方，L都在rbx(3)中
        void *rbx = (void *)_Unwind_GetGR(ctx, 3);

        prof->luaV_execute_flag = false;

        if(rbx != prof->last_lua_state)
        {
            // 插入lua
            if(prof->frame_count >= MAX_STACK_DEEP) return _URC_NO_REASON;
            // copy
            frame = &prof->frame_list[prof->frame_count];
            prof->frame_count += 1;
            frame->addr = (void*)(prof->luaV_execute_begin+4);
            frame->lua_state = NULL;
            frame->lua_frame_list = 0;
            //
            frame = &prof->frame_list[prof->frame_count-2];
            frame->addr = 0;
            frame->lua_state = rbx;
            frame->lua_frame_list = 0;
            if (prof->last_lua_state == 0)
            {
                // 调用链上第一个lua_state，最顶层的lua state
                // 直接读是不安全的， 使用hook延迟处理
                prof->cb_lua_addhook(rbx);
            }
            else
            {
                if(prof->read_lua_frame(rbx, frame, false))
                {
                    prof->no_memory = 1;
                    return _URC_NO_REASON;
                }
            }
            prof->last_lua_state = rbx;    
            
        }
    }

    if(prof->frame_count >= MAX_STACK_DEEP) return _URC_NO_REASON;
    frame = &prof->frame_list[prof->frame_count];
    prof->frame_count += 1;
    if(ip > prof->luaV_execute_begin && ip < prof->luaV_execute_end && prof->cb_lua_getstackinfo != NULL)
    {
        prof->luaV_execute_flag = true;
        // 统一使用开始地址，细分没什么意义
        frame->addr = (void*)(prof->luaV_execute_begin+4);
        frame->lua_state = NULL;
    }
    else
    {
        frame->addr = (void*)ip;
        frame->lua_state = NULL;
    }
    
    return _URC_NO_REASON;
}

int LuaProfiler::read_lua_frame(void* L, FrameInfo* frame, bool use_malloc)
{
    int level = 0;
    const char* buffer;
    int sz;
    StringNode* sn;

    frame->lua_frame_list = 0;
    for(;;)
    {
        buffer = cb_lua_getstackinfo(L, level++, &sz);
        if(buffer == 0) break;
        if(use_malloc)
        {
            sn = (StringNode*)malloc(sizeof(StringNode));
        }
        else
        {
            sn = get_string_node();
        }
        
        if(!sn)
        {
            return -1;
        }
        memcpy(sn->str, buffer, sz);
        sn->str[sz] = 0;
        sn->sz = sz;
        sn->next = frame->lua_frame_list;
        frame->lua_frame_list = sn;
    }
    return 0;
}

void LuaProfiler::merge_frame_list(FrameInfo* fl, int count)
{
    if(_merge_frame_list(fl, count))
    {
        flush_data();
        _merge_frame_list(fl, count);
    }
}

int LuaProfiler::_merge_frame_list(FrameInfo* fl, int count)
{
    FrameInfo* frame;
    int enter_lua_stack = 0;
    // c root
    StackNode* node = root_node->children;
    for(int i=count-1; i>1; i--)
    {
        frame = fl + i;
        if(!enter_lua_stack)
        {
            if(frame->lua_state == 0)
            {
                node = add_stack_child(node, frame->addr, 0);
                if(!node) return -1;
                continue;
            }
            else
            {
                enter_lua_stack = 1;
                // lua root
                node = root_node->children->next;
            }
        }
        // enter_lua_stack
        if(frame->lua_state == 0)
        {
            node = add_stack_child(node, frame->addr, 0);
            if(!node) return -1;
        }
        else
        {
            StringNode *sn = frame->lua_frame_list;
            while(sn)
            {
                node = add_stack_child(node, 0, sn);
                if(!node) return -1;
                sn = sn->next;
            }
        }
    }
    node->sample_count += 1;
    return 0;
}

void LuaProfiler::_handler_sample()
{
    LockHolder _lock(&lock);

    if(!root_node) return;
    
    frame_count = 0;
    last_lua_state = 0;
    no_memory = 0;
    luaV_execute_flag = false;
    _Unwind_Backtrace(libgcc_backtrace_helper, this);
    if(no_memory)
    {
        // again
        flush_data();
        frame_count = 0;
        last_lua_state = 0;
        no_memory = 0;
        luaV_execute_flag = false;
        _Unwind_Backtrace(libgcc_backtrace_helper, this);
        if(no_memory)
        {
            return;
        }
    }

    if(last_lua_state == 0)
    {
        // 纯c
        merge_frame_list(frame_list, frame_count);
    }
    else
    {
        // lua/c
        send_cmd(CMD_OP_ADD_FRAME_LIST, frame_count);
        FDWrite(fd[1], (char*)frame_list, frame_count*sizeof(FrameInfo));
    }
    for(int i=0; i<frame_count; i++)
    {
        frame_list[i].lua_frame_list = 0;
    }
    frame_count = 0;
    last_lua_state = 0;
}

// 不在signal中
void LuaProfiler::_on_lua_hook(void* L) 
{
    FrameInfo frame;
    LockHolder _lock(&lock);

    frame.addr = 0;
    frame.lua_state = L;
    frame.lua_frame_list = 0;
    read_lua_frame(L, &frame, true);
    send_cmd(CMD_OP_ON_LUA_HOOK, 0);
    FDWrite(fd[1], (char*)&frame, sizeof(FrameInfo));
}

int LuaProfiler::start(struct ProfilerOption *option, int *tid_list, int tid_count) {
    if (working) {
        fprintf(stderr, "profiler is working, cannot start again\n");
        return -1;
    }
    // 检查signal是否被占用
    int ret;
    struct sigaction sa;

    strncpy(out_file_name, option->out_file_name, STR_SIZE);
    frequency = option->frequency;
    if(frequency > 1000) frequency = 1000;
    if(frequency < 1) frequency = 1;
    luaV_execute_begin = option->luaV_execute_begin;
    luaV_execute_end = luaV_execute_begin + option->luaV_execute_size;
    cb_lua_getstackinfo = option->cb_lua_getstackinfo;
    cb_lua_addhook = option->cb_lua_addhook;

    free_all_timer();
    for(int i=0; i<tid_count; i++)
    {
        timer_array[i].tid = tid_list[i];
        timer_array[i].init = 0;
    }
    timer_count = tid_count;

    if(option->control_signal > 0)
        control_signal = option->control_signal;
    else
        control_signal = SIGUSR1;
    if(option->sample_signal > 0)
        sample_signal = option->sample_signal;
    else
        sample_signal = SIGPROF;

    ret = sigaction(control_signal, NULL, &sa);
    if(ret)
    {
        fprintf(stderr, "invalid signal num %d\n", control_signal);
        return -1;
    }
    if(sa.sa_handler != SIG_IGN && sa.sa_handler != SIG_DFL)
    {
        fprintf(stderr, "signal %d has been used\n", control_signal);
        return -1;
    }

    ret = sigaction(sample_signal, NULL, &sa);
    if(ret)
    {
        fprintf(stderr, "invalid signal num %d\n", sample_signal);
        return -1;
    }
    if(sa.sa_handler != SIG_IGN && sa.sa_handler != SIG_DFL)
    {
        fprintf(stderr, "signal %d has been used\n", sample_signal);
        return -1;
    }

    // signal handler
    sa.sa_handler = handler_control;
    sa.sa_flags = SA_RESTART;
    sigemptyset(&sa.sa_mask);
    sigaddset(&sa.sa_mask, sample_signal);
    ret = sigaction(control_signal, &sa, NULL);
    if(ret)
    {
        fprintf(stderr, "sigaction fail %d\n", control_signal);
        return -1;
    }

    // signal handler
    sa.sa_handler = handler_sample;
    sa.sa_flags = SA_RESTART;
    sigemptyset(&sa.sa_mask);
    sigaddset(&sa.sa_mask, control_signal);
    ret = sigaction(sample_signal, &sa, NULL);
    if(ret)
    {
        fprintf(stderr, "sigaction fail %d\n", sample_signal);
        return -1;
    }

    // 新建线程
    pthread_create(&control_thread, 0, worker_profiler, NULL);
    send_cmd(CMD_OP_START, 0);

    working = 1;
    return 0;
}

int LuaProfiler::stop() {
    if (working)
    {
        struct sigaction sa;

        sa.sa_handler = SIG_IGN;
        sigemptyset(&sa.sa_mask);
        sigaction(sample_signal, &sa, NULL);
        sigaction(control_signal, &sa, NULL);

        send_cmd(CMD_OP_STOP, 0);
    }
    working = 0;
    return 0;
}

static void* worker_profiler(void* args)
{
    printf("worker_profiler enter:%lx\n", pthread_self());
    LuaProfiler::inst.process_cmd();
    printf("worker_profiler exit:%lx\n", pthread_self());
    return NULL;
}

static void handler_control(int sig)
{
    LuaProfiler::inst._handler_control();
}

static void handler_sample(int sig)
{
    LuaProfiler::inst._handler_sample();
}

extern "C" void
ProfilerOnLuaHook(void* L) {
    LuaProfiler::inst._on_lua_hook(L);
}

extern "C" int 
ProfilerStart(struct ProfilerOption *option, int *tid_list, int tid_count) {
    return LuaProfiler::inst.start(option, tid_list, tid_count);
}
extern "C" int 
ProfilerStop() {
    return LuaProfiler::inst.stop();
}

