#!/usr/bin/env python
# -*- coding: utf-8 -*-
from cgitb import reset
import json
import datetime
import time
from unittest import result
from bottle import route, template, redirect
from bottle import request, response

import user_manager
from user_manager import check_user

import view_utils
import common_utils


@route('/view_sys_mail')
@check_user("sys_mail")
def view_sys_mail(curr_user):
    return template("sys_mail", curr_user=curr_user, **(view_utils.all_funcs))


PNAME_1 = "邮件系统"


@route('/add_mail_sys', method='post')
@check_user("sys_mail")
def add_mail_sys(user):
    # 获取数据
    title = request.params.get("title")
    content = request.params.get("content")
    server_id = request.params.get("server_id")
    channel = request.params.get("channel")
    is_all_channel = bool(request.params.get("is_all_channel"))
    item_list = json.loads(request.params.get("item_list"))
    begin_ts = request.params.get("sys_mail_begin_time")
    end_ts = request.params.get("sys_mail_end_time")

    result = common_utils.global_mail(
        server_id, title, content, channel, is_all_channel, item_list, begin_ts, end_ts)

    ret_error = []

    if result["code"] == 0:
        print('添加OK')
        common_utils.push_log(user, PNAME_1, "后台邮件", '服务器id:'+server_id)
    else:
        print(result['err_msg'])
        common_utils.push_log(user, PNAME_1, "后台邮件",
                              server_id, result["err_msg"])
        ret_error.append("%s %s \n" % (server_id, result["err_msg"]))

    if ret_error:
        return {"err": ret_error}
    else:
        return {"info": "ok"}
