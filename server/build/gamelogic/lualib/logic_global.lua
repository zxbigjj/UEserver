g_reason = require("reason")
setmetatable(g_reason, {__index = function(t, k)
    error("no this reason:" .. k)
end})

g_tips = require("tips")
setmetatable(g_tips, {__index = function(t, k)
    error("no this tips:" .. k)
end})

g_const = require("const")
setmetatable(g_const, {__index = function(t, k)
    error("no this gconst:" .. k)
end})

CSConst = require("CSCommon.CSConst")
setmetatable(CSConst, {__index = function(t, k)
    error("no this csconst:" .. k)
end})

__is_cross_mapper = {
    game = false,
    cross = true,
}

__is_global_mapper = {
    global_friend = true,
    world = true,
    pay = true,
    gm_router = true,
}

function IS_CROSS() return false end
function IS_GLOBAL() return false end

if __is_cross_mapper[skynet.getenv("server_type")] then
    function IS_CROSS() return true end
elseif __is_global_mapper[skynet.getenv("server_type")] then
    function IS_GLOBAL() return true end
end
