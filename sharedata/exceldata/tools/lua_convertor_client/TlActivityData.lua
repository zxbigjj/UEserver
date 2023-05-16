local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        if v.type == 2 then
            ret.first_recharge_activity = v.id
        elseif v.type == 3 then
            if not ret.daily_recharge_activity_list then
                ret.daily_recharge_activity_list = {}
            end
            table.insert(ret.daily_recharge_activity_list, v.id)
        elseif v.type == 6 then
            ret.recharge_draw_activity = v.id
        end
        ret[k] = v
    end
    return ret
end

return M