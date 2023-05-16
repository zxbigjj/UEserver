#encoding=utf-8
#每个服务器跑
import os, os.path
import json
import zipfile
import time, datetime
import threading
import sys

this_dir = os.path.dirname(os.path.abspath(__file__))
log_path = os.path.abspath(os.path.join(this_dir, "../../log"))

import ConfigParser
config = ConfigParser.ConfigParser()
config.read(os.path.join(this_dir, "../tools.conf"))

GAME_ID = config.get("log_tools", "game_id")
GAME_ID = '%d' % int(GAME_ID)
CENTER_IP = config.get("log_tools", "center_ip")
PlatformDict = {
    "android": 13,
    "ios": 11,
}
def make_server_id(server_id):
    server_id = int(server_id)
    return "%2d%04d%d" % (PlatformDict["android"], int(GAME_ID), server_id+100000)

def parse_line(line):
    try:
        index = line.index("{")
        head = line[:index]
        tail = line[index:]
        tail = json.loads(tail)

        name = head[head.rindex("[")+1 : head.rindex("]")]
        data = tail["data"]
        if type(data) == dict:
            # lua表中间有nil的话会被打成字典， key从"1"开始
            maxkey = max([int(k) for k in data.keys()])
            _data = [data.get(unicode(k), u"") for k in xrange(1, maxkey+1)]
            data = _data
        data = [u"%s" % d for d in data]
        while len(data) < tail["length"]:
            data.append(u"")
    except Exception,e:
        print line
        raise(e)
    return name, data

# 每天上传的日志
# 日志结构
# log/s2_center/20170523/*_2017052301.log
def check_upload2center():
    now_dt = datetime.datetime.now()
    print 'check_upload2center', now_dt
    yest_dt = now_dt - datetime.timedelta(days=1)
    dir_yest = yest_dt.strftime("%Y%m%d")
    server_id = ""

    if not os.path.isdir(os.path.join(this_dir, dir_yest)):
        os.mkdir(os.path.join(this_dir, dir_yest))
    # 扫描
    out_file_dict = {}
    for root, dirs, files in os.walk(log_path):
        if not files:
            continue
        if not root.endswith(dir_yest):
            continue
        files = [f for f in files if f.startswith("bdclog_") and f.endswith(".log")]
        files = [f for f in files if not f.endswith("_upflag.log")]
        if not files:
            continue
        files.sort()

        if not server_id:
            server_id = root.split("/")[-2]
            server_id = server_id[1:server_id.index("_")]
            server_id = make_server_id(server_id)

        for file_name in files:
            fullname = os.path.join(root, file_name)
            print "读取:" + fullname
            with open(fullname) as fi:
                for line in fi.readlines():
                    name, data = parse_line(line)
                    content = u"\x1b\x7c".join(data) + u"\n"
                    if name not in out_file_dict:
                        out_file_name = [GAME_ID, server_id, name.lower()]
                        out_file_name.append(yest_dt.strftime("%Y-%m-%d"))
                        out_file_name = "_".join(out_file_name) + ".log"
                        out_file_name = os.path.join(this_dir, dir_yest, out_file_name)
                        out_file_dict[name] = [open(out_file_name, "w"), out_file_name]
                    out_file_dict[name][0].write(content.encode("utf8"))
            # os.system("mv %s %s" % (fullname, fullname.replace(".log", "_upflag.log")))
    if out_file_dict:
        for name, fi in out_file_dict.items():
            fi[0].close()
            print "生成:" + fi[1]
        # 上传
        print "上传中..."
        os.system("rsync -av --password-file=rsync.pass %s haojisheng@%s::bdclog" % (dir_yest, CENTER_IP))
        for name, fi in out_file_dict.items():
            os.system("rm %s" % fi[1])
    os.system("rmdir %s" % os.path.join(this_dir, dir_yest))
    return

