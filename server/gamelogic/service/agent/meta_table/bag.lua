local role_bag = DECLARE_MODULE("meta_table.bag")

local excel_data = require("excel_data")
local drop_utils = require("drop_utils")

local Item_Mapper = {
    [CSConst.ItemType.Default] = {add = '_add_item_prop', consume = '_consume_item_prop', build = '_build_item_prop'},
    [CSConst.ItemType.Prop] = {},
    [CSConst.ItemType.Stuff] = {},
    [CSConst.ItemType.Virtual] = {add = '_add_item_virtual', consume = '_consume_item_virtual'},
    [CSConst.ItemType.Hero] = {add = '_add_item_hero'},
    [CSConst.ItemType.Equip] = {add = '_add_item_equip', consume = '_consume_item_equip', build = '_build_item_equip'},
    [CSConst.ItemType.Lover] = {add = '_add_item_lover'},
}

function role_bag.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
    }
    return setmetatable(self, role_bag)
end

function role_bag:load_bag()
    -- 加载的时候排序背包，其他时候不排序
    self:sort_item_list()
end

-- 排序并堆叠背包物品
function role_bag:sort_item_list()
    local item_list = self.db.bag_item_list
    DB_LIST_SORT(item_list, function(a, b) return a.item_id < b.item_id end)

    local index = 2
    local reason = g_reason.sort_bag
    local _pile_func = function(item)
        local item_config = excel_data.ItemData[item.item_id]
        if item_config.max_plus <= 1 then return end
        local prev_item = item_list[index - 1]
        if prev_item.item_id ~= item.item_id then
            return
        end
        if prev_item.count >= item_config.max_plus then
            return
        end
        local prev_count, count = prev_item.count, item.count
        local max_plus = item_config.max_plus
        if prev_count + count <= max_plus then
            self:_remove_bag_item(item.guid, reason, index)
            self:_addcount_bag_item(prev_item, count, reason)
            return true
        else
            local sub_count = max_plus - prev_count
            self:_subcount_bag_item(item, sub_count, reason)
            self:_addcount_bag_item(prev_item, sub_count, reason)
            return
        end
    end

    while true do
        local item = item_list[index]
        if not item then break end
        if not _pile_func(item) then
            index = index + 1
        end
    end
end

function role_bag:online_bag()
    self.role:send_client("s_online_bag_item", {item_list = self.db.bag_item_list})
end

function role_bag:new_item_guid(item_id)
    return self.role:new_guid() .. string.rand_string(2) .. "_" .. item_id
end

function role_bag:get_item_id_from_guid(item_guid)
    return tonumber(string.match(item_guid, "_(%d+)$"))
end

function role_bag:get_bag_item_index(item_guid)
    local item_list = self.db.bag_item_list
    for index, item in ipairs(item_list) do
        if item.guid == item_guid then
            return index
        end
    end
    return 0
end

function role_bag:get_bag_item(item_guid)
    local index = self:get_bag_item_index(item_guid)
    return self.db.bag_item_list[index]
end

-- 新增物品
function role_bag:add_new_item(item_id, count, reason, not_notify)
    print("add_new_item item_id : "..json.encode(item_id))
    if count == 0 then
        return true ;
    end
    if count <= 0 then
        error("add_new_item count error:" .. count)
    end
    local item_config = excel_data.ItemData[item_id]
    if not item_config then
        error("add_new_item item_id error:" .. item_id)
    end
    if not not_notify and not self.role.is_doing_online then
        print("add_new_item item_id : "..json.encode(item_id))
        self.role:send_client("s_notify_add_item", {item_id = item_id, count = count})
    end

    print("add_new_item count : "..json.encode(count))
    -- 宝物碎片不进背包
    if self.role:add_treasure_fragment(item_id, count) then return true end

    -- 称号不进入背包
    if item_config.item_type == CSConst.ItemType.Title then
        self.role:add_title(item_id)
        return
    end

    local func = Item_Mapper[item_config.item_type].add  or Item_Mapper[CSConst.ItemType.Default].add
    print("add_new_item fun : "..json.encode(func))
    self[func](self, item_id, count, reason)
