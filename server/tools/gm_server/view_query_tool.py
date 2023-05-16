#!/usr/bin/env python
#coding=utf-8


from bottle import route, template, redirect
from bottle import request, response
from user_manager import check_user

import view_utils
import common_utils
import json
import datetime
import time


@route('/view_query_tool')
@check_user("query_tool")
def view_query_tool(curr_user):
    return template("query_tool", curr_user=curr_user, **(view_utils.all_funcs))


@route('/query_by_sql', method="post")
@check_user("query_tool")
def query_by_sql(curr_user):
    try:
        server_id = request.params.get("server_id")
        cmd = request.params.get("query_tool_msg")
    except:
        return {"err": "Check the input"}
    else:
        args = dict(server_id=server_id, cmd=cmd)
        result = common_utils.call_gm(server_id, None, "query_by_sql", args)
        if result['code'] == 0:
            print(result['data'])
            if result['data'] is not None and result['data'] != {}:
                title_list = [{'checkbox': True}]
                for title, _ in result['data'][0].items():
                    title_list.append({'title': title, 'field': title})
                return {"info": result['data'], "title_list": title_list}
            else:
                return {"err": "Database is empty"}
        else:
            return {"err": result['err_msg']}
