#!/usr/bin/env python
# -*- coding: utf-8 -*-
from bottle import route, template, redirect
from bottle import request, response
from user_manager import check_user

import json
import datetime
import time
import view_utils
import common_utils


####################################################################################
@route('/view_server_list')
@check_user("server_list")
def view_server_list(curr_user):
    return template("server_list", curr_user=curr_user, **(view_utils.all_funcs))


@route('/query_server_list')
@check_user("server_list")
def query_server_list(curr_user):
    result = common_utils.call_gm(None, None, 'get_server_list', None)

    server_info_list = []
    for server_id, server_info in result.items():
        request = common_utils.call_gm(
            server_id, None, 'get_server_info_role_online', None)
        if request['code'] == 0:
            server_info['role_online_num'] = request['data']['role_online_num']
            server_info['role_total_num'] = request['data']['role_total_num']
            server_info['running_state'] = '1'
            server_info_list.append(server_info)
        else:
            server_info_list.append(server_info)

    return {'info': server_info_list}


####################################################################################
# @route('/view_statistic')
# @check_user("statistic")
# def view_statistic(curr_user):
#     return template("statistic", curr_user=curr_user, **(view_utils.all_funcs))
