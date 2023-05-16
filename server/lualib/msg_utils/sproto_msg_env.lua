local SprotoLoader = require "sprotoloader"
local SprotoCore = require "sproto.core"

local sproto_msg_env = DECLARE_MODULE("msg_utils.sproto_msg_env")
-- 一个节点只需要一个服务init就可以了, 放到common_init

sproto_msg_env.BASE_PACKAGE = "base_package"
sproto_msg_env.PROTO_ID_C2S = 1
sproto_msg_env.PROTO_ID_S2C = 2
sproto_msg_env.sproto_list = {
    {
        id = sproto_msg_env.PROTO_ID_C2S,
        filename = 'c2s.spb',
    },
    {
        id = sproto_msg_env.PROTO_ID_S2C,
        filename = 's2c.spb',
    },
}

function sproto_msg_env.init(sp_path)
    if not sp_path then
        local skynet = require "skynet"
        sp_path = skynet.getenv('sprotopath')
    end
    sp_path = sp_path or ""
    for _, item in ipairs(sproto_msg_env.sproto_list) do
        local full_path = sp_path .. '/' .. item.filename
        local file_handle = assert(io.open(full_path, "rb"), "Can't open sproto bin file")
        local bin = file_handle:read("*all")
        io.close(file_handle)
        SprotoLoader.save(bin, item.id)
        print("load sproto:" .. full_path)
    end
end

return sproto_msg_env
