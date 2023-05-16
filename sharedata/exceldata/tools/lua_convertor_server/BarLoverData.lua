local M = {}

function M:convert(datas)
    local weight_table = {}
    local total_weight = 0
    for id, data in pairs(datas) do
        weight_table[id] = data.weight
        total_weight = total_weight + data.weight
    end
    datas.weight_table = weight_table
    datas.total_weight = total_weight
    return datas
end

return M