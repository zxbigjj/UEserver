local role_guide = DECLARE_MODULE("meta_table.guide")

local excel_data = require("excel_data")
local json = require("cjson")

function role_guide.new(role)
    local self = {
        role = role,
        db = role.db,
    }
    return setmetatable(self, role_guide)
end

-- 指引组类型优先级
local guide_type_priority = {
    [CSConst.GuideType.EventGuide]  = 1,
    [CSConst.GuideType.UnlockGuide] = 2,
}

-- 指引组比较函数
local function guide_comp(left_group_id, right_group_id)
    local group_id_to_guide_type = excel_data.ForceGuideData.group_id_to_guide_type
    local left_type_priority = guide_type_priority[group_id_to_guide_type[left_group_id]]
    local right_type_priority = guide_type_priority[group_id_to_guide_type[right_group_id]]
    if left_type_priority ~= right_type_priority then
        return left_type_priority < right_type_priority
    else
        return left_group_id < right_group_id
    end
end

-- 添加新的指引组
function role_guide:add_guide(group_id)
    local guide_list = self.db.guide_list
    local guide_dict = self.db.guide_dict
    if #guide_dict == 0 then
        guide_dict[group_id] = 0
        local guide_exltable = excel_data.ForceGuideData
        local guide_group_list = guide_exltable.guide_group_list
        local guide_step_list = guide_group_list[group_id]
        local guide_exldata = guide_exltable[guide_step_list[1]]
        if guide_exldata.front_reward_id then
            self:reward_guide(guide_exldata.front_reward_id)
        end
        self.role:send_client("s_update_newbie_guide_info", {guide_dict = guide_dict})
    else
        table.bi_insert(guide_list, group_id, guide_comp)
    end
end

-- 初始化
function role_guide:init_guide()
    -- 未解锁的系统
    local locked_dict = self.db.guide_locked_dict
    local func_unlock_data = excel_data.FuncUnlockData
    for funcId, funcData in pairs(func_unlock_data) do
        if type(funcId) == 'number' and funcData.unlock_type then
            locked_dict[funcId] = true
        end
    end

    -- 新手指引
    local guide_dict = self.db.guide_dict
    local guide_exltable = excel_data.ForceGuideData
    for id, exldata in pairs(guide_exltable) do
        if type(id) == 'number' and exldata.type == 1 then
            guide_dict[exldata.group_id] = 0
        end
    end

    -- 前置奖励
    for group_id in pairs(guide_dict) do
        local guide_id = guide_exltable.guide_group_list[group_id][1]
        local guide_exldata = guide_exltable[guide_id]
        if guide_exldata.front_reward_id then
            self:reward_guide(guide_exldata.front_reward_id)
        end
    end
end

-- 上线通知
function role_guide:online_guide()
    self.role:send_client("s_update_newbie_guide_info", {guide_dict = self.db.guide_dict})
    self.role:send_client('s_level_event_trigger', {locked_dict = self.db.guide_locked_dict})
end

-- 指引奖励
function role_guide:reward_guide(reward_id)
    local reward_record = excel_data.RewardData[reward_id]
    self.role:add_item_list(reward_record.item_list, g_reason.guide_reward)
end

