#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
from bottle import route, template, redirect
from bottle import request, response
from user_manager import check_user
import view_utils
import common_utils
import config
import time


@route('/view_hero_activities')
@check_user("hero_activities")
def view_event_config(curr_user):
    return template("hero_activities", curr_user=curr_user, **(view_utils.all_funcs))


############################################################################################
@route("/query_hero_activities")
@check_user("hero_activities")
def query_hero_activities(curr_user):
    result = common_utils.call_gm(55, None, "query_hero_activities", None)
    if result['code'] == 0:
        return {"info": result["data"]}
    else:
        return {"err": result['err_msg']}


@route('/add_hero_activities', method="post")
@check_user("hero_activities")
def add_hero_activities(curr_user):
    try:
        server_id = int(request.params.get("server_id"))
        reward = json.loads(request.params.get("reward"))
        price = int(request.params.get("price")[:-3])
        discount = int(request.params.get("discount"))
        refresh_interval = int(request.params.get("refresh_interval"))
        icon = request.params.get("icon")
        hero_id = int(request.params.get("hero_id"))
        hero_left_id = int(request.params.get("hero_left_id"))
        hero_right_id = int(request.params.get("hero_right_id"))
        activity_name_fir = request.params.get("activity_name_fir")
        activity_name_sec = request.params.get("activity_name_sec")
    except:
        return {"err": "Check the input"}
    args = dict(
        server_id=server_id, item_list=reward,
        price=price, discount=discount,
        icon=icon,
        hero_id=hero_id,
        hero_left_id=hero_left_id,
        hero_right_id=hero_right_id,
        refresh_interval=refresh_interval,
        activity_name_fir=activity_name_fir,
        activity_name_sec=activity_name_sec,
        status='activate', purchase_count=1,
    )
    print(args)
    result = common_utils.call_gm(server_id, None, "add_hero_activities", args)
    if result['code'] == 0:
        return {"info": ""}
    else:
        return {"err": result['err_msg']}


@route('/update_hero_activities', method="post")
@check_user("hero_activities")
def update_hero_activities(curr_user):
    try:
        id = int(request.params.get("id"))
        server_id = int(request.params.get("server_id"))
        reward = json.loads(request.params.get("reward"))
        price = int(request.params.get("price")[:-3])
        discount = int(request.params.get("discount"))
        refresh_interval = int(request.params.get("refresh_interval"))
        icon = request.params.get("icon")
        hero_id = int(request.params.get("hero_id"))
        hero_left_id = int(request.params.get("hero_left_id"))
        hero_right_id = int(request.params.get("hero_right_id"))
        activity_name_fir = request.params.get("activity_name_fir")
        activity_name_sec = request.params.get("activity_name_sec")
    except:
        return {"err": "Check the input"}
    args = dict(
        id=id,
        server_id=server_id, item_list=reward,
        price=price, discount=discount,
        icon=icon,
        hero_id=hero_id,
        hero_left_id=hero_left_id,
        hero_right_id=hero_right_id,
        refresh_interval=refresh_interval,
        activity_name_fir=activity_name_fir,
        activity_name_sec=activity_name_sec,
        status='activate', purchase_count=1,
    )
    print(args)
    result = common_utils.call_gm(
        server_id, None, "edit_hero_activities", args)

    if result['code'] == 0:
        return {"info": ""}
    else:
        return {"err": result['err_msg']}


@route('/del_hero_activities', method="post")
@check_user("hero_activities")
def del_hero_activities(curr_user):
    try:
        id = int(request.params.get("id"))
        server_id = int(request.params.get("server_id"))
    except:
        return {"err": "error"}
    args = dict(id=id, server_id=server_id)
    print(args)
    result = common_utils.call_gm(server_id, None, "del_hero_activities", args)
    if result['code'] == 0:
        return {"info": ""}
    else:
        return {"err": result['err_msg']}
