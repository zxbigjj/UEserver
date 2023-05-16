
local Vector2 = {}
Vector2.__index = Vector2

function Vector2.New(x, z)
    local v = {x = 0, z = 0}
    setmetatable(v, Vector2)
    v:Set(x,z)
    return v
end

function Vector2:Set(x, z)
    self.x = x or 0
    self.z = z or 0
end

function Vector2:SetNormalize()
    local num = self:Magnitude()    
    
    if num == 1 then
        return self
    elseif num > 1e-05 then    
        self:Div(num)
    else    
        self:Set(0,0)
    end 

    return self
end

function Vector2:Div(num)
    self.x = self.x / num
    self.z = self.z / num
    return self
end

function Vector2:Closs(v2)
    return self.x * v2.z - self.z * v2.x
end

function Vector2:Dot(v2)
    return self.x * v2.x + self.z * v2.z
end

function Vector2:SqrMagnitude()
    return self.x * self.x + self.z * self.z
end

function Vector2:Magnitude()
    return math.sqrt(self.x * self.x + self.z * self.z)
end

Vector2.__call = function(t,x,z)
    return Vector2.New(x,z)
end

Vector2.__tostring = function(self)
    return string.format("[%f,%f]", self.x, self.z)
end

Vector2.__div = function(va, d)
    return Vector2.New(va.x / d, va.z / d)
end

Vector2.__mul = function(va, d)
    return Vector2.New(va.x * d, va.z * d)
end

Vector2.__add = function(va, vb)
    return Vector2.New(va.x + vb.x, va.z + vb.z)
end

Vector2.__sub = function(va, vb)
    return Vector2.New(va.x - vb.x, va.z - vb.z)
end

Vector2.__unm = function(va)
    return Vector2.New(-va.x, -va.z)
end

Vector2.__eq = function(va,vb)
    return va.x == vb.x and va.z == vb.z
end

return Vector2