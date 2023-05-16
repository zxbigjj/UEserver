-- 暂时先用dkjson
local cjson = require("cjson").new()
cjson.encode_sparse_array('on', 1, 1)
return cjson