local mem_tool = DECLARE_MODULE("mem_tool")
DECLARE_RUNNING_ATTR(mem_tool, "stop_flag", false)
DECLARE_RUNNING_ATTR(mem_tool, "min_sleep_count", 200)

function mem_tool._checker_maker(path_dict, top_list, top_count, push)
    local format = string.format
    local type_dict = {
        ["table"]=true,
        ["function"]=true,
        ["thread"] = true,
        ["userdata"] = true,
    }
    return function(obj)
        local path = path_dict[obj]
        local num = 0
        local t = type(obj)
        if t == "table" then
            for k,v in pairs(obj) do
                num = num + 1
                if (type(k) == 'string' or type(k) == "number") and type_dict[type(v)] then
                    push(v, format("%s-%s", path, k))
                end
            end
            if getmetatable(obj) then
                push(getmetatable(obj), path .. '-[m]')
                num = num + 1
            end
        elseif t == "function" then
            local index = 1
            while true do
                local k, v = debug.getupvalue(obj, index)
                if not k then break end
                num = num + 1
                if type_dict[type(v)] then
                    push(v, format("%s-[u]%s", path, k))
                end
                index = index + 1
            end
        elseif t == 'thread' then
            local level = 1
            while true do
                local info = debug.getinfo(obj, level, 'nf')
                if not info then break end
                num = num + 1
                if info.func then
                    push(info.func, format("%s-[t]%s", path, info.name))
                    local index = 1
                    while true do
                        local k, v = debug.getlocal(obj, level, index)
                        if not k then break end
                        num = num + 1
                        if type_dict[type(v)] then
                            push(v, format("%s-[l]%s", path, k))
                        end
                        index = index + 1
                    end

                    index = -1
                    while true do
                        local k,v = debug.getlocal(obj, level, index)
                        if not k then break end
                        num = num + 1
                        if type_dict[type(v)] then
                            push(v, format("%s-[v]%s", path, k))
                        end
                        index = index - 1
                    end
                end
                level = level + 1
            end
        elseif t == 'userdata' then
            if getmetatable(obj) then
                push(getmetatable(obj), path .. "-[m]")
                num = num + 1
            end
        end

        if #top_list < top_count or top_list[1].num < num then
            if #top_list >= top_count then
                table.remove(top_list, 1)
            end
            local insert_pos = #top_list + 1
            for pos, info in ipairs(top_list) do
                if info.num >= num then
                    insert_pos = pos
                    break
                end
            end
            table.insert(top_list, insert_pos, {num=num, path=path})
        end
    end
end

-- 扫描全部内存
function mem_tool.check_mem(top_count)
    top_count = top_count or 100
    mem_tool.stop_flag = false

    local path_dict = setmetatable({}, {__mode="kv"})
    local top_list = {}
    path_dict[path_dict] = ''
    path_dict[top_list] = ''
    
    local push_list = {}
    local pop_dict = setmetatable({}, {__mode="kv"})
    path_dict[push_list] = ''
    path_dict[pop_dict] = ''


    local push = function(obj, path)
        if not path_dict[obj] then
            path_dict[obj] = path
            table.insert(push_list, obj)
        end
    end
    local transfer = function()
        for _, obj in ipairs(push_list) do
            pop_dict[obj] = true
        end
        push_list = {}
        path_dict[push_list] = ''
    end
    local print_result = function()
        for _, result in ipairs(top_list) do
            print(string.format('%8d %s', result.num, result.path))
        end
    end
    local checker = mem_tool._checker_maker(path_dict, top_list, top_count, push)

    push(_G, "G")
    push(debug.getregistry(), "R")
    transfer()
    local check_count = 0
    local print_ts = skynet.now()
    local sleep_count = mem_tool.min_sleep_count
    while true do
        local obj, value = next(pop_dict)
        if not value then
            transfer()
            obj, value = next(pop_dict)
            if not value then
                -- finish
                break
            end
        end
        pop_dict[obj] = nil
        checker(obj)
        check_count = check_count + 1

        if check_count % sleep_count == 0 then
            if #push_list > 10000 then
                transfer()
            end

            -- 2秒输出一次
            if check_count % (sleep_count * 200) == 0 then
                check_count = 0
                local use_time = skynet.now() - print_ts - 200
                print_ts = skynet.now()
                -- 重新计算sleep_count
                sleep_count = math.floor(sleep_count * 200 / use_time)
                sleep_count = math.max(mem_tool.min_sleep_count, sleep_count)

                print_result()
                local left_count = #push_list
                for k, v in pairs(pop_dict) do
                    left_count = left_count + 1
                end
                print("======================check_mem_print", sleep_count, use_time, left_count)
            end
            skynet.sleep(1)

            if mem_tool.stop_flag then
                mem_tool.stop_flag = false
                break
            end
        end
    end

    print("======================check_mem_result")
    print_result()
    print("======================check_mem_over")
end

function mem_tool.stop_check_mem()
    mem_tool.stop_flag = true
end


function mem_tool.fast_scan_module(max_deep)
    max_deep = max_deep or 3
    local result = {}
    local scaned = {}
    local scan_func = nil
    scan_func = function(tb, path_name, deep)
        if scaned[tb] then return scaned[tb] end
        scaned[tb] = 0
        local len = 0
        local total_len = 0
        local sub_table_count = 0

        for k,v in pairs(tb) do
            len = len + 1
            if type(v) == 'table' then
                sub_table_count = sub_table_count + 1
            end
        end

        if deep < max_deep and sub_table_count < 300 then
            for k,v in pairs(tb) do
                if type(v) == 'table' then
                    total_len = total_len + scan_func(v, string.format("%s:%s", path_name, k), deep + 1)
                else
                    total_len = total_len + 1
                end
            end
        else
            total_len = len
        end
        result[path_name] = {len, sub_table_count, total_len}
        scaned[tb] = total_len
        return total_len
    end

    local skip_module = {
        excel_data = true
    }
    for mod_name, mod in pairs(package.loaded) do
        if type(mod) == 'table' and not skip_module[mod_name] then
            scan_func(mod, mod_name, 1)
        else
        end
    end

    while true do
        local del = next(scaned)
        if del then
            scaned[del] = nil
        else
            break
        end
    end
    return result
end

function mem_tool.diff_module(sleep_seconds)
    local a = mem_tool.fast_scan_module()
    skynet.sleep(sleep_seconds * 100)
    local b = mem_tool.fast_scan_module()

    local result = {}
    for k, v in pairs(b) do
        v = v[1]
        local old_v = a[k] and a[k][1] or 0
        if v ~= old_v then
            table.insert(result, {k, v-old_v, v, old_v})
        end
    end
    for k, v in pairs(a) do
        v = v[1]
        if not b[k] then
            table.insert(result, {k, 0-v, 0, v})
        end
    end
    return result
end

return mem_tool