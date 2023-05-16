#coding=utf-8
import requests
import hashlib
import json
import time

# 双方约定的密钥
key = '8dFACTRDdNiAiYv6pV046UfJ147RzE37'
# gm服务器地址
# url = 'http://127.0.0.1:40203/do_gm'
url = 'http://182.61.57.26:10112/do_gm'
# url = 'http://62.234.79.188:10112/do_gm'
# 本次请求的gm指令参数，gm_name为指令名，server_id为游戏服编号，content为test指令要求的参数
now = int(time.time())
gm_args = dict(
    gm_name = "query_rank_forbid",
    server_id = 1,
    rank_type = 2
    # uuid = '1000021',
    # title = '测试群发物品',
    # content = 'helloworldhelloworldhelloworldhelloworldhelloworldhelloworldhelloworldhelloworldhelloworldhelloworldhelloworldhelloworldhelloworldhelloworldhelloworldhelloworldhelloworldhelloworld',
    # from_server_id = 3,
    # from_uuid = '3000027',
    # name = "abcde",

    # family_id = "3100001",
    # content = "helloworld",
    # is_close = True,
    # channel = "ios",
    # key = 'abc00393tph59x07',
    # group_name = "abd",
    # total_use_count = 1,
    # total_count = 1000,
    # role_create_ts1 = now - 1000000,
    # role_create_ts2 = now + 1000000,
    # start_ts = now + 2,
    # end_ts = now + 10000000,
    # expire_ts = now + 10000000,
    # channel = "",
    # is_all_channel = True,
    # item_list = [{"item_id":303005, "is_binding":True, "count":12}]
)


# 将gm参数转为json字符串
data = json.dumps(gm_args)
# 当前时间戳
ts = int(time.time())
# 使用md5计算签名
md5 = hashlib.md5()
md5.update('ts=%s&key=%s&data=%s' % (ts, key, data))
sign = md5.hexdigest()

# 请求，data形参为post请求的参数
r = requests.post(url, json={"data":data, "ts":ts, "sign":sign})
# 返回的结果为json格式
result = json.loads(r.text)
# code字段为0则成功，否则失败
if result["code"] != 0:
    # 失败时err_msg字段为失败原因
    print("error:%s" % result["err_msg"])
else:
    # 成功的话，data字段为gm指令返回信息
    print("ok:%s" % result["data"])