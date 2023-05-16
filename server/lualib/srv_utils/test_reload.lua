-- 热更新标准模块示例
local skynet = require("skynet")

local some_value = 111

-- 本模块
local M = DECLARE_MODULE("srv_utils.test_reload")
-- 模块属性, running属性热更新后保持不变
DECLARE_RUNNING_ATTR(M, "running_attr", 222)
M.const_attr = 333

-- 模块函数
function M.func()
	M.const_attr = M.const_attr + 1
	print("热更新绑定变量", some_value)
	print("热更新普通属性", M.const_attr)
	print("热更新运行时属性", M.running_attr)
end

-- 类定义, 比模块多一个DECLARE_CLASS, 其他类似
local MyClass = DECLARE_CLASS(M, "MyClass")
-- 类属性和方法，running属性热更新后保持不变
DECLARE_RUNNING_ATTR(MyClass, "class_running", 444)
MyClass.class_const = 555
function MyClass.New()
	self = setmetatable({}, MyClass)
	-- 实例属性
	self.obj_attr = 666
	return self
end
function MyClass:func()
	print("热更新类", self.obj_attr, self.class_running, self.class_const)
end

if M.__RELOADING then
	print("===热更新结束===")
	M.running_attr = M.running_attr + 1000
else
	skynet.fork(function()
		local obj = MyClass.New()
		while true do
			M.running_attr = M.running_attr + 1
			M.func()
			obj.class_running = obj.class_running + 1
			obj:func()
			skynet.sleep(100)
		end
	end)
end

return M