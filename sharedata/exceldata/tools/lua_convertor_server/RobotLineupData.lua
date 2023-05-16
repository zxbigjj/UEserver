
local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        if #v.hero_list > 6 then
            error("hero_list 长度不能超过6")
        end
        local pos_list = {}
        for i, pos in ipairs(v.pos_list) do
            pos_list[pos] = {
                robot_hero_id = v.hero_list[i],
            }
        end
        for pos = 1, 6 do
            pos_list[pos] = pos_list[pos] or {}
        end
        v.pos_list = pos_list
        ret[k] = v
    end
    return ret
end

return M