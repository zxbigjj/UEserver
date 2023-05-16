#!/usr/bin/python
# -*- coding: utf-8 -*-
import os
import sys
import time
from subprocess import check_output
from _shut_utils import shutdown_skynet


THIS_DIR = os.path.dirname(os.path.abspath(__file__))
STATUS_DIR = 'status/'
CONFIG_DIR = 'config/'


def start_server(server_id):
    server_id = int(server_id)
    config_files = []

    os.system('chmod +x bin/skynet')
    if not os.path.isfile(STATUS_DIR + "reload.txt"):
        os.system("touch " + STATUS_DIR + "reload.txt")

    for name in ['game', 'chat', 'dynasty']:
        config_files.append("s%d_%s.lua" % (server_id, name))

    for config in config_files:
        node_name = config[:-4]
        print('启动:%s' % node_name)
        os.system("touch %s%s.starting" % (STATUS_DIR, node_name))
        # os.system('valgrind --tool=memcheck bin/skynet config/%s >> log/%s.log 2>&1 &' % (config, node_name))
        os.system('LD_PRELOAD=build/libtcmalloc.so.4.4.5 bin/skynet %s%s >> log/%s.log 2>&1 &' %
                  (CONFIG_DIR, config, node_name))

    while True:
        files = check_output("cd %s && ls" % STATUS_DIR, shell=True)
        files = [x for x in files.split("\n") if x.endswith(".starting")]
        if files:
            print(" ".join(files))
            time.sleep(5)
        else:
            break

    print('启动:auto_reload.py')
    os.system(
        'python tools/auto_reload.py s%d_reload >> log/auto_reload.log 2>&1 &' % server_id)
    os.system("ps aux | grep s%d_ | grep -v grep" % server_id)


def shutdown_server(server_id, kill=False):
    server_id = int(server_id)
    config_files = []
    server_name_list = []

    if kill:
        server_name_list = ['game', 'chat', 'dynasty']
    else:
        server_name_list = ['game']
    for server_name in server_name_list:
        config_files.append("s%d_%s.lua" % (server_id, server_name))

    pid = check_output(
        "ps aux | grep python | grep auto_reload.py | grep s%d_reload | grep -v grep | awk '{print $2}'" % server_id, shell=True)
    if pid:
        print('关闭:auto_reload.py     pid:' + pid)
        os.system("kill %s" % pid)

    for config in config_files:
        shutdown_skynet(CONFIG_DIR + config, kill)
        print("已关闭：" + config)

    os.system("ps aux | grep skynet | grep s%d_ | grep -v grep" %
              server_id)


if __name__ == "__main__":
    assert(THIS_DIR == os.getcwd())

    cmd_list = sys.argv[1:]
    print("cmd list: ", cmd_list)

    if cmd_list == []:
        print("no cmd")
    else:
        if cmd_list[0] == "start":
            for server_id in cmd_list[1:]:
                shutdown_server(server_id)
            for server_id in cmd_list[1:]:
                start_server(server_id)

        elif cmd_list[0] == "shutdown":
            for server_id in cmd_list[1:]:
                shutdown_server(server_id)

        elif cmd_list[0] == "shutdown_kill":
            for server_id in cmd_list[1:]:
                shutdown_server(server_id, True)

        else:
            print("no cmd")
