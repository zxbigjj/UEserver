#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import os, os.path, time
from subprocess import check_output
this_dir = os.path.dirname(os.path.abspath(__file__))

def start(node_name):
    print "启动：" + node_name
    os.system("touch status/%s.starting" % node_name)
    os.system('LD_PRELOAD=build/libtcmalloc.so.4.4.5 bin/skynet config/%s.lua >> log/%s.log 2>&1 &' % (node_name, node_name))

def main():
    assert(this_dir == os.getcwd())

    os.system("python shutdown_all.py")

    if not os.path.isfile("status/reload.txt"):
        os.system("touch status/reload.txt")

    print '启动:notice_http'
    os.system('python tools/notice_http/main.py >> log/notice_http.log 2>&1 &')
    print '启动:version_http'
    os.system('python tools/version_http/main.py >> log/version_http.log 2>&1 &')

    os.system('chmod +x bin/skynet')
    start("s2800_cluster_router")
    os.system("sleep 3")

    node_list = ['s2801_world', 's2803_gm_router', 's2810_login', 's70_cross']
    for node_name in node_list:
        start(node_name)

    while True:
        files = check_output("cd status && ls", shell=True)
        files = [x for x in files.split("\n") if x.endswith(".starting")]
        if files:
            print " ".join(files)
            time.sleep(1)
        else:
            break

    print '启动:auto_reload.py'
    os.system('python tools/auto_reload.py global_reload >> log/auto_reload.log 2>&1 &')

if __name__ == "__main__":
    main()