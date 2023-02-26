local function require(x)
    package.loaded[x] = nil
    return require(x)
end
local valid_chests = {"sunkenchest", "minotaurchest", "pandoraschest"}
return function(t)
    if not t or not t.AddChestItems then return end
    local old = t.AddChestItems
    t.AddChestItems = function(chest, loot, num, ...)
        if chest and table.contains(valid_chests, chest.prefab) and type(loot) == "table" then
            local mia_loot = require("mia_labyrinth_loottable")
            for i, v in ipairs(mia_loot) do table.insert(loot, v) end
        end
        return old(chest, loot, num, ...)
    end
end