end

-- 构建物品
function role_bag:build_new_item(item_id, count)
    local item_config = excel_data.ItemData[item_id]
    if not item_config then
        error("build_new_item item_id error:" .. item_id)
    end
    if count <= 0 then
        error("build_new_item count error:" .. count)
    end
    local func = Item_Mapper[item_config.item_type].build or Item_Mapper[CSConst.ItemType.Default].build
    return self[func](self, item_id, count)
end

-- 构建道具
function role_bag:_build_item_prop(item_id, count)
    if count <= 0 then
        error("_build_new_prop_item count error:" .. item_id .. "," .. count)
    end
    return {
        guid = self:new_item_guid(item_id),
        item_id = item_id,
        count = count,
    }
end

-- 构建装备
function role_bag:_build_item_equip(item_id, count)
    return {
        guid = self:new_item_guid(item_id),
        item_id = item_id,
        count = 1,
        star_lv = 0,
        refine_lv = 0,
        refine_exp = 0,
        strengthen_lv = 1,
        strengthen_exp = 0,
        smelt_lv = 0,
        smelt_exp = 0,
        lucky_value = 0,
    }
end

-- 新增道具
function role_bag:_add_item_prop(item_id, count, reason)
    if count <= 0 then
        error("_add_item_prop count error:" .. item_id .. "," .. count)
    end

    local item_config = excel_data.ItemData[item_id]
    local max_plus = item_config.max_plus
    -- 叠加到背包
    if max_plus > 1 then
        self:_pile_bag_item(item_id, count, max_plus, reason)
    else
        for i=1, count do
            local item = self:build_new_item(item_id, 1)
            self:_append_bag_item(item, reason)
        end
    end
end

-- 增加虚拟物品
function role_bag:_add_item_virtual(item_id, count, reason)
    if count <= 0 then
        error("_add_item_virtual count error:" .. item_id .. "," .. count)
    end
    local item_config = excel_data.ItemData[item_id]
    if item_config.item_type ~= CSConst.ItemType.Virtual then return end
    if item_config.sub_type == CSConst.ItemSubType.Exp then
        if item_id == CSConst.Virtual.Exp then
            self.role:add_exp(count, reason)
        elseif item_id == CSConst.Virtual.VIPExp then
            self.role:add_vip_exp(count, reason)
        end
    elseif item_config.sub_type == CSConst.ItemSubType.Currency then
        self.role:add_currency(item_id, count, reason)
    else
        error("This item is not virtual item_id error:" .. item_id)
    end
    return true
end

function role_bag:_add_item_hero(item_id, count, reason)
    if count <= 0 then
        error("_add_item_hero count error:" .. item_id .. "," .. count)
    end
    local item_config = excel_data.ItemData[item_id]
    if item_config.item_type ~= CSConst.ItemType.Hero then return end
    if item_config.sub_type == CSConst.ItemSubType.Hero then
        if self.role:get_hero(item_config.hero_id) then
            self:_add_item_prop(item_config.fragment, count * item_config.fragment_count, reason)
        else
            self.role:add_hero(item_config.hero_id)
            count = count - 1
            if count > 0 then
                self:_add_item_prop(item_config.fragment, count * item_config.fragment_count, reason)
            end
        end
    elseif item_config.sub_type == CSConst.ItemSubType.HeroFragment then
        self:_add_item_prop(item_id, count, reason)
    end
end

function role_bag:_add_item_equip(item_id, count, reason)
    if count <= 0 then
        error("_add_item_equip count error:" .. item_id .. "," .. count)
    end

    for i = 1, count do
        local item = self:_build_item_equip(item_id, 1)
        self:_append_bag_item(item, reason)
    end
end

