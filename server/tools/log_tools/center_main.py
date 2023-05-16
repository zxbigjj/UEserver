#encoding=utf-8
#日志中心跑
import os, os.path, sys
import json
import zipfile
import time, datetime
import re

this_dir = os.path.dirname(os.path.abspath(__file__))

import ConfigParser
config = ConfigParser.ConfigParser()
config.read(os.path.join(this_dir, "../tools.conf"))

GAME_ID = config.get("log_tools", "game_id")
GAME_ID = '%d' % int(GAME_ID)

# 每天上传
def check_upload_bdc():
    now_dt = datetime.datetime.now()
    print "check_upload_bdc", now_dt
    yest_dt = now_dt - datetime.timedelta(days=1)
    dir_yest = os.path.join(this_dir, "bdclog", yest_dt.strftime("%Y%m%d"))
    if not os.path.isdir(dir_yest):
        return
    # 打包
    print "开始打包:" + dir_yest
    zip_dict = {}
    for file_name in os.listdir(dir_yest):
        if not file_name.endswith(".log") or not file_name.startswith(GAME_ID):
            continue
        m = re.match(r"\d+_\d+_(\w+)_\d{4}\-\d{2}\-\d{2}\.log", file_name)
        if not m: continue
        log_name = m.groups()[0].lower()
        if log_name not in zip_dict:
            zip_name =  [GAME_ID, log_name, yest_dt.strftime("%Y-%m-%d")]
            zip_name = "_".join(zip_name) + ".zip"
            zip_dict[log_name] = zipfile.ZipFile(os.path.join(dir_yest, zip_name), 'w')
            print zip_name
        zip_dict[log_name].write(os.path.join(dir_yest, file_name), file_name)
    if not zip_dict:
        return
    # close
    for zip_file in zip_dict.values():
        zip_file.close()
    print "打包结束, 上传"
    # 上传
    os.system("sh send_daily.sh %s" % dir_yest)
    print "上传完成"

# 每小时上传
def check_upload_bdchour():
    now_dt = datetime.datetime.now()
    print 'check_upload_bdchour', now_dt
    dir_name = os.path.join(this_dir, "bdclog", now_dt.strftime("%Y%m%d%H"))
    if not os.path.isdir(dir_name):
        return
    out_file_name = [GAME_ID, now_dt.strftime("%Y-%m-%d_%H")]
    out_file_name = "_".join(out_file_name) + ".log"
    out_file_name = os.path.join(dir_name, out_file_name)
    has_new = False
    for file_name in os.listdir(dir_name):
        if not file_name.endswith(".log") or not file_name.startswith(GAME_ID):
            continue
        m = re.match(r"\d+_\d+_(\w+)_\d{4}\-\d{2}\-\d{2}\_\d{2}\.log", file_name)
        if not m: continue
        fullname = os.path.join(dir_name, file_name)
        os.system("cat %s >> %s" % (fullname, out_file_name))
        os.system("mv %s %s" % (fullname, fullname + ".bak"))
        has_new = True
    # 上传
    if os.path.exists(out_file_name) and has_new:
        print "上传:" + out_file_name
        os.system("sh send_hour.sh %s" % dir_name)

def main():
    if not os.path.isdir("bdclog"):
        os.mkdir("bdclog")
    check_dict = {
        'check_upload_bdc': 0,
        'check_upload_bdchour':0,
    }
    while True:
        time.sleep(1)
        now = time.time()
        # 每天上传
        if check_dict['check_upload_bdc'] < now:
            check_upload_bdc()
            sys.stdout.flush()
            sys.stderr.flush()
            now = time.time()
            now_dt = datetime.datetime.now()
            diff = 3600*24 - (now_dt.hour * 3600 + now_dt.minute*60 + now_dt.second)
            # 1点上传
            check_dict['check_upload_bdc'] = now + diff + 3600
        # 每小时上传
        if check_dict['check_upload_bdchour'] < now:
            check_upload_bdchour()
            sys.stdout.flush()
            sys.stderr.flush()
            now = time.time()
            now_dt = datetime.datetime.now()
            diff = 3600 - (now_dt.minute*60 + now_dt.second)
            # 多等2分钟
            check_dict['check_upload_bdchour'] = now + diff + 120

if __name__ == "__main__":
    main()
