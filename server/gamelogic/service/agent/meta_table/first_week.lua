local first_week = DECLARE_MODULE("meta_table.first_week")
local date = require("sys_utils.date")
local excel_data = require("excel_data")

local TaskMapper = {
    [CSConst.FirstWeekTaskType.LoginNum] = "login_num_task",            --登陆
    [CSConst.FirstWeekTaskType.HeroAttrScoreNum] = "count_task",        --帮力达到
    [CSConst.FirstWeekTaskType.PassCityNum] = "pass_stage",            --通关关卡数
    [CSConst.FirstWeekTaskType.EquipStrengthLevel] = "count_task",      --玩家装备强化等级
    [CSConst.FirstWeekTaskType.EquipRefineLevel] = "count_task",        --玩家装备精炼等级
    [CSConst.FirstWeekTaskType.TreasureStrengthNum] = "count_task",     --玩家宝物强化
    [CSConst.FirstWeekTaskType.TreasureRefineLevel] = "count_task",     --玩家宝物精炼
    [CSConst.FirstWeekTaskType.GrabNum] = "add_type_task",              --夺宝次数
    [CSConst.FirstWeekTaskType.TrainStarNum] = "add_type_task",         --试炼累计获得星数
    [CSConst.FirstWeekTaskType.ArenaNum] = "add_type_task",             --竞技场次数
    [CSConst.FirstWeekTaskType.DailyDareNum] = "add_type_task",         --日常挑战次数
    [CSConst.FirstWeekTaskType.DoteLoverNum] = "add_type_task",         --情人约会次数
    [CSConst.FirstWeekTaskType.ChildrenNum] = "add_type_task",          --子女数量
    [CSConst.FirstWeekTaskType.RandomDoteLoverNum] = "add_type_task",   --随机宠爱情人次数
    [CSConst.FirstWeekTaskType.PlayerLevel] = "count_task",             --玩家等级达到
    [CSConst.FirstWeekTaskType.FightScoreNum] = "count_task",           --战力达到
    [CSConst.FirstWeekTaskType.DestinyLevel] = "count_task",            --天命最高到达
    [CSConst.FirstWeekTaskType.TraitorDamage] = "count_task",           --叛军最高伤害
    [CSConst.FirstWeekTaskType.TraitorFeats] = "count_task",            --叛军累计最高功勋
    [CSConst.FirstWeekTaskType.JoinDynasty] = "count_task",             --进入或创建王朝
    [CSConst.FirstWeekTaskType.DynastyBuild] = "add_type_task",         --王朝高级建设
    [CSConst.FirstWeekTaskType.DynastyChallenge] = "add_type_task",     --王朝挑战次数
    [CSConst.FirstWeekTaskType.HuntRareAnimal] = "add_type_task",       --狩猎猛兽
    [CSConst.FirstWeekTaskType.PassHuntStage] = "add_type_task",        --通关狩猎场
    [CSConst.FirstWeekTaskType.LoverTrain] = "add_type_task",           --情人培训事件
    [CSConst.FirstWeekTaskType.TravelNum] = "add_type_task",            --出行次数
    [CSConst.FirstWeekTaskType.ChildMarry] = "add_type_task",           --儿女联姻
    [CSConst.FirstWeekTaskType.LoverGrade] = "count_task",              --情人妃位达到
}

local max_open_day = 7

function first_week.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
        is_open = true,
        is_can_recive = true,
    }
    return setmetatable(self, first_week)
end

function first_week:init()
    local task_data = excel_data.FirstWeekData
    local task_info = self.db.first_week.task_info
    local recive_info = self.db.first_week.recive_info
    local half_sell = self.db.first_week.half_sell
    local daily_sell = self.db.first_week.daily_sell
    local task_type_info = excel_data.FirstWeekTaskData

    for day_index, task_value in ipairs(task_data) do
        for _, task_id in ipairs(task_value.task_id_list) do
            local task_type = task_type_info[task_id].task_type
            task_info[task_type] = 0
            recive_info[task_id] = false
        end

        half_sell[day_index] = false

        local sell = {}
        for k, id in ipairs(task_value.sell_item) do
            sell[id] = 0
        end
        daily_sell[day_index] = sell
    end
end

function first_week:get_day()
    local index_time = date.get_day_time(nil, 0) - date.get_day_time(self.db.create_ts, 0)
    -- 四舍五入时间戳
    local day = math.floor(index_time / CSConst.Time.Day + 0.5) + 1
    if day <= CSConst.DaysInWeek then return day end
    return CSConst.DaysInWeek
end

function first_week:online()
    self:update_state()
    if self.is_can_recive == false then return end
    self:send_msg()
end

function first_week:daily()
    self:update_state()
    if not self.is_open then return end
    self:update_first_week_task(CSConst.FirstWeekTaskType.LoginNum, nil)
    self:send_msg()
end

function first_week:update_state()
    local diff_time = date.time_second() - self.db.create_ts
    local max_recive_day = excel_data.ParamData["max_recive_day"].f_value
    self.is_open = true
    self.is_can_recive = true
    if diff_time > CSConst.Time.Day * max_recive_day then
        self.is_open = false
        self.is_can_recive = false
        return
    end
    if diff_time > CSConst.Time.Day * max_open_day then
        self.is_open = false
        self.is_can_recive = true
    end
end

