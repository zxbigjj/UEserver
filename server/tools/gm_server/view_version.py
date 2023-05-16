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

import requests
import hashlib
import config


@route('/view_version')
@check_user("version")
def view_version(curr_user):
    return template("version", curr_user=curr_user, **(view_utils.all_funcs))


@route('/query_version')
@check_user("version")
def query_version(curr_user):
    channel_list = ['ios', 'android']
    result_dict = {}

    for channel in channel_list:
        url = "http://%s:%d/static/version/%s" % (
            config.version_http_ip,
            config.version_http_port,
            channel
        )
        result_dict[channel] = json.loads(requests.get(url).text)

    return result_dict


@route('/update_version', method='POST')
@check_user("version")
def update_version(curr_user):
    try:
        android_url = request.params.get('android_url')
        android_version = request.params.get('android_version')
        ios_url = request.params.get('ios_url')
        ios_version = request.params.get('ios_version')
        state = request.params.get('state')
        context = request.params.get('context')
    except:
        return {'err': '检查输入'}

    args = dict(
        android=dict(
            url=android_url,
            version=android_version,
            context=context,
            state=state,
        ),
        ios=dict(
            url=ios_url,
            version=ios_version,
            context=context,
            state=state,
        )
    )

    print(args)

    ts = int(time.time())
    ip = config.version_http_ip
    port = config.version_http_port
    url = "http://%s:%d/%s" % (ip, port, 'update_static')

    key = 'bHDsfXPt26Tjr35pXJHwVHxHXFsfCNGe'
    md5 = hashlib.md5()
    md5.update('ts=%s&key=%s&args=%s' % (ts, key, json.dumps(args)))
    sign = md5.hexdigest()

    resp = requests.post(url, json={"args": args, "ts": ts, "sign": sign})
    result = json.loads(resp.text)
    return result
