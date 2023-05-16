log_path = '{{log_path}}'
reload_path = '{{reload_path}}'
config_path = '{{config_path}}'

db_host = '{{db_host}}'
db_port = {{db_port}}
db_user = '{{db_user}}'
db_passwd = '{{db_passwd}}'

server_id = {{server_id}}
server_name = '{{"s%s" % server_id}}' -- 服务器ID
server_type = '{{server_type}}'

cluster_nodename = '{{node_name}}' -- 集群节点名
cluster_nodeaddr = '{{ip}}:{{cluster_port}}' -- 地址
cluster_router = '{{cluster_router}}'
cluster_router_name = '{{cluster_router_name}}'
cluster_port = {{cluster_port}}
debug_console_port = {{debug_port}}

min_cross_server_id = {{min_cross_server_id}}
{% if cross_server_id is defined %}
cross_server_id = {{cross_server_id}}
{% endif %}

-----------------程序配置, sa无需理会-------------------
-- bootstrap = "snlua bootstrap"
luaservice = root.."service/?.lua;"..root.."service/?/main.lua;"..root.."skynet/service/?.lua;"..root.."skynet/service/?/main.lua;"..root.."gamelogic/service/?.lua;"..root.."gamelogic/service/?/main.lua;"
lua_path = root .. "build/lualib/?.lua;" .. root .. "lualib/?.lua;"..root.."skynet/lualib/?.lua;"..root.."gamelogic/lualib/?.lua"
lua_cpath = root.."build/lclualib/?.so;"..root .. "build/clualib/?.so"
cpath = root .. "build/cservice/?.so"
lualoader = root.."skynet/lualib/loader.lua"
preload = root .. "lualib/global_variables.lua"

sprotopath = root.."bin"

----------------程序配置, sa无需理会-------------------