local RandomMgr = DECLARE_MODULE("CSCommon.Fight.RandomMgr")

function RandomMgr.New(seed)
  local self = setmetatable({}, RandomMgr)
  self.random_seed = seed
  if self.random_seed then
    self.seed = math.floor(self.random_seed) % 0x10000000
  else
    self.seed = math.random(0, 0x10000000 - 1)
    self.random_seed = self.seed
  end
  return self
end

function RandomMgr:Destroy()
  self.seed = nil
end

function RandomMgr:Random()
  self:__Randomize()
  return self.seed / 0x10000000
end

function RandomMgr:RandomInt(m, n)
  self:__Randomize()
  return math.floor(m + self.seed / 0x10000000 * (n + 1 - m))
end

function RandomMgr:RandomFloat(m, n)
  self:__Randomize()
  return m + self.seed / 0x10000000 * (n - m)
end

function RandomMgr:RandomSelect(table)
  local i = self:RandomInt(1, #table)
  return table[i]
end

function RandomMgr:__Randomize()
  self.seed = (22695477 * self.seed + 1) % 0x10000000
end

function RandomMgr:GetOriginalSeed()
  return self.random_seed
end

return RandomMgr