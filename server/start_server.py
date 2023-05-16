#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import os, subprocess, os.path
from subprocess import check_output
import time
import re

this_dir = os.path.dirname(os.path.abspath(__file__))
config_dir = 'config/'
status_dir = 'status/'

def main():
    assert(this_dir == os.getcwd())
    
    game_config = check_output("cd %s && ls s*_game.lua" % config_dir, shell=True)
    game_config = [x.strip() for x in game_config.split("\n") if x.strip()]
    # if len(game_config) != 1:
    #     print "game_config 不唯一"
    #     print repr(game_config)
    #     return
    game_config = game_config[3]
        
    # server_id
    server_id = game_config[1:game_config.index("_")]
    server_id = int(server_id)

    os.system("python -u shutdown_server.py")
    os.system('chmod +x bin/skynet')

    if not os.path.isfile(status_dir + "reload.txt"):
        os.system("touch " + status_dir + "reload.txt")

    config_files = [game_config]
    for name in ['chat','dynasty']:
        config_files.append("s%d_%s.lua" % (server_id, name))

    for config in config_files:
        node_name = config[:-4]
        print '启动:%s' % node_name
        os.system("touch %s%s.starting" % (status_dir, node_name))
        # os.system('valgrind --tool=memcheck bin/skynet config/%s >> log/%s.log 2>&1 &' % (config, node_name))
        os.system('LD_PRELOAD=build/libtcmalloc.so.4.4.5 bin/skynet %s%s >> log/%s.log 2>&1 &' % (config_dir, config, node_name))

    while True:
        files = check_output("cd %s && ls" % status_dir, shell=True)
        files = [x for x in files.split("\n") if x.endswith(".starting")]
        if files:
            print " ".join(files)
            time.sleep(1)
        else:
            break
        
    print '启动:auto_reload.py'
    os.system('python tools/auto_reload.py s%d_reload >> log/auto_reload.log 2>&1 &' % server_id)

    os.system("ps aux | grep s%d_ | grep -v grep" % server_id)

if __name__ == "__main__":
    main()
