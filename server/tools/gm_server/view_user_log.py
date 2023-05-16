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


@route('/view_user_log')
@check_user("user_log")
def view_user_log(curr_user):
    return template("user_log", curr_user=curr_user, **(view_utils.all_funcs))


@route('/query_user_log', method="post")
@check_user('user_log')
def query_user_log(curr_user):
    name = request.params.get('name')
    ts_begin = request.params.get('ts_begin')
    ts_end = request.params.get('ts_end')

    if ts_begin:
        ts_begin = time.mktime(time.strptime(ts_begin, "%Y-%m-%d"))
    else:
        ts_begin = 0
    if ts_end:
        ts_end = time.mktime(time.strptime(ts_end, "%Y-%m-%d")) + 24*3600
    else:
        ts_end = time.time()

    query = {"ts": {"$lt": ts_end, "$gt": ts_begin}}
    if name:
        user = user_manager.get_user_by_name(name)
        if user:
            query["uname"] = name
        else:
            return {"err": "用户不存在"}
    log_list = common_utils.query_log(
        query, projection={'_id': False}, limit=1000)
    return {"log_list": log_list}
