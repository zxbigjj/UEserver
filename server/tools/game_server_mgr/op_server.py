#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import os.path
import yaml
import time

##########################################################################
# 添加服务器
CONFIG_TEMPLATE_PATH = "/../../config.template"
CONFIG_PATH = "/../../config/"
SERVER_PATH = "/../../"
this_dir = os.path.dirname(os.path.abspath(__file__))


def make_game_server_lua():
    try:
        os.chdir(this_dir + CONFIG_PATH)
        os.system('python generator.py --global')
        time.sleep(1)
        os.system('python generator.py')
        os.chdir(this_dir)
    except:
        return False
    else:
        return True


def start_all_game_server():
    try:
        path_tmp = this_dir
        os.chdir(this_dir + SERVER_PATH)
        os.system('python start_server.py')
        os.chdir(path_tmp)
    except:
        return False
    else:
        return True


def query_game_server_lua():
    from subprocess import check_output

    assert(this_dir == os.getcwd())
    game_config_list = check_output(
        "cd %s && ls s*_game.lua" % (this_dir + CONFIG_PATH), shell=True)
    game_config_list = [x.strip()
                        for x in game_config_list.split("\n") if x.strip()]

    return game_config_list


def query_game_server():
    with open(this_dir + CONFIG_TEMPLATE_PATH + "/config.yaml", "r") as f:
        config = yaml.safe_load(f.read())
    return config['server_list']


def add_game_server(args):
    try:
        with open(this_dir + CONFIG_TEMPLATE_PATH + "/config.yaml", "a") as f:
            yaml.safe_dump(args, f, allow_unicode=True,
                           default_flow_style=False)
    except IOError:
        return False
    else:
        return True


def make_game_server_databases(server_id):
    import pymysql
    try:
        db = pymysql.connect(host='localhost', user='root',
                             password='cys123456')
        cursor = db.cursor()
        sql = "CREATE DATABASE IF NOT EXISTS hd_game%s" % server_id
        cursor.execute(sql)
        cursor.close()
        db.commit()
        db.close()
    except:
        return False
    else:
        return True
