
local M = {}


local function split(str, delimiter)
  if str == nil or str == '' or delimiter == nil then
      return nil
  end
  local result = {}
  local sum = 1
  for match in (str..delimiter):gmatch("(.-)"..delimiter) do
    if sum == 1 then
      result["min"]= tonumber(match)
      sum = sum + 1
    else
      result["max"]= tonumber(match)
      break
    end
  end
  return result
end

function M:convert(data)
  local ret = {}
  for k, v in pairs(data) do
    if v.aptitude_value_limit and v.aptitude_list then
      v.aptitude_limit = {}
      for i, name in ipairs(v.aptitude_list) do
        for k, value in ipairs(v.aptitude_value_limit) do
          if k == i then
            v.aptitude_limit[name] = split(value, '~')
          end
        end
      end
      v.aptitude_value_limit = nil
      -- v.aptitude_list = nil
    end
    ret[k] = v
  end
  return ret
end

return M