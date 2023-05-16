local M = DECLARE_MODULE("table_extend")

local skynet = require("skynet")

function M.PrintTable(tb)
    print(STR(tb))
end

-------------------------------------------------
-- LRU是Least Recently Used 近期最少使用算法
-- 双向循环链表实现,最近使用的在尾部
-- [prev, next, key, value, ts]
local LRU = DECLARE_CLASS(M, "LRU")
DECLARE_FINISH(LRU)
function LRU.new(reverse, max_count)
    local self = {}
    self.__elem_dict = {}
    self.__count = 0
    self.__max_count = max_count or 1000*1000*1000
    self.__reverse = reverse
    self.__root = {}
    self.__root[1] = self.__root
    self.__root[2] = self.__root
    setmetatable(self, LRU)
    return self
end

function LRU.touch(self, k)
    local elem = self.__elem_dict[k]
    if not elem then return end
    self[k] = nil
    self[k] = elem[4]
    return elem[4]
end

function LRU.__index(self, k)
    local elem = self.__elem_dict[k]
    if elem then return elem[4] end
end

function LRU.__newindex(self, k, v)
    if v == nil then
        local elem = self.__elem_dict[k]
        if elem then
            -- 删除
            elem[1][2] = elem[2]
            elem[2][1] = elem[1]
            self.__elem_dict[k] = nil
            self.__count = self.__count - 1
        end
    else
        local elem = self.__elem_dict[k]
        if elem then
            -- 删除
            elem[1][2] = elem[2]
            elem[2][1] = elem[1]
            self.__elem_dict[k] = nil
            self.__count = self.__count - 1
        end
        -- 添加到尾部
        local root = self.__root
        local last = root[1]
        if elem then
            elem[1], elem[2], elem[4], elem[5] = last, root, v, skynet.time()
        else
            elem = {last, root, k, v, skynet.time()}
        end
        last[2], root[1] = elem, elem
        self.__elem_dict[k] = elem
        self.__count = self.__count + 1
        if self.__count > self.__max_count then
            LRU.pop(self)
        end
    end
end

function LRU.__pairs(self)
    if self.__reverse then
        local _next = function(self, k)
            local prev = k and self.__elem_dict[k] or self.__root
            local elem = prev[1]
            return elem[3], elem[4]
        end
        return _next, self, nil
    else
        local _next = function(self, k)
            local prev = k and self.__elem_dict[k] or self.__root
            local elem = prev[2]
            return elem[3], elem[4]
        end
        return _next, self, nil
    end
end

function LRU.__len(self)
    return self.__count
end

-- 参数意义等同于string.sub
-- function LRU.sub(self, start, stop)
--     start = start or 1
--     if start < 0 then start = self.__count + start + 1 end
--     if start < 1 then start = 1 end

--     stop = stop or -1
--     if stop < 0 then stop = self.__count + stop + 1 end
--     if stop > self.__count then stop = self.__count end
    
--     if start > stop then
--         return function(...) end, self, nil
--     end
--     local index = 1
--     local elem = self.__root
--     local reverse = self.__reverse
--     -- 1 <= start <= stop <= count
--     while true do
--         if index == start then
--             return function(self, _)
--                 if index > stop then return end
--                 index = index + 1
--                 elem = reverse and elem[1] or elem[2]
--                 return elem[3], elem[4]
--             end, self, nil
--         end
--         index = index + 1
--         elem = reverse and elem[1] or elem[2]
--     end
--     return function(...) end, self, nil
-- end

function LRU.clear(self)
    self.__elem_dict = {}
    self.__count = 0
    self.__root = {}
    self.__root[1] = self.__root
    self.__root[2] = self.__root
end

-- 从list中删除，count减1，pairs也迭代不到
-- 但依然可以通过[key]读取和真正删除
-- function LRU.hide(self, key)
--     local value = self[key]
--     self[key] = nil
--     rawset(self, key, value)
-- end

