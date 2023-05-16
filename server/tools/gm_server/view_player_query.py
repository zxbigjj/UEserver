#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import time

from bottle import route, template, redirect
from bottle import request, response

import user_manager
from user_manager import check_user

import view_utils
import common_utils


################################player query###############################
PNAME_1 = "玩家查询"


@route('/view_player_query')
@check_user("player_query")
def view_player_query(user):
    all_group = user_manager.get_all_group()
    all_group.sort(key=lambda v: v.num)
    return template("player_query", curr_user=user, child="player_query", **(view_utils.all_funcs))


@route('/query_player', method="POST")
# @check_user("player_query/player_forbid")
def query_player():
    try:
        name = request.params.get("name")
        uuid = request.params.get("uuid")
        server_id = int(request.params.get("server_id"))
    except:
        return {"err": "请检查输入"}

    if name == '' and uuid == '':
        return {"err": "请检查输入"}

    args = dict(server_id=server_id)
    if name != '':
        args['name'] = name
    if uuid != '':
        args['uuid'] = uuid

    print(args)
    result = common_utils.call_gm(server_id, None, "query_user_info", args)

    if result['code'] == 0:
        result['data']['hero_dict'] = list(result['data']['hero_dict'].values())
        result['data']['lover_dict'] = list(result['data']['lover_dict'].values())
        return {"info": result["data"]}
    else:
        return {"err": result['err_msg']}


################################player forbid###############################
PNAME_2 = "封禁解封"


@route('/view_player_forbid')
@check_user("player_forbid")
def view_player_forbid(user):
    all_group = user_manager.get_all_group()
    all_group.sort(key=lambda v: v.num)
    return template("forbid_query", curr_user=user, child="player_forbid", **(view_utils.all_funcs))


@route('/kick_role', method='post')
@check_user("player_forbid")
def kick_role(user):
    uuid = request.params.get("uuid")
    server_id = request.params.get("server_id")

    if not uuid:
        return {"err": "uuid为空"}
    result = common_utils.call_gm(server_id, uuid, "kick_role", None)
    if result["code"] == 0:
        common_utils.push_log(user, PNAME_2, "踢下线",
                              "服务器ID:%s; UID:%s" % (server_id, uuid))
        return {"info": 'True'}
    else:
        return {"err": result["err_msg"]}


@route('/forbad_role', method='post')
@check_user("player_forbid")
def forbad_role(user):
    uuid = request.params.get("uuid")
    server_id = request.params.get("server_id")
    forbad_until_time = request.params.get("forbad_until_time")
    forbad_reason = request.params.get("forbad_reason")

    if uuid == "" or uuid is None:
        return {"err": "uuid为空"}

    args = dict(
        opt_params=forbad_reason,
        duration=forbad_until_time,
    )
    result = common_utils.call_gm(server_id, uuid, "forbid_login", args)
    if result["code"] == 0:
        common_utils.push_log(user, PNAME_2, "封禁", "UID:" + str(uuid) + "; 截止时间:" +
                              time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(int(forbad_until_time))))
        return {"info": result["data"]}
    else:
        return {"err": result["err_msg"]}


@route('/remove_forbad_role', method='post')
@check_user("player_forbid")
def remove_forbad_role(user):
    uuid = request.params.get("uuid")
    server_id = request.params.get("server_id")

    if not uuid:
        return {"err": "uuid为空"}
    result = common_utils.call_gm(server_id, uuid, "undo_forbid_login", None)
    if result["code"] == 0:
        common_utils.push_log(user, PNAME_2, "解封登陆",
                              "服务器ID:%s; UID:%s" % (server_id, uuid))
        return {"info": result["data"]}
    else:
        return {"err": result["err_msg"]}


@route('/forbad_speak', method='post')
@check_user("player_forbid")
def forbad_speak(user):
    uuid = request.params.get("uuid")
    server_id = request.params.get("server_id")
    forbad_until_time = request.params.get("forbad_until_time")
    forbad_reason = request.params.get("forbad_reason")

    args = dict(
        opt_params=forbad_reason,
        duration=forbad_until_time,
    )
    result = common_utils.call_gm(server_id, uuid, "forbid_speak", args)
    if result["code"] == 0:
        common_utils.push_log(user, PNAME_2, "禁言", "UID:" + str(uuid) + "; 截止时间:" +
                              time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(int(forbad_until_time))))
        print(time.strftime("%Y-%m-%d %H:%M:%S",
              time.localtime(int(forbad_until_time))))
        return {"info": result["data"]}
    else:
        return {"err": result["err_msg"]}


