
local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        if #v.monster_list > 6 then
            error("怪物数量不能超过6个")
        end
        local pos_list = {}
        for i, pos in ipairs(v.pos_list) do
            if pos < 0 or pos > 6 then error("pos out of range group_id : ", k) end
            if pos_list[pos] then error("two pos is same group_id: ", k) end
            pos_list[pos] = {monster_id = v.monster_list[i]}
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