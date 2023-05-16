-- 热更新
-- skynet有codecache， 所以不能直接require
-- 通过读文件然后load的方式实现
local skynet = require("skynet")
local lfs = require("lfs")
local log = g_log

local M = DECLARE_MODULE("srv_utils.reload")
-- 所有需要reload的模块
DECLARE_RUNNING_ATTR(M, "_all_reload_mod", {})

-- 初始化
function M.start(self_is_watcher)
	-- package处理
	table.insert(package.searchers, 1, function(mod_name) 
		if M._all_reload_mod[mod_name] then
			return M._load_mod, mod_name
		else
			return nil
		end
	end)

	local skynet = require("skynet")
	if not self_is_watcher then
		local result = skynet.call(".reload_watcher", "lua", 
			"lc_x_reload_register", skynet.self(), package.path)
		if result.errcode ~= 0 then
			log:error("reload init error:" .. result.errcode)
		else
			if result.excel_dict and next(result.excel_dict) then
				require("excel_data").reload()
			end
			for mod_name, file_name in pairs(result.mod_dict) do
				M._reload_mod(mod_name, file_name)
			end
		end
	end
end

function M.set_reload_after_callback(mod, callback)
	mod.__RELOAD_AFTER = function()
		local result = xpcall(callback, g_log.trace_handle)
		if not result then
			log:error("reload after callback fail:" .. mod.__RELOAD_MOD_NAME)
		end
	end
end

function M.bind_reload(mod, bind_mod)
	mod.__RELOAD_BINDING = mod.__RELOAD_BINDING or {}
	mod.__RELOAD_BINDING[bind_mod.__RELOAD_MOD_NAME] = bind_mod.__RELOAD_FILENAME
end

function M._reload_mod(mod_name, file_name)
	M._all_reload_mod[mod_name] = file_name
	local old_mod = package.loaded[mod_name]
	if not old_mod or type(old_mod) ~= "table" then
		return
	end
	if not rawget(old_mod, "__RELOAD_FLAG") then
		log:warn("ignore reload module:" .. file_name)
		return 
	end

	if rawget(old_mod, "__RELOADING") then
		-- 正在热更新，过一会重试
		skynet.timeout(10, function()
			M._reload_mod(mod_name, file_name)
		end)
		return
	end

	log:info("reload_mod begin: " .. mod_name .. " <==> " .. file_name)
	local fobj = io.open(file_name, "r")
	local code = fobj:read("a")
	fobj:close()
	old_mod.__RELOADING = true
	local chunk, err = load(code, file_name)
	if not chunk then
		log:error("reload_mod fail:" .. file_name)
		log:error(err)
	else
		local result = xpcall(chunk, g_log.trace_handle)
		if not result then
			log:error("reload_mod fail:" .. file_name)
			package.loaded[mod_name] = old_mod
		else
			if rawget(old_mod, "__RELOAD_AFTER") then
				old_mod.__RELOAD_AFTER()
			end
			old_mod.__RELOADING = false
			log:warn("reload_mod finish:" .. mod_name .. " <==> " .. file_name)
			skynet.timeout(1, function()
				for k, v in pairs(rawget(old_mod, "__RELOAD_BINDING") or {}) do
					M._reload_mod(k, v)
				end
			end)
		end
	end
	old_mod.__RELOADING = false
end

function M._load_mod(mod_name)
	local file_name = M._all_reload_mod[mod_name]
	local fobj = io.open(file_name, "r")
	local code = fobj:read("a")
	fobj:close()
	local chunk, err = load(code, file_name)
	if not chunk then
		error(string.format("load lua fail: %s, %s", file_name, err))
		return
	end
	local result = chunk()
	log:warn("load_mod finish:" .. file_name)
	DECLARE_FINISH(result)
	return result
end

function M.reload(mod_name)
	local file_name = package.searchpath(mod_name, package.path)
	assert(file_name, "cannot find mod:" .. mod_name)
	M._reload_mod(mod_name, file_name)
end

-- lua handle
local lua_handles_utils = require("msg_utils.lua_handles_utils")
lua_handles_utils.add_send_handle("ls_x_reload_notify", function(excel_list, mod_dict) 
	if excel_list and next(excel_list) then
		require("excel_data").reload()
	end
	for mod_name,file_name in pairs(mod_dict) do
		M._reload_mod(mod_name, file_name)
	end
end)

return M