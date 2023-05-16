#!/usr/bin/python
# -*- coding: utf-8 -*-
import os, os.path
import time
import socket
from subprocess import check_output

def shutdown_skynet(config_file, kill):
    cmd = "ps aux | grep skynet | grep %s | grep -v grep | awk '{print $2}'" % config_file
    pid = check_output(cmd, shell=True)
    pid = pid.strip()
    if not pid:
        print 'cannot find process:' + config_file
        return
    if kill:
        print '强制关闭:', config_file, 'pid:'+pid
        os.system("kill %s" % pid)
        return
    # telnet shutdown
    # line = check_output("grep debug_console_port %s" % config_file, shell=True)
    # port = line.split("=")[1].strip()
    # port = int(port)

    # # socket连接
    # print '关闭:', config_file, port, 'pid:'+pid
    # sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    # sock.connect(("127.0.0.1", port))
    # sock.recv(1024)
    # sock.sendall('shutdown\n')
    # print sock.recv(1024)
    # sock.close()


    # touch shutdown
    node_name = os.path.basename(config_file)[:-4]
    os.system("touch status/" + node_name + ".shuting")

    count = 0
    while True:
        if not check_output(cmd, shell=True):
            break
        time.sleep(0.1)
        count += 1
        if count % 10 == 0:
            print '等待 %s:%s 关闭...' % (config_file, pid)
