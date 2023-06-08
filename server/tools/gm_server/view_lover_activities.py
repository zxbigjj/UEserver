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


@route('/view_lover_activities')
@check_user("lover_activities")
def view_event_config(curr_user):
    return template("lover_activities", curr_user=curr_user, **(view_utils.all_funcs))


############################################################################################
@route("/query_lover_activities" , method="post")
@check_user("lover_activities")
def query_lover_activities(curr_user):
    server_list = common_utils.call_gm(None, None, 'get_server_list', None)
    List=[]
    for server_id, server_info in server_list.items():
        request = common_utils.call_gm(
            server_id, None, 'get_server_info_role_online', None)
        if request['code'] == 0:
            args = dict(
                server_id=server_id,
            )
            List =List+ list(common_utils.call_gm(server_id, None, "query_lover_activities",None)["data"])
    
    return {"info": List}


@route('/add_lover_activities', method="post")
@check_user("lover_activities")
def add_lover_activities(curr_user):
    try:
        goods_name = request.params.get("goods_name")
        server_id = int(request.params.get("server_id"))
        reward = json.loads(request.params.get("reward"))
        price = int(request.params.get("price"))
        discount = int(request.params.get("discount"))
        icon = request.params.get("icon")
        face_time = request.params.get("face_time")
        refresh_interval = int(request.params.get("refresh_interval"))
        lover_id = int(request.params.get("lover_id"))
        lover_piece = int(request.params.get("lover_piece"))
        lover_fashion = int(request.params.get("lover_fashion"))
        lover_type = int(request.params.get("lover_type"))
        activity_name_fir = request.params.get("activity_name_fir")
        activity_name_sec = request.params.get("activity_name_sec")
    except:
        return {"err": "检查输入"}
    args = dict(
        goods_name=goods_name,
        server_id=server_id,
        item_list=reward,
        price=price, discount=discount,
        icon=icon, face_time=face_time,
        refresh_interval=refresh_interval,
        lover_id=lover_id, lover_piece=lover_piece,
        lover_fashion=lover_fashion, lover_type=lover_type,
        activity_name_fir=activity_name_fir, activity_name_sec=activity_name_sec,
        status='activate', purchase_count=1,
    )

    
    
    result = common_utils.call_gm(server_id, None, "add_lover_activities", args)
    
    if result['code'] == 0:
        return {"info": ""}
    else:
        return {"err": result['err_msg']}

@route('/clone_lover_activities', method="post")
@check_user("lover_activities")
def clone_lover_activities(curr_user):
    try:
        goods_name = request.params.get("goods_name")
        server_id = int(request.params.get("server_id"))
        reward = json.loads(request.params.get("reward"))
        price = int(request.params.get("price"))
        discount = int(request.params.get("discount"))
        icon = request.params.get("icon")
        face_time = request.params.get("face_time")
        refresh_interval = int(request.params.get("refresh_interval"))
        lover_id = int(request.params.get("lover_id"))
        lover_piece = int(request.params.get("lover_piece"))
        lover_fashion = int(request.params.get("lover_fashion"))
        lover_type = int(request.params.get("lover_type"))
        activity_name_fir = request.params.get("activity_name_fir")
        activity_name_sec = request.params.get("activity_name_sec")
    except:
        return {"err": "检查输入"}
    args = dict(
        goods_name=goods_name,
        server_id = server_id,
        item_list=reward,
        price=price, discount=discount,
        icon=icon, face_time=face_time,
        refresh_interval=refresh_interval,
        lover_id=lover_id, lover_piece=lover_piece,
        lover_fashion=lover_fashion, lover_type=lover_type,
        activity_name_fir=activity_name_fir, activity_name_sec=activity_name_sec,
        status='activate', purchase_count=1,
    )

    
    
    result = common_utils.call_gm(server_id, None, "add_lover_activities", args)
    
    if result['code'] == 0:
        return {"info": ""}
    else:
        return {"err": result['err_msg']}
    


@route('/update_lover_activities', method="post")
@check_user("lover_activities")
def update_lover_activities(curr_user):
    try:
        goods_name = request.params.get("goods_name")
        id = int(request.params.get("id"))
        server_id = int(request.params.get("server_id"))
        reward = json.loads(request.params.get("reward"))
        price = int(request.params.get("price"))
        discount = int(request.params.get("discount"))
        icon = request.params.get("icon")
        face_time = request.params.get("face_time")
        refresh_interval = int(request.params.get("refresh_interval"))
        lover_id = int(request.params.get("lover_id"))
        lover_piece = int(request.params.get("lover_piece"))
        lover_fashion = int(request.params.get("lover_fashion"))
        lover_type = int(request.params.get("lover_type"))
        activity_name_fir = request.params.get("activity_name_fir")
        activity_name_sec = request.params.get("activity_name_sec")
    except:
        return {"err": "Check the input"}
    args = dict(
        goods_name=goods_name,
        server_id=server_id,
        id=id,
        item_list=reward,
        price=price, discount=discount,
        icon=icon, face_time=face_time,
        refresh_interval=refresh_interval,
        lover_id=lover_id, lover_piece=lover_piece,
        lover_fashion=lover_fashion, lover_type=lover_type,
        activity_name_fir=activity_name_fir, activity_name_sec=activity_name_sec,
        status='activate', purchase_count=1,
    )
    print(args)
    
    result = common_utils.call_gm(server_id, None, "edit_lover_activities", args)
    
    if result['code'] == 0:
        return {"info": ""}
    else:
        return {"err": result['err_msg']}
    


@route('/del_lover_activities', method="post")
@check_user("lover_activities")
def del_lover_activities(curr_user):
    try:
        id = int(request.params.get("id"))
        server_id = int(request.params.get("server_id"))
    except:
        return {"err": "error"}
    else:
        pass
    args = dict(id=id, server_id=server_id)

    print(args)
    
    result = common_utils.call_gm(server_id, None, "del_lover_activities", args)
    
    if result['code'] == 0:
        return {"info": ""}
    else:
        return {"err": result['err_msg']}
    


# @route('/activate_lover_activities', method="post")
# @check_user("lover_activities")
# def activate_lover_activities(curr_user):
#     try:
#         id = int(request.params.get("id"))
#         server_id = int(request.params.get("server_id"))
#         refresh_interval = int(request.params.get("refresh_interval"))
#     except:
#         return {"err": "Check the input"}
#     args = dict(
#         id=id, server_id=server_id,
#         refresh_interval=refresh_interval,
#         status="activate",
#     )
#     result = common_utils.call_gm(server_id, None, "set_lover_activities", args)
#     if result['code'] == 0:
#         return {"info": ""}
#     else:
#         return {"err": result['err_msg']}
