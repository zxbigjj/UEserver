local date = require("sys_utils.date")
local excel_data = require("excel_data")
local agent_utils = require("agent_utils")
local cache_utils = require("cache_utils")
local schema_game = require("schema_game")

local title = DECLARE_MODULE("meta_table.title")

function title.new(role)
    local self = {
        role = role,
        data = role.db.title,
        timer_dict = {} -- key: title_id, value: timer
    }
    return setmetatable(self, title)
end

-- 加载时检查是否有即将过期的称号
function title:load()
    if not self.data.title_dict then
        self.data.title_dict = {}
    else
        self:check_for_expired()
    end
    -- 给角色加属性
    local add_attr_dict = {}
    for title_id, _ in pairs(self.data.title_dict) do
        local exldata = excel_data.ItemData[title_id]
        if exldata.add_role_attr_dict then
            table.dict_attr_add(add_attr_dict, exldata.add_role_attr_dict)
        end
    end
    self.role:modify_attr(nil, add_attr_dict, true)
end

-- 每小时检查一次有没有即将过期的称号
function title:hourly()
    self:check_for_expired()
end

-- 检查是否有即将过期或已过期的称号
function title:check_for_expired()
    local now_ts = date.time_second()
    for id, ts in pairs(self.data.title_dict) do -- id: 称号id, ts: 获得时间
        local validity_period_sec = excel_data.ItemData[id].validity_period_sec -- 有效时长:秒
        if validity_period_sec then
            local expire_ts = ts + validity_period_sec -- 过期时间
            if expire_ts <= now_ts then
                -- 如果已过期则直接remove
                self:remove_title(id)
            else
                -- 如果在当前小时会过期，则启动定时器
                local now_hour0 = date.get_hour_begin(now_ts)
                local expire_hour0 = date.get_hour_begin(expire_ts)
                if now_hour0 == expire_hour0 and (not self.timer_dict[id]) then
                    self.timer_dict[id] = self.role:timer_once(expire_ts - now_ts, function() self:remove_title(id) end)
                end
            end
        end
    end
end

-- 每日重置教父膜拜次数
function title:daily()
    if not self.role:check_function_is_unlocked(CSConst.FuncUnlockId.GodfatherHall) then return end
    self.data.is_worship = false -- false: 未膜拜, true: 已膜拜
    self.role:send_client("s_update_worship_data", {is_worship = self.data.is_worship})
end

-- 上线时发送称号数据
function title:online()
    self.role:send_client("s_update_title_data", {wearing_id = self.data.wearing_id, title_dict = self.data.title_dict})
    if self.role:check_function_is_unlocked(CSConst.FuncUnlockId.GodfatherHall) then
        self.role:send_client("s_update_worship_data", {is_worship = self.data.is_worship})
    end
end

-- 添加称号
function title:add_title(title_id, add_ts)
    local exldata = excel_data.ItemData[title_id]
    if self.data.title_dict[title_id] then return end
    if exldata.item_type ~= CSConst.ItemType.Title then return end
    -- 检查是否已过期
    if add_ts and exldata.validity_period_sec then
        local now_ts = date.time_second()
        local expire_ts = add_ts + exldata.validity_period_sec
        if expire_ts <= now_ts then return end
        local now_hour0 = date.get_hour_begin(now_ts)
        local expire_hour0 = date.get_hour_begin(expire_ts)
        -- 如果这个小时内会过期则启动定时器
        if now_hour0 == expire_hour0 then
            self.timer_dict[title_id] = self.role:timer_once(expire_ts - now_ts, function() self:remove_title(title_id) end)
        end
    end
    self.data.title_dict[title_id] = add_ts or date.time_second()
    -- 增加角色属性
    if exldata.add_role_attr_dict then
        self.role:modify_attr(nil, exldata.add_role_attr_dict, true)
    end
    -- 增加头目属性
    if exldata.add_hero_attr_dict then
        for hero_id, _ in pairs(self.role:get_hero_dict()) do
            self.role:modify_hero_attr(hero_id, nil, exldata.add_hero_attr_dict)
        end
    end
    self.role:send_client("s_notify_add_title", {title_id = title_id, getting_ts = self.data.title_dict[title_id]})
end

