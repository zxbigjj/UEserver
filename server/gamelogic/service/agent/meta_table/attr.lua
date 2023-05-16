local role_attr = DECLARE_MODULE("meta_table.attr")

local excel_data = require("excel_data")
local attr_utils = require("attr_utils")
local role_utils = require("role_utils")

function role_attr.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
    }
    return setmetatable(self, role_attr)
end

function role_attr:load_attr()
    self.db.raw_attr_dict = {}
    self.db.attr_dict = {}
    self.db.score = 0
end

function role_attr:modify_attr(old_attr_dict, new_attr_dict, is_role)
    local attr_diff_dict = role_utils.get_attr_dict_diff(old_attr_dict, new_attr_dict)
    if not attr_diff_dict or not next(attr_diff_dict) then return end

    local ret = {}
    local attribute_data = excel_data.AttributeData
    local raw_attr_dict = self.db.raw_attr_dict
    for attr_name, attr_value in pairs(attr_diff_dict) do
        local data = attribute_data[attr_name]
        if (is_role and data.is_role_attr) or data.other_add_role_attr then
            -- 筛选人物属性
            raw_attr_dict[attr_name] = (raw_attr_dict[attr_name] or 0) + attr_value
            table.update(ret, attr_utils.on_modify_raw(raw_attr_dict, attr_name))
        end
    end
    if not next(ret) then return end
    local attr_dict = self.db.attr_dict
    for attr_name, attr_value in pairs(ret) do
        local data = attribute_data[attr_name]
        if (is_role and data.is_role_attr) or data.other_add_role_attr then
            attr_dict[attr_name] = attr_value
        end
    end
    local new_score = self:eval_score(attr_dict)
    local old_score = self.db.score
    self.db.score = new_score
    if self.db.score > self.db.max_score then
        local old_max_score = self.db.max_score
        self.db.max_score = self.db.score
        -- 限时活动、冲榜活动，帮力历史最高涨幅统计
        self.role:update_activity_data(CSConst.ActivityType.GrowthScore, self.db.max_score - old_max_score)
        self.role:update_rush_activity_data(CSConst.RushActivityType.score, self.db.max_score - old_max_score)
    end
    self:on_modify_attr(old_score, new_score)
    if is_role then
        self.role:send_client("s_update_base_info", {attr_dict = attr_dict, score = self.db.score})
    else
        -- 英雄增加属性时，帮力和战力要一起发给客户端，这里不发
        self.role:send_client("s_update_base_info", {attr_dict = attr_dict})
    end

    self.role:log("ModifyAttr", {attr_diff_dict = attr_diff_dict, result = ret})
    return true
end

function role_attr:on_modify_attr(old_score, new_score)
    self.role:update_task(CSConst.TaskType.Score)
    self.role:update_first_week_task(CSConst.FirstWeekTaskType.HeroAttrScoreNum, new_score)
    self.role:update_achievement(CSConst.AchievementType.Score, new_score)
    self.role:update_dynasty_role_info({score = new_score})
    --跨服帮力排行榜更新
    print("cross_score_rank"..new_score)
    self.role:update_cross_role_rank("cross_score_rank", new_score)
    self.role:update_role_rank("score_rank", new_score)
end

function role_attr:eval_score(attr_dict)
    -- todo:战力规则未定，暂时这样写
    local score = 0
    for _, v in pairs(attr_dict) do
        score = score + v
    end
    return math.floor(score)
end

return role_attr