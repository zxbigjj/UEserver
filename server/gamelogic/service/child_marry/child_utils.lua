local OfflineObjMgr = require("db.offline_db").OfflineObjMgr
local timer = require("timer")
local child_utils = DECLARE_MODULE("child_utils")
local date = require("sys_utils.date")

local CNAME = "ChildPropose"
DECLARE_RUNNING_ATTR(child_utils, "_mgr", nil)

DECLARE_RUNNING_ATTR(child_utils, "sign_dict", {}) --主键为grade_id, 值为 grad_id相同的woman_list, man_list
DECLARE_RUNNING_ATTR(child_utils, "timer", nil)

local MaxCount = 10
local ResetTimer = 3600 --每隔一小时重置sign_dict

local function cmp(a, b)
    if a.attr_value == b.attr_value then
        return a.apply_time < b.apply_time
    end
    return a.attr_value > b.attr_value
end

function child_utils:init(schema_name)
    child_utils._mgr = OfflineObjMgr.new(require(schema_name)[CNAME])
    child_utils._mgr:load_all()
    child_utils.timer = timer.loop(ResetTimer, function()
        child_utils:reset_sign_dict()
    end, 0)
end

function child_utils:reset_sign_dict()
    child_utils.sign_dict = {}
    for uuid ,info in pairs(child_utils._mgr:get_all()) do
        local propose_object_dict = info.propose_object_dict
        for child_id, object in pairs(info.propose_object_dict) do
            if not child_utils.sign_dict[object.grade] then
                child_utils.sign_dict[object.grade] = {
                    woman_list = {},
                    man_list = {},
                }
            end
            local sign_list = child_utils:get_sign_list(object.sex, object.grade)
            table.insert(sign_list, object)
        end
    end
    child_utils:sort_sign_dict()
end

function child_utils:sort_sign_dict()
    for grade, info_list in pairs(child_utils.sign_dict) do
        table.sort(child_utils.sign_dict[grade].woman_list, cmp)
        table.sort(child_utils.sign_dict[grade].man_list, cmp)
    end
end

function child_utils:add_object(object)
    if not object.uuid or not object.child_id then return end
    object.attr_value = 0
    for name, value in pairs(object.attr_dict) do
        object.attr_value = object.attr_value + value
    end
    child_utils:sign_add_object(object)
    local info = child_utils._mgr:get(object.uuid) or {}
    local propose_object_dict = info.propose_object_dict or {}
    propose_object_dict[object.child_id] = object
    info.propose_object_dict =  propose_object_dict
    child_utils._mgr:set(object.uuid, info)
    return true
end

function child_utils:delete_object(uuid, child_id)
    if not uuid or not child_id then return end
    local object = child_utils:get_object_info(uuid, child_id)
    if not object then return end
    local info =  child_utils._mgr:find_one(object.uuid)
    if not child_utils:sign_delete_object(object) then return end
    info.propose_object_dict[child_id] = nil
    if #info.propose_object_dict == 0 then
        child_utils._mgr:delete(uuid)
    else
        child_utils._mgr:set(uuid, info)
    end
    object.marry_time = date.time_second()
    return object
end

function child_utils:get_object_info(uuid, child_id)
    if not uuid or not child_id then return end
    local info = child_utils._mgr:find_one(uuid)
    if not info or not info.propose_object_dict or not info.propose_object_dict[child_id] then return end
    return info.propose_object_dict[child_id]
end

function child_utils:get_all_object_info(uuid, sex, page_id, grade)
    local sign_list = child_utils:get_sign_list(sex, grade)
    if not sign_list then return end

    local left = (page_id - 1) * MaxCount
    if left <= 0 then left = 1 end
    local right = page_id * MaxCount
    local len = #sign_list

    if left > len then return end
    if right > len then
        right = len
    end

    local object_list = {}
    for i = left, right do
        local sign = sign_list[i]
        if sign and sign.uuid ~= uuid then
            table.insert(object_list, sign)
        end
    end
    return object_list
end

function child_utils:get_sign_list(sex, grade)
    if not child_utils.sign_dict[grade] then return end
    if sex == CSConst.Sex.Man then
        return child_utils.sign_dict[grade].man_list
    elseif sex == CSConst.Sex.Woman then
        return child_utils.sign_dict[grade].woman_list
    end
end

function child_utils:find_sign_index(object)
    local sign_list = child_utils:get_sign_list(object.sex, object.grade)
    if not sign_list then return end
    for index, info in ipairs(sign_list) do
        if info.uuid == object.uuid and info.child_id == object.child_id then
            return index
        end
    end
end

function child_utils:sign_add_object(object)
    if not child_utils.sign_dict[object.grade] then
        child_utils.sign_dict[object.grade] = {
            woman_list = {},
            man_list = {},
        }
    end
    local sign_list = child_utils:get_sign_list(object.sex, object.grade)
    local index = child_utils:find_sign_index(object)
    if index then
        sign_list[index] = object
    else
        table.bi_insert(sign_list, object, cmp)
    end
end

function child_utils:sign_delete_object(object)
    local index = child_utils:find_sign_index(object)
    if not index then return end
    local sign_list = child_utils:get_sign_list(object.sex, object.grade)
    if not sign_list then return end
    table.remove(sign_list, index)
    return true
end

function child_utils.save_all()
    child_utils._mgr:save_all()
end

return child_utils