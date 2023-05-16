local daily_dare = DECLARE_MODULE("meta_table.daily_dare")
local date = require("sys_utils.date")
local fight_game = require("CSCommon.Fight.Game")
local role_utils = require("role_utils")
local excel_data = require("excel_data")

function daily_dare.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
    }
    return setmetatable(self, daily_dare)
end

function daily_dare:get_week_day(ts)
    ts = ts or date.time_second()
    local day = date.get_week_day(ts)
    if day == "0" then
        day = "7"
    end
    return day
end

function daily_dare:online_dare()
    self.role:send_client("s_update_daily_dare_info",{dare_list = self:build_dare_list()})
end

function daily_dare:daily_refresh()
    local daily_dare_dict = self.db.daily_dare_dict
    for dare_id, info in pairs(daily_dare_dict) do
        daily_dare_dict[dare_id].is_passing = false
    end
    self.role:send_client("s_update_daily_dare_info",{dare_list = self:build_dare_list()})
end

-- 根据当天是周几构建dare_list, 发送给客户端用
function daily_dare:build_dare_list()
    local dare_list = {}
    local day = self:get_week_day()
    local dare_dict = excel_data.DailyDareData.open_date_dict[day]
    local daily_dare_dict = self.db.daily_dare_dict
    for dare_id, info in pairs(dare_dict) do
        if daily_dare_dict[dare_id] then
            local dare_info = {
                dare_id = dare_id,
                difficult_list = {},
                is_passing = daily_dare_dict[dare_id].is_passing
            }
            for difficult_id, v in pairs(daily_dare_dict[dare_id].difficult_dict) do
                table.insert(dare_info.difficult_list, difficult_id)
            end
            table.insert(dare_list, dare_info)
        end
    end
    return dare_list
end

-- 升级解锁
function daily_dare:unlock_lvl()
    local role_level = self.role:get_level()
    local daily_dare_dict = self.db.daily_dare_dict
    local flag = nil
    for dare_id, value in pairs(excel_data.DailyDareData) do
        if type(dare_id) == "number" then
            local dare_config = value
            if dare_config.open_level <= role_level then
                if not daily_dare_dict[dare_id] then
                    flag = true
                    daily_dare_dict[dare_id] = {
                        dare_id = dare_id,
                        difficult_dict = {},
                        is_passing = false,
                    }
                end
            end
            for difficult_id, config in pairs(dare_config.difficult_dict) do
                if config.open_level <= role_level then
                    flag = true
                    daily_dare_dict[dare_id].difficult_dict[difficult_id] = CSConst.DailyDareStatus.Unlocked
                end
            end
        end
    end
    if flag then
        self.role:send_client("s_update_daily_dare_info",{dare_list = self:build_dare_list()})
    end
end

-- 挑战，参数：挑战id，难度id， 每个挑战当天只能挑战一次。
function daily_dare:dare(dare_id, difficult_id)
    local day = self:get_week_day()
    local open_dict = excel_data.DailyDareData.open_date_dict[day]
    if not open_dict[dare_id] then return end
    local dare_config = excel_data.DailyDareData[dare_id]
    if not dare_config then return end
    local difficult_config = dare_config.difficult_dict[difficult_id]
    if not difficult_config then return end

    local dare_db = self.db.daily_dare_dict[dare_id]
    if dare_db.difficult_dict[difficult_id] ~= CSConst.DailyDareStatus.Unlocked then return end
    if dare_db.is_passing then return end

    local own_fight_data = self.role:get_role_fight_data()
    if not own_fight_data then return end
    -- 战斗
    local fight_data = {
        seed = math.random(1, g_const.Fight_Random_Num),
        victory_id = difficult_config.victory_id,
        own_fight_data = own_fight_data,
        enemy_fight_data = role_utils.get_monster_fight_data(dare_config.monster_group_id, difficult_config.monster_level)
    }
    local game = fight_game.New(fight_data)
    local is_win = game:GoToFight()
    -- 挑战胜利给与奖励，失败不扣任何
    if is_win then
        if not self.role:change_action_point(dare_config.strength_comsume) then return end
        dare_db.is_passing = true
        local item_list = {{item_id = dare_config.drop_item, count = difficult_config.drop_item_count}}
        self.role.fight_reward = {item_list = item_list, reason = g_reason.daily_dare_passing}
        self.role:send_client("s_update_daily_dare_info",{ dare_list = self:build_dare_list()})
        self.role:update_daily_active(CSConst.DailyActiveTaskType.DailyDareNum, 1)
    end
    self.role.first_week:update_first_week_task(CSConst.FirstWeekTaskType.DailyDareNum, 1)
    self.role:update_task(CSConst.TaskType.DailyDare, {progress = 1})

    return {
        errcode = g_tips.ok,
        fight_data = fight_data,
        is_win = is_win,
    }
end

return daily_dare