-- 更新日常活跃任务进度
function first_week:update_first_week_task(task_type, progress)
    if not self.is_open then return end
    self:update_state()
    if not self.is_open then return end
    if not task_type or not TaskMapper[task_type] then return end
    local task_info = self.db.first_week.task_info
    if task_info[task_type] == nil then return end

    local func = TaskMapper[task_type]
    if func then
        self[func](self, task_type, progress)
    end
    local task_progress = task_info[task_type]
    self.role:send_client("s_update_first_week_task", {task_type = task_type, progress = task_progress})
end
-- 计数型任务更新
function first_week:count_task(task_type, progress)
    if not self.is_open then return end
    local task_info = self.db.first_week.task_info
    progress = math.floor(progress)
    if task_info[task_type] < progress then
        task_info[task_type] = progress
    end
end
-- 累加型任务更新
function first_week:add_type_task(task_type, progress)
    if not self.is_open then return end
    local task_info = self.db.first_week.task_info
    task_info[task_type] = task_info[task_type] + progress
end
-- 通关城市数
function first_week:pass_stage(task_type, progress)
    if not self.is_open then return end
    local task_info = self.db.first_week.task_info
    local pass_city_num = excel_data.StageData[progress].city_id - 1
    if task_info[task_type] < pass_city_num then
        task_info[task_type] = pass_city_num
    end
end
-- 累登任务更新
function first_week:login_num_task(task_type, progress)
    if not self.is_open then return end
    local task_info = self.db.first_week.task_info
    if self.db.logout_ts == 0 then
        task_info[task_type] = task_info[task_type] + 1
        return
    end

    local last_online_time = os.date("*t", self.db.logout_ts)
    local now_time = os.date("*t", date.time_second())
    if last_online_time.year ~= now_time.year or last_online_time.month ~= now_time.month or last_online_time.day ~= now_time.day then
        task_info[task_type] = task_info[task_type] + 1
    end
end
-- 领取任务奖励
function first_week:recive_task_reward(task_id)
    if self.is_can_recive ~= true then return end
    self:update_state()
    if self.is_can_recive ~= true then return end
    if not task_id then return end
    local task_info = self.db.first_week.task_info
    local recive_info = self.db.first_week.recive_info
    local task_type = excel_data.FirstWeekTaskData[task_id].task_type
    if task_info[task_type] == nil or recive_info[task_id] == true then return end
    local task = excel_data.FirstWeekTaskData[task_id]
    if not task then return end
    if task.require_count > task_info[task.task_type] then return end

    local reason = g_reason.first_week_task_reward
    local reward_info = {}
    recive_info[task_id] = true
    for k, v in ipairs(task.reward_id) do
        table.insert(reward_info, {item_id = task.reward_id[k], count = task.reward_count[k]})
    end
    self.role:add_item_list(reward_info, reason)
    self:send_msg()
    return true
end
-- 购买半价限购
function first_week:buy_half_sell(day_index)
    if self.is_can_recive ~= true then return end
    self:update_state()
    if self.is_can_recive ~= true then return end
    if not day_index or day_index > self:get_day() then return end
    local half_sell = self.db.first_week.half_sell
    if half_sell[day_index] == true then return end
    local half_sell_info = excel_data.FirstWeekData[day_index]

    local reason = g_reason.first_week_half_sell
    half_sell[day_index] = true
    if self.role:consume_item(half_sell_info.consume_item_id, half_sell_info.consume_item_count, reason) then
        self.role:add_item(half_sell_info.item_id, half_sell_info.item_count, reason)
    end
    self:send_msg()
    return true
end
-- 购买每日热卖
function first_week:buy_sell_item(day_index, sell_index, buy_num)
    if self.is_can_recive ~= true then return end
    self:update_state()
    if self.is_can_recive ~= true then return end
    if not day_index or day_index > self:get_day() then return end
    if not buy_num or buy_num < 1 then return end
    local daily_sell = self.db.first_week.daily_sell[day_index]
    if not daily_sell then return end
    local sell_item_id = sell_index
    local sell_data = excel_data.FirstWeekSellData[sell_item_id]
    if not daily_sell[sell_index] then return end

    if daily_sell[sell_index] >= sell_data.sell_limit_num then return end
    local reason = g_reason.first_week_sell_item
    local new_num = daily_sell[sell_index] + buy_num
    if new_num > sell_data.sell_limit_num then return end
    daily_sell[sell_index] = new_num
    if self.role:consume_item(sell_data.consume_item_id, sell_data.consume_item_count * buy_num, reason) then
        self.role:add_item(sell_data.sell_item_id, sell_data.sell_item_count * buy_num, reason)
    end
    self:send_msg()
    return true
end

function first_week:send_msg()
    local daily_sell_info = {}
    local daily_sell = self.db.first_week.daily_sell
    local today = self:get_day()
    for k, v in ipairs(daily_sell) do
        if k > today then break end
        daily_sell_info[k] = {}
        daily_sell_info[k].sell_info = {}
        for sell_index, sell_num in pairs(v) do
            daily_sell_info[k].sell_info[sell_index] = sell_num
        end
    end

    local msg = {}
    msg.start_time = self.db.create_ts
    msg.task_dict = self.db.first_week.task_info
    msg.recive_dict = self.db.first_week.recive_info
    msg.half_sell = self.db.first_week.half_sell
    msg.daily_sell = daily_sell_info
    self.role:send_client("s_update_first_week_info", msg)
end

return first_week