@route('/remove_forbad_speak', method='post')
@check_user("player_forbid")
def remove_forbad_speak(user):
    uuid = request.params.get("uuid")
    server_id = request.params.get("server_id")

    if not uuid:
        return {"err": "uuid为空"}
    result = common_utils.call_gm(server_id, uuid, "undo_forbid_speak", None)
    if result["code"] == 0:
        common_utils.push_log(user, PNAME_2, "解封禁言",
                              "服务器ID:%s; UID:%s" % (server_id, uuid))
        return {"info": result["data"]}
    else:
        return {"err": result["err_msg"]}


############################### player level ###############################
PNAME_3 = "经验查询"


@route('/view_player_level')
@check_user("level_query")
def view_player_query(user):
    # all_group = user_manager.get_all_group()
    # all_group.sort(key=lambda v: v.num)
    return template("level_query", curr_user=user, **(view_utils.all_funcs))


@route('/add_role_exp', method="POST")
@check_user("level_query")
def add_role_exp(user):
    # get values
    server_id = request.params.get("server_id")
    uuid = request.params.get("uuid")
    exp = request.params.get("exp")
    print(server_id, uuid, exp)

    args = dict(count=exp,)
    res = common_utils.call_gm(server_id, uuid, "add_role_exp", args)
    if res['code'] == 0:
        common_utils.push_log(user, PNAME_3, "增加经验",
                              "服务器ID:%s; UID:%s; 经验:%s" % (server_id, uuid, exp))
        return {'info': res["data"]}
    else:
        return {'err': res["err_msg"]}


@route('/delete_role_exp', method="POST")
@check_user("level_query")
def delete_role_exp(user):
    # get values
    server_id = request.params.get("server_id")
    uuid = request.params.get("uuid")
    exp = request.params.get("exp")
    print(server_id, uuid, exp)

    args = dict(count=exp,)
    res = common_utils.call_gm(server_id, uuid, "delete_role_exp", args)
    if res['code'] == 0:
        common_utils.push_log(user, PNAME_3, "减少经验",
                              "服务器ID:%s; UID:%s; 经验:%s" % (server_id, uuid, exp))
        return {'info': res["data"]}
    else:
        return {'err': res["err_msg"]}


@route('/set_role_level', method="POST")
@check_user("level_query")
def set_role_level(user):
    # get values
    server_id = request.params.get("server_id")
    uuid = request.params.get("uuid")
    level = request.params.get("level")
    print(server_id, uuid, level)

    args = dict(level=level,)
    res = common_utils.call_gm(server_id, uuid, "set_role_level", args)
    if res['code'] == 0:
        common_utils.push_log(user, PNAME_3, "设定等级",
                              "服务器ID:%s; UID:%s; 等级:%s" % (server_id, uuid, level))
        return {'info': res["data"]}
    else:
        return {'err': res["err_msg"]}


############################### player delete_item ###############################
@route('/view_delete_item')
@check_user("delete_item")
def view_delete_item(curr_user):
    return template("delete_item", curr_user=curr_user, **(view_utils.all_funcs))


@route('/role_delete_item', method="POST")
@check_user("delete_item")
def role_delete_item(curr_user):
    try:
        server_id = int(request.params.get("server_id"))
        uuid = request.params.get("uuid")
        name = request.params.get("name")
        item_id = request.params.get("item_id")
        item_count = request.params.get("item_count")
    except:
        return {"err": "请检查输入"}
    
    args = dict(
        server_id=server_id,
        # uuid=uuid,
        guid=item_id,
        count=item_count,
    )
    if name == '' and uuid == '':
        return {"err": "请检查输入"}
    if name != '':
        args['name'] = name
    if uuid != '':
        args['uuid'] = uuid
    print(args)

    result = common_utils.call_gm(server_id, uuid, "delete_item", args)
    if result['code'] == 0:
        return {"info": ""}
    else:
        return {"err": result['err_msg']}
