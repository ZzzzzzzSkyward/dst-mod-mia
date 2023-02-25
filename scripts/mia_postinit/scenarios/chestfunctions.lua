return function(t)
    if not t or not t.AddChestItems then return end
    local old = t.AddChestItems
    t.AddChestItems = function(chest, loot, num, ...)
        if type(loot) == "table" then
            table.insert(loot, {
                -- Weapon Items
                item = {"blazereap", "blazereap", "blazereap"},
                chance = 0.04,
                count = math.random(1, 3),
                initfn = function(item)
                    item.components.finiteuses:SetUses(math.random(item.components.finiteuses.total * 0.1,
                        item.components.finiteuses.total * 1))
                end
            })
        end
        return old(chest, loot, num, ...)
    end
end