-- 获取要增加的英雄属性
function title:get_hero_title_attr()
    local add_attr_dict = {}
    for title_id, _ in pairs(self.data.title_dict) do
        local exldata = excel_data.ItemData[title_id]
        if exldata.add_hero_attr_dict then
            table.dict_attr_add(add_attr_dict, exldata.add_hero_attr_dict)
        end
    end
    return add_attr_dict
end

-- 移除称号
function title:remove_title(title_id)
    self.timer_dict[title_id] = nil
    self.data.title_dict[title_id] = nil
    if self.data.wearing_id == title_id then
        self.data.wearing_id = nil
        self.role:send_client("s_update_wearing_id", {wearing_id = self.data.wearing_id})
    end
    local exldata = excel_data.ItemData[title_id]
    if exldata.add_role_attr_dict then
        self.role:modify_attr(exldata.add_role_attr_dict, nil, true)
    end
    if exldata.add_hero_attr_dict then
        for hero_id, _ in pairs(self.role:get_hero_dict()) do
            self.role:modify_hero_attr(hero_id, exldata.add_hero_attr_dict, nil)
        end
    end
    self.role:send_client("s_notify_del_title", {title_id = title_id})
end

-- 佩戴称号
function title:wearing_title(title_id)
    if not title_id or not self.data.title_dict[title_id] then return end
    self.data.wearing_id = title_id
    self.role:send_client("s_update_wearing_id", {wearing_id = self.data.wearing_id})
    return true
end

-- 取消佩戴称号
function title:unwearing_title()
    if not self.data.wearing_id then return end
    self.data.wearing_id = nil
    self.role:send_client("s_update_wearing_id", {wearing_id = self.data.wearing_id})
    return true
end

-- 膜拜教父
function title:worship_godfather()
    if not self.role:check_function_is_unlocked(CSConst.FuncUnlockId.GodfatherHall) then return end
    if self.data.is_worship then return end
    self.data.is_worship = true
    local reward_id = excel_data.LevelData[self.role:get_level()].worship_godfather_reward
    self.role:add_item_list(excel_data.RewardData[reward_id].item_list, g_reason.worship_godfather_reward)
    self.role:send_client("s_update_worship_data", {is_worship = self.data.is_worship})
    self.role:update_daily_active(CSConst.DailyActiveTaskType.WorshipNum, 1)
    return true
end

-- 功能解锁通知
function title:on_function_unlocked(func_id)
    if func_id ~= CSConst.FuncUnlockId.GodfatherHall then return end
    self.data.is_worship = false -- false: 未膜拜, true: 已膜拜
    self.role:send_client("s_update_worship_data", {is_worship = self.data.is_worship})
end

-- 获取教父殿堂数据
function title:get_godfather_hall_data()
    local godfather_hall_data = {godfather_dict = {}}
    for id, data in pairs(excel_data.ItemData) do
        if data.item_type == CSConst.ItemType.Title and data.sub_type == CSConst.ItemSubType.RushActivityTitle then
            godfather_hall_data.godfather_dict[id] = {history_list = {}}
        end
    end
    for title_id, title_data in pairs(godfather_hall_data.godfather_dict) do
        local db_data = schema_game.RushActivityTitle:load(title_id)
        if db_data then
            if db_data.current_uuid then
                local role = agent_utils.get_role(db_data.current_uuid)
                if role then
                    title_data.current_roleid = role:get_role_id()
                    title_data.current_name = role:get_name()
                    title_data.current_vip = role:get_vip()
                else
                    local role_info = cache_utils.get_role_info(db_data.current_uuid, {"role_id", "name", "vip"})
                    title_data.current_roleid = role_info.role_id
                    title_data.current_name = role_info.name
                    title_data.current_vip = role_info.vip.vip_level
                end
            end
            title_data.history_list = table.deep_copy(db_data.history_list)
            for i, history_info in ipairs(title_data.history_list) do
                local role = agent_utils.get_role(history_info.uuid)
                if role then
                    title_data.history_list[i].name = role:get_name()
                else
                    local role_info = cache_utils.get_role_info(history_info.uuid, {"name"})
                    title_data.history_list[i].name = role_info.name
                end
            end
        end
    end
    return godfather_hall_data
end

return title