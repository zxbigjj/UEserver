#!/usr/bin/env python
# -*- coding: utf-8 -*-
import datetime
import json
from bottle import route, template, redirect
from bottle import request, response

import user_manager
from user_manager import check_user

import view_utils, common_utils

PNAME = "账号管理"

class UserRender(object):
    def __init__(self, user):
        self.uid = user.uid
        self.name = user.name
        self.nick = user.nick
        self.group = user_manager.get_group_by_key(user.group_id).name
        self.create_ts = fmt_ts(user.create_ts)
        self.modify_ts = fmt_ts(user.modify_ts)
        self.status = user.status

def fmt_ts(ts):
    dt = datetime.datetime.fromtimestamp(ts)
    return dt.strftime('%Y/%m/%d %H:%M')

@route('/view_user_mgr')
@check_user("user_mgr")
def view_user_mgr(user):
    all_user = [UserRender(u) for u in user_manager.get_all_user()]
    return template("user_mgr", curr_user=user,
        all_user=all_user,
        all_group=user_manager.get_all_group(),
        all_status=user_manager.get_all_status(),
        **(view_utils.all_funcs))

@route('/add_user', method='POST')
@check_user("user_mgr")
def add_user(curr_user):
    name = request.params.get("name")
    pwd = request.params.get("pwd")
    nick = request.params.get("nick")
    group_name = request.params.get("group_name")
    status = request.params.get('status')

    if not pwd:
        return "密码不能为空"
    user = user_manager.get_user_by_name(name)
    if user:
        return "账号已存在"
    group = user_manager.get_group_by_name(group_name)
    if not group:
        return "用户组不存在"
    if status not in user_manager.get_all_status():
        return "状态错误"
    user_manager.create_user(name, pwd, group.gid, nick, status)
    common_utils.push_log(curr_user, PNAME, "新建账号", 
        "%s(%s), %s, %s" % (name, nick, group.name, status))
    return

@route('/delete_user', method="POST")
@check_user("user_mgr")
def delete_user(curr_user):
    uid_list = json.loads(request.params.get("uid_list"))
    for uid in uid_list:
        if uid == curr_user.uid:
            return '不能删除自己'
        user = user_manager.get_user_by_uid(uid)
        if user and user.name == 'admin':
            return '不能删除admin'
    name_list = []
    for uid in uid_list:
        user = user_manager.get_user_by_uid(uid)
        if user:
            user.delete()
            name_list.append("%s(%s)" % (user.name, user.nick))
    common_utils.push_log(curr_user, PNAME, "删除账号", ",".join(name_list))
    return

@route('/modify_user', method='POST')
@check_user("user_mgr")
def modify_user(curr_user):
    uid = request.params.get("uid")
    user = user_manager.get_user_by_uid(uid)
    if not user:
        return "用户不存在"
    if user.name == 'admin':
        return "不能修改amdin"

    pwd = request.params.get("pwd")
    nick = request.params.get("nick")
    group_name = request.params.get("group_name")
    status = request.params.get('status')

    group = user_manager.get_group_by_name(group_name)
    if not group:
        return "用户组不存在"
    if status not in user_manager.get_all_status():
        return "状态错误"

    old_group = user_manager.get_group_by_key(user.group_id)
    old_desc = "%s,%s,%s" % (user.nick, old_group.name, user.status)
    user.modify(nick, pwd, group.gid, status)
    new_desc = "%s,%s,%s" % (user.nick, group.name, user.status)
    common_utils.push_log(curr_user, PNAME, "修改账号", '%s => %s' % (old_desc, new_desc))
    return