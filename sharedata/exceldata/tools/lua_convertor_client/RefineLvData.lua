local M = {}

function M:convert(data)
    local ret = {}
    ret.equipment_refine_list = {}
    ret.treasure_refine_list = {}
    for k,v in pairs(data) do
        if v.exp_q1 then ret.equipment_refine_list[k] = v end
        if v.item_num then ret.treasure_refine_list[k] = v end
        ret[k] = v
    end
    ret.equipment_refine_list[0].total_exp_q1 = 0
    ret.equipment_refine_list[0].total_exp_q2 = 0
    ret.equipment_refine_list[0].total_exp_q3 = 0
    ret.equipment_refine_list[0].total_exp_q4 = 0
    ret.equipment_refine_list[0].total_exp_q5 = 0
    for level, data in ipairs(ret.equipment_refine_list) do
        data.total_exp_q1 = ret.equipment_refine_list[level - 1].total_exp_q1 + ret.equipment_refine_list[level - 1].exp_q1
        data.total_exp_q2 = ret.equipment_refine_list[level - 1].total_exp_q2 + ret.equipment_refine_list[level - 1].exp_q2
        data.total_exp_q3 = ret.equipment_refine_list[level - 1].total_exp_q3 + ret.equipment_refine_list[level - 1].exp_q3
        data.total_exp_q4 = ret.equipment_refine_list[level - 1].total_exp_q4 + ret.equipment_refine_list[level - 1].exp_q4
        data.total_exp_q5 = ret.equipment_refine_list[level - 1].total_exp_q5 + ret.equipment_refine_list[level - 1].exp_q5
    end
    return ret
end

return M