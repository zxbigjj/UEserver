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


@route('/view_role_log')
@check_user("role_log")
def view_role_log(curr_user):
    print('get role log')
    return template("role_log", curr_user=curr_user, **(view_utils.all_funcs))

@route('/patch_server_url')
def view_role_log():
    
    id = int(request.params.get("id"))
    if(id== 'NaN'):
        return False
    param1=request.params.get("param1")
    param2=request.params.get("param2")
    param3=request.params.get("param3")
    param4=request.params.get("param4")
    now = time.mktime(time.localtime())
    args = dict(
        id=id,
        param1=param1,
        param2=param2,
        param3=param3,
        param4=param4,
        now=now,
    )
    result=db.insert_one("Patch_Server_Url",args)
    return {'info': '操作成功'}
@route('/view_server_url', method="POST")
def view_notify(): 
    id = int(request.params.get("id"))
    args = dict(
        id=id,
    )
    List= list(db.find("Patch_Server_Url",args))
    List.reverse()
    return dumps({"info": List})
@route('/delete_server_url', method="POST")
def view_notify(): 
    begin_time = int(request.params.get("begin_time"))/ 1000
    end_time = int(request.params.get("end_time"))/ 1000
    List=db.find("Patch_Server_Url",{'now':{'$gte':begin_time,'$lte':end_time}})
    for log in List:
        db.delete_one("Patch_Server_Url",{'now':log['now']})
    

    return dumps({"info": "操作成功" })