function role_bag:_add_item_lover(item_id, count, reason)
    if count <= 0 then
        error("_add_item_lover count error:" .. item_id .. "," .. count)
    end
    local item_config = excel_data.ItemData[item_id]
    if item_config.item_type ~= CSConst.ItemType.Lover then return end
    if item_config.sub_type == CSConst.ItemSubType.Lover then
        if self.role:get_lover(item_config.lover_id) then
            self:_add_item_prop(item_config.fragment, count * item_config.fragment_count, reason)
        else
            self.role:add_lover(item_config.lover_id)
            count = count - 1
            if count > 0 then
                self:_add_item_prop(item_config.fragment, count * item_config.fragment_count, reason)
            end
        end
    end
end

-- 堆叠物品
function role_bag:_pile_bag_item(item_id, add_count, max_plus, reason)
    local item_list = self.db.bag_item_list
    for _, item in ipairs(item_list) do
        if item.item_id == item_id and item.count < max_plus then
            local old_count = item.count
            if old_count + add_count <= max_plus then
                item.count = old_count + add_count
                add_count = 0
            else
                add_count = add_count - (max_plus - old_count)
                item.count = max_plus
            end

            self.role:send_client("s_bag_item_update", {update_item = item})
            local log_data = {item = item, add_count = item.count-old_count, reason = reason}
            self.role:log("BagItemAddCount", log_data)
            if add_count == 0 then
                break
            end
        end
    end
    if add_count == 0 then return 0 end

    local _pile_new_item = function()
        local item = self:build_new_item(item_id, 1)
        if add_count <= max_plus then
            item.count = add_count
            add_count = 0
        else
            item.count = max_plus
            add_count = add_count - max_plus
        end
        return item
    end

    while add_count > 0 do
        local item = _pile_new_item()
        self:_append_bag_item(item, reason)
    end
end

function role_bag:_append_bag_item(item, reason)
    local list = self.db.bag_item_list
    DB_LIST_INSERT(list, item)
    self.role:send_client("s_bag_item_add", {add_item = item})
    local log_data = {item = item, reason = reason}
    self.role:log("BagItemAdd", log_data)
    self.role:gaea_log("AddItem", {
        itemId = item.item_id,
        itemType = ItemTypeName(item.item_id),
        itemCnt = item.count,
        itemTotal = item.count,
        reason = reason,
    })
end

function role_bag:_remove_bag_item(item_guid, reason, index)
    index = index or self:get_bag_item_index(item_guid)
    local item = DB_LIST_REMOVE(self.db.bag_item_list, index)
    if item then
        self.role:send_client("s_bag_item_remove", {item_guid = item.guid})
        local log_data = {item = item, reason = reason}
        self.role:log("BagItemDel", log_data)
        self.role:gaea_log("ConsumeItem", {
            itemId = item.item_id,
            itemType = ItemTypeName(item.item_id),
            itemCnt = item.count,
            itemTotal = item.count,
            reason = reason,
        })
        return item
    end
end

function role_bag:_addcount_bag_item(item, add_count, reason)
    if add_count <= 0 then return end
    item.count = item.count + add_count

    self.role:send_client("s_bag_item_update", {update_item = item})
    local log_data = {add_count = add_count, item = item, reason = reason}
    self.role:log("BagItemAddCount", log_data)
    self.role:gaea_log("AddItem", {
        itemId = item.item_id,
        itemType = ItemTypeName(item.item_id),
        itemCnt = add_count,
        itemTotal = item.count,
        reason = reason,
    })
end

function role_bag:_subcount_bag_item(item, sub_count, reason)
    if sub_count <= 0 or sub_count > item.count then return end
    item.count = item.count - sub_count

    self.role:send_client("s_bag_item_update", {update_item = item})
    local log_data = {sub_count = sub_count, item = item, reason = reason}
    self.role:log("BagItemSubCount", log_data)
    self.role:gaea_log("ConsumeItem", {
        itemId = item.item_id,
        itemType = ItemTypeName(item.item_id),
        itemCnt = sub_count,
        itemTotal = item.count,
        reason = reason,
    })
    return true
