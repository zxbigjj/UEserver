local child_utils = require("child_utils")
local cluster_utils = require("msg_utils.cluster_utils")
local date = require("sys_utils.date")

local child_marry = DECLARE_MODULE("child_marry")

function child_marry:get_all_object_info(uuid, sex, page_id, grade)
    return child_utils:get_all_object_info(uuid, sex, page_id, grade)
end

function child_marry:get_object_info(uuid, child_id)
    return child_utils:get_object_info(uuid, child_id)
end

function child_marry:add_object(object)
    return child_utils:add_object(object)
end

function child_marry:delete_object(uuid, child_id)
    return child_utils:delete_object(uuid, child_id)
end

function child_marry:marriage(uuid, child_id, object)
  local other_object = child_marry:get_object_info(uuid, child_id)
  if not other_object then return end
  if other_object.sex == object.sex or other_object.grade ~= object.grade then return end
  other_object = child_marry:delete_object(uuid, child_id)
  if not other_object then return end
  other_object.marry_time = date.time_second()
  object.marry_time = other_object.marry_time
  cluster_utils.send_agent(nil, uuid, "ls_child_marriage", {child_id = child_id, object = object})
  return other_object
end

return child_marry