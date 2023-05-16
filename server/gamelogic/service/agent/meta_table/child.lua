local role_child = DECLARE_MODULE("meta_table.child")
local date = require("sys_utils.date")
local excel_data = require("excel_data")
local cluster_utils = require("msg_utils.cluster_utils")
local offline_cmd = require("offline_cmd")
local json = require("json")

function role_child.new(role)
  local self = {
      role = role,
      uuid = role.uuid,
      db = role.db,
      timer = {},
  }
  return setmetatable(self, role_child)
end

function role_child:init_child()
  self.db.child_grid_num = excel_data.ParamData["child_grid_num"].f_value
  self.db.child = {}
  self.db.propose_object_list = {}
  self.db.is_first_child = true
end

-- 儿女属性上线计算
function role_child:load_child()
  local attr_dict = {}
  local child_dict = self.db.child
  for child_id, child in pairs(child_dict) do
    if child.child_status == CSConst.ChildStatus.Adult or child.child_status == CSConst.ChildStatus.Married then
      table.dict_attr_add(attr_dict, child.attr_dict)
      if child.child_status == CSConst.ChildStatus.Married then
        table.dict_attr_add(attr_dict, child.marry.attr_dict)
      end
    end
  end
  self.role:modify_attr(nil, attr_dict)
end

function role_child:online_child()
  local child_dict = self.db.child
  for child_id, child in pairs(child_dict) do
    local quality_config = excel_data.ChildQualityData[child.grade]
    local exp_config =  excel_data.ChildExpData[child.level]
    local extra_num = self.role:get_vip_privilege_num(CSConst.VipPrivilege.ChildMaxVitalityNum)
    -- 未成年儿女，根据离线时间恢复活力
    if (child.child_status == CSConst.ChildStatus.Baby
      or child.child_status == CSConst.ChildStatus.Growing)
       and (child.vitality_num < exp_config.vitality_limit + extra_num) then
      local add_number = (date.time_second() - child.last_time) / exp_config.cooldown
      local total_number = math.floor(add_number) + child.vitality_num
      if total_number < exp_config.vitality_limit + extra_num then
        child_dict[child_id].vitality_num = total_number
        child_dict[child_id].last_time =  child_dict[child_id].last_time + exp_config.cooldown * math.floor(add_number)
        local delay_time = exp_config.cooldown * (1 - math.fmod(add_number, 1))
        self:timer_loop(child_id, delay_time)
      else
        child_dict[child_id].vitality_num = exp_config.vitality_limit + extra_num
        child_dict[child_id].last_time = date.time_second()
      end
    -- 已成年儿女，存在提亲的相关数据，根据离线时间计算是否取消提亲请求
    elseif child.child_status == CSConst.ChildStatus.Adult and child.apply_time then
      local request_time = excel_data.ParamData["child_request_timer"].f_value
      if date.time_second() < child.apply_time + request_time then
        self:request_timer(child_id, request_time - (date.time_second() - child.apply_time))
      else
        self:driving_cancel_request(child_id)
      end
    end
  end
  self.role:send_client("s_update_child_info",{child = child_dict, grid_num = self.db.child_grid_num, propose_object_list = self.db.propose_object_list})
end

-- 新建
function role_child:new_child(type_id, mother_id)
  local child_dict = self.db.child
  local lover = self.role:get_lover(mother_id)
  if not lover then return end
  -- 判断未封爵的孩子是否达到格子数上限
  local child_num = 0
  for child_id, child in pairs(child_dict) do
    if child.child_status ~= CSConst.ChildStatus.Adult and child.child_status ~= CSConst.ChildStatus.Married then
      child_num = child_num + 1
    end
  end
  if child_num >= self.db.child_grid_num then return end
  if self.db.is_first_child then
    self.db.is_first_child = nil
  else
    local rand = math.random()
    local lover_level_config = excel_data.LoverLevelData[lover.level]
    local extra_prob = self.role:get_vip_privilege_num(CSConst.VipPrivilege.GetChildPre)
    if rand > lover_level_config.probability[type_id] + extra_prob then return end
  end
  return self:add_child(mother_id)
