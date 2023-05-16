local LUUID = require "luuid"

local M = {}

-- 每个一个进程只做一次
function M.init(type_id, action_id)
    return LUUID.init(type_id, action_id)
end


local g_cache_max = 16
local g_cache_num = 0
local g_cache_idx = 0

-- 每个一个虚拟机初始化的
function M.config(cache_max)
    cache_max = math.tointeger(cache_max)
    if not (cache_max and cache_max > 0 and cache_max < 0xffff) then
        error("illegal uuid config")
    end

    g_cache_max = cache_max or 16
end


function M.new()
   if g_cache_num <= 0 then
       g_cache_idx = LUUID.apply(g_cache_max)
       g_cache_num = g_cache_max
       print("--- g cache begin idx", g_cache_idx, g_cache_num)
   end

   g_cache_idx = g_cache_idx + 1
   g_cache_num = g_cache_num - 1
   return LUUID.new(g_cache_idx)
end

return M
