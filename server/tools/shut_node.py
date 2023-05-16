#coding=utf-8
#关闭node, 参数node的配置文件
import sys
import getopt
import socket
import os.path
import subprocess

def get_debug_port(config_file_name):
    # 检查是不是自己的进程
    basename = os.path.basename(config_file_name)
    lines = subprocess.check_output(["ps", "aux"]).split("\n")
    lines = [line for line in lines if basename in line and "shut_node" not in line]
    uname = subprocess.check_output(["whoami"]).strip()
    for line in lines:
        if line.strip().split(" ")[-1] != uname:
            assert("cannot shut server:" + line)
    
    with open(config_file_name) as config_file:
        for line in config_file.readlines():
            if line.startswith("server_id"):
                pos = line.find("=")
                server_id = int(line[pos+1:].strip())
            if line.startswith("debug_console_port"):
                pos = line.find("=")
                exec "port=" + (line[pos+1:].strip().replace("server_id", "%d"%server_id))
                return port
    raise RuntimeError("cannot find debug port in: " + config_file)

def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "c:p:")
    except getopt.GetoptError as err:
        # print help information and exit:
        print str(err)  # will print something like "option -a not recognized"
        return

    print sys.argv

    port = None
    for k,v in opts:
        if k=="-c":
            port = get_debug_port(v)
            print "===shutdown:" + str(port)
        if k=="-p":
            port = int(v)
            print "===shutdown:" + str(port)

    if not port:
        print "请指定node的配置文件(-c),或者debug端口(-p)"
        return
    # socket连接
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        sock.connect(("127.0.0.1", port))
    except:
        print "ignore"
        return
    sock.recv(1024)
    sock.sendall('shutdown\n')
    while True:
        data = sock.recv(1024)
        if not data:
            break
        else:
            print data
    print "===over"
    sock.close()

if __name__ == '__main__':
    main()