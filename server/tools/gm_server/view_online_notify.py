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
@route('/view_online_notify')
@check_user("online_notify")
def view_online_notify(user):
    return template("online_notify", curr_user=user, **(view_utils.all_funcs))


################################################
# 公告管理
PNAME = "公告管理"


@route('/query_roll_notice', method='post')
@check_user("online_notify")
def query_roll_notice(user):
    # get values
    server_id = request.params.get("server_id")

    print(server_id)

    result = common_utils.call_gm(server_id, None, 'query_roll_notice', None)

    if result['code'] == 0:
        return json.dumps({"info": result['data']})
    else:
        print("失败", result["err_msg"])
        return {'err': result['err_msg']}


@route('/add_roll_notice', method="POST")
@check_user("online_notify")
def add_roll_notice(user):
    # get values
    server_id = request.params.get("server_id")
    content = request.params.get("content")
    interval = request.params.get("interval")
    start_ts = request.params.get("start_ts")
    end_ts = request.params.get("end_ts")

    print(interval, end_ts, start_ts, content, server_id)

    args = dict(
        server_id=server_id,
        content=content,
    )

    now = int(time.time())
    if interval == '' or interval is None:
        args["interval"] = 100
    else:
        args["interval"] = int(interval)

    if start_ts == 'NaN':
        args["start_ts"] = now + 2
    else:
        args["start_ts"] = int(start_ts)

    if end_ts == 'NaN':
        args["end_ts"] = now + 100
    else:
        args["end_ts"] = int(end_ts)

    result = common_utils.call_gm(server_id, None, 'add_roll_notice', args)

    if result['code'] == 0:
        common_utils.push_log(user, PNAME, "添加公告",
                              "%s %s" % (server_id, result["notice_id"]))
        return json.dumps({"info": result['data']})
    else:
        print("失败", result["err_msg"])
        return {'err': result['err_msg']}


@route('/delete_roll_notice', method="POST")
@check_user("online_notify")
def delete_roll_notice(user):
    # get values
    server_id = request.params.get("server_id")
    notice_id = request.params.get("notice_id")

    print(server_id, notice_id)

    args = dict(
        notice_id=notice_id,
    )

    result = common_utils.call_gm(server_id, None, 'delete_roll_notice', args)

    if result['code'] == 0:
        common_utils.push_log(user, PNAME, "删除公告",
                              "%s %s" % (server_id, notice_id))
        return {'info': result['data']}
    else:
        return {'err': 'False'}


@route('/edit_roll_notice', method="POST")
@check_user("online_notify")
def edit_roll_notice(user):
    # get values
    server_id = request.params.get("server_id")
    notice_id = request.params.get("notice_id")
    content = request.params.get("content")
    start_ts = request.params.get("start_ts")
    end_ts = request.params.get("end_ts")
    interval = request.params.get("interval")

    print(interval, end_ts, start_ts, content, server_id, notice_id)

    args = dict(
        server_id=server_id,
        notice_id=notice_id,
        content=content,
    )

    now = int(time.time())
    if interval == '' or interval is None:
        args["interval"] = 100
    else:
        args["interval"] = int(interval)

    if start_ts == 'NaN':
        args["start_ts"] = now + 2
    else:
        args["start_ts"] = int(interval)

    if end_ts == 'NaN':
        args["end_ts"] = now + 100
    else:
        args["end_ts"] = int(interval)

    result = common_utils.call_gm(server_id, None, 'edit_roll_notice', args)

    if result['code'] == 0:
        common_utils.push_log(user, PNAME, "修改公告",
                              "%s %s" % (server_id, notice_id))
        return json.dumps({"info": result['data']})
    else:
        print("失败", result["err_msg"])
        return {'err': result['err_msg']}