# 每天上传的日志userinfo
# 日志结构
# log/s2_center/20170523/*_2017052301.log
def check_upload2userinfo():
    now_dt = datetime.datetime.now()
    print 'check_upload2userinfo', now_dt
    yest_dt = now_dt - datetime.timedelta(days=1)
    dir_yest = yest_dt.strftime("%Y%m%d")
    dir_now = now_dt.strftime("%Y%m%d")
    server_id = ""

    if not os.path.isdir(os.path.join(this_dir, dir_yest)):
        os.mkdir(os.path.join(this_dir, dir_yest))
    # 扫描
    out_file_dict = {}
    for root, dirs, files in os.walk(log_path):
        if not files:
            continue
        if not root.endswith(dir_now):
            continue
        files = [f for f in files if f.startswith("userinfo_") and f.endswith(".log")]
        files = [f for f in files if not f.endswith("_upflag.log")]
        if not files:
            continue
        files.sort()

        if not server_id:
            server_id = root.split("/")[-2]
            server_id = server_id[1:server_id.index("_")]
            server_id = make_server_id(server_id)

        for file_name in files:
            fullname = os.path.join(root, file_name)
            print "读取:" + fullname
            with open(fullname) as fi:
                for line in fi.readlines():
                    name, data = parse_line(line)
                    content = u"\x1b\x7c".join(data) + u"\n"
                    if name not in out_file_dict:
                        out_file_name = [GAME_ID, server_id, name.lower()]
                        out_file_name.append(yest_dt.strftime("%Y-%m-%d"))
                        out_file_name = "_".join(out_file_name) + ".log"
                        out_file_name = os.path.join(this_dir, dir_yest, out_file_name)
                        out_file_dict[name] = [open(out_file_name, "w"), out_file_name]
                    out_file_dict[name][0].write(content.encode("utf8"))
            # os.system("mv %s %s" % (fullname, fullname.replace(".log", "_upflag.log")))
    if out_file_dict:
        for name, fi in out_file_dict.items():
            fi[0].close()
            print "生成:" + fi[1]
        # 上传
        print "上传中..."
        os.system("rsync -av --password-file=rsync.pass %s haojisheng@%s::bdclog" % (dir_yest, CENTER_IP))
        for name, fi in out_file_dict.items():
            os.system("rm %s" % fi[1])
    os.system("rmdir %s" % os.path.join(this_dir, dir_yest))
    return

# 每小时上传的日志
# 日志结构
# log/s2_center/20170523/*_2017052301.log
def check_upload2center_hour():
    now_dt = datetime.datetime.now()
    print 'check_upload2center_hour', now_dt
    dir_name = now_dt.strftime("%Y%m%d%H")
    server_id = ""

    if not os.path.isdir(os.path.join(this_dir, dir_name)):
        os.mkdir(os.path.join(this_dir, dir_name))
    # 扫描
    out_file_dict = {}
    for root, dirs, files in os.walk(log_path):
        if not files:
            continue
        if not root.endswith(dir_name[:-2]):
            continue
        files = [f for f in files if f.startswith("realtime_") and f.endswith(dir_name + ".log")]
        files = [f for f in files if "upflag" not in f]
        if not files:
            continue
        files.sort()

        if not server_id:
            server_id = root.split("/")[-2]
            server_id = server_id[1:server_id.index("_")]
            server_id = make_server_id(server_id)

        for file_name in files:
            fullname = os.path.join(root, file_name)
            print "读取:" + fullname
            with open(fullname) as fi:
                for line in fi.readlines():
                    name, data = parse_line(line)
                    content = u"$$".join(data) + u"\n"
                    if name not in out_file_dict:
                        out_file_name = [GAME_ID, server_id, name.lower()]
                        out_file_name.append(now_dt.strftime("%Y-%m-%d_%H"))
                        out_file_name = "_".join(out_file_name) + ".log"
                        out_file_name = os.path.join(this_dir, dir_name, out_file_name)
                        out_file_dict[name] = [open(out_file_name, "w"), out_file_name]
                    out_file_dict[name][0].write(content.encode("utf8"))
            # os.system("mv %s %s" % (fullname, fullname.replace(".log", "_upflag.log")))
    if out_file_dict:
        for name, fi in out_file_dict.items():
            fi[0].close()
            print "生成:" + fi[1]
        # 上传
        print "上传中..."
        os.system("rsync -av --password-file=rsync.pass %s haojisheng@%s::bdclog" % (dir_name, CENTER_IP))
        for name, fi in out_file_dict.items():
            os.system("rm %s" % fi[1])
    os.system("rmdir %s" % os.path.join(this_dir, dir_name))
    return

def main():
    os.system("chmod 600 rsync.pass")
    check_dict = {
        'check_upload2center': 0,
        'check_upload2center_hour': 0,
        'check_upload2userinfo': 0,
    }
    while True:
        time.sleep(1)
        now = time.time()
        # 每天
        if check_dict['check_upload2center'] < now:
            check_upload2center()
            sys.stdout.flush()
            sys.stderr.flush()
            now = time.time()
            now_dt = datetime.datetime.now()
            diff = 3600*24 - (now_dt.hour * 3600 + now_dt.minute*60 + now_dt.second)
            # 多等15秒
            check_dict['check_upload2center'] = now + diff + 15
        # userinfo
        if check_dict['check_upload2userinfo'] < now:
            check_upload2userinfo()
            sys.stdout.flush()
            sys.stderr.flush()
            now = time.time()
            now_dt = datetime.datetime.now()
            diff = 3600*24 - (now_dt.hour * 3600 + now_dt.minute*60 + now_dt.second)
            # 0点30分
            check_dict['check_upload2userinfo'] = now + diff + 30*60
        # 每小时
        if check_dict['check_upload2center_hour'] < now:
            check_upload2center_hour()
            sys.stdout.flush()
            sys.stderr.flush()
            now = time.time()
            now_dt = datetime.datetime.now()
            diff = 3600 - (now_dt.minute*60 + now_dt.second)
            # 多等15秒
            check_dict['check_upload2center_hour'] = now + diff + 15

if __name__ == "__main__":
    main()