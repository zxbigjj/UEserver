#coding=utf-8
from bottle import request, response
from bottle import run, route, template, redirect, static_file
import common_utils
import config
import user_manager
import time
import datetime
import os.path
import json
import urllib2
import binascii
import hashlib

import gevent
import gevent.monkey
gevent.monkey.patch_all()


root = os.path.dirname(os.path.abspath(__file__))


@route('/hello')
def hello():
    return "hello world"


@route('/static/<filepath:path>')
def server_static(filepath):
    return static_file(filepath, root=root+"/static")


@route('/login')
def login():
    user = user_manager.get_curr_user()
    if user and not user.is_disabled():
        redirect("/welcome")
        return
    return template("login")


@route('/login', method='POST')
def login_post():
    name = request.forms.get('username')
    pwd = request.forms.get('password', "")
    user = user_manager.get_user_by_name(name)
    if not user or not user.check_pwd(pwd):
        return "账号密码输入有误"
    if user.is_disabled():
        return "账号已被禁用"
    user.refresh_token()
    response.set_cookie("uid", user.uid)
    response.set_cookie("token", user.token)

    user.last_login_ip = user.login_ip
    user.last_login_ts = user.login_ts
    # ipinfo = urllib2.urlopen("http://ip.taobao.com/service/getIpInfo.php?ip=%s" % request.environ.get('REMOTE_ADDR'))
    # ipinfo = json.loads(ipinfo.read())["data"]
    # user.login_ip = ipinfo["ip"] + " (%s)" % (" ".join([ipinfo["country"], ipinfo["city"]]))
    user.login_ip = "北京市"
    user.login_ts = time.time()
    user.save()
    return ""


@route('/logout')
def logout():
    response.set_cookie("uid", "")
    response.set_cookie("token", "")
    redirect("/login")
    return


@route('/welcome')
def welcome():
    user = user_manager.get_curr_user()
    if not user or user.is_disabled():
        redirect("/login")
        return

    if user.last_login_ts:
        last_login_dt = datetime.datetime.fromtimestamp(user.last_login_ts)
        last_login_time = last_login_dt.strftime("%Y-%m-%d %H:%M:%S")
    else:
        last_login_time = ""
    import view_utils
    return template("welcome",
                    curr_user=user,
                    last_login_ip=user.last_login_ip,
                    last_login_time=last_login_time,
                    **(view_utils.all_funcs))


@route('/change_password', method='POST')
def change_password():
    user = user_manager.get_curr_user()
    if not user:
        redirect("/login")
        return
    pwd = request.forms.get('pwd')
    if not pwd:
        return '密码不能为空'
    user.change_pwd(pwd)
    return ''


#################################################

@route('/query_zone', method="POST")
def query_zone():
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

#################################################


def init():
    import db
    db.init()
    user_manager.init()

    # UserMgr
    import view_user_mgr
    import view_group_mgr
    # PlayerMgr
    import view_player_query
    import view_role_vip_mgr
    import view_server_list
    import view_version
    import view_server_time
    # LogMgr
    import view_user_log
    import view_role_log
    # MailMgr
    import view_sys_mail
    import view_role_mail
    # NoticeMgr
    import view_online_notify
    import view_system_notify
    # OtherMgr
    import view_map_mgr
    import view_gift_key
    import view_query_union
    import view_query_vip
    # EventMgr
    import view_event_config
    import view_event_query
    # Separate
    import view_query_tool
    import view_lover_activities
    import view_hero_activities


init()
run(host='0.0.0.0', port=config.port, server="gevent", debug=True)
