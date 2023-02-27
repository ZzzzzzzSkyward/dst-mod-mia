local cache = {}
local function SearchItem(p)
    if nil ~= cache[p] then return cache[p] end
    for k, v in pairs(Ents) do
        if v.prefab == p then
            cache[p] = true
            return true
        end
    end
    cache[p] = false
    return false
end
local function RetrofitStartingInv(inst)
    local inv = inst.starting_inventory
    if not inv then return end
    for k, v in ipairs(inv) do
        if not inst.components.inventory:Has(v, 1) and not SearchItem(v) then
            local item = SpawnPrefab(v)
            inst.components.inventory:GiveItem(item)
        end
    end
end
return function(inst)
    if GetModConfigData("complement") == "true" then
        inst:DoTaskInTime(0, function()
            if TheWorld.components.timer:TimerExists("retrofitrikodone") then return end
            for k, v in pairs(Ents) do if v.prefab == "riko" then RetrofitStartingInv(v) end end
            TheWorld.components.timer:StartTimer("retrofitrikodone", 1, true)
        end)
    else
        if TheWorld.components.timer:TimerExists("retrofitrikodone") then
            TheWorld.components.timer:StopTimer("retrofitrikodone")
        end
    end
end