end

function role_bag:add_item_list(item_list, reason, not_notify)
    for _, item in ipairs(item_list) do
        self:add_new_item(item.item_id, item.count, reason, not_notify)
    end
end

function role_bag:add_item_dict(item_dict, reason, not_notify)
    for item_id, count in pairs(item_dict) do
        self:add_new_item(item_id, count, reason, not_notify)
    end
end

function role_bag:consume_item_list(item_list, reason, force_consume)
    -- 先判断所有物品都能消耗
    for _, item in ipairs(item_list) do
        if not self:can_consume_item(item.item_id, item.count, item.guid, force_consume) then
            return
        end
    end
    for _, item in ipairs(item_list) do
        self:consume_item(item.item_id, item.count, reason, item.guid, force_consume)
    end
    return true
end

function role_bag:consume_item_dict(item_dict, reason, force_consume)
    -- 先判断所有物品都能消耗
    for item_id, count in pairs(item_dict) do
        if not self:can_consume_item(item_id, count, nil, force_consume) then
            return
        end
    end
    for item_id, count in pairs(item_dict) do
        self:consume_item(item_id, count, reason, nil, force_consume)
    end
    return true
end

function role_bag:consume_item(item_id, count, reason, item_guid, force_consume)
    if not self:can_consume_item(item_id, count, item_guid, force_consume) then return end
    if item_guid then
        item_id = self:get_item_id_from_guid(item_guid)
    end
    if not item_id then return end
    local item_config = excel_data.ItemData[item_id]
    if not item_config then
        error("consume_item item_id error:" .. item_id)
    end
    local func = Item_Mapper[item_config.item_type].consume or Item_Mapper[CSConst.ItemType.Default].consume
    if self[func](self, item_id, count, reason, item_guid, force_consume) then
        self.role:update_task(CSConst.TaskType.ItemConsume, {item_id = item_id, progress = count})
        return true
    end
end

function role_bag:can_consume_item(item_id, count, item_guid, force_consume)
    if count < 0 then
        error("_consume_item count error:" .. item_id .. "," .. count)
    end
    if item_guid then
        item_id = self:get_item_id_from_guid(item_guid)
    end
    local item_config = excel_data.ItemData[item_id]
    if item_config.sub_type == CSConst.ItemSubType.Currency then
        return self.role:get_currency(item_id) >= count
    elseif item_config.sub_type == CSConst.ItemSubType.Equipment then
        return self:check_consume_equip_count(item_id, count, item_guid, force_consume)
    end
    return self:get_item_count(item_id, item_guid) >= count
end

-- 是否可以消耗装备
local function is_can_consume_equip(equip)
    -- 穿戴的装备和培养过的装备不能消耗
    print(equip.star_lv)
    print(equip.refine_lv)
    print(equip.refine_exp)
    print(equip.strengthen_lv)
    print(equip.strengthen_exp)
    print(equip.smelt_lv)
    print(equip.smelt_exp)
    if equip.star_lv > 0 or equip.refine_lv > 0 or equip.refine_exp > 0
        or equip.strengthen_lv > 1 or equip.strengthen_exp > 0
        or equip.smelt_lv > 0 or equip.smelt_exp > 0 then
        return
    end
    return true
end

-- 检查消耗装备数量
function role_bag:check_consume_equip_count(item_id, count, item_guid, force_consume)
    print('=================1')
    if item_guid then
        local item = self:get_bag_item(item_guid)
        if not item then
            error("item item_guid error:" .. item_guid)
        end

        if item.lineup_id then
            print('========33========='.. item.lineup_id)
            return 
        end
        if not is_can_consume_equip(item) and not force_consume then return end
        return item.count >= count
    end
    local item_list = self.db.bag_item_list
    local all_count = 0
    for _, item in ipairs(item_list) do
        if item.item_id == item_id then
            if not item.lineup_id and (force_consume or is_can_consume_equip(item)) then
                all_count = all_count + item.count
            end
        end
    end
    return all_count >= count
