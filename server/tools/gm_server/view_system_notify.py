#!/usr/bin/env python
# -*- coding: utf-8 -*-
import json
import datetime
import time
import db
from bottle import route, template, redirect
from bottle import request, response
from bson.json_util import dumps
import user_manager
from user_manager import check_user

import view_utils
import common_utils


################################################
@route('/view_system_notify')
@check_user("system_notify")
def view_system_notify(user): 
    return template("system_notify", curr_user=user, **(view_utils.all_funcs))

################################################
# 公告管理
PNAME = "公告管理"

@route('/view_notify')
def view_notify(): 
    List= list(db.find("SysNotice"))
    for notice in List:
        notice.__delitem__('_id')
        notice.__delitem__('end_ts')
        notice.__delitem__('start_ts')
        notice.__delitem__('notice_id')
    
    return dumps(List,ensure_ascii=False)

@route('/query_system_notice', method='post')
@check_user("system_notify")
def query_system_notice(user):
    # get values
    #server_id = request.params.get("server_id")
    
    return dumps({"info": db.find("SysNotice")})
    


@route('/add_system_notice', method="POST")
@check_user("system_notify")
def add_system_notice(user):
    title =request.params.get("title")
    content = request.params.get("content")
    state = request.params.get("state")
    start_ts = request.params.get("start_ts")
    end_ts = request.params.get("end_ts")
     
    notice_id=len(list(db.find("SysNotice")))+1
    
    args = dict(
        title=title,
        content=content,
        state=state,
        #status=True,
        notice_id=notice_id,
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

    result = db.insert_one("SysNotice", args)
    if(len(list(db.find("SysNotice")))==notice_id):
        return {'info': '操作成功'}
    else:
        return {'err': "操作失败"}
    


    



@route('/delete_system_notice', method="POST")
@check_user("system_notify")
def delete_system_notice(user):
    # get values
    #server_id = request.params.get("server_id")
    notice_id = int(request.params.get("notice_id"))
    count=len(list(db.find("SysNotice")))
    
    
    db.delete_one("SysNotice", { "notice_id" :notice_id })
    if(len(list(db.find("SysNotice")))==count-1):
        return {'info': '操作成功'}
    else:
        return {'err': "操作失败"}


@route('/edit_system_notice', method="POST")
@check_user("system_notify")
def edit_system_notice(user):
    # get values
    notice_id = int(request.params.get("notice_id"))
    title = request.params.get("title")
    content = request.params.get("content")
    state = request.params.get("state")
    start_ts = request.params.get("start_ts")
    end_ts = request.params.get("end_ts")
    
    #status=   True if request.params.get("status")=="true"else False

    print( end_ts, start_ts, content, notice_id)

    args = dict(
        notice_id=notice_id,
        title=title,
        content=content,
        state=state,
        #status=status,
    )

    now = int(time.time())
    
    if start_ts == 'NaN':
        args["start_ts"] = now + 2
    else:
        args["start_ts"] = int(start_ts)

    if end_ts == 'NaN':
        args["end_ts"] = now + 100
    else:
        args["end_ts"] = int(end_ts)

    result = db.replace_one("SysNotice", { "notice_id" : notice_id },args)
    
    if db.find_one("SysNotice", args):
        return {'info': '操作成功'}
    else:
        return {'err': '操作失败'}


