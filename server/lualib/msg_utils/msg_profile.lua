local msg_profile = DECLARE_MODULE("msg_utils.msg_profile")

DECLARE_RUNNING_ATTR(msg_profile, "_main_profiler", nil)
DECLARE_RUNNING_ATTR(msg_profile, "ProfileFlag", false)

function msg_profile.on_handle_finish(cmd, used_time)
    if not msg_profile.ProfileFlag then return end
    if not msg_profile._main_profiler then
        msg_profile._main_profiler = msg_profile.MsgProfile.New()
        skynet.report_debug_info("msg_profile", function() return table.concat(msg_profile.format_lines(), "\n") end)
    end
    msg_profile._main_profiler:on_handle_finish(cmd, used_time)
end

function msg_profile.time_run(tag, func)
    if not msg_profile.ProfileFlag then
        return func()
    end
    local start_ts = skynet.gettimeofday()
    local ret = func()
    msg_profile.on_handle_finish(tag, skynet.gettimeofday() - start_ts)

    return ret
end

function msg_profile.format_lines()
    if not msg_profile._main_profiler then
        return {}
    end
    return msg_profile._main_profiler:format_lines()
end

local MsgProfile = DECLARE_CLASS(msg_profile, "MsgProfile")
function MsgProfile.New()
    local self = {
        msg_info_dict = {}
    }
    setmetatable(self, MsgProfile)
    return self
end

function MsgProfile:clear()
    self.msg_info_dict = {}
end

function MsgProfile:on_handle_finish(cmd, used_time)
    local info = self.msg_info_dict[cmd]
    if not info then
        info = {
            count = 0,
            total_time = 0,
            max_time = 0,
            cmd = cmd,
        }
        self.msg_info_dict[cmd] = info
    end
    
    info.count = info.count + 1
    info.total_time = info.total_time + used_time
    if info.max_time < used_time then
        info.max_time = used_time
    end
end

function MsgProfile:format_lines()
    local lines = {"", ""}
    local info_list = table.values(self.msg_info_dict)
    table.sort(info_list, function(a, b) return a.total_time > b.total_time end)

    local total_time = 0
    local total_count = 0
    local max_time = 0
    for _, info in ipairs(info_list) do
        table.insert(lines, string.format('  %.5f  %.5f   %.5f  %6d  => %s', 
            info.total_time, info.max_time, info.total_time/info.count, info.count, info.cmd))
        total_count = total_count + info.count
        total_time = total_time + info.total_time
        if max_time < info.max_time then
            max_time = info.max_time
        end
    end
    lines[1] = "msg_profile:\ntotal  max  ave  count"
    lines[2] = string.format(' %.5f  %.5f  %.5f  %6d', 
        total_time, max_time, total_time/total_count, total_count)
    return lines
end

return msg_profile