end

function role_bag:get_item_count(item_id, item_guid)
    local item_config = excel_data.ItemData[item_id]
    if item_config.item_type == CSConst.ItemType.Virtual then
        if item_config.sub_type == CSConst.ItemSubType.Currency then
            return self.role:get_currency(item_id)
        else
            error("get virtual item count error:" .. item_id)
        end
    end

    if item_guid then
        local item = self:get_bag_item(item_guid)
        if not item then
            error("_consume_item item_guid error:" .. item_guid)
        end
        return item.count
    end
    local item_list = self.db.bag_item_list
    local all_count = 0
    for _, item in ipairs(item_list) do
        if item.item_id == item_id then
            all_count = all_count + item.count
        end
    end
    return all_count
end

-- 消耗道具
function role_bag:_consume_item_prop(item_id, count, reason, item_guid)
    if item_guid then
        local item = self:get_bag_item(item_guid)
        if item.count == count then
            self:_remove_bag_item(item_guid, reason)
        else
            self:_subcount_bag_item(item, count, reason)
        end
        local log_data = {count = count, reason = reason, item_id = item_id, item_guid = item_guid}
        self.role:log("BagItemConsume",log_data)
        return true
    end

    local item_list = self.db.bag_item_list
    local item_list_num = #item_list
    local log_data = {count = count, reason = reason, item_id = item_id}
    while item_list_num > 0 and count > 0 do
        local item = item_list[item_list_num]
        if item.item_id == item_id then
            if item.count > count then
                self:_subcount_bag_item(item, count, reason)
                break
            else
                count = count - item.count
                self:_remove_bag_item(item.guid, reason, item_list_num)
            end
        end
        item_list_num = item_list_num - 1
    end
    self.role:log("BagItemConsume",log_data)
    return true
end

-- 消耗虚拟物品
function role_bag:_consume_item_virtual(item_id, count, reason)
    local item_config = excel_data.ItemData[item_id]
    if item_config.sub_type == CSConst.ItemSubType.Currency then
        self.role:sub_currency(item_id, count, reason)
    else
        error("This item is not virtual item_id error:" .. item_id)
    end
    return true
end

function role_bag:_consume_item_equip(item_id, count, reason, item_guid, force_consume)
    if item_guid then
        local index = self:get_bag_item_index(item_guid)
        self:_remove_bag_item(item_guid, reason, index)
        return true
    end

    local item_list = self.db.bag_item_list
    local item_list_num = #item_list
    local log_data = {count = count, reason = reason, item_id = item_id}
    while item_list_num > 0 and count > 0 do
        local item = item_list[item_list_num]
        if item.item_id == item_id then
            if not item.lineup_id and (force_consume or is_can_consume_equip(item)) then
                count = count - item.count
                self:_remove_bag_item(item.guid, reason, item_list_num)
            end
        end
        item_list_num = item_list_num - 1
    end
    self.role:log("BagItemConsume",log_data)
    return true
end

---------------------------- use item ----------------------------------
local Use_Item = {
    [CSConst.UseItem.ActionPoint] = "use_action_point_item",
    [CSConst.UseItem.Vitality] = "use_vitality_item",
    [CSConst.UseItem.Discuss] = "use_discuss_item",
}

-- 使用物品
function role_bag:use_bag_item(item_guid, count, index)
    if not item_guid or not count then return end
    if count <= 0 then return end
    local item = self:get_bag_item(item_guid)
    if not item then return end
    if item.count < count then return end
    local item_config = excel_data.ItemData[item.item_id]
    if item_config.sub_type == CSConst.ItemSubType.Present
        or item_config.sub_type == CSConst.ItemSubType.SelectPresent
        or item_config.sub_type == CSConst.ItemSubType.RandomPresent then
        return self:use_present_item(item_guid, count, index)
    else
        local func = Use_Item[item.item_id]
        if func then
            if self[func](self, item.item_id, count) then return g_tips.ok_resp end
        end
    end
