local skynet = require "skynet"
require 'skynet.manager'
local ServerEnv = require "srv_utils.server_env"
local mysql_db = require "db.mysql_db"

local UUID = require 'uuid'

local function InitUUID(server_id)
    local db_cfg = require("srv_utils.server_env").get_db_cfg("gamedb")
    local db = mysql_db.new(db_cfg)
    if not db:is_table_exist('t_uuid_alloc') then
        pcall(db.create_table, db,
            't_uuid_alloc',
            {
            'id int unsigned not null auto_increment', 
            'rand_key varchar(16)',
            },
            {
            'primary key (id)', 
            'unique (rand_key)',
            }) 
    end
    -- 利用自增生成id
    local action_id
    while true do
        local rand_key = string.rand_string(16)
        if pcall(db.query, db, string.format('insert t_uuid_alloc (rand_key) values ("%s")', rand_key)) then
            action_id = db:query(string.format("select * from t_uuid_alloc where rand_key='%s'", rand_key))[1].id
            break
        end
    end
    db:close()

    local uuid_tag = UUID.init(server_id, action_id)
    assert(uuid_tag, "uuid init fail")
    g_log:infof("uuid init<%s|%s>, tag<%s>", server_id, action_id, uuid_tag)
end

local function CommonInit()
    local server_id = math.tointeger(ServerEnv.get_server_id())
    assert(server_id and server_id >= 0 and server_id <= 0xffff, "illegal server_id")
    InitUUID(server_id)
end

local function init()
end

init()
skynet.start(CommonInit)