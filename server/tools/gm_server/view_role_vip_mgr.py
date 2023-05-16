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


@route('/view_role_vip_mgr')
@check_user("role_vip_mgr")
def view_gift_key(curr_user):
    return template("role_vip_mgr", curr_user=curr_user, **(view_utils.all_funcs))
#######################################################################################


@route('/set_role_vip', method="POST")
@check_user('role_vip_mgr')
def set_role_vip(curr_user):
    try:
        uuid = str(request.params.get('uuid'))
        server_id = int(request.params.get('server_id'))
        vip_level = int(request.params.get('vip_level'))
    except:
        return {'err': '请检查输入'}
    args = dict(uuid=uuid, server_id=server_id, vip_level=vip_level)
    result = common_utils.call_gm(server_id, uuid, "set_role_vip", args)
    if result['code'] == 0:
        return {'info': result['data']}
    else:
        return {'err': result['err_msg']}
