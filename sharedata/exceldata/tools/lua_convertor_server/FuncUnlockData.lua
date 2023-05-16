local M = {}

function M:convert(data)
    local vip_unlock_dict = {}
    for k, v in pairs(data) do
    	-- 2为vip解锁，3为vip或等级解锁
        if v.unlock_type == 3 or v.unlock_type == 2 then
            local new_unlock = vip_unlock_dict[v.vip]
            if not new_unlock then
                vip_unlock_dict[v.vip] = {}
                new_unlock = vip_unlock_dict[v.vip]
            end
            table.insert(new_unlock, k)
        end
    end
    data.vip_unlock_dict = vip_unlock_dict
    return data
end

return M