-- -- hide的反操作
-- function LRU.show(self, key)
--     local value = self[key]
--     rawset(self, key, nil)
--     self[key] = value
-- end

-- pop最老的元素
function LRU.pop(self)
    local elem = self.__reverse and self.__root[1] or self.__root[2]
    if elem == self.__root then
        return
    end
    -- 删除
    elem[1][2] = elem[2]
    elem[2][1] = elem[1]
    self.__elem_dict[elem[3]] = nil
    self.__count = self.__count - 1
    return elem[3], elem[4]
end

-- peek最老的元素
function LRU.peek(self)
    local elem = self.__reverse and self.__root[1] or self.__root[2]
    if elem == self.__root then
        return
    end
    return elem[3], elem[4], elem[5]
end

function LRU.map(self, func)
    local root = self.__root
    if self.__reverse then
        local elem = root[1]
        while elem ~= root do
            func(elem[3], elem[4])
            elem = elem[1]
        end
    else
        local elem = root[2]
        while elem ~= root do
            func(elem[3], elem[4])
            elem = elem[2]
        end
    end
end

-- function LRU.__call(self, cmd, ...)
--     local func = LRU[cmd]
--     if func then
--         return func(self, ...)
--     else
--         error("unknow cmd:" .. cmd)
--     end
-- end

-------------------------------------- 双向链表，头尾操作
-- [prev, next, value]
local LinkedList = DECLARE_CLASS(M, "LinkedList")
DECLARE_FINISH(LinkedList)
function LinkedList.new(max_count)
    local self = {}
    self.__count = 0
    self.__max_count = max_count or 1000*1000*1000
    self.__root = {}
    self.__root[1] = self.__root
    self.__root[2] = self.__root
    setmetatable(self, LinkedList)
    return self
end

-- __pairs使用闭包存在gc回收问题的风险？
-- 使用map函数
-- function LinkedList.__pairs(self)
--     local next_elem = self.__root[2]
--     local idx = 0
--     local _next = function(self, k)
--         if next_elem == self.__root then
--             return nil, nil
--         end
--         local elem = next_elem
--         next_elem = elem[2]
--         idx = idx + 1
--         return idx, elem[3]
--     end
--     return _next, self, nil
-- end

function LinkedList.__len(self)
    return self.__count
end

function LinkedList.map(self, func)
    local root = self.__root
    local elem = root[2]
    local index = 0
    while elem ~= root do
        index = index + 1
        func(index, elem[3])
        elem = elem[2]
    end
end

function LinkedList.clear(self)
    self.__count = 0
    self.__root = {}
    self.__root[1] = self.__root
    self.__root[2] = self.__root
end

local function _list_add(list, _prev, v)
    local _next = _prev[2]
    local elem = {_prev, _next, v}
    _prev[2], _next[1] = elem, elem
    list.__count = list.__count + 1
end

function LinkedList.peek(self)
    return self.__root[1][3]
end

function LinkedList.peekleft(self)
    return self.__root[2][3]
end

-- 尾部插入
function LinkedList.append(self, v)
    _list_add(self, self.__root[1], v)
    if self.__count > self.__max_count then
        return self:popleft()
    end
end

-- 头部插入
function LinkedList.appendleft(self, v)
    _list_add(self, self.__root, v)
    if self.__count > self.__max_count then
        return self:pop()
    end
end

local function _list_remove(list, elem)
    if elem == list.__root then
        return
    end
    elem[1][2] = elem[2]
    elem[2][1] = elem[1]
    list.__count = list.__count - 1
    return elem[3]
end

-- 尾部pop
function LinkedList.pop(self)
    return _list_remove(self, self.__root[1])
end

-- 头部pop
function LinkedList.popleft(self)
    return _list_remove(self, self.__root[2])
end

-- function LinkedList.__call(self, cmd, ...)
--     local func = LinkedList[cmd]
--     if func then
--         return func(self, ...)
--     else
--         error("unknow cmd:" .. cmd)
--     end
-- end

