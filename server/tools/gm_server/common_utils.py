#!/usr/bin/env python
# -*- coding: utf-8 -*-
import binascii
import json
import db
import config
import requests
import hashlib
import yaml
import os, os.path
import subprocess
import time

##########################################################################
# 公共


# 只管抛出全部,不管类型;返回字典
def req_gm_router(path, data):
    ip = config.gm_router_ip
    port = config.gm_router_port
    url = "http://%s:%d/%s" % (ip, port, path)
    ts = int(time.time())
    key = '8dFACTRDdNiAiYv6pV046UfJ147RzE37'
    md5 = hashlib.md5()
    md5.update('ts=%s&key=%s&data=%s' % (ts, key, data))
    sign = md5.hexdigest()
    r = requests.post(url, json={"data": data, "ts": ts, "sign": sign})
    result = json.loads(r.text)
    return result


# 施工
def call_gm(server_id, uuid, cmd, args):  # args 字典
    print("is ready to " + cmd)
    data = dict(gm_name=cmd,)
    if server_id:
        data["server_id"] = server_id
    if uuid:
        data["uuid"] = uuid
    args_type = type(args)
    if args_type is dict:
        for key, values in args.items():
            data[key] = values
    elif args_type is str:
        data['name'] = args

    print(data)

    return req_gm_router("do_gm", json.dumps(data))


##########################################################################
# 邮件功能


def role_mail(server_id, title, content, item_list, uid):
    data = dict(
        gm_name='role_mail',
        server_id=server_id,
        uuid_list=[uid],
        title={"chs": title},
        expire_ts=int(time.time()) + 10000000,
    )

    if item_list:
        data['item_list'] = item_list
    if content:
        data['content'] = {"chs": content}

    return req_gm_router("do_gm", json.dumps(data))


def global_mail(server_id, title, content, channel, is_all_channel, item_list, start_ts, end_ts):
    now = int(time.time())
    data = dict(
        gm_name='global_mail',
        server_id=server_id,
        title={"chs": title},
        channel=channel,
        is_all_channel=is_all_channel,
        start_ts=start_ts,
        end_ts=end_ts,

        expire_ts=now + 10000000,
        role_create_ts1=now - 1000000,
        role_create_ts2=now + 1000000,
    )

    if item_list:
        data['item_list'] = item_list
    if content:
        data['content'] = {"chs": content}

    result = req_gm_router("do_gm", json.dumps(data))
    return result

##########################################################################
# 查询功能


# 成功返回空字符， 失败返回错误说明
def check_uuid(uuid_list):
    r = call_gm(None, uuid_list, 'query_uuid', None)
    if(r['code'] != 0):
        return r['err_msg']
    else:
        return None


def call_dev_http():
    data = dict(
        gm_name="query_all_servers",
    )
    return req_gm_router('do_gm',  json.dumps(data))


# def query_forbid_login(server_id, uuid):
#     data = dict(
#         gm_name="query_forbid_login",
#         server_id=server_id,
#         uuid=uuid,
#     )
#     return req_gm_router('do_gm',  json.dumps(data))


# def query_forbid_speak(server_id, uuid):
#     data = dict(
#         gm_name="query_forbid_speak",
#         server_id=server_id,
#         uuid=uuid,
#     )
#     return req_gm_router('do_gm',  json.dumps(data))


# def query_user_info(server_id, uuid):
#     data = dict(
#         gm_name="query_user_info",
#         server_id=server_id,
#         uuid=uuid,
#     )
#     return req_gm_router('do_gm',  json.dumps(data))

##########################################################################
# 日志功能


def push_log(user, page_name, op_name, data):
    import db
    doc = dict(
        uname=user.name,
        page_name=page_name,
        op_name=op_name,
        data=data,
        ts=int(time.time())
    )
    db.insert_one("OpLog", doc)


def query_log(query, **kwargs):
    return [x for x in db.find("OpLog", query, **kwargs)]


##########################################################################
# 添加服务器    fk,ljgn


class ServerList(object):
    def __init__(self, this_dir):
        self.__this_dir = this_dir
        self.server = self.__this_dir + '/../..'
        self.config_template_dir = self.server + '/config.template'
        self.config_dir = self.server + '/config'

    def add_config_info_into_config_file(self):
        import yaml

    def make_game_server_lua(self):
        pass

    def __check_game_server_db(self, db_config, server_id):
        import pymysql
        try:
            db_client = pymysql.connect(
                host=db_config['host'],
                user=db_config['user'],
                password=db_config['password']
            )
            cursor = db_client.cursor()
            sql = "CREATE DATABASE IF NOT EXISTS hd_game%s" % int(server_id)
            cursor.execute(sql)
            cursor.close()
            db_client.commit()
            db_client.close()
        except:
            return False
        else:
            return True

    def start_selected_game_server(self, db_config, game_server_list):
        for game_server in game_server_list:
            if self.__check_game_server_db(db_config, server_id):
                pass

# def make_game_server_lua():
#     try:
#         os.chdir(this_dir + CONFIG_PATH)
#         os.system('python generator.py --global')
#         time.sleep(1)
#         os.system('python generator.py')
#         os.chdir(this_dir)
#     except:
#         return False
#     else:
#         return True


# def start_all_game_server():
#     try:
#         path_tmp = this_dir
#         os.chdir(this_dir + SERVER_PATH)
#         os.system('python start_server.py')
#         os.chdir(path_tmp)
#     except:
#         return False
#     else:
#         return True


# def query_game_server_lua():
#     from subprocess import check_output

#     assert(this_dir == os.getcwd())
#     game_config_list = check_output(
#         "cd %s && ls s*_game.lua" % (this_dir + CONFIG_PATH), shell=True)
#     game_config_list = [x.strip()
#                         for x in game_config_list.split("\n") if x.strip()]

#     return game_config_list


# def query_game_server():
#     with open(this_dir + CONFIG_TEMPLATE_PATH + "/config.yaml", "r") as f:
#         config = yaml.safe_load(f.read())
#     return config['server_list']


# def add_game_server(args):
#     try:
#         with open(this_dir + CONFIG_TEMPLATE_PATH + "/config.yaml", "a") as f:
#             yaml.safe_dump(args, f, allow_unicode=True,
#                            default_flow_style=False)
#     except IOError:
#         return False
#     else:
#         return True


# def make_game_server_databases(server_id):
#     import pymysql
#     try:
#         db = pymysql.connect(host='localhost', user='root',
#                              password='cys123456')
#         # db = pymysql.connect(host='localhost', user='root',
#         #                      password='a89767543413c530')
#         cursor = db.cursor()
#         sql = "CREATE DATABASE IF NOT EXISTS hd_game%s" % server_id
#         cursor.execute(sql)
#         cursor.close()
#         db.commit()
#         db.close()
#     except:
#         return False
#     else:
#         return True
