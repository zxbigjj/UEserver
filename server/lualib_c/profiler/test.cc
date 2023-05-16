#include <signal.h>
#include <time.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <pthread.h>
// #include <execinfo.h>

#include "luaprofiler.h"

// #define MAX_THREAD_COUNT 64
// #define CLOCKID CLOCK_THREAD_CPUTIME_ID
// #define SIG SIGVTALRM

// static int SAMPLE_INTERVAL = 10;
// static timer_t TIMERID[MAX_THREAD_COUNT] = {0};


static int gettid()
{
    return syscall(SYS_gettid);
}

// static void
// handler(int sig)
// {
//    /* Note: calling printf() from a signal handler is not
//       strictly correct, since printf() is not async-signal-safe;
//       see signal(7) */

//    printf("=================Caught signal %d %d\n", sig, gettid());

// }

// int
// start_thread_timer(int index)
// {
//     struct sigevent sev;
//     struct itimerspec its;
//     struct sigaction sa;
    
//     if (index < 0 || index >= MAX_THREAD_COUNT)
//         return -1;
//     if (TIMERID[index] != 0)
//         return -1;

//     /* Establish handler for timer signal */
//     sa.sa_handler = handler;
//     sigemptyset(&sa.sa_mask);
//     if (sigaction(SIG, &sa, NULL) == -1)
//        return -1;

//     /* Create the timer */
//     sev.sigev_signo = SIG;
//     sev.sigev_notify = SIGEV_THREAD_ID;
//     sev._sigev_un._tid = gettid();
//     if (timer_create(CLOCKID, &sev, &TIMERID[index]) == -1)
//        return -1;

//     /* Start the timer */
//     its.it_value.tv_sec = SAMPLE_INTERVAL / 1000;
//     its.it_value.tv_nsec = (SAMPLE_INTERVAL % 1000) * 1000000;
//     its.it_interval.tv_sec = its.it_value.tv_sec;
//     its.it_interval.tv_nsec = its.it_value.tv_nsec;

//     if (timer_settime(TIMERID[index], 0, &its, NULL) == -1)
//         return -1;

//     /* Ok */
//     // printf("===============start_timer %d\n", index);
//     return 0;
// }

static void
busy()
{
    int i;
    for(i=0; i<10000*1000; i++);
}

static void
test1()
{
    busy();
}

static void
test2()
{
    busy();
}

static int tid_list[2];

static void *
worker1(void *args)
{
    tid_list[0] = gettid();
    while(1)
    {
        test1();
        sleep(1);
        printf("---worker1 sleep\n");
    }
}

static void *
worker2(void *args)
{
    tid_list[1] = gettid();
    while(1)
    {
        test2();
        sleep(1);
        printf("---worker2 sleep\n");
    }
}

int main(int argc, char *argv[])
{ 
    int i;
    struct ProfilerOption option;
    pthread_t thread1;
    pthread_t thread2;

    pthread_create(&thread1, 0, worker1, NULL);
    pthread_create(&thread2, 0, worker2, NULL);

    option.out_file_name = "test.data";
    option.frequency = 100;
    option.control_signal = SIGUSR1;
    option.sample_signal = SIGPROF;
    option.luaV_execute_begin = 0;
    option.luaV_execute_size = 0;
    option.cb_lua_getstackinfo = 0;

    sleep(3);
    ProfilerStart(&option, tid_list, 2);

    sleep(3);
    ProfilerStop();

    sleep(3);
    ProfilerStart(&option, tid_list, 2);

    sleep(3);
    ProfilerStop();

    pthread_join(thread1, NULL);
    pthread_join(thread2, NULL);
    return 0;
}