-------------------------------------- 双头队列，头尾操作
local Deque = DECLARE_CLASS(M, "Deque")
DECLARE_FINISH(Deque)
local max_deque_pos = 2000*1000*1000
function Deque.new()
    local self = {}
    self.__left = 1
    self.__right = 1
    self.__deque = {}
    setmetatable(self, Deque)
    return self
end

function Deque.__len(self)
    return self.__right - self.__left
end

function Deque.__index(self, k)
    if type(k) == 'string' then
        return Deque[k]
    else
        if k >= 1 and k <= self.__right - self.__left then
            return self.__deque[self.__left + k - 1]
        end
        return nil
    end
end

function Deque.__newindex(self, k, value)
    assert(k >= 1 and k <= self.__right - self.__left)
    self.__deque[self.__left + k - 1] = value
end

function Deque.__next(self, k)
    if not k then
        k = 1
    else
        k = k + 1
    end
    if k > self.__right - self.__left then
        return nil, nil
    end
    return k, self.__deque[self.__left + k - 1]
end

function Deque.__pairs(self)
    return Deque.__next, self, nil
end

-- function Deque.__call(self, cmd, ...)
--     local func = Deque[cmd]
--     if func then
--         return func(self, ...)
--     else
--         error("unknow cmd:" .. cmd)
--     end
-- end

function Deque.clear(self)
    self.__left = 1
    self.__right = 1
    self.__deque = {}
end

function Deque.__rerange(self)
    local left, right = self.__left, self.__right
    self.__right = right - left + 1
    self.__left = 1
    table.move(self.__deque, left, right, 1)
end

function Deque.append(self, v)
    self.__deque[self.__right] = v
    self.__right = self.__right + 1
    if self.__right > max_deque_pos then
        Deque.__rerange(self)
    end
end

function Deque.appendleft(self, v)
    self.__left = self.__left - 1
    self.__deque[self.__left] = v
    if self.__left < -max_deque_pos then
        Deque.__rerange(self)
    end
end

function Deque.peek(self)
    if self.__right > self.__left then
        return self.__deque[self.__right - 1]
    end
end

function Deque.peekleft(self)
    if self.__right > self.__left then
        return self.__deque[self.__left]
    end
end

function Deque.pop(self)
    if self.__right > self.__left then
        self.__right = self.__right - 1
        local value = self.__deque[self.__right]
        self.__deque[self.__right] = nil
        return value
    end
end

function Deque.popleft(self)
    if self.__right > self.__left then
        local value = self.__deque[self.__left]
        self.__deque[self.__left] = nil
        self.__left = self.__left + 1
        return value
    end
end

-------------------------------------------------

function M._test_lru()
    local x = LRU.new()
    x.d = 1
    x.b = 2
    x.c = 3
    x.a = 4
    x.e = 5
    
    for k,v in pairs(x) do
        print(k,v)
    end
    print("sub:")
    for k,v in LRU.sub(x, 2, 4) do
        print(k,v)
    end
    LRU.hide(x, "c")
    print("hide:")
    for k,v in LRU.sub(x, 2, 4) do
        print(k,v)
    end
    LRU.pop(x)
    print(#x)
    for k,v in pairs(x) do
        print("===", k)
        x[k] = nil
    end
    print(#x)
end

function M._test_list()
    local list = M.LinkedList.new()
    list:append(1)
    list:append(2)
    list:append(3)
    list:append(4)
    print(list:pop())
    print(list:popleft())
    list:appendleft(1)
    list:map(function(i,v) print(i,v) end)
end

function M._test_deque()
    local list = M.Deque.new()
    list:append(1)
    list:append(2)
    list:append(3)
    list:append(4)
    print(list:pop())
    print(list:popleft())
    list:appendleft(1)
    for k,v in ipairs(list) do
        print(k,v)
    end
end

-- M._test_lru()

return M