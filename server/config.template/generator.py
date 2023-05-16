#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import sys
import shutil
import jinja2
import json

import all_server
SERVER_DICT = {}
for server in all_server.server_list:
    SERVER_DICT[server.server_id] = server

this_dir = os.path.dirname(os.path.abspath(__file__))
template_path = os.path.join(this_dir, "template")
target_dir_path = os.path.join(this_dir, '../config')
target_dir_path = os.path.abspath(target_dir_path)
if not os.path.exists(target_dir_path):
    os.makedirs(target_dir_path)

jinja_env = jinja2.Environment(
    loader=jinja2.FileSystemLoader(template_path)
)

def do_template(node):
    template = jinja_env.get_template(node.template_name)
    content = template.render(**node.__dict__).encode("utf8")
    target_file_path = os.path.join(target_dir_path, node.node_name + ".lua")
    f = open(target_file_path, 'w')
    f.write(content)
    f.close()

def do_skynet_server_config(server_id, ip=''):
    server = SERVER_DICT[server_id]
    for node in server.get_node_list():
        if ip and node.ip != ip:
            continue
        do_template(node)

def make_cluster_router():
     lines = []
     server_id_list = SERVER_DICT.keys()
     server_id_list.sort()
     for server_id in server_id_list:
         server = SERVER_DICT[server_id]
         for node in server.get_node_list():
             lines.append('%s = "%s:%d"' % (node.node_name, node.ip, node.cluster_port))
     for line in lines:
         print line

def make_all_game():
    out_attr_list = [
        'node_name', 'server_id', 'name', 'ip', 'ssh_ip', 'area_id', 'area_name',
        'open_time', 'open_ts', 'allow_login', 'state', 'recommend_status', 'recommend_priority',
        'login_port', 'ssl_login_port', 'enable_ssl',
    ]
    out_list = []
    for _, server in SERVER_DICT.items():
        for node in server.node_list:
            if node.type != 'game': continue
            if node.template_name != 'game.lua': continue
            info = {}
            for attr in out_attr_list:
                if hasattr(node, attr):
                    value = getattr(node, attr)
                    info[attr] = value
            out_list.append(info)

    content = json.dumps(out_list, indent=2, ensure_ascii=False)
    f = open(os.path.join(target_dir_path, "all_game.json"), 'w')
    f.write(content)
    f.close()

def main():
    if '--cluster_router' in sys.argv:
        make_cluster_router()
        return
    if '--all_game' in sys.argv:
        make_all_game()
        return
    if '--global' in sys.argv:
        make_all_game()
        for server_id, server in SERVER_DICT.iteritems():
            if server.server_type not in ['game', 'cross']:
                do_skynet_server_config(server_id, '')
        return

    ip = ''
    for arg in sys.argv:
        if arg.startswith('--ip='):
            ip = arg[5:]
    if len(sys.argv) >= 2:
        for server_id in [int(s) for s in sys.argv[1].split(",")]:
            do_skynet_server_config(server_id, ip)
    else:
        for server_id, _ in SERVER_DICT.iteritems():
            do_skynet_server_config(server_id, ip)
        
if __name__ == '__main__':
    main()

