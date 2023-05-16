local M = {}

function M:convert(data)
    local ret = {}
    for k,v in pairs(data) do
        if k == "dynasty_compete_fight_day" then
            v.day_dict = {}
            for _, day in pairs(v.tb_string) do
                v.day_dict[day] = true
            end
        end
        ret[k] = v
    end
    return ret
end

return M