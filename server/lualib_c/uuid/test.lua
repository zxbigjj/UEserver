local UUID = require "uuid"

-- init
local type_id = 1001
local action_id = 0xffffff

local ret = UUID.init(type_id, action_id)
print(ret)

UUID.config(1024)
for i=1, 40 do
    print(UUID.new())
end

local key_set = {}
for i=1, 100 do
    local max = math.random(10, 100)
    local k
    for j=1, max do
        k = UUID.new()
        assert(key_set[k] == nil, k)
        key_set[k] = true
        -- print(k)
    end
    UUID.config(max)
    print(i, max, k)
end
