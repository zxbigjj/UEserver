#!/usr/bin/env python
# -*- coding: utf-8 -*-
import json
import functools
from bottle import route, template, redirect
from bottle import request, response

import user_manager
from user_manager import check_user

import view_utils
import common_utils

PNAME = "组管理"


@route('/view_group_mgr')
@check_user("group_mgr")
def view_group_mgr(user):
    all_group = user_manager.get_all_group()
    all_group.sort(key=lambda v: v.num)
    return template("group_mgr", curr_user=user, all_group=all_group, **(view_utils.all_funcs))


@route('/add_group', method="POST")
@check_user("group_mgr")
def add_group(user):
    name = request.params.get("name")
    info = request.params.get("info")
    group = user_manager.get_group_by_name(name)
    if group:
        return "%s已经存在了" % name
    group = user_manager.create_user_group(name, info, [])
    common_utils.push_log(user, PNAME, "创建组", name)
    return


@route('/delete_group', method="POST")
@check_user("group_mgr")
def delete_group(user):
    gid_list = json.loads(request.params.get("gid_list"))
    for gid in gid_list:
        group = user_manager.get_group_by_key(gid)
        if group and group.get_member():
            return (" %s 还有成员，不可删除" % group.name)
    name_list = []
    for gid in gid_list:
        group = user_manager.get_group_by_key(gid)
        if group:
            group.delete()
            name_list.append(group.name)
    common_utils.push_log(user, PNAME, "删除组", ",".join(name_list))
    return


@route('/modify_group', method="POST")
@check_user("group_mgr")
def modify_group(user):
    name = request.params.get("name")
    info = request.params.get("info")
    gid = request.params.get("gid")
    group = user_manager.get_group_by_key(gid)
    if not group:
        return "找不到组"
    if name != group.name and user_manager.get_group_by_name(name):
        return "%s已存在， 不能重名" % name
    common_utils.push_log(user, PNAME, "修改组",
                          "%s=>%s, %s=>%s" % (group.name, name, group.info, info))
    group.modify(name, info)
    return


@route('/set_power', method='POST')
@check_user('group_mgr')
def set_power(user):
    gid = request.params.get("gid")
    power_list = []
    for k, v in request.params.items():
        if k == 'gid':
            continue
        if v == 'on':
            power_list.append(k)
    group = user_manager.get_group_by_key(gid)
    if not group:
        return "找不到组"
    old_power = set(group.power_list)
    group.set_power(power_list)
    new_power = set(group.power_list)
    old_power, new_power = "-".join(old_power -
                                    new_power), "/".join(new_power-old_power)
    common_utils.push_log(user, PNAME, "设置权限",
                          "移除：%s, 新增：%s" % (old_power, new_power))
    return


@route('/query_group', method="POST")
@check_user('group_mgr')
def query_group(user):
    gid = request.params.get("gid")
    group = user_manager.get_group_by_key(gid)
    if not group:
        return {'err': '找不到组'}
    return {'group': group.todict()}
