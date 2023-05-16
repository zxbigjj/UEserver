local boss_utils = DECLARE_MODULE("flash_event_utils")

-----------------------------------------------------------
-- 世界boss行为
-- boss受到伤害
function boss_utils.on_hurt(hp_dict, role_name, hurt)
    local data = _mgr:get(BOSS_ID)
    data.hp_dict = hp_dict
    local boss_hp = 0
    for _, hp in pairs(data.hp_dict) do
        boss_hp = boss_hp + hp
    end
    if boss_hp <= 0 then
        boss_utils.death(role_name)
    end
    for uuid in pairs(boss_utils.role_dict) do
        local role = agent_utils.get_role(uuid)
        if role then
            role.traitor:update_traitor_boss_info(role_name, hurt)
        end
    end
end

-- boss死亡
function boss_utils.death(role_name)
    local data = _mgr:get(BOSS_ID)
    local new_level = data.boss_level + 1
    if excel_data.TraitorBossData[new_level] then
        data.boss_level = new_level
    end
    data.hp_dict = {}
    data.killed_role = role_name
    local now = date.time_second()
    local refresh_time = excel_data.ParamData["traitor_boss_refresh_time"].tb_int
    local revive_ts = math.random(refresh_time[1] - refresh_time[2], refresh_time[1] + refresh_time[2])
    data.revive_ts = now + revive_ts
    boss_utils.save(data)
    boss_utils.revive_timer = timer.once(revive_ts, function()
        boss_utils.revive_timer = nil
        boss_utils.revive()
    end)

    for _, uuid in pairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        if role then
            role.traitor:set_traitor_boss_reward_dict(data.boss_level)
        end
    end
end

-- boss复活
function boss_utils.revive()
    local data = _mgr:get(BOSS_ID)
    local boss_data = boss_utils.build_boss_info(data.boss_level)
    data.max_hp = boss_data.max_hp
    data.hp_dict = boss_data.hp_dict
    data.killed_role = nil
    data.revive_ts = nil
    boss_utils.save(data)

    for uuid in pairs(boss_utils.role_dict) do
        local role = agent_utils.get_role(uuid)
        if role then
            role.traitor:traitor_boss_revive()
        end
    end
end