end

-- 使用礼包
function role_bag:use_present_item(item_guid, count, index)
    if not item_guid or not count then return end
    if count <= 0 then return end
    local item = self:get_bag_item(item_guid)
    if not item then return end
    if item.count < count then return end
    local item_config = excel_data.ItemData[item.item_id]
    if index and (index < 1 or index > #item_config.item_list) then return end
    if not self:consume_item(item.item_id, count, g_reason.use_item, item_guid) then return end
    local item_dict = {}
    if item_config.sub_type == CSConst.ItemSubType.Present then
        -- 普通礼包
        for i, id in ipairs(item_config.item_list) do
            item_dict[id] = item_config.item_count_list[i] * count
        end
    elseif item_config.sub_type == CSConst.ItemSubType.SelectPresent then
        -- 多选一礼包
        if index then
            local item_id = item_config.item_list[index]
            local item_count = item_config.item_count_list[index] * count
            item_dict[item_id] = item_count
        else
            -- 没有index则随机一个
            local len = #item_config.item_list
            for i = 1, count do
                index = math.random(1, len)
                local item_id = item_config.item_list[index]
                local item_count = item_config.item_count_list[index]
                item_dict[item_id] = (item_dict[item_id] or 0) + item_count
            end
        end
    elseif item_config.sub_type == CSConst.ItemSubType.RandomPresent then
        -- 随机礼包
        for i = 1, count do
            local item_list = drop_utils.roll_drop(item_config.drop_id)
            local info = item_list[1]
            item_dict[info.item_id] = (item_dict[info.item_id] or 0) + info.count
        end
    end
    self:add_item_dict(item_dict, g_reason.use_item)
    return {errcode = g_tips.ok, item_dict = item_dict}
end

function role_bag:use_action_point_item(item_id, count)
    return self.role:use_action_point_item(count)
end

function role_bag:use_vitality_item(item_id, count)
    return self.role:use_vitality_item(count)
end

function role_bag:use_discuss_item(item_id, count)
    return self.role:use_discuss_item(count)
end

-- 分解物品
function role_bag:decompose_item(decompose_item_list)
    if not decompose_item_list or not next(decompose_item_list) then return end
    local sub_type
    local item_dict = {}
    for _, v in ipairs(decompose_item_list) do
        local item = self:get_bag_item(v.guid)
        if not item or item.lineup_id then return end
        if item.count < v.count then return end
        local data = excel_data.ItemData[item.item_id]
        if data.is_treasure or not data.decompose_list then return end
        -- 每次只能分解同一种类别的物品
        if sub_type and sub_type ~= data.sub_type then return end
        sub_type = data.sub_type
        for i, item_id in ipairs(data.decompose_list) do
            item_dict[item_id] = (item_dict[item_id] or 0) + data.decompose_value_list[i] * v.count
        end
        if data.item_type == CSConst.ItemType.Equip then
            -- 分解装备要返回培养材料
            local ret = require("CSCommon.CSFunction").get_equip_recover_item(item)
            for item_id, item_count in pairs(ret) do
               item_dict[item_id] = (item_dict[item_id] or 0) + item_count
            end
        end
    end

    if not self:consume_item_list(decompose_item_list, g_reason.decompose_item, true) then return end
    self:add_item_dict(item_dict, g_reason.decompose_item)
    return true
end

-- 物品合成
function role_bag:item_compose(item_id, compose_count)
    if not item_id or not compose_count then return end
    local item_data = excel_data.ItemData[item_id]
    if not item_data or not item_data.compose_item then return end
    local count = item_data.synthesize_count * compose_count
    if not self:consume_item(item_id, count, g_reason.item_compose) then return end
    self:add_new_item(item_data.compose_item, compose_count, g_reason.item_compose)
    return true
end

return role_bag