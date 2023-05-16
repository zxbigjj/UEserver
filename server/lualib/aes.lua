local core = require("aes.core")
local BLOCKLEN = 16

local M = DECLARE_MODULE("aes")

local AesCtr = DECLARE_CLASS(M, 'AesCtr')
function AesCtr.new(key, iv, decrypt_mode)
    assert(type(key) == 'string')
    assert(type(iv) == 'string')
    local self = {}
    self.ctx = core.aes_new_ctx(key, iv)
    self.decrypt_mode = decrypt_mode
    return setmetatable(self, AesCtr)
end

function AesCtr:encrypt(data)
    assert(not self.decrypt_mode)
    return core.aes_ctr_xcrypt(self.ctx, data)
end

function AesCtr:decrypt(data)
    assert(self.decrypt_mode)
    return core.aes_ctr_xcrypt(self.ctx, data)
end


local pkcs7_padding = {}
for i=1,16 do
	local chars = {}
	for j=1,i do
		table.insert(chars, string.char(i))
	end
	pkcs7_padding[i] = table.concat(chars, "")
end
local AesCbc = DECLARE_CLASS(M, 'AesCbc')
function AesCbc.new(key, iv, decrypt_mode)
    assert(type(key) == 'string')
    assert(type(iv) == 'string')
    local self = {}
    self.ctx = core.aes_new_ctx(key, iv)
    self.decrypt_mode = decrypt_mode
    self._no_padding = nil
    return setmetatable(self, AesCbc)
end

function AesCbc:encrypt(data)
    assert(not self.decrypt_mode)
    if not self._no_padding then
    	local sz = string.len(data)
    	sz = sz % BLOCKLEN
    	data = data .. pkcs7_padding[BLOCKLEN - sz]
    end
    return core.aes_cbc_encrypt(self.ctx, data)
end

function AesCbc:decrypt(data)
    assert(self.decrypt_mode)
    local rawdata = core.aes_cbc_decrypt(self.ctx, data)
    if not self._no_padding then
    	local last_byte = string.byte(rawdata, -1, -1)
    	rawdata = string.sub(rawdata, 1, -last_byte-1)
    end
    return rawdata
end

function AesCbc:no_padding(value)
	self._no_padding = value
end

-- decrypt_mode == true for decrypt
function M.new_aes_ctr(key, iv, decrypt_mode)
    return AesCtr.new(key, iv, decrypt_mode)
end

-- decrypt_mode == true for decrypt
function M.new_aes_cbc(key, iv, decrypt_mode)
    return AesCbc.new(key, iv, decrypt_mode)
end

local function test()
    skynet.timeout(1, function()
        local aes = require("aes")
        local list = {}
        for i=1, 32 do
            table.insert(list, string.char(math.random(0, 255)))
        end
        local key, iv = "abcdabcdabcdabcd", "1234123412341234"
        local a = aes.new_aes_cbc(key, iv, false)
        local b = aes.new_aes_cbc(key, iv, true)
        
        local x
        for i=1, 1 do
            x = a:encrypt("helloworld123456")
            PRINT(x, string.len(x), string.hex(x))
        end
    end)
end

return M