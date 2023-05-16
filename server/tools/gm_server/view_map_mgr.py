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


################################################
@route('/view_map_mgr')
@check_user("map_mgr")
def view_map_mgr(user):
    return template("map_mgr", curr_user=user, **(view_utils.all_funcs))


################################################
@route('/set_role_stage_to', method='post')
@check_user('map_mgr')
def set_role_stage_to(user):
    try:
        server_id = int(request.params.get("server_id"))
        uuid = request.params.get("uuid")
        stage_id = request.params.get("stage_id")
    except:
        return {'err': '请检查输入'}
    args = dict(server_id=server_id, uuid=uuid, stage=stage_id)
    result = common_utils.call_gm(server_id, uuid, "set_role_stage_to", args)
    if result['code'] == 0:
        return {'info': '操作成功'}
    else:
        return {'err': '操作错误'}
