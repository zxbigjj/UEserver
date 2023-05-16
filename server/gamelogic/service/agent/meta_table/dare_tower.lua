local dare_tower = DECLARE_MODULE("meta_table.dare_tower")
local fight_game = require("CSCommon.Fight.Game")
local role_utils = require("role_utils")
local excel_data = require("excel_data")
local drop_utils = require("drop_utils")

function dare_tower.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
        timer = {},
    }
    return setmetatable(self, dare_tower)
end

function dare_tower:init()
    local dare_tower = self.db.dare_tower
    local extra_pass_num = self.role:get_vip_privilege_num(CSConst.VipPrivilege.DareTowerNum)
    dare_tower.pass_num = excel_data.ParamData["dare_tower_daily_plunder_num"].f_value + extra_pass_num
    dare_tower.max_tower = 1
end

function dare_tower:online()
    local dare_tower = self.db.dare_tower
    self.role:send_client("s_update_dare_tower_info",{
        pass_num = dare_tower.pass_num,
        dare_dict = dare_tower.dare_dict,
        max_tower = dare_tower.max_tower,
        treasure_dict = dare_tower.treasure_dict,
    })
end

function dare_tower:daily_tower()
    local dare_tower = self.db.dare_tower
    dare_tower.dare_dict = {}
    local extra_pass_num = self.role:get_vip_privilege_num(CSConst.VipPrivilege.DareTowerNum)
    dare_tower.pass_num = excel_data.ParamData["dare_tower_daily_plunder_num"].f_value + extra_pass_num
    self.role:send_client("s_update_dare_tower_info",{
        dare_dict = dare_tower.dare_dict,
        pass_num = dare_tower.pass_num,
    })
end

function dare_tower:dare(tower_id)
    local tower_config = excel_data.DareTowerData[tower_id]
    if not tower_config then return end
    local dare_tower = self.db.dare_tower
    if dare_tower.dare_dict[tower_id] or dare_tower.max_tower < tower_id  then return end

    if dare_tower.pass_num <= 0 then return end
    -- 战斗
    local own_fight_data = self.role:get_role_fight_data()
    if not own_fight_data then return end
    local fight_data = {
        seed = math.random(1, g_const.Fight_Random_Num),
        victory_id = tower_config.victory_id,
        own_fight_data = own_fight_data,
        enemy_fight_data = role_utils.get_monster_fight_data(tower_config.monster_group_id, tower_config.level)
    }
    local game = fight_game.New(fight_data)
    local is_win = game:GoToFight()
    local item_list = {}
    if is_win then
        if not self.role:change_action_point(tower_config.consume_action_point) then return end
        dare_tower.dare_dict[tower_id] = true
        dare_tower.pass_num = dare_tower.pass_num - 1
        item_list = drop_utils.roll_drop(tower_config.general_reward)
        if tower_config.treasure_chest_reward then
            dare_tower.treasure_dict[tower_id]  = true
        end
        -- 当前塔层是max_tower,则开放max_tower + 1层
        if dare_tower.max_tower == tower_id then
            table.extend(item_list, tower_config.first_reward_list)
            dare_tower.max_tower = tower_id + 1
        end
        -- 行动点奖励
        local level_data = excel_data.LevelData[self.role:get_level()]
        table.insert(item_list, {item_id = CSConst.Virtual.Exp, count = level_data.action_point_to_exp * tower_config.consume_action_point})
        table.insert(item_list, {item_id = CSConst.Virtual.Money, count = level_data.action_point_to_money * tower_config.consume_action_point})
        self.role.fight_reward = {item_list = item_list, reason = g_reason.dare_tower_fight}
        self.role:send_client("s_update_dare_tower_info",{
            dare_dict = dare_tower.dare_dict,
            pass_num = dare_tower.pass_num,
            max_tower = dare_tower.max_tower,
            treasure_dict = dare_tower.treasure_dict,
        })
        self.role:update_daily_active(CSConst.DailyActiveTaskType.DareTowerNum, 1)
    end
    return {
        errcode = g_tips.ok,
        fight_data = fight_data,
        is_win = is_win,
        item_list = item_list,
    }
end

-- 领取宝箱奖励
function dare_tower:receive_treasure_reward(tower_id)
    local tower_config = excel_data.DareTowerData[tower_id]
    if not tower_config or not tower_config.treasure_chest_reward then return end
    local treasure_dict = self.db.dare_tower.treasure_dict
    if not treasure_dict[tower_id] then return end
    local item_list = excel_data.RewardData[tower_config.treasure_chest_reward].item_list
    treasure_dict[tower_id] = nil
    self.role:add_item_list(item_list, g_reason.dare_tower_treasure_chest)
    self.role:send_client("s_update_dare_tower_info",{treasure_dict = treasure_dict})
    return true
end

function dare_tower:vip_level_up_privilege_tower_num(old_level, new_level)
    local old_level_info = excel_data.VipData[old_level]
    local new_level_info = excel_data.VipData[new_level]
    local lock_info = excel_data.VIPPrivilegeData
    local lock_name = lock_info[CSConst.VipPrivilege.DareTowerNum].vip_data_name
    local extra_num = new_level_info[lock_name]
    if old_level > 0 then extra_num = extra_num - old_level_info[lock_name] end
    local dare_tower = self.db.dare_tower
    dare_tower.pass_num = dare_tower.pass_num + extra_num
    self.role:send_client("s_update_dare_tower_info",{
        pass_num = dare_tower.pass_num,
    })
end

return dare_tower