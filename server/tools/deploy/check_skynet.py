#!/usr/bin/python
# -*- coding: utf-8 -*-

# 启动/停止 skynet进程

import sys, os
import os.path
import time
import socket
from subprocess import check_output, CalledProcessError

def find_pid(script_path):
    cmd = "ps aux | grep 'skynet %s' | grep -v grep | awk '{print $2}'" % script_path
    return check_output(cmd, shell=True)

def stop(script_path):
    pid = find_pid(script_path)
    if pid:
        # get debug port
        node_name = os.path.basename(script_path[:-4])
        os.system("touch status/%s.shuting" % (node_name))

        count = 0
        while True:
            if not find_pid(script_path):
                break
            time.sleep(0.1)
            count += 1
            if count % 10 == 0:
                print '等待 %s:%s 关闭...' % (script_path, pid)
        print "已停止：%s" % script_path

def start(script_path, args):
    if find_pid(script_path):
        return
    node_name = os.path.basename(script_path[:-4])
    cmd = 'bin/skynet %s %s >> log/%s.log 2>&1 &' % (script_path, " ".join(args), node_name)
    # cmd = 'valgrind --tool=memcheck ' + cmd
    cmd = 'LD_PRELOAD=build/libtcmalloc.so.4.4.5 nohup ' + cmd

    os.system("touch status/%s.starting" % (node_name))
    if not os.path.isfile("status/reload.txt"):
        os.system("touch status/reload.txt")
    check_output(cmd, shell=True)
    print "启动：%s" % script_path

def main():
    if len(sys.argv) < 3:
        raise RuntimeError("参数太少")
    if sys.argv[1] == "stop":
        stop(sys.argv[2])
    elif sys.argv[1] == "start":
        start(sys.argv[2], sys.argv[3:])
    else:
        raise RuntimeError("只支持stop|start")
    
if __name__ == "__main__":
    try:
        main()
    except CalledProcessError,e:
        print e
        sys.exit(returncode)
    except Exception,e:
        print e
        sys.exit(1)
