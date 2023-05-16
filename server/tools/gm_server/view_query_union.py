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


@route('/view_query_union')
@check_user("query_union")
def view_gift_key(curr_user):
    return template("query_union", curr_user=curr_user, **(view_utils.all_funcs))
#######################################################################################


@route('/query_dynasty_info', method="POST")
@check_user("query_union")
def query_dynasty_info(curr_user):
    try:
        server_id = int(request.params.get("server_id"))
        dynasty_name = request.params.get("dynasty_name")
    except:
        return {'err': '请检查输入'}
    if len(dynasty_name) < 3:
        return {'err': '王朝名称不能小于3个字符'}
    args = dict(server_id=server_id, dynasty_name=dynasty_name)
    result = common_utils.call_gm(server_id, None, "seek_dynasty", args)
    if result['code'] == 0:
        return {'info': result['data']}
    else:
        return {'err': result['err_msg']}


@route('/set_dynasty_info', method="POST")
@check_user("query_union")
def set_dynasty_info(curr_user):
    try:
        server_id = int(request.params.get("server_id"))
        uuid = request.params.get("uuid")
        dynasty_id = int(request.params.get("dynasty_id"))
        dynasty_exp = int(request.params.get("dynasty_exp"))
    except:
        return {'err': '请检查输入'}
    args = dict(
        server_id=server_id, uuid=uuid,
        dynasty_id=dynasty_id, dynasty_exp=dynasty_exp
    )
    result = common_utils.call_gm(server_id, None, "add_dynasty_exp", args)
    if result['data'] != {}:
        return {'info': result['data']}
    else:
        return {'err': '操作错误'}