-- 完成指引
function role_guide:complete_guide(group_id)
    print("--- complete_guide in " .. group_id)
    if not group_id then return end
    local guide_dict = self.db.guide_dict
    local guide_step = guide_dict[group_id]
    if not guide_step then return end

    local guide_exltable = excel_data.ForceGuideData
    local guide_group_list = guide_exltable.guide_group_list
    local guide_step_list = guide_group_list[group_id]
    if not guide_step_list then return end

    local guide_id = guide_step_list[guide_step + 1]
    if not guide_id then return end
    local guide_exldata = guide_exltable[guide_id]
    if guide_exldata.complete_reward_id then
        self:reward_guide(guide_exldata.complete_reward_id)
    end

    guide_dict[group_id] = guide_dict[group_id] + 1
    guide_step = guide_dict[group_id]
    if guide_step >= #guide_step_list then
        -- 指引组已完成
        guide_dict[group_id] = nil
        local guide_list = self.db.guide_list
        if #guide_dict == 0 and #guide_list > 0 then
            guide_dict[DB_LIST_REMOVE(guide_list, 1)] = 0
            for k in pairs(guide_dict) do group_id = k; break end
            guide_step_list = guide_group_list[group_id]
            guide_exldata = guide_exltable[guide_step_list[1]]
            if guide_exldata.front_reward_id then
                self:reward_guide(guide_exldata.front_reward_id)
            end
        end
    else
        -- 指引组未完成
        guide_exldata = guide_exltable[guide_step_list[guide_step + 1]]
        if guide_exldata.front_reward_id then
            self:reward_guide(guide_exldata.front_reward_id)
        end
    end
    json.encode_sparse_array(true) 
    print("--- complete_guide back " .. json.encode(self.db.guide_dict))
    self.role:send_client("s_update_newbie_guide_info", {guide_dict = self.db.guide_dict})
    return true
end

-- 新手指引事件触发
function role_guide:event_trigger_check(event_id)
    if not event_id then return end
    local guide_event_dict = self.db.guide_event_dict
    if not guide_event_dict[event_id] then
        guide_event_dict[event_id] = true
        local guide_event_data = excel_data.EventTriggerData
        local guide_id = guide_event_data[event_id].start_guide_group
        local func_id = guide_event_data[event_id].func_id
        if func_id then
            local func_exldata = excel_data.FuncUnlockData[func_id]
            guide_id = func_exldata.start_guide_group
            self.db.guide_locked_dict[func_id] = nil
            self:on_function_unlocked(func_id)
            self.role:send_client('s_level_event_trigger', {locked_dict = self.db.guide_locked_dict})
        end
        if guide_id then
            local group_id = excel_data.ForceGuideData[guide_id].group_id
            self:add_guide(group_id)
        end
    end
end

-- 等级解锁事件触发
function role_guide:level_trigger_check(new_level)
    local locked_dict = self.db.guide_locked_dict
    local func_unlock_data = excel_data.FuncUnlockData
    for funcId, locked in pairs(locked_dict) do
        local unlock_type = func_unlock_data[funcId].unlock_type
        if ((unlock_type == CSConst.FuncUnlockType.Level or unlock_type == CSConst.FuncUnlockType.VipOrLevel) and new_level >= func_unlock_data[funcId].level) then
            locked_dict[funcId] = nil
            self:on_function_unlocked(funcId)
            self.role:send_client('s_level_event_trigger', {locked_dict = self.db.guide_locked_dict})
            local guide_id = func_unlock_data[funcId].start_guide_group
            if guide_id then
                local group_id = excel_data.ForceGuideData[guide_id].group_id
                self:add_guide(group_id)
            end
        end
    end
end

-- vip等级解锁事件触发
function role_guide:vip_level_trigger_check(id_list)
    local locked_dict = self.db.guide_locked_dict
    local func_unlock_data = excel_data.FuncUnlockData
    local get_change = false
    for _, lock_id in pairs(id_list) do
        if locked_dict[lock_id] then
            get_change = true
            locked_dict[lock_id] = nil
            self:on_function_unlocked(lock_id)
            local guide_id = func_unlock_data[lock_id].start_guide_group
            if guide_id then
                local group_id = excel_data.ForceGuideData[guide_id].group_id
                self:add_guide(group_id)
            end
        end
    end
    if get_change then self.role:send_client('s_level_event_trigger', {locked_dict = self.db.guide_locked_dict}) end
end

-- 检查功能/系统是否已解锁
function role_guide:check_function_is_unlocked(func_id)
    if not func_id then return end
    return not self.db.guide_locked_dict[func_id]
end

-- 功能/系统解锁事件
function role_guide:on_function_unlocked(func_id)
    self.role.title:on_function_unlocked(func_id) -- 教父殿堂
end

return role_guide
