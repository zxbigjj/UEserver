local dirty_utils = DECLARE_MODULE("dirty_utils")

function dirty_utils.is_name_dirty(name)    
    -- local dmgr = require("CSCommon.data_mgr")
    -- return dmgr:CheckHasBadWord(name)
    return false
end

return dirty_utils