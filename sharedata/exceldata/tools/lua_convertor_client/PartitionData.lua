local M = {}

function M:convert(data)
    local ret = {}
    ret["partition_list"] = {}
    ret["partition_id_dict"] = {}
    for k,v in pairs(data) do
        ret[k] = v
        if not ret["partition_list"][v.area] then
            ret["partition_list"][v.area] = {}
        end
        table.insert(ret["partition_list"][v.area], v)
        if not ret["partition_id_dict"][v.area] then
            ret["partition_id_dict"][v.area] = {}
        end
        ret["partition_id_dict"][v.area][v.partition] = k
    end
    for _,partition_list in pairs(ret["partition_list"]) do
        table.sort(partition_list, function (partition1, partition2)
            return partition1.build_time > partition2.build_time
        end)
    end
    return ret
end

return M