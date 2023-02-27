local valid_chests = {"sunkenchest", "minotaurchest", "pandoraschest", "krakenchest"}
return function(t)
    if not t or not t.AddChestItems then return end
    local old = t.AddChestItems
    t.AddChestItems = function(chest, loot, num, ...)
        if chest and table.contains(valid_chests, chest.prefab) and type(loot) == "table" then
            local mia_loot = dig("labyrinth_loottable")
            for i, v in ipairs(mia_loot) do table.insert(loot, v) end
        end
        return old(chest, loot, num, ...)
    end
end
