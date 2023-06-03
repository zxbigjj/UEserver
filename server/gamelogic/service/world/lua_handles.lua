local skynet = require("skynet")
local excel_data = require('excel_data')
local gift_key = require("gift_key")
local json = require("json")
local pay_order = require("pay_order")

local lua_handles = DECLARE_MODULE("lua_handles")

local function make_item_list(item_list)
    local attach = {}
    for _, info in ipairs(item_list or {}) do
        local item_id = tonumber(info.item_id)
        local count = tonumber(info.count)
        if not excel_data.ItemData[item_id] then
            return false, "item_id not exist:" .. tostring(info.item_id)
        end
        if count < 1 then
            return false, "item count <= 0"
        end
        table.insert(attach, {item_id=item_id, count=count})
    end
    if not next(attach) then
        attach = nil
    end
    return true, attach
end

function lua_handles.lc_make_gift_key(args)
    --local group_name = string.lower(args.group_name)
    --if string.len(group_name) ~= 3 or not gift_key.check_str_valid(group_name) then
        --return false, 'group_name is invalid'
    --end

    local group_name = ''
    local total_count = args.total_count
    if total_count > 100000 then
        return false, 'total_count must < 100000'
    end

    if args.end_ts < args.start_ts then
        return false, "start_ts must < end_ts"
    end

    local ok, data = make_item_list(args.item_list)
    if not ok then
        return false, data
    end
    local item_list = data

    local key_list = gift_key.add_gift_batch(
        group_name, 
        args.total_use_count, 
        args.total_count, 
        args.start_ts, 
        args.end_ts, 
        item_list)
    return true, {key_list=key_list}
end

function lua_handles.lc_query_gift_key(args)
    local key = string.lower(args.key)
    if not gift_key.check_str_valid(key) then
        return false, "key isnot valid"
    end
    local info = gift_key.query_gift_key(key)
    if info then
        return true, info
    else
        return false, "key not exist"
    end
end

function lua_handles.lc_query_gift_key_close_dict(args)
    return gift_key.query_close_dict()
end

function lua_handles.lc_query_gift_key_close(args)
    local close_dict = gift_key.query_close_dict()
    local list = {}
    for k,v in pairs(close_dict) do
        table.insert(list, {channel=k, is_close=v})
    end
    return true, {close_list = list}
end

function lua_handles.lc_switch_gift_key(args)
    local close_dict = gift_key.set_close_status(args.channel, args.is_close)
    local list = {}
    for k,v in pairs(close_dict) do
        table.insert(list, {channel=k, is_close=v})
    end
    return true, {close_list = list}
end

function lua_handles.lc_use_gift_key(key)
    return gift_key.use_gift_key(key)
end

function lua_handles.lc_save_pay_order(args)
    local orderTable = {}
    local transactionId = args.transactionId
    orderTable["transactionId"] = transactionId
    local userId = args.userId
    orderTable["userId"] = userId
    local gameId = args.gameId
    orderTable["gameId"] = gameId

    local products = args.products
    print("products")
    print(products[1])
    local itemId ;
    local itemName ;
    local unitPrice ;
    local quantity ;
    local imageUrl ;
    local description;
    local info = products;
    --for _, info in ipairs(products or {}) do
        print(info["itemId"])
        itemId = info["itemId"]
        itemName = info["itemName"]
        unitPrice = info["unitPrice"]
        quantity = info["quantity"]
        imageUrl = info["imageUrl"]
        description = info["description"]
    --end
    orderTable["itemId"] = itemId
    orderTable["itemName"] = itemName
    orderTable["unitPrice"] = unitPrice
    orderTable["quantity"] = quantity
    --orderTable["imageUrl"] = imageUrl
    --orderTable["description"] = description
    print(description)
    return pay_order.savePayOrder(orderTable), orderTable
end

function lua_handles.lc_query_pay_order(args)
    local orderId = args.order_id
    return pay_order.queryPayOrder(orderId)
end


return lua_handles