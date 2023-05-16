#!/usr/bin/python
# -*- coding: utf-8 -*-

# 启动/停止 python进程

import sys, os
import os.path
from subprocess import check_output, CalledProcessError

def find_pid(script_path):
    cmd = "ps aux | grep 'python %s' | grep -v grep | awk '{print $2}'" % script_path
    return check_output(cmd, shell=True)

def stop(script_path):
    pid = find_pid(script_path)
    if pid:
        check_output("kill %s" % pid, shell=True)
        print "已杀掉：%s" % script_path

def start(script_path, args):
    if find_pid(script_path):
        return
    log_name = script_path.replace("/", "_")[:-3]
    cmd = 'nohup python %s %s >> log/%s.log 2>&1 &' % (script_path, " ".join(args), log_name)
    check_output(cmd, shell=True)
    if not find_pid(script_path):
        RuntimeError("%s 启动失败")
    else:
        print "已启动：%s" % script_path

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
