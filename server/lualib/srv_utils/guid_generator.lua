local guid_gen = DECLARE_MODULE("srv_utils.guid_generator")

function guid_gen:new_guid()
    local cur_guid = self._cur_guid or 1
    self._cur_guid = cur_guid + 1
    return cur_guid
end

function guid_gen:new_rand_guid()
    local cur_guid = self._cur_guid or 1
    self._cur_guid = cur_guid + 1
    return cur_guid .. string.rand_string(6)
end

return guid_gen