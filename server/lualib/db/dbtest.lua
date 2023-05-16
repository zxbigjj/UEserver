local dbtest = DECLARE_MODULE("db.dbtest")

local mysql_db = require("db.mysql_db")

-- 测试事务
function dbtest.test_transaction()
    -- 查询失败依然强行提交
    local client = mysql_db.get_db_client("gamedb")
    skynet.fork(function() client:query("begin") end)
    skynet.fork(function() client:query("update t_Role set exp=12345 where uuid='3000001'") end)
    skynet.fork(function() client:query("update t_Role set exp='abc' where uuid='3000001'") end)
    skynet.fork(function()
        client:query("commit")
        PRINT(client:query("select exp from t_Role where uuid='3000001'"))
    end)
    -- 第三条失败， 第二条生效, select结果是12345
end

-- 测试并发


return dbtest