#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys, os, os.path
from subprocess import check_output
from _shut_utils import shutdown_skynet

this_dir = os.path.dirname(os.path.abspath(__file__))

def main():
    assert(this_dir == os.getcwd())

    if '--kill' in sys.argv:
        kill = True
        sys.argv.remove('--kill')
    else:
        kill = False
    
    pid = check_output("ps aux | grep python | grep auto_reload.py | grep global_reload | grep -v grep | awk '{print $2}'", shell=True)
    if pid:
        print '关闭:auto_reload.py', 'pid:'+pid
        os.system("kill %s" % pid)

    pid = check_output("ps aux | grep python | grep notice_http | grep -v grep | awk '{print $2}'", shell=True)
    if pid:
        print '关闭:notice_http', 'pid:'+pid
        os.system("kill %s" % pid)

    pid = check_output("ps aux | grep python | grep version_http | grep -v grep | awk '{print $2}'", shell=True)
    if pid:
        print '关闭:version_http', 'pid:'+pid
        os.system("kill %s" % pid)

    shutdown_skynet('config/s70_cross.lua', kill)
    shutdown_skynet('config/s2810_login.lua', kill)
    shutdown_skynet('config/s2803_gm_router.lua', kill)
    shutdown_skynet('config/s2801_world.lua', kill)
    shutdown_skynet('config/s2800_cluster_router.lua', kill)

if __name__ == "__main__":
    main()