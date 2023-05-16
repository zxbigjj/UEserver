local cluster_utils = require("msg_utils.cluster_utils")

local event_meta = DECLARE_MODULE("meta_table.event")

--[[
事件(ev_type, subtype, value)
listen, unlisten监听事件
]]
function event_meta.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
    }
    return setmetatable(self, event_meta)
end

function event_meta:_get_event(key)
    return string.match(key, "^(%w+_)")
end

function event_meta:load_event()
    self.event_mgr = {
        tag_mapper = {},
        hub = {},
    }
end

function event_meta:listen_event(tag, ev_type, subtype, func, is_once)
    local mgr = self.event_mgr
    local key = ev_type .. (subtype or "")
    local obj = {tag=tag, key=key, func=func, is_once=is_once}

    if not mgr.hub[key] then
        mgr.hub[key] = {[tag]=obj}
    else
        mgr.hub[key][tag] = obj
    end

    if not mgr.tag_mapper[tag] then
        mgr.tag_mapper[tag] = {[key]=obj}
    else
        mgr.tag_mapper[tag][key] = obj
    end
end

function event_meta:unlisten_event(tag, ev_type, subtype)
    local hub = self.event_mgr.hub
    local tag_mapper = self.event_mgr.tag_mapper

    if ev_type then
        local key = ev_type .. (subtype or "")
        local obj = nil
        if tag_mapper[tag] then
            obj = tag_mapper[tag][key]
            tag_mapper[tag][key] = nil
        end
        if hub[key] then
            obj = obj or hub[key][tag]
            hub[key][tag] = nil
            if not next(hub[key]) then
                hub[key] = nil
            end
        end
        if obj then
            obj.cancel = true
            obj.func = nil
        end
    else
        -- delete all
        if not tag_mapper[tag] then return end
        for key, obj in pairs(tag_mapper[tag]) do
            obj.cancel = true
            obj.func = nil
            if hub[key] then
                hub[key][tag] = nil
                if not next(hub[key]) then
                    hub[key] = nil
                end
            end
        end
        tag_mapper[tag] = nil
    end
end

function event_meta:_trigger_event_list(key, subtype, value)
    local hub = self.event_mgr.hub
    local tag_mapper = self.event_mgr.tag_mapper
    local func_dict = hub[key]
    if not func_dict then
        return
    end
    hub[key] = nil

    local status, cb_result
    for tag, obj in pairs(func_dict) do
        if obj.cancel then
            func_dict[tag] = nil
        else
            if obj.is_once then
                func_dict[tag] = nil
                if tag_mapper[tag] then
                    tag_mapper[tag][key] = nil
                    if not next(tag_mapper[tag]) then
                        tag_mapper[tag] = nil
                    end
                end
                status, cb_result = xpcall(obj.func, g_log.trace_handle, subtype, value)
            else
                status, cb_result = xpcall(obj.func, g_log.trace_handle, subtype, value)
                if obj.cancel then
                    func_dict[tag] = nil
                end
            end
            if cb_result == g_const.EventResultBreak then
                break
            end
        end
    end

    if next(func_dict) then
        hub[key] = table.update(func_dict, hub[key])
    end
end

function event_meta:push_event(ev_type, subtype, value)
    self:_trigger_event_list(ev_type, subtype, value)
    if subtype then
        self:_trigger_event_list(ev_type .. subtype, subtype, value)
    end
end

return event_meta