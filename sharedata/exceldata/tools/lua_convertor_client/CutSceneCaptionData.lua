local M = {}

function M:convert(data)
    local ret = {}
    ret["cut_scene_caption_list"] = {}
    for k, v in pairs(data) do
        table.insert(ret["cut_scene_caption_list"], v)
    end
    table.sort(ret["cut_scene_caption_list"], function (caption1, caption2)
        return caption2.start_time > caption1.start_time
    end)
    return ret
end

return M