end

-- 新建一个儿女
function role_child:add_child(mother_id)
  local child_dict = self.db.child
  local lover = self.role:get_lover(mother_id)
  if not lover then return end
  local lover_level_config = excel_data.LoverLevelData[lover.level]
  local quality_index = math.roll(lover_level_config.quality_probability)
  local child = {
    birth_time = date.time_second(),
    child_id = #child_dict + 1,
    mother_id = mother_id,
    level = 0,
    exp = 0,
    sex = math.random(CSConst.Sex.Man, CSConst.Sex.Woman),
    grade = lover_level_config.child_quality[quality_index],
    child_status = CSConst.ChildStatus.New,
    display_id = self:get_display_id(mother_id)
  }
  child_dict[child.child_id] = child
  self.role:send_client("s_update_child_info",{child = {[child.child_id] = child}})
  self.role:update_task(CSConst.TaskType.ChildNum)
  -- 检查是否为第一次生孩子，如果是则触发对应事件
  self.role:guide_event_trigger_check(CSConst.GuideEventTriggerType.GetFirstChild)
  self.role:update_first_week_task(CSConst.FirstWeekTaskType.ChildrenNum, 1)
  self.role:update_achievement(CSConst.AchievementType.ChildNum, 1)
  return child
end

-- 获取孩子肤色
function role_child:get_display_id(mother_id)
  local skin_id
  local id = math.random(CSConst.Sex.Man, CSConst.Sex.Woman)
  if id == CSConst.Sex.Man then
    local role_id = self.role:get_role_id()
    skin_id = excel_data.RoleLookData[role_id].skin_id
  else
    skin_id = excel_data.LoverData[mother_id].skin_id
  end
  local data = excel_data.SkinData[skin_id]
  local index = math.random(1, #data.child_role_list)
  return data.child_role_list[index]
end

-- 命名，给予资质
function role_child:child_give_name(child_id, name)
  if not IsStringBroken(name) then return end
  local child = self.db.child[child_id]
  if not child or child.child_status ~= CSConst.ChildStatus.New then return end
  if string.len(name) > CSConst.NameLenLimit then return end
  local quality_config = excel_data.ChildQualityData[child.grade]
  local aptitude_list = quality_config.aptitude_list
  local aptitude_value =  quality_config.child_aptitude
  for index, name in ipairs(aptitude_list) do
    child.aptitude_dict[name] = quality_config.base_aptitude
    aptitude_value = aptitude_value - quality_config.base_aptitude
  end

  local ChildAptitudeDripData = excel_data.ChildAptitudeDripData
  local index = math.random(1, #ChildAptitudeDripData)
  local drip_list = ChildAptitudeDripData[index].weight_list
  for i = 1, aptitude_value do
    local j = math.roll(drip_list)
    child.aptitude_dict[aptitude_list[j]] = child.aptitude_dict[aptitude_list[j]] + 1
  end
  child.name = name
  child.vitality_num = 0
  child.child_status = CSConst.ChildStatus.Baby
  self:timer_start(child_id)
  self.role:send_client("s_update_child_info",{child = {[child_id] = child}})
  return true
end

-- 教育
function role_child:child_education(child_id)
  local child = self.db.child[child_id]
  if not child or not child.vitality_num
    or child.child_status == CSConst.ChildStatus.New
      or child.child_status == CSConst.ChildStatus.Adult then return end
  if child.vitality_num <= 0 then return end
  local quality_config = excel_data.ChildQualityData[child.grade]
  local child_lvl_config = excel_data.ChildExpData[child.level]
  if child.level >= quality_config.level_limit then return end

  child.vitality_num = child.vitality_num - 1
  self:timer_start(child_id)

  child.exp = child.exp + 1
  -- 教育增加一项属性值
  local name = quality_config.aptitude_list[math.random(1, #quality_config.aptitude_list)]
  child.attr_dict[name] = (child.attr_dict[name] or 0) + quality_config.education_attr
  if child.exp >= child_lvl_config.exp then
    self:child_lvl_up(child_id)
  end
  self.role:send_client("s_update_child_info",{child = {[child_id] = child}})
  self.role:update_daily_active(CSConst.DailyActiveTaskType.TeachChildrenNum, 1)
  self.role:update_task(CSConst.TaskType.ChildTeach, {progress = 1})
  self.role:update_festival_activity_data(CSConst.FestivalActivityType.educate) -- 节日活动教育儿女
  return true
end

-- 升级
function role_child:child_lvl_up(child_id)
  local child = self.db.child[child_id]
  local child_lvl_config = excel_data.ChildExpData[child.level]
  local quality_config = excel_data.ChildQualityData[child.grade]
  child.exp = child.exp - child_lvl_config.exp
  child.level = child.level + 1
  local extra_num = self.role:get_vip_privilege_num(CSConst.VipPrivilege.ChildMaxVitalityNum)
  --抓周，活力达到满值，并且赋予属性
  if child.level == 1 and child.child_status == CSConst.ChildStatus.Baby then
    child_lvl_config = excel_data.ChildExpData[child.level]
    child.child_status = CSConst.ChildStatus.Growing
    child.vitality_num = child_lvl_config.vitality_limit + extra_num
    local scale = excel_data.ParamData["child_aptitude_to_attr"].f_value
    local base_attr = excel_data.ParamData["child_base_attr"].f_value
    for name, value in pairs(child.aptitude_dict) do
      child.attr_dict[name] = base_attr + value * scale
    end
  else
    -- 升级增加所有属性.
    local scale = excel_data.ParamData["child_lvlup_to_attr"].f_value
    for name, value in pairs(child.aptitude_dict) do
      child.attr_dict[name] = child.attr_dict[name] + ((value / scale) * child.level)
    end
  end
end

-- 册封
function role_child:child_canonized(child_id)
  local child = self.db.child[child_id]
  if not child then return end
  local quality_config = excel_data.ChildQualityData[child.grade]
  if not quality_config then return end
  if child.level < quality_config.level_limit or child.child_status ~= CSConst.ChildStatus.Growing then return end
  child.child_status = CSConst.ChildStatus.Adult
  self.role:modify_attr(nil, child.attr_dict, true)
  self.role:send_client("s_update_child_info",{child = {[child_id] = child}})
  -- 第一个儿女长大成人
  self.role:guide_event_trigger_check(CSConst.GuideEventTriggerType.GetFirstAdultChild)
  return true
end

function role_child:timer_start(child_id)
  local child = self.db.child[child_id]
  if not child then return end
  local child_lvl_config = excel_data.ChildExpData[child.level]
  local quality_config = excel_data.ChildQualityData[child.grade]
  local extra_num = self.role:get_vip_privilege_num(CSConst.VipPrivilege.ChildMaxVitalityNum)

  if not self.timer[child_id] and child.level < quality_config.level_limit
    and child.vitality_num < child_lvl_config.vitality_limit + extra_num then
    child.last_time = date.time_second()
    self:timer_loop(child_id, child_lvl_config.cooldown)
  end
end

function role_child:timer_loop(child_id, delay_seconds)
  if self.timer[child_id] then
    self.timer[child_id]:cancel()
    self.timer[child_id] = nil
  end
  local child = self.db.child[child_id]
  if not child then return end
  local child_lvl_config = excel_data.ChildExpData[child.level]
  self.timer[child_id] = self.role:timer_loop(child_lvl_config.cooldown, function()
    self:vitality_num_restore(child_id)
  end, delay_seconds)
end

function role_child:vitality_num_restore(child_id)
  local child = self.db.child[child_id]
  if not child then return end
  local child_lvl_config = excel_data.ChildExpData[child.level]
  local quality_config = excel_data.ChildQualityData[child.grade]
  local extra_num = self.role:get_vip_privilege_num(CSConst.VipPrivilege.ChildMaxVitalityNum)
  if child.level < quality_config.level_limit and
  child.vitality_num < child_lvl_config.vitality_limit + extra_num then
    child.vitality_num = child.vitality_num + 1
    child.last_time = date.time_second()
    self.role:send_client("s_update_child_info",{child = {[child_id] = child}})
  end
  if child.vitality_num >= child_lvl_config.vitality_limit + extra_num
    or child.level >= quality_config.level_limit then
    self.timer[child_id]:cancel()
    self.timer[child_id] = nil
  end
end

-- 格子解锁
function role_child:child_grid_unlock()
  local grid_num = self.db.child_grid_num + 1
  local grid_config = excel_data.ChildGridData[grid_num]
  if not grid_config then return end
  local item_id = grid_config.cost_name
  local count = grid_config.cost_value
  if not item_id or not count then return end
  local reason = g_reason.child_grid_unlock
  if not self.role:consume_item(item_id, count, reason) then return end
  self.db.child_grid_num = grid_num
  self.role:send_client("s_update_child_info",{grid_num = grid_num})
  return true
end

-- 改名
function role_child:child_rename(child_id, child_name)
  local child = self.db.child[child_id]
  if not child or not child.name then return end
  local item_id = excel_data.ParamData["child_stuff_id"].item_id
  local count = excel_data.ParamData["child_rename_count"].f_value
  local reason = g_reason.child_rename
  if not self.role:consume_item(item_id, count, reason) then return end
  child.name = child_name
  self.role:send_client("s_update_child_info",{child = {[child_id] = child}})
  return true
end

-- 使用物品恢复活力
function role_child:child_use_item(child_id)
  local child = self.db.child[child_id]
  if not child or not child.name then return end
  local param_config
  if child.child_status == CSConst.ChildStatus.Baby then
    param_config = excel_data.ParamData["child_baby_vitality_restore"]
  elseif child.child_status == CSConst.ChildStatus.Growing then
    param_config = excel_data.ParamData["child_vitality_restore"]
  end
  if not param_config then return end
  local child_lvl_config = excel_data.ChildExpData[child.level]
  local extra_num = self.role:get_vip_privilege_num(CSConst.VipPrivilege.ChildMaxVitalityNum)
  if child.vitality_num >= child_lvl_config.vitality_limit + extra_num then return end
  local reason = g_reason.child_vitality_restore
  if not self.role:consume_item(param_config.item_id, param_config.count, reason) then return end
  local child_lvl_config = excel_data.ChildExpData[child.level]
  child.vitality_num = child.vitality_num + excel_data.ItemData[param_config.item_id].recover_count
  if self.timer[child_id] then
    self.timer[child_id]:cancel()
    self.timer[child_id] = nil
  end
  self.role:send_client("s_update_child_info",{child = {[child_id] = child}})
  return true
end

function role_child:get_child_object_info(child_id)
  local child = self.db.child[child_id]
  if not child then return end
  return {
    uuid = self.uuid,
    role_name = self.db.name,
    child_id = child.child_id,
    sex = child.sex,
    grade = child.grade,
    child_name = child.name,
    aptitude_dict = table.deep_copy(child.aptitude_dict),
    attr_dict = table.deep_copy(child.attr_dict),
    apply_time = child.apply_time,
    display_id = child.display_id,
  }
end

function role_child:call_child_marry(cmd, data)
  return skynet.call(".child_marry", "lua", cmd, data)
end

function role_child:send_child_marry(cmd, data)
  return skynet.send(".child_marry", "lua", cmd, data)
end

-- 提亲，联姻，结婚消耗物品，取消上述操作返回一半
function role_child:modify_item_num(item_id, modify_type, apply_type, child_grade)
  local marry_config = excel_data.MarryExpendData[child_grade]
  if not marry_config then return end

  local consume_item_info = marry_config[apply_type]
  if not consume_item_info then return end
  local count = consume_item_info[item_id]
  if not count then return end
  if modify_type == g_const.AddItem and item_id == marry_config.diamond then
    count = math.floor(count / CSConst.ChildRequestItemCounGoBackRate)
  end

  local reason = g_reason.child_request
  if modify_type == g_const.AddItem then
    self.role:add_item(item_id, count, reason)
  elseif modify_type == g_const.SubItem then
    if not self.role:consume_item(item_id, count, reason) then return end
  end
  return true
end

-- 发送提亲/联姻请求,参数：我方child_id,提亲/联姻种类，提亲请求对方角色ID,选择消耗物品id
function role_child:send_request(child_id, apply_type, uuid, item_id)
  local child = self.db.child[child_id]
  if not apply_type or not item_id then return end
  if not child or child.child_status ~= CSConst.ChildStatus.Adult then return end
  if child.apply_type or child.apply_time or child.marry then return end
  if uuid == self.uuid then return end
  if not self:modify_item_num(item_id, g_const.SubItem, apply_type, child.grade) then return end

  child.apply_type = apply_type
  child.apply_time = date.time_second()
  child.consume_item_id = item_id
  local object = self:get_child_object_info(child_id)
  if apply_type == CSConst.ChildSendRequest.Service then
    self:send_child_marry("ls_add_object",{object = object})
  elseif apply_type == CSConst.ChildSendRequest.Assign and uuid then
    local name = cluster_utils.call_agent(nil, uuid, "lc_receive_request", object)
    child.apply_role_name = name
    child.apply_uuid = uuid
  elseif apply_type == CSConst.ChildSendRequest.Cross then
    cluster_utils.send_cross_marry("ls_add_object",{object = object})
  else
    return
  end

  local request_time = excel_data.ParamData["child_request_timer"].f_value
  self:request_timer(child_id, request_time)
  self.role:send_client("s_update_child_info",{child = {[child_id] = child}})
  return true
end

-- 接收提亲请求
function role_child:receive_request(object)
  if not object.uuid or not object.child_id then return end
  local propose_object_list = self.db.propose_object_list
  local index = self:get_object_index(object.uuid, object.child_id)
  if index then
    table.remove(propose_object_list, index)
  end
  table.insert(propose_object_list, object)
  self.role:send_client("s_update_child_info",{propose_object_list = propose_object_list})
end

function role_child:request_timer(child_id, request_time)
  if self.timer[child_id] then
    self.timer[child_id]:cancel()
    self.timer[child_id] = nil
  end
  self.timer[child_id] = self.role:timer_once(request_time, function()
    self:driving_cancel_request(child_id)
  end)
end

function role_child:get_object_index(uuid, child_id)
  if #self.db.propose_object_list <= 0 then return end
  for index, info in ipairs(self.db.propose_object_list) do
    if info.uuid == uuid and info.child_id == child_id then
      return index
    end
  end
end

-- 主动取消提亲/联姻请求
function role_child:driving_cancel_request(child_id)
  local child = self.db.child[child_id]
  if not child or child.child_status ~= CSConst.ChildStatus.Adult then return end
  if not child.apply_type or not child.apply_time then return end

  if child.apply_type == CSConst.ChildSendRequest.Service then
    local object = self:call_child_marry("lc_delete_object",{uuid = self.uuid, child_id = child_id})
    if not object then return end
  elseif child.apply_type == CSConst.ChildSendRequest.Assign and child.apply_uuid then
    cluster_utils.send_agent(nil, child.apply_uuid, "ls_cancel_request", {uuid = self.uuid, child_id = child_id})
    child.apply_role_name = nil
    child.apply_uuid = nil
  elseif child.apply_type == CSConst.ChildSendRequest.Cross then
    local object = cluster_utils.call_cross_marry("lc_delete_object",{uuid = self.uuid, child_id = child_id})
    if not object then return end
  end
  if self.timer[child_id] then
    self.timer[child_id]:cancel()
    self.timer[child_id] = nil
  end
  self:modify_item_num(child.consume_item_id, g_const.AddItem, child.apply_type, child.grade)
  child.consume_item_id = nil
  child.apply_type = nil
  child.apply_time = nil
  self.role:send_client("s_update_child_info",{child = {[child_id] = child}})
  return true
end

-- 被动取消提亲请求
function role_child:passive_cancel_request(uuid, child_id)
  local propose_object_list = self.db.propose_object_list
  local index = self:get_object_index(uuid, child_id)
  if not index then return end
  table.remove(propose_object_list, index)
  self.role:send_client("s_update_child_info",{propose_object_list = propose_object_list})
  return true
end

-- 主动拒绝提亲请求
function role_child:driving_refuse_request(uuid, child_id)
  local propose_object_list = self.db.propose_object_list
  if uuid == self.uuid then return end
  local index = self:get_object_index(uuid, child_id)
  if not index then return end
  table.remove(propose_object_list, index)
  cluster_utils.send_agent(nil, uuid, "ls_refuse_request", child_id)
  self.role:send_client("s_update_child_info",{propose_object_list = propose_object_list})
  return true
end

-- 主动拒绝所有提亲请求
function role_child:driving_refuse_all_request()
  for index, object in ipairs(self.db.propose_object_list) do
    if object.uuid and object.child_id then
      cluster_utils.send_agent(nil, object.uuid, "ls_refuse_request", object.child_id)
    end
  end
  self.db.propose_object_list = {}
  self.role:send_client("s_update_child_info",{propose_object_list = {}})
  return true
end

-- 被动拒绝提亲请求
function role_child:passive_refuse_request(child_id)
  local child = self.db.child[child_id]
  if not child or child.child_status ~= CSConst.ChildStatus.Adult then return end
  if not child.apply_uuid or not child.apply_time then return end

  self:modify_item_num(child.consume_item_id, g_const.AddItem, child.apply_type, child.grade)
  if self.timer[child_id] then
    self.timer[child_id]:cancel()
    self.timer[child_id] = nil
  end
  child.apply_role_name = nil
  child.consume_item_id = nil
  child.apply_uuid = nil
  child.apply_type = nil
  child.apply_time = nil
  self.role:send_client("s_update_child_info",{child = {[child_id] = child}})
  return true
end

-- 主动同意结婚
function role_child:driving_marriage(child_id, apply_type, object_uuid, object_child_id, item_id)
  local child = self.db.child[child_id]
  if not child then return end
  if object_uuid == self.uuid then return end
  if child.marry then return end
  if not self:modify_item_num(item_id, g_const.SubItem, apply_type, child.grade) then return end

  local marry
  local object = self:get_child_object_info(child_id)
  print("marry start 1"..json.encode(apply_type))
  if apply_type == CSConst.ChildSendRequest.Service then
    print("marry start 2")
    local other_object = self:call_child_marry("lc_marriage",{uuid = object_uuid, child_id = object_child_id, object = object})
    if not other_object then return end
    marry = other_object
  elseif apply_type == CSConst.ChildSendRequest.Assign then
    local propose_object_list = self.db.propose_object_list
    local index = self:get_object_index(object_uuid, object_child_id)
    if not index then return end
    marry = table.deep_copy(propose_object_list[index])
    if marry.sex == child.sex or marry.grade ~= child.grade then return end
    marry.marry_time = date.time_second()
    table.remove(propose_object_list, index)

    object.marry_time = marry.marry_time
    print("marry start 3")
    cluster_utils.send_agent(nil, object_uuid, "ls_passive_marriage", object_child_id, object)
    print("marry start 4")
    self.role:send_client("s_update_child_info",{propose_object_list = propose_object_list})
  elseif apply_type == CSConst.ChildSendRequest.Cross then
    local other_object = cluster_utils.call_cross_marry("lc_marriage", {uuid = object_uuid, child_id = object_child_id, object = object})
    if not other_object then return end
    marry = other_object
  end

  child.marry = marry
  self.role:modify_attr(nil, marry.attr_dict, true)
  self.role:send_client("s_update_child_info",{child = {[child_id] = child}})
  self.role:update_task(CSConst.TaskType.Marry, {progress = 1})
  self.role:update_first_week_task(CSConst.FirstWeekTaskType.ChildMarry, 1)
  self.role:update_achievement(CSConst.AchievementType.Marry, 1)
  return true
end

-- 被动同意联姻
function role_child:passive_marriage(child_id, object)
  print("marry start child_id1"..child_id)
  local child = self.db.child[child_id]
  if not child or child.marry or not child.apply_type then return end
  if child.sex == object.sex then return end
  if self.timer[child_id] then
    self.timer[child_id]:cancel()
    self.timer[child_id] = nil
  end
  if child.apply_type == CSConst.ChildSendRequest.Assign then
    child.apply_role_name = nil
    child.apply_uuid = nil
  end
  child.apply_time = nil
  child.marry = object
  print("marry start child_id2"..json.encode(object))
  self.role:modify_attr(nil, object.attr_dict, true)
  self.role:send_client("s_update_child_info",{child = {[child_id] = child}})
  self.role:update_task(CSConst.TaskType.Marry, {progress = 1})
  self.role:update_first_week_task(CSConst.FirstWeekTaskType.ChildMarry, 1)
  self.role:update_achievement(CSConst.AchievementType.Marry, 1)
  return true
end

-- 联姻成功后，客户端确定后修改child_status
function role_child:marriage_confirm_status(child_id)
  local child = self.db.child[child_id]
  if not child or not child.marry then return end
  if child.child_status ~= CSConst.ChildStatus.Adult
    or child.child_status == CSConst.ChildStatus.Marrieds
    then return end
  child.child_status = CSConst.ChildStatus.Married
  self.role:send_client("s_update_child_info",{child = {[child_id] = child}})
  return true
end

function role_child:get_request_tables(sex, page_id, grade)
  local data = {
    uuid = self.uuid,
    sex = sex,
    page_id = page_id,
    grade = grade,
  }
  local service_object_list = self:call_child_marry("lc_get_all_object_info", data)
  local cross_object_list = cluster_utils.call_cross_marry("lc_get_all_object_info",data)
  return {
    errcode = 0,
    service_object_list = service_object_list or {},
    cross_object_list = cross_object_list or {},
  }
end

-- vip升级增加孩子教导次数上限
function role_child:vip_level_up_privilege_child_vitality_num(old_level, new_level)
  local child_dict = self.db.child
  for child_id, child in pairs(child_dict) do
    local quality_config = excel_data.ChildQualityData[child.grade]
    local exp_config = excel_data.ChildExpData[child.level]
    local extra_num = self.role:get_vip_privilege_num(CSConst.VipPrivilege.ChildMaxVitalityNum)
    if (child.child_status == CSConst.ChildStatus.Baby
      or child.child_status == CSConst.ChildStatus.Growing)
      and (child.vitality_num < exp_config.vitality_limit + extra_num) then
      if not self.timer[child_id] then
        child.last_time = date.time_second()
        self.timer[child_id] = self.role:timer_loop(exp_config.cooldown, function()
          self:vitality_num_restore(child_id)
        end)
      end
    end
  end
  self.role:send_client("s_update_child_info",{child = child_dict})
end

-- 获取孩子及其对象的属性
function role_child:get_marry_attr(child_id)
  local child_db = self.db.child[child_id]
  if not child_db then return end
  local attr_dict = {}
  for k, v in pairs(child_db.attr_dict) do
    attr_dict[k] = v
  end
  if child_db.marry then
    for k, v in pairs(child_db.marry.attr_dict) do
      attr_dict[k] = (attr_dict[k] or 0) + v
    end
  end
  return attr_dict
end

return role_child