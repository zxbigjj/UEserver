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


def formatTime(ts):
    return time.strftime("%Y-%m-%d %H:%M", time.localtime(int(ts)))


@route('/view_query_vip')
@check_user("query_vip")
def view_gift_key(curr_user):
    return template("query_vip", curr_user=curr_user, **(view_utils.all_funcs))
#######################################################################################


@route('/query_charge_info', method="post")
@check_user("query_vip")
def query_dynasty_info(curr_user):
    try:
        server_id = int(request.params.get("server_id"))
    except:
        return {'err': '请检查输入'}
    result = common_utils.call_gm(server_id, None, "get_charge_info", None)
    if result['code'] == 0:
        for chargeInfo in result['data']['form']:
            chargeInfo['order_id'] = formatTime(chargeInfo['order_id'][:10])
        return {'info': result['data']}
    else:
        return {'err': result['err_msg']}
