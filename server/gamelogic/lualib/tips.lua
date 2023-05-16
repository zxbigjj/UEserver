local M = DECLARE_MODULE("tips")

M.ok = 0
M.ok_resp = {errcode=M.ok}
M.error = 1
M.error_resp = {errcode=M.error}

M.server_error = "服务器错误"
------------------------------------------------------运维-----
M.yunwei_uuid_not_exist = "角色uuid不存在"
M.yunwei_forbid_login = "此角色已被禁止登陆"
---------------------------------------------------------礼包码
M.gift_key_wrong = "礼包码错误"
M.gift_key_used = "礼包码已被使用"
M.gift_key_expire = "礼包码已过期"
M.gift_key_too_early = "礼包码还未到可用时间"
M.gift_key_same = "您已经用过此类礼包码了"

return M