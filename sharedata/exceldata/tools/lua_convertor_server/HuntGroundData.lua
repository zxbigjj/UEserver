
local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        v.animal_num = #v.animal_hp
        ret[k] = v
        local first_pass_award_list = {}
        for i, item_id in ipairs(v.first_pass_award_list) do
            first_pass_award_list[i] = {
                item_id = item_id,
                count = v.first_pass_award_num_list[i]
            }
        end
        v.first_pass_award_num_list = nil
        v.first_pass_award_list = first_pass_award_list
    end
    return ret
end

return M