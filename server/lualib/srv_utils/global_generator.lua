--[[
    1.key must not be number
    2.must init all key in init stage
--]]

local global_generator = DECLARE_MODULE("srv_utils.global_generator")
local CLOSE_FLAG = "_GLOBAL_GENERATOR_CLOSE"

function global_generator.new()
    local result = {}
    local _keys = {}
    local mt = {
        __index = global_generator,
        __newindex = function(t, k, v)
            if rawget(t, CLOSE_FLAG) then
                if not _keys[k] then
                    error(string.format("key %s don't exist", tostring(k)), 2)
                else
                    rawset(t, k ,v)
                end
            else
                rawset(t, k ,v)
                _keys[k] = true
            end
        end
    }
    setmetatable(result, mt)
    return result
end

function global_generator.begin_init(self)
    rawset(self, CLOSE_FLAG, false)
end

function global_generator.finish_init(self)
    rawset(self, CLOSE_FLAG, true)
end

return global_generator