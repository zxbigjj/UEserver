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


@route('/view_gift_key')
@check_user("gift_key")
def view_gift_key(curr_user):
    return template("gift_key", curr_user=curr_user, **(view_utils.all_funcs))
@route('/delete_gift_key', method='post')
@check_user("gift_key")
def delete_gift_key(user):
    # get values
    #server_id = request.params.get("server_id")
    gift_key=request.params.get("gift_key")
    args = dict(
        key=gift_key,
    )
    result = common_utils.call_gm(None, None, 'delete_gift_key', args)
    if result['code'] == 0:
        return json.dumps({"info": result['data']})
    else:
        print("失败", result["err_msg"])
        return {'err': result['err_msg']}
@route('/query_gift_key', method='post')
@check_user("gift_key")
def query_gift_key(user):
    # get values
    #server_id = request.params.get("server_id")
    gift_key=request.params.get("gift_key")
    args = dict(
        key=gift_key,
    )
    result = common_utils.call_gm(None, None, 'query_gift_key', args)
    if result['code'] == 0:
        return json.dumps({"info": result['data']})
    else:
        print("失败", result["err_msg"])
        return {'err': result['err_msg']}
@route('/query_all_gift_key', method='post')
@check_user("gift_key")
def query_all_gift_key(user):
    
    
    result = common_utils.call_gm(None, None, 'query_all_gift_key', None)
    List=[]
    List=result['data']
    if(type(List)==list):
        List.reverse()
    if result['code'] == 0:
        return json.dumps({"info": result['data']})
    else:
        print("失败", result["err_msg"])
        return {'err': result['err_msg']}

@route('/add_gift_key', method="POST")
@check_user("gift_key")
def add_gift_key(user):
    group_name =request.params.get("group_name")
    total_use_count = request.params.get("total_use_count")
    total_count = request.params.get("total_count")
    start_ts = request.params.get("start_ts")
    end_ts = request.params.get("end_ts")
    item_list = json.loads(request.params.get("item_list"))
    if not total_use_count.isdigit():  # 是否为数字
            return {"err": "礼包码次数存在非数字 "}
    

    
    args = dict(
        group_name=group_name,
        total_use_count=total_use_count,
        total_count=total_count,
        item_list=item_list,
    )
    #print(title,content)
    now = int(time.time())
    
    if start_ts == 'NaN':
        args["start_ts"] = now + 2
    else:
        args["start_ts"] = int(start_ts)

    if end_ts == 'NaN':
        args["end_ts"] = now + 100
    else:
        args["end_ts"] = int(end_ts)

    result = common_utils.call_gm(None, None, 'make_gift_key', args)

    if result['code'] == 0:
        return json.dumps({"info": result['data']})
    else:
        print("失败", result["err_msg"])
        return {'err': result['err_msg']}
    
