# -*- coding: utf-8 -*-
# 注意对外端口10100-10120
# game登陆端口：10108
# gm http端口：10112
# dev_http端口：10113
# login http端口：10114 
import sys
reload(sys)
sys.setdefaultencoding('utf-8')
import datetime, time, os
import yaml
this_dir = os.path.dirname(os.path.abspath(__file__))
with open(this_dir + "/config.yaml") as f:
    config = yaml.safe_load(f.read())

global_config = config["global"]
global_port_offst = global_config.get('global_port_offst', 40000)
cluster_router = ""
cluster_router_name = ""

class Node(object):
    def __init__(self, **kwargs):
        self.name = kwargs['name']
        self.ip = kwargs['ip']
        self.node_name = kwargs['node_name']
        self.template_name = kwargs['template_name']

        self.server_id = kwargs['server_id']
        self.server_type = kwargs['server_type']
        self.cluster_port = kwargs['cluster_port']
        self.debug_port = kwargs['debug_port']

        for k, v in global_config.items():
            setattr(self, k, v)

        if 'extra_args' in kwargs:
            for k, v in kwargs['extra_args'].items():
                setattr(self, k, v)
            db_name = kwargs['extra_args'].get('db')
            if db_name:
                for db in config['db_list']:
                    if db['name'] == db_name:
                        setattr(self, 'db_host', db['host'])
                        setattr(self, 'db_port', db['port'])
                        setattr(self, 'db_user', db['user'])
                        setattr(self, 'db_passwd', db['passwd'])
                        break

class Server(object):
    def __init__(self, server_type, server_id, name):
        self.server_type = server_type
        self.server_id = server_id
        self.name = name

        self.node_list = []

    def get_node_list(self):
        return self.node_list

    def add_node(self, ip, node_name, template_name, cluster_port, debug_port, **extra_args):
        self.node_list.append(Node(
            name = self.name,
            ip = ip,
            node_name = node_name,
            template_name = template_name,
            server_id = self.server_id,
            server_type = self.server_type,
            cluster_port = cluster_port,
            debug_port = debug_port,
            extra_args = extra_args
        ))

class Server_game(Server):
    def __init__(self, server_id, name, ip, city_list=None, war_list=None, **kwargs):
        assert(server_id < global_config['min_cross_server_id'])
        if 'open_time' in kwargs:
            dt = datetime.datetime.strptime(kwargs['open_time'], "%Y-%m-%d %H:%M:%S")
            kwargs['open_ts'] = int(time.mktime(dt.timetuple()))

        super(Server_game, self).__init__('game', server_id, name)
        enable_ssl = True
        if 'enable_ssl' in kwargs:
            enable_ssl = kwargs['enable_ssl']
        elif 'enable_ssl' in global_config:
            enable_ssl = global_config['enable_ssl']

        if global_config['port_mode'] == 'dev':
            if enable_ssl:
                login_port = (10000 + server_id * 100 + 15)
                ssl_login_port = login_port - 1
            else:
                login_port = (10000 + server_id * 100 + 15)
                ssl_login_port = 0
            port = (login_port + 1)
        else:
            if enable_ssl:
                ssl_login_port = 10108
                login_port = 20000
            else:
                ssl_login_port = 0
                login_port = 10108
            port = 20001
        city_list = city_list if city_list else [{"ip":ip}]
        war_list = war_list if war_list else [{"ip":ip}]
        # game
        self.add_node(ip, 's%d_game' % server_id, 'game.lua', port, port+1, 
            login_port=login_port, ssl_login_port=ssl_login_port, **kwargs)
        port += 2
        # chat
        self.add_node(ip, 's%d_chat' % server_id, 'chat.lua', port, port+1, **kwargs)
        port += 2
        # dynasty
        self.add_node(ip, 's%d_dynasty' % server_id, 'dynasty.lua', port, port+1, **kwargs)
        port += 2


class Server_cross(Server):
    def __init__(self, server_id, name, ip, city_list=None, war_list=None, **kwargs):
        assert(server_id >= global_config['min_cross_server_id'])
        super(Server_cross, self).__init__('cross', server_id, name)
        port = (10000 + server_id * 100 + 15) if global_config['port_mode'] == 'dev' else 30001
        city_list = city_list if city_list else [{"ip":ip}]
        war_list = war_list if war_list else [{"ip":ip}]
        # cross
        self.add_node(ip, 's%d_cross' % server_id, 'cross.lua', port, port+1, **kwargs)

class Server_world(Server):
    def __init__(self, server_id, name, ip, **kwargs):
        super(Server_world, self).__init__('world', server_id, name)
        port = global_port_offst + 1
        self.add_node(ip, 's%d_world' % server_id, 'world.lua', port, port+1, **kwargs)
        port += 2

class Server_pay(Server):
    def __init__(self, server_id, name, ip, **kwargs):
        super(Server_pay, self).__init__('pay', server_id, name)
        port = global_port_offst + 101
        self.add_node(ip, 's%d_pay' % server_id, 'pay.lua', port, port+1, **kwargs)
        port += 2

class Server_gm_router(Server):
    def __init__(self, server_id, name, ip, **kwargs):
        super(Server_gm_router, self).__init__('gm_router', server_id, name)
        port = global_port_offst + 201
        gm_router_port = port + 2 if global_config['port_mode'] == 'dev' else 10112
        self.add_node(ip, 's%d_gm_router' % server_id, 'gm_router.lua', port, port+1,
            gm_router_port = gm_router_port, **kwargs)
        port += 3

class Server_cluster_router(Server):
    def __init__(self, server_id, name, ip, **kwargs):
        super(Server_cluster_router, self).__init__('cluster_router', server_id, name)
        port = global_port_offst + 301
        self.add_node(ip, 's%d_cluster_router' % server_id, 'cluster_router.lua', port, port+1, **kwargs)
        port += 2
        global cluster_router, cluster_router_name
        cluster_router = "%s:%d" % (ip, global_port_offst + 301)
        cluster_router_name = 's%d_cluster_router' % server_id

class Server_login(Server):
    def __init__(self, server_id, name, ip, **kwargs):
        super(Server_login, self).__init__('login', server_id, name)
        port = (10001 + server_id * 10) if global_config['port_mode'] == 'dev' else (global_port_offst + 5001)
        http_port = port+2 if global_config['port_mode'] == 'dev' else 10114
        self.add_node(ip, 's%d_login' % server_id, 'login.lua', port, port+1,
            http_port=http_port, **kwargs)
        port += 3

server_list = [
]
for conf in config['server_list']:
    server_cls = locals()['Server_' + conf['type']]
    server_list.append(server_cls(**conf))
for server in server_list:
    for node in server.node_list:
        setattr(node, 'cluster_router', cluster_router)
        setattr(node, 'cluster_router_name', cluster_router_name)
