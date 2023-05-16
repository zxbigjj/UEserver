local M = {}

function M:convert(exltable)
    for id, data in pairs(exltable) do
        local item_obj_list = {}
        for i = 1, #data.item_id_list do
            local item_id, count = data.item_id_list[i], data.item_num_list[i]
            table.insert(item_obj_list, {item_id = item_id, count = count})
        end
        data.item_list = item_obj_list
    end
    return exltable
end

return M