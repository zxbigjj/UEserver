#coding=utf-8
#关闭node, 参数node的配置文件
import sys
import getopt
import socket
import subprocess
import os, re

profile_data_file = os.path.abspath("profile.data")

def get_debug_port(config_file_name):
    context = {}
    server_id = 0
    debug_console_port_text = ""
    with open(config_file_name) as config_file:
        for line in config_file.readlines():
            match = re.match("^server_id\\s*=\\s(\d+)", line)
            if match:
                server_id = int(match.groups()[0])
            if line.startswith("debug_console_port"):
                debug_console_port_text = line
    if server_id and debug_console_port_text:
        context["server_id"] = server_id
        exec debug_console_port_text in context
        return context["debug_console_port"]
    raise RuntimeError("cannot find debug port in: " + config_file_name)

def get_port(pid):
    # 获取配置文件
    data = subprocess.check_output(["ps", "u", "-p" , str(pid)])
    data = data.split("\n")[1]
    config_file_name = data[data.index("skynet")+7:].split()[0]
    port = get_debug_port("../" + config_file_name)
    return port

def make_cmd(pid, sec):
    global profile_data_file
    # 获取子线程
    data = subprocess.check_output(["ps", "-T", "-p" , str(pid)])
    data = data.split("\n")[1:]
    tid_list = [x.split()[1] for x in data if x]
    # cat maps
    os.system("cat /proc/%d/maps > %s" % (pid, profile_data_file))
    # locate luaV_execute
    data = subprocess.check_output(["sh", "-c", "readelf -s ../bin/skynet | grep luaV_execute"])
    data = data.strip()
    assert(len(data.split("\n")) == 1)
    luaV_execute_begin = int(data.split()[1], 16)
    luaV_execute_size = int(data.split()[2])
    cmd = "profile %s %s %s %s" % (sec, profile_data_file, luaV_execute_begin, luaV_execute_size)
    cmd += " " + " ".join(tid_list)
    return cmd

def main():
    if len(sys.argv) < 3:
        print "请指定进程id和秒数"
        return
    pid = int(sys.argv[1])
    sec = int(sys.argv[2])
    port = get_port(pid)
    cmd = make_cmd(pid, sec)
    print 'cmd', cmd
    if '--show' in sys.argv:
        return
    # socket连接
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect(("127.0.0.1", port))
    sock.recv(1024)
    sock.sendall(cmd + "\n")
    while True:
        data = sock.recv(1024)
        print data
        break
    sock.close()

if __name__ == '__main__':
    main()