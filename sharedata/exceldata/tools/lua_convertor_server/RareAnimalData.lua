
local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        local must_item = {}
        local drop_id = {}
        local rank_start = 1
        for i, rank_end in ipairs(v.award_rank_list) do
            if i == #v.award_rank_list then
                must_item[rank_end] = v.must_item[i]
                drop_id[rank_end] = v.drop_id[i]
                break
            end
            for j=rank_start, rank_end do
                must_item[j] = v.must_item[i]
                drop_id[j] = v.drop_id[i]
            end
            rank_start = rank_end + 1
        end
        v.must_item = must_item
        v.drop_id = drop_id
        ret[k] = v
    end
    return ret
end

return M