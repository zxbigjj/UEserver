root = "./"
thread = 8
logger = nil
harbor = 0
start = "cross_launcher"

gamedb = 'hd_game70'

log_path = 'log/'
reload_path = 'status/'
config_path = 'config/'

db_host = '127.0.0.1'
db_port = 3306
db_user = 'root'
db_passwd = '123456'

server_id = 70
server_name = 's70' -- 服务器ID
server_type = 'cross'

cluster_nodename = 's70_cross' -- 集群节点名
cluster_nodeaddr = '117.50.193.85:17015' -- 地址
cluster_router = '117.50.193.85:40301'
cluster_router_name = 's2800_cluster_router'
cluster_port = 17015
debug_console_port = 17016

min_cross_server_id = 70


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