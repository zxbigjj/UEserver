#!/usr/bin/env python
# -*- coding: utf-8 -*-
import json
import datetime
import time
from bottle import route, template, redirect
from bottle import request, response

import user_manager
from user_manager import check_user

import view_utils
import common_utils

import config

################################################
# 修改系统时间
PNAME = "修改系统时间"

@route('/view_server_time')
@check_user("server_time")
def view_server_time(curr_user):
    return template("server_time", curr_user=curr_user, **(view_utils.all_funcs))


@route('/add_server_time', method='post')
@check_user("server_time")
def add_server_time(curr_user):
   
    # get values
    server_id = int(request.params.get('server_id'))
    server_time = int(request.params.get('server_time'))
    print(server_time)

    args = dict(server_time=server_time)
    result = common_utils.call_gm(server_id, None, 'set_serverTimes', args)
    if result['code'] == 0:
        return {'info': result['data']}
    else:
        return {'err': result['err_msg']}