#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys, os, os.path
from subprocess import check_output
from _shut_utils import shutdown_skynet
import re

this_dir = os.path.dirname(os.path.abspath(__file__))
config_dir = 'config/'
status_dir = 'status/'

def main():
    assert(this_dir == os.getcwd())

    if '--kill' in sys.argv:
        kill = True
        sys.argv.remove('--kill')
    else:
        kill = False
    
    game_config = check_output("cd %s && ls s*_game.lua" % config_dir, shell=True)
    game_config = [x.strip() for x in game_config.split("\n") if x.strip()]
    # if len(game_config) != 1:
    #     print "game_config 不唯一"
    #     print repr(game_config)
    #     return
    print repr(game_config)
    game_config = game_config[3]
        
    # server_id
    server_id = game_config[1:game_config.index("_")]
    server_id = int(server_id)

    config_files = [game_config]
    if kill:
        for name in ['dynasty','chat']:
            config_files.append("s%d_%s.lua" % (server_id, name))
    
    pid = check_output("ps aux | grep python | grep auto_reload.py | grep s%d_reload | grep -v grep | awk '{print $2}'" % server_id, shell=True)
    if pid:
        print '关闭:auto_reload.py', 'pid:'+pid
        os.system("kill %s" % pid)
    
    for config in config_files:
        shutdown_skynet(config_dir + config, kill)
        print "已关闭：" + config


    os.system("ps aux | grep skynet | grep s%d_ | grep -v grep" % server_id)

if __name__ == "__main__":
    main()
