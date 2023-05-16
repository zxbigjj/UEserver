local M = DECLARE_MODULE("attr_utils")

local sandbox = require("CSCommon.sandbox")
local excel_data = require("excel_data")
local CSFunction = require("CSCommon.CSFunction")

-- 修改原始属性后刷新
function M.on_modify_raw(raw_dict, modify_raw_name)
    return CSFunction.on_modify_raw(raw_dict, modify_raw_name)
end

-- 根据原始属性计算最终属性
function M.refresh_all_attr(raw_dict)
    return CSFunction.refresh_all_attr(raw_dict)
end

-- 计算英雄战力
function M.eval_hero_score(attr_dict)
    return CSFunction.eval_hero_score(attr_dict)
end

-- 获取机器人英雄属性
function M.get_robot_hero_attr(robot_id, level)
    local data = excel_data.HeroRobotData[robot_id]
    local attr_dict = sandbox.get_robot_hero_attr(data.robot_grow)(data.hero_id, level)
    return attr_dict
end

-- 获取英雄初始属性
function M.get_hero_init_attr()
    local data = excel_data.GrowConstData["base_role_define"]
    return {
        ["hit"] = data.base_hit,
        ["miss"] = data.base_miss,
        ["crit"] = data.base_crit,
        ["crit_def"] = data.base_crit_def
    }
end

return M