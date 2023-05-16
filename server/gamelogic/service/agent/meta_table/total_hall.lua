local total_hall = DECLARE_MODULE("meta_table.total_hall")
local date = require("sys_utils.date")
local excel_data = require("excel_data")
local drop_utils = require("drop_utils")
local CSFunction = require("CSCommon.CSFunction")

local InfoSelect = {
  one = 1,
  two = 2,
}

function total_hall.new(role)
  local self = {
      role = role,
      uuid = role.uuid,
      db = role.db,
      info_timer = nil,
      cmd_timer = {},
  }
  return setmetatable(self, total_hall)
end

function total_hall:init_hall()
  local level_config = excel_data.LevelData[self.role:get_level()]
  self.db.info.num = level_config.info_max_count
  self.db.info.last_time = date.time_second()

  for i, num in ipairs(level_config.cmd_max_count) do
    self.db.cmd_list[i] = { num = num , last_time = date.time_second()}
  end
end

function total_hall:load_hall()
  self:info_reset()
end

function total_hall:online_total_hall()
  local db_info = self.db.info
  local db_cmd_list = self.db.cmd_list
  local level_data = excel_data.LevelData[self.role:get_level()]
  -- 上线后，检查info，cmd的数量是否达到最大值，没有则启动计算离线时间累计可增加多少.
  if db_info.num < level_data.info_max_count then
    local add_number = (date.time_second() - db_info.last_time) / level_data.info_cooldown
    local total_number = math.floor(add_number) + db_info.num
    if total_number < level_data.info_max_count then
      db_info.num = total_number
      db_info.last_time =  db_info.last_time + level_data.info_cooldown * math.floor(add_number)
      local info_delay_time = level_data.info_cooldown * (1 - math.fmod(add_number, 1))
      self:info_timer_loop(info_delay_time)
    else
      db_info.num = level_data.info_max_count
      db_info.last_time = date.time_second()
    end
  end

  for i, cmd in ipairs(db_cmd_list) do
    if cmd.num < level_data.cmd_max_count[i] then
      local cmd_cooldown = CSFunction.get_cmd_cooldown(self.role:get_score())
      local add_number = (date.time_second() - cmd.last_time) / cmd_cooldown
      local total_number = math.floor(add_number) + db_cmd_list[i].num
      if total_number < level_data.cmd_max_count[i] then
        db_cmd_list[i].num = total_number
        db_cmd_list[i].last_time = db_cmd_list[i].last_time + cmd_cooldown * math.floor(add_number)
        local cmd_delay_time = cmd_cooldown * (1 - math.fmod(add_number, 1))
        self:cmd_timer_loop(i, cmd_delay_time)
      else
        db_cmd_list[i].num = level_data.cmd_max_count[i]
        db_cmd_list[i].last_time = date.time_second()
      end
    end
  end
  self.role:send_client("s_update_total_hall_info",{ info = db_info, cmd_dict = db_cmd_list})
end

-- 处理情报，id为1时为掉落奖励，2时为经验奖励，选项只有1和2
function total_hall:handle_info(id)
  local info = self.db.info
  if info.num <= 0 or not info.info_id then return end
  if id ~= InfoSelect.one and id ~= InfoSelect.two then return end
  local reason = g_reason.handle_info
  if id == InfoSelect.one then
    self.role:add_item(info.item_id, info.count, reason)
  elseif id == InfoSelect.two then
    local count = excel_data.LevelData[self.role:get_level()].info_exp
    self.role:add_item(CSConst.Virtual.Exp, count, reason)
  end
  self.db.info = {
    num = info.num - 1,
    last_time = info.last_time,
  }
  self:info_refresh()
  self.role:update_achievement(CSConst.AchievementType.HandleInfo, 1)
  self.role:update_daily_active(CSConst.DailyActiveTaskType.HandleInfoNum, 1)
  self.role:update_task(CSConst.TaskType.Info, {progress = 1})
  return true
end

