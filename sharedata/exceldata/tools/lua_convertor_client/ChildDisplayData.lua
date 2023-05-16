local M = {}

local kChildStatus = {
    New = 1,
    Baby = 2,
    Growing = 3,
    Child = 4,
    Adult = 5,
    Married = 6,
}   --与CSConst.ChildStatus保持一致

local kChildSex = {
    Man = 1,
    Woman = 2,
}

function M:convert(data)
    local ret = {}
    local kChild
    for k,v in pairs(data) do
        ret[k] = v
        ret[k][kChildSex.Man] = {
            [kChildStatus.Growing] = v.baby_boy_unit,
            [kChildStatus.Child] = v.boy_unit,
            [kChildStatus.Adult] = v.man_unit,
            [kChildStatus.Married] = v.man_unit,
        }
        ret[k][kChildSex.Woman] = {
            [kChildStatus.Growing] = v.baby_girl_unit,
            [kChildStatus.Child] = v.girl_unit,
            [kChildStatus.Adult] = v.woman_unit,
            [kChildStatus.Married] = v.woman_unit,
        }
    end
    return ret
end

return M