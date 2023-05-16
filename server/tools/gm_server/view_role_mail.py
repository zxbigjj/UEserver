#!/usr/bin/env python
#coding=utf-8

import json
import datetime
import time
from bottle import route, template, redirect
from bottle import request, response

import user_manager
from user_manager import check_user

import view_utils
import common_utils


@route('/view_role_mail')
@check_user("role_mail")
def view_role_mail(curr_user):
    return template("role_mail", curr_user=curr_user, **(view_utils.all_funcs))


################################################################################################
PNAME_1 = "邮件系统"


@route('/add_mail_role', method='post')
@check_user("role_mail")
def add_mail_role(user):
    title = request.params.get("title")
    content = request.params.get("content")
    server_id = request.params.get("server_id")
    item_list = json.loads(request.params.get("item_list"))
    arr_uuids = json.loads(request.params.get("arr_uuids"))

    if not arr_uuids:
        return {"err": "uuid 不能为空"}
    for uuid in arr_uuids:
        if not uuid.isdigit():  # 是否为数字
            return {"err": "uuid 存在非数字"}

    ret_error = []

    for uuid in arr_uuids:
        result = common_utils.role_mail(
            server_id, title, content, item_list, uuid)

        if result['code'] == 0:
            print('添加成功' + str(uuid) + "," + title + "," + content)
            common_utils.push_log(user, PNAME_1, "添加玩家邮件成功",
                                  str(uuid) + "," + title + "," + content)
        else:
            print('添加失败: ', result['err_msg'])
            common_utils.push_log(user, PNAME_1, "添加玩家邮件失败",
                                  str(uuid) + "," + title + "," + content)
            ret_error.append("%s %s \n" % (uuid, result["err_msg"]))

    if ret_error:
        return {"err": ret_error}
    else:
        return {"info": "ok"}
