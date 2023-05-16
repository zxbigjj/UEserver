#!/usr/bin/env python
# -*- coding: utf-8 -*-

from bottle import request, response
from bottle import run, route, template, redirect, static_file

import op_server
import time
import json

import gevent
import gevent.monkey
gevent.monkey.patch_all()


@route('/query_server_list')
def query_server_list(curr_user):
    config = op_server.query_game_server()
    server_lua = op_server.query_game_server_lua()
    server_config = []
    title_list = []
    for server in config:
        if server['type'] == 'game':
            server_config.append(server)
    for title in config[0]:
        title_list.append({'title': title, 'field': title})
    return {'info': server_config, 'title_list': title_list, 'server_id': server_lua}


@route('/add_in_server_list', method='post')
def add_in_server_list(curr_uesr):
    try:
        name = request.params.get("name")
        type = 'game'
        server_id = int(request.params.get("server_id"))
        ip = request.params.get("ip")
        area_id = int(request.params.get("area_id"))
        area_name = request.params.get("area_name")
        open_time = request.params.get("open_time")
        allow_login = int(request.params.get("allow_login"))
        enable_ssl = bool(request.params.get("enable_ssl"))
        state = request.params.get("state")
        recommend_status = 0
        recommend_priority = 1
        cross_server_id = 70
    except:
        return {"err": "请检查输入"}
    args = dict(
        name=name, type=type, server_id=server_id, ip=ip,
        area_id=area_id, area_name=area_name,
        open_time=open_time,
        allow_login=allow_login, enable_ssl=enable_ssl, state=state,
        recommend_status=recommend_status, recommend_priority=recommend_priority, cross_server_id=cross_server_id,
    )
    if op_server.add_game_server(args):
        return {'info': ''}
    else:
        return {'err': 'error'}


@route('/make_game_server_lua')
def make_game_server_lua(curr_user):
    if not op_server.make_game_server_lua():
        return {'err': '创建启动文件失败'}
    return {'info': ''}


@route('/start_selected_server_list', method='post')
def start_selected_server_list(curr_user):
    game_server_list = json.loads(request.params.get('game_server_list'))
    if game_server_list == []:
        return {'err': '请选择'}

    import os
    import os.path
    tmp_dir = os.path.dirname(os.path.abspath(__file__))
    server_dir = tmp_dir + '/../../'
    os.chdir(server_dir)
    for game_server in game_server_list:
        server_id = game_server[1:game_server.index("_")]
        op_server.make_game_server_databases(server_id)
        time.sleep(2)
        os.system('python start_server.py --%s' % game_server)
    os.chdir(tmp_dir)
    return {'info': ''}


run(host='0.0.0.0', port=30100, server='gevent', debug=True)
