
local M = {}
local max_btn_num = 2
local only_level_type = 1
local only_vip_type = 2
local vip_or_level_type = 3
local event_type = 4
function M:convert(data)
    local ret = {}
    ret["sys_unlock_list"] = {}
    ret["playment_list"] = {}
    ret["func_to_vip_level"] = {}
    local temp = {}
    for k, v in pairs(data) do
        local ui_key
        local ui
        local btn_path_key
        local btn_path
        local effect_id_key
        local effect_id
        local effect_path_key
        local effect_path
        local first_ui_name
        local ui_to_btn_data_list = {}
        for i = 1, max_btn_num do
            ui_key = "ui" .. i
            btn_path_key = "ui_btn_path" .. i
            effect_id_key = "effect_id" .. i
            effect_path_key = "ui_effect_path" .. i
            ui = v[ui_key]
            btn_path = v[btn_path_key]
            effect_id = v[effect_id_key]
            effect_path = v[effect_path_key]
            if not btn_path then break end
            if i == 1 then first_ui_name = ui end
            ui = ui or first_ui_name
            if not ui_to_btn_data_list[ui] then ui_to_btn_data_list[ui] = {} end
            table.insert(ui_to_btn_data_list[ui], {btn_path = btn_path, effect_id = effect_id, effect_path = effect_path})
        end
        v.ui_to_btn_data_list = ui_to_btn_data_list
        if v.level then
            temp[v.level] = temp[v.level] or {level = v.level, data = {}}
            table.insert(temp[v.level].data, v)
        end
        if v.show_in_playment then
            table.insert(ret["playment_list"], v)
        end
        if v.unlock_type == vip_or_level_type or v.unlock_type == only_vip_type then
            ret["func_to_vip_level"][k] = v.vip
        end

        ret[k] = v
    end
    for _, data in pairs(temp) do
        table.insert(ret["sys_unlock_list"], data)
    end
    table.sort(ret["sys_unlock_list"], function (data1, data2)
        if data1.level == data2.level then
            return data1.id < data2.id
        end
        return data1.level < data2.level
    end)
    local ui_to_id_list = {}
    
    for k, v in pairs(data) do
        if v.ui_to_btn_data_list then
            for ui, _ in pairs(v.ui_to_btn_data_list) do
                if not ui_to_id_list[ui] then ui_to_id_list[ui] = {} end
                table.insert(ui_to_id_list[ui], k)
            end
        end
    end
    ret.ui_to_id_list = ui_to_id_list

    table.sort(ret["playment_list"], function (func1, func2)
        return func2.id > func1.id
    end)
    return ret
end

return M