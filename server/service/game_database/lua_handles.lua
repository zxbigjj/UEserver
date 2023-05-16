local db_utils = require("db_utils")

local db_handles = DECLARE_MODULE("lua_handles")

function db_handles.lc_query(db_name, conn_seed, query)
    return db_utils.get_db_client(db_name, conn_seed):query(query)
end

function db_handles.lc_query_one(db_name, conn_seed, query)
    return db_utils.get_db_client(db_name, conn_seed):query_one(query)
end

function db_handles.lc_select_one(db_name, conn_seed, t_name, condition, selector)
    return db_utils.get_db_client(db_name, conn_seed):select_one(t_name, condition, selector)
end

function db_handles.lc_select_many(db_name, conn_seed, t_name, condition, selector, order, limit)
    return db_utils.get_db_client(db_name, conn_seed):select_many(t_name, condition, selector, order, limit)
end

function db_handles.lc_update(db_name, conn_seed, t_name, condition, setter)
    return db_utils.get_db_client(db_name, conn_seed):update(t_name, condition, setter)
end

function db_handles.lc_json_update(db_name, conn_seed, t_name, condition, field_name, ...)
    return db_utils.get_db_client(db_name, conn_seed):json_update(t_name, condition, field_name, ...)
end

function db_handles.lc_batch_insert(db_name, conn_seed, t_name, doc_list)
    return db_utils.get_db_client(db_name, conn_seed):batch_insert(t_name, doc_list)
end

function db_handles.lc_insert(db_name, conn_seed, t_name, doc, use_replace)
    return db_utils.get_db_client(db_name, conn_seed):insert(t_name, doc, use_replace)
end

function db_handles.lc_query_count(db_name, conn_seed, t_name)
    return db_utils.get_db_client(db_name, conn_seed):query_count(t_name)
end

function db_handles.lc_delete(db_name, conn_seed, t_name, condition)
    return db_utils.get_db_client(db_name, conn_seed):delete(t_name, condition)
end

function db_handles.lc_create_table(db_name, conn_seed, table_name, field_list, index_list)
    return db_utils.get_db_client(db_name, conn_seed):create_table(table_name, field_list, index_list)
end

function db_handles.lc_drop_table(db_name, conn_seed, table_name)
    return db_utils.get_db_client(db_name, conn_seed):drop_table(table_name)
end

function db_handles.lc_add_column(db_name, conn_seed, t_name, field_name, define)
    return db_utils.get_db_client(db_name, conn_seed):add_column(t_name, field_name, define)
end

function db_handles.lc_drop_column(db_name, conn_seed, t_name, field_name)
    return db_utils.get_db_client(db_name, conn_seed):drop_column(t_name, field_name)
end

function db_handles.lc_modify_column(db_name, conn_seed, t_name, field_name, define)
    return db_utils.get_db_client(db_name, conn_seed):modify_column(t_name, field_name, define)
end

function db_handles.lc_change_column(db_name, conn_seed, t_name, old_name, new_name, define)
    return db_utils.get_db_client(db_name, conn_seed):change_column(t_name, old_name, new_name, define)
end

function db_handles.lc_drop_index(db_name, conn_seed, t_name, index_name)
    return db_utils.get_db_client(db_name, conn_seed):drop_index(t_name, index_name)
end

function db_handles.lc_add_index(db_name, conn_seed, t_name, index_name, index_tail)
    return db_utils.get_db_client(db_name, conn_seed):add_index(t_name, index_name, index_tail)
end

function db_handles.lc_is_table_exist(db_name, conn_seed, t_name)
    return db_utils.get_db_client(db_name, conn_seed):is_table_exist(t_name)
end

return db_handles