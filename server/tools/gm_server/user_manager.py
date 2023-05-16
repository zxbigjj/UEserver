#!/usr/bin/env python
# -*- coding: utf-8 -*-
import string
import time
import random
import hashlib

import db
import bson
from bottle import request, response, abort, redirect


def md5(data):
    m = hashlib.md5()
    m.update(data)
    return m.hexdigest()


ALL_POWER = [
    "user_mgr", "group_mgr",
    "player_query", "level_query", "role_vip_mgr", "player_forbid", "server_list", "delete_item", "version","server_time",
    "user_log", "role_log",
    "sys_mail", "role_mail",
    'online_notify', "system_notify",
    "map_mgr", "gift_key", "query_union", "query_vip",
    "event_config", "event_query",
    "query_tool", "lover_activities", "hero_activities",
]

ALL_STATUS = ['正常', '禁用']


def get_all_status():
    return list(ALL_STATUS)


class UserGroup(db.SimpleDbBase):
    DB_NAME = "DbUserGroup"
    KEY_NAME = "gid"
    CACHE = {}

    def __init__(self, data):
        self.gid = ""
        self.num = 0
        self.name = ""
        self.info = ""
        self.power_list = []

        super(UserGroup, self).__init__(data)

    def set_power(self, power_list):
        power_list = [p for p in power_list if p in ALL_POWER]
        self.power_list = power_list
        self.save()

    def modify(self, name, info):
        self.name = name
        self.info = info
        self.save()

    def get_member(self):
        return [u for u in get_all_user() if u.group_id == self.gid]

    def todict(self):
        return dict(self.__dict__)


def create_user_group(name, info, power_list):
    num_list = [g.num for _, g in UserGroup.get_all().iteritems()]
    num = 1
    if num_list:
        num = max(num_list) + 1
    power_list = [p for p in power_list if p in ALL_POWER]
    data = {
        "num": num,
        "name": name,
        "info": info,
        "power_list": power_list
    }
    return UserGroup.create(data, "name")


def get_all_group():
    return UserGroup.get_all().values()


def get_group_by_name(name):
    return UserGroup.get_by_field("name", name)


def get_group_by_key(gid):
    return UserGroup.get_by_key(gid)


class User(db.SimpleDbBase):
    DB_NAME = "DbUser"
    KEY_NAME = "uid"
    CACHE = {}

    def __init__(self, data):
        self.name = ""
        self.nick = ""
        self.pwd = ""
        self.uid = ""

        self.create_ts = time.time()
        self.modify_ts = time.time()
        self.status = ''

        self.token = ""
        self.token_expire = 0

        self.login_ip = ""
        self.login_ts = 0
        self.last_login_ip = ""
        self.last_login_ts = 0

        self.group_id = 0

        super(User, self).__init__(data)

    def refresh_token(self):
        chars = [random.choice(string.hexdigits) for i in xrange(32)]
        self.token = "".join(chars)
        self.token_expire = time.time() + 24*3600
        self.save()

    def modify(self, nick, new_raw_pwd, group_id, status):
        self.nick = nick
        if new_raw_pwd:
            self.pwd = md5(new_raw_pwd)
        self.group_id = group_id
        self.status = status
        self.modify_ts = time.time()
        self.save()

    def change_pwd(self, new_raw_pwd):
        self.pwd = md5(new_raw_pwd)
        self.modify_ts = time.time()
        self.save()

    def check_pwd(self, raw_pwd):
        return self.pwd == md5(raw_pwd)

    def check_power(self, need_power):
        group = get_group_by_key(self.group_id)
        if not group:
            return False
        for power in need_power.split(","):
            for p in power.split("/"):
                if p in group.power_list:
                    break
            else:
                return False
        return True

    def is_disabled(self):
        return self.status == "禁用"


def create_user(name, raw_pwd, group_id, nick, status=u"正常"):
    if not UserGroup.get_by_key(group_id):
        raise RuntimeError("用户所属的组不存在")
    return User.create({"name": name, "pwd": md5(raw_pwd), "group_id": group_id, "nick": nick, "status": status}, "name")


def get_user_by_name(name):
    return User.get_by_field("name", name)


def get_user_by_uid(uid):
    return User.get_by_key(uid)


def get_all_user():
    return User.get_all().values()


def get_curr_user():
    uid = request.get_cookie("uid")
    token = request.get_cookie("token")
    if uid:
        user = get_user_by_uid(uid)
        if user and user.token == token and time.time() < user.token_expire:
            return user


def init():
    UserGroup.load_all()
    g_admin = UserGroup.get_by_field("name", "超级管理员")
    if g_admin:
        g_admin.set_power(ALL_POWER)
    else:
        g_admin = create_user_group("超级管理员", "拥有所有操作权限", ALL_POWER)

    User.load_all()
    admin = get_user_by_name("admin")
    if not admin:
        create_user("admin", "admin", g_admin.gid, "admin")


def check_user(need_power):
    def decorator(func):
        def wrapper(*args, **kw):
            user = get_curr_user()
            if not user or user.is_disabled():
                redirect("/login")
                return
            if not user.check_power(need_power):
                abort(401, "当前用户没有权限访问此页面")
                return
            return func(user, *args, **kw)
        return wrapper
    return decorator
