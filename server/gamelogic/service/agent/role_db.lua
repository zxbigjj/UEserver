local schema_game = require("schema_game")
local cluster_utils = require("msg_utils.cluster_utils")

local role_db = DECLARE_MODULE("role_db")

local Db_Dict = {
	-- false表示跟随role一起使用,不需要get/set用法
	["Role"] = false,
	
	-- true表示get/set用法， 可能脱离role单独用
	-- ["Warehouse"] = true,
}
local Duration = 10 * 60

--绑定玩家身上的数据必须玩家uuid做key
local _all_db_obj_mgr = DECLARE_RUNNING_ATTR(role_db, "_all_db_obj_mgr", {})

function role_db.init()
	for cname, is_check in pairs(Db_Dict) do
		local schema = schema_game[cname]
		_all_db_obj_mgr[cname] = {
			_collection_name = cname,
			_schema = schema,
			_db_dict = {},
			_load_lock = {},
		}
	end

	skynet.report_debug_info('role_db', function()
		return role_db:debug_info()
	end)
end

function role_db:debug_info()
	local words = {}
	for cname, v in pairs(_all_db_obj_mgr) do
		local count = 0
		for k, _ in pairs(v._db_dict) do
			count = count + 1
		end
		table.insert(words, string.format("%s:%s", cname, count))
	end
	return table.concat(words, ", ")
end

function role_db:get_obj(cname)
	return _all_db_obj_mgr[cname]
end

function role_db:_load(mgr, key, not_auto_create)
	while mgr._load_lock[key] do
		skynet.sleep(1)
	end
	if mgr._db_dict[key] then
		mgr._db_dict[key].ts = skynet.time()
		return mgr._db_dict[key].value
	end
	mgr._load_lock[key] = true
	xpcall(function()
		local db = mgr._schema:load(key)
		if not db then
			if not_auto_create then return end
			db = mgr._schema:new_obj(key)
			local info = {value = db, ts = skynet.time(), is_save = true, is_insert = true}
			mgr._db_dict[key] = info
			role_db:_check_start_timer(mgr._collection_name, key, info)
		else
			mgr._db_dict[key] = {value = db, ts = skynet.time()}
		end

		
	end, g_log.trace_handle)
	mgr._load_lock[key] = nil
	return mgr._db_dict[key].value
end

function role_db:create(cname, key)
	local mgr = role_db:get_obj(cname)
	if not mgr then return end
	local value = mgr._schema:new_obj(key)
	local db = {value = value, ts = skynet.time(), is_save = true, is_insert = true}
	mgr._db_dict[key] = db
	role_db:_check_start_timer(cname, key, db)
	return value
end

function role_db:get(cname, key)
	local mgr = role_db:get_obj(cname)
	if not mgr then return end
	local db = mgr._db_dict[key]
	if db then
		db.ts = skynet.time()
		return db.value
	end
	return role_db:_load(mgr, key)
end

function role_db:find_one(cname, uuid)
	local mgr = role_db:get_obj(cname)
	if not mgr then return end
	local db = mgr._db_dict[uuid]
	if db then
		db.ts = skynet.time()
		return db.value
	end
	return role_db:_load(mgr, uuid, true)
end

function role_db:set(cname, uuid, value)
	local mgr = role_db:get_obj(cname)
	if not mgr then return end
	value = mgr._schema:attach(value)

	local db = mgr._db_dict[uuid]
	if not db then
		db = {}
		mgr._db_dict[uuid] = db
	end
	db.value, db.ts, db.is_save = value, skynet.time(), true
	role_db:_check_start_timer(cname, uuid, db)
	return value
end

function role_db:_check_start_timer(cname, uuid, db)
	if not role_db:is_uuid_online(uuid) and not db.save_timer then
		db.save_timer = require("timer").once(Duration, function() role_db:save_timer_cb(cname, uuid) end)
	end
end

function role_db:save_timer_cb(cname, uuid)
	local db = _all_db_obj_mgr[cname]._db_dict[uuid]
	if not db then return end
	db.save_timer = nil

	if role_db:is_uuid_online(uuid) then return end
	local is_insert, query = role_db:_get_save_query(_all_db_obj_mgr[cname], uuid)
	if query then
		role_db:__save(uuid, is_insert, query)
	end
end

function role_db:is_uuid_online(uuid)
	return _all_db_obj_mgr["Role"]._db_dict[uuid] and true
end

function role_db:_get_save_query(mgr, key, is_save_clear)
	local db = mgr._db_dict[key]
	if not db then return end
	if is_save_clear then
		mgr._db_dict[key] = nil
	end
	if Db_Dict[mgr._collection_name] == false then
		if db.is_insert then
			db.is_insert = nil
			return true, mgr._schema:make_insert_query(key, db.value)
		else
			return false, mgr._schema:get_save_query(db.value)
		end
	end
	if db.ts + Duration <= skynet.time() then
		mgr._db_dict[key] = nil
	end
	if db.is_save then
		db.is_save = false
		if db.is_insert then
			db.is_insert = nil
			return true, mgr._schema:make_insert_query(key, db.value)
		else
			return false, mgr._schema:get_save_query(db.value)
		end
	end
end

function role_db:__save(uuid, is_insert, query)
	if is_insert then
		cluster_utils.call_db("lc_insert", 'gamedb', uuid, table.unpack(query, 1, query.n))
	else
		cluster_utils.call_db("lc_update", 'gamedb', uuid, table.unpack(query, 1, query.n))
	end
end

function role_db:save_role(key, is_save_clear)
	local query_list = {}
	local ts = skynet.time()

	for cname, mgr in pairs(_all_db_obj_mgr) do
		local is_insert, query = role_db:_get_save_query(mgr, key, is_save_clear)
		if query then
			table.insert(query_list, {is_insert=is_insert, query=query})
		end
	end

	if #query_list == 0 then return end

	for _, info in ipairs(query_list) do
		role_db:__save(key, info.is_insert, info.query)
	end
	g_log:role("SaveRole", {uuid=key, use=skynet.time()-ts})
end

function role_db.save_all()
	local uuid_dict = {}
	for cname, mgr in pairs(_all_db_obj_mgr) do
		for uuid, _ in pairs(mgr._db_dict) do
			uuid_dict[uuid] = true
		end
	end

	for uuid, _ in pairs(uuid_dict) do
		role_db:save_role(uuid, true)
	end
end

return role_db