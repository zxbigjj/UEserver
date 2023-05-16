local patch_utils = DECLARE_MODULE("patch_utils")

local PATCH_DB_NAME = "t_DbPatch"
local patch_list = {
    [1] = "patch_20160701",
    [2] = 'patch_20190419'
}

function patch_utils.do_patch()
    if skynet.getenv("server_type") ~= 'game' then
        return
    end
    local db_client = require("db_utils").get_db_client("gamedb")
    if not db_client:is_table_exist(PATCH_DB_NAME) then
        pcall(db_client.create_table, db_client,
            PATCH_DB_NAME,
            {
            'id int', 
            'last_patch_index int',
            },
            {
            'primary key (id)', 
            }) 
    end

    local patch_info = db_client:select_one(PATCH_DB_NAME, {id=0})
    if not patch_info then
        patch_info = {id=0, last_patch_index=#patch_list}
        db_client:insert(PATCH_DB_NAME, patch_info)
    end
    local index = patch_info.last_patch_index
    while index < #patch_list do
        index = index + 1
        local func_name = patch_list[index]
        if func_name then
            g_log:db("PatchBegin", index, func_name)
            patch_utils[func_name](db_client)
            patch_info.last_patch_index = index
            db_client:update(PATCH_DB_NAME, {id=0}, {last_patch_index = index})
            g_log:db("PatchFinish", index, func_name)
        end
    end
end

function patch_utils.patch_20160701(db_client)
    -- 清空Player和Role
end

function patch_utils.patch_20190419(db_client)
    -- 清空排行榜
    -- db_client:query("delete from t_Rank")
end

return patch_utils