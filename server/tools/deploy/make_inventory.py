#!/usr/bin/python
# -*- coding: utf-8 -*-

# 生成ansible hosts

import sys, os, string
import os.path
import jinja2
import yaml

config = None

class DictObj(dict):
    def __init__(self, *args, **kw):
        dict.__init__(self, *args, **kw)
 
    def __getattr__(self, key):
        return dict.get(self, key, None)
 
    def __setattr__(self, key, value):
        self[key] = value
 
    def __delattr__(self, key):
        del self[key]

def dict2obj(d):
    for k, v in d.iteritems():
        if type(v) == dict:
            d[k] = dict2obj(v)
        elif type(v) == list:
            d[k] = [dict2obj(x) for x in v]
    return DictObj(d)

def int2abc(i):
    assert(i>=0)
    ret = ""
    while True:
        ret = string.letters[i%26] + ret
        i = i/26
        if i == 0: break
    return ret

def main():
    global config
    with open("../../config.template/config.yaml") as f:
        config = yaml.safe_load(f.read())
        config = dict2obj(config)
    # 准备数据
    
    all_server = DictObj(
        game_list = [],
        cross_list = [],
        login_list = [],
        singleton_dict = DictObj(),
        )
    all_host = {}
    def add_host(ip, ssh_ip):
        if ip not in all_host:
            all_host[ip] = DictObj(ip=ip, ssh_ip=ssh_ip)

    for server in config.server_list:
        if not server.ssh_ip:
            server.ssh_ip = server.ip
        add_host(server.ip, server.ssh_ip)
        if server.type == 'game':
            if server.server_id >= config['global'].min_cross_server_id:
                raise RuntimeError("game server too huge:%s" % server.server_id)
            all_server.game_list.append(server)
        elif server.type == "cross":
            if server.server_id < config['global'].min_cross_server_id:
                raise RuntimeError("cross server too small:%s" % server.server_id)
            all_server.cross_list.append(server)
        elif server.type == 'login':
            all_server.login_list.append(server)
        else:
            if server.type in all_server.singleton_dict: 
                raise RuntimeError('server type already exist:%s' % server.type)
            all_server.singleton_dict[server.type] = server

        if not all_host[server.ip]:
            all_host[server.ip] = DictObj(ip=server.ip, ssh_ip=server.ssh_ip)
    all_host = all_host.values()

    with open("hosts.tpl") as f:
        template = jinja2.Template(f.read().decode("utf-8"))
    print template.render(
        all_server = all_server, 
        all_host = all_host,
    ).encode("utf-8")
    
if __name__ == "__main__":
    main()