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


@route('/view_event_config')
@check_user("event_config")
def view_event_config(curr_user):
    return template("event_config", curr_user=curr_user, **(view_utils.all_funcs))


############################################################################################


@route('/add_event', method="post")
@check_user("event_config")
def add_event(curr_user):
    # get values
    server_id_list = request.params.get("server_id_list")   # 数组
    start_time = request.params.get("start_time")
    end_time = request.params.get("end_time")
    notify_start_time = request.params.get("notify_start_time")
    reward_end_time = request.params.get("reward_end_time")
    event_icon = request.params.get("event_icon")
    event_type = request.params.get("event_type")   # 字典
    event_status = request.params.get("event_status")
    priority = request.params.get("priority")
    cross_world = request.params.get("cross_world")
    alliance_change = request.params.get("alliance_change")
    auto_reward = request.params.get("auto_reward")

    args = dict(
        server_id_list=server_id_list,
        start_time=start_time,
        end_time=end_time,
        notify_start_time=notify_start_time,
        reward_end_time=reward_end_time,
        event_icon=event_icon,
        event_type=event_type,
        event_status=event_status,
        priority=priority,
        cross_world=cross_world,
        alliance_change=alliance_change,
        auto_reward=auto_reward,
    )

    print(args)