-- 情报刷新，首先重置其item_id,info_id和数量等信息
function total_hall:info_refresh()
  if not self.db.info.info_id then
    self:info_reset()
  end
  local db_info = self.db.info

  local level_data = excel_data.LevelData[self.role:get_level()]
  if not self.info_timer and db_info.num < level_data.info_max_count then
    db_info.last_time = date.time_second()
    self:info_timer_loop(level_data.info_cooldown)
  end
  self.role:send_client("s_update_total_hall_info",{ info = db_info })
end

-- 情报重置
function total_hall:info_reset()
  local level_data = excel_data.LevelData[self.role:get_level()]
  local info = {
    num = self.db.info.num or level_data.info_max_count,
    last_time = self.db.info.last_time or date.time_second(),
    info_id = math.random(1, #excel_data.InfoData)
  }
  local info_config = excel_data.InfoData[info.info_id]
  local reward_id = info_config.reward_type[math.random(1, #info_config.reward_type)]
  local info_reward_config = excel_data.InfoRewardData[reward_id]
  if info_reward_config.item_id then
    info.item_id = info_reward_config.item_id
    if info_reward_config.attr_name and info_reward_config.reward_float_ratio_limit then
      local ratio_limit = info_reward_config.reward_float_ratio_limit
      local attr_value = self.role:get_attr_value(info_reward_config.attr_name)
      local min_value = math.floor(attr_value * ratio_limit[1])
      local max_value = math.floor(attr_value * ratio_limit[2])
      info.count = info_reward_config.base_value + math.random(min_value, max_value)
    else
      info.count = excel_data.LevelData[self.role:get_level()].info_exp
    end
  elseif info_reward_config.drop_id then
    local item_list = drop_utils.roll_drop(info_reward_config.drop_id)
    info.item_id = item_list[1].item_id
    info.count = item_list[1].count
  end
  self.db.info = info
end

-- 情报定时器，间隔为level_data.info_cooldown
function total_hall:info_timer_loop(delay_seconds)
  if self.info_timer then
    self.info_timer:cancel()
    self.info_timer = nil
  end
  local level_data = excel_data.LevelData[self.role:get_level()]
  self.info_timer = self.role:timer_loop(level_data.info_cooldown, function()
    self:info_num_restore()
  end, delay_seconds)
end

function total_hall:info_num_restore()
  local db_info =  self.db.info
  local level_data = excel_data.LevelData[self.role:get_level()]
  if db_info.num < level_data.info_max_count then
    db_info.num = db_info.num + 1
    db_info.last_time = date.time_second()
    self.role:send_client("s_update_total_hall_info",{ info = {last_time = db_info.last_time, num = db_info.num }})
  end
  if db_info.num >= level_data.info_max_count then
    self.info_timer:cancel()
    self.info_timer = nil
  end
end

-- 发布命令
function total_hall:publish_cmd(id)
  local cmd = self.db.cmd_list[id]
  if not cmd then return end
  if cmd.num <= 0 then return end
  local levy_config = excel_data.LevyData[id]
  if not levy_config then return end
  local item_id = levy_config.levy_item_id
  local count = levy_config.trans_ratio * self.role:get_attr_value(levy_config.influence_attribute)
  count = math.floor(count)
  count = count < 1 and 1 or count
  local reason = g_reason.publish_cmd
  if levy_config.cast_item_id then
    if not self.role:consume_item(levy_config.cast_item_id, count, reason) then return end
  end
  cmd.num = cmd.num - 1
  self.role:add_item(item_id, count, reason)
  self:cmd_refresh(id)
  self.role:update_achievement(CSConst.AchievementType.PublishCmd, 1)
  self.role:update_task(CSConst.TaskType.Cmd, {progress = 1})
  if id == CSConst.CmdType.Money then
    self.role:update_task(CSConst.TaskType.MoneyCmd, {progress = 1})
  elseif id == CSConst.CmdType.Food then
    self.role:update_task(CSConst.TaskType.FoodCmd, {progress = 1})
  elseif id == CSConst.CmdType.Soldier then
    self.role:update_task(CSConst.TaskType.SoldierCmd, {progress = 1})
  end
  self.role:update_daily_active(CSConst.DailyActiveTaskType.PublishCmdConscriptNum, 1, id)
  self.role:update_daily_active(CSConst.DailyActiveTaskType.PublishCmdFoodNum, 1, id)
  self.role:update_daily_active(CSConst.DailyActiveTaskType.PublishCmdMoneyNum, 1, id)
  return true
end

-- 命令刷新
function total_hall:cmd_refresh(id)
  local db_cmd = self.db.cmd_list[id]
  if not db_cmd then return end
  local level_data = excel_data.LevelData[self.role:get_level()]
  if not self.cmd_timer[id] and db_cmd.num < level_data.cmd_max_count[id] then
    db_cmd.last_time = date.time_second()
    local cmd_cooldown = CSFunction.get_cmd_cooldown(self.role:get_score())
    self:cmd_timer_loop(id, cmd_cooldown)
  end
  self.role:send_client("s_update_total_hall_info",{ cmd_dict = { [id] = db_cmd }})
end

function total_hall:cmd_timer_loop(id, delay_seconds)
  -- 启动定时器，间隔为cmd_cooldown
  if self.cmd_timer[id] then
    self.cmd_timer[id]:cancel()
    self.cmd_timer[id] = nil
  end
  local cmd_cooldown = CSFunction.get_cmd_cooldown(self.role:get_score())
  self.cmd_timer[id] = self.role:timer_loop(cmd_cooldown, function ()
    self:cmd_num_restore(id)
  end, delay_seconds)
end

function total_hall:cmd_num_restore(id)
  local db_cmd = self.db.cmd_list[id]
  local level_data = excel_data.LevelData[self.role:get_level()]
  if not db_cmd then return end
  if db_cmd.num < level_data.cmd_max_count[id] then
    db_cmd.num = db_cmd.num + 1
    db_cmd.last_time = date.time_second()
    self.role:send_client("s_update_total_hall_info",{ cmd_dict = { [id] = db_cmd }})
  end
  if db_cmd.num >= level_data.cmd_max_count[id] then
    self.cmd_timer[id]:cancel()
    self.cmd_timer[id] = nil
  end
end

-- 使用相应的物品增加次数
function total_hall:add_number(item_id, cmd_id, count)
  local level_data = excel_data.LevelData[self.role:get_level()]
  if item_id == excel_data.ParamData["hall_info_item"].item_id then
    local info = self.db.info
    local reason = g_reason.handle_info
    if not self.role:consume_item(item_id, count, reason) then return end
    info.num = info.num + count
    if self.info_timer and info.num >= level_data.info_max_count then
      self.info_timer:cancel()
      self.info_timer = nil
    end
    self.role:send_client("s_update_total_hall_info",{ info = { num = info.num  } })
    return true
  elseif item_id == excel_data.ParamData["hall_cmd_item"].item_id and cmd_id then
    local cmd = self.db.cmd_list[cmd_id]
    if not cmd then return end
    local reason = g_reason.publish_cmd
    if not self.role:consume_item(item_id, count, reason) then return end
    cmd.num = cmd.num + count
    if self.cmd_timer[cmd_id] and cmd.num >= level_data.cmd_max_count[cmd_id] then
      self.cmd_timer[cmd_id]:cancel()
      self.cmd_timer[cmd_id] = nil
    end
    self.role:send_client("s_update_total_hall_info",{ cmd_dict = {[cmd_id] = { num = cmd.num } }})
    return true
  end
end

-- 一键征收
function total_hall:publish_all_cmd()
  local cmd = self.db.cmd_list
  local levy_config = excel_data.LevyData
  local reason = g_reason.publish_cmd
  local cmd_dict = {}
  for cmd_id, data in ipairs(levy_config) do
    for i = cmd[cmd_id].num, 1, -1 do
      if self:publish_cmd(cmd_id) then
        cmd_dict[cmd_id] = (cmd_dict[cmd_id] or 0) + 1
      else
        break
      end
    end
  end
  return {errcode = g_tips.ok, cmd_dict = cmd_dict}
end

return total_hall