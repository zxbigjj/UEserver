local child_marry = require("child_marry")
local lua_handles = DECLARE_MODULE("lua_handles")

function lua_handles.lc_get_all_object_info(data)
  if not data.uuid or not data.page_id or not data.sex or not data.grade then return end
  return child_marry:get_all_object_info(data.uuid, data.sex, data.page_id, data.grade)
end

function lua_handles.lc_get_object_info(data)
  if not data.uuid or not data.child_id then return end
  return child_marry:get_object_info(data.uuid, data.child_id)
end

function lua_handles.ls_add_object(data)
  if not data.object then return end
  return child_marry:add_object(data.object)
end

function lua_handles.lc_delete_object(data)
  if not data.uuid or not data.child_id then return end
  return child_marry:delete_object(data.uuid, data.child_id)
end

function lua_handles.lc_marriage(data)
  if not data.uuid or not data.child_id or not data.object then return end
  return child_marry:marriage(data.uuid, data.child_id, data.object)
end

return lua_handles