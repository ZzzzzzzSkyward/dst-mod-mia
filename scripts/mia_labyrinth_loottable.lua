local t = {
    {
        item = {"charcoal_sand"},
        chance = 0.07,
        count = math.random(1, 9),
        initfn = function(item)
        end
    },
    {
        item = {"sun_sphere"},
        chance = 0.1,
        count = 1,
        initfn = function(item)
            item.components.fueled:SetPercent(math.random(0, 0.02))
        end
    },
    {
        item = {"longetivity_drink"},
        chance = 0.02,
        count = 1,
        initfn = function(item)
        end
    },
    {
        item = {"tomorrow_signal"},
        chance = 0.005,
        count = math.random(1, 9),
        initfn = function(item)
        end
    },
    {
        item = {"blaze_reap"},
        chance = 0.04,
        count = 1,
        initfn = function(item)
            item.components.fueled:SetPercent(math.random(1, 10) / item.components.fueled.maxfuel)
        end
    }
}
--#PLANNED count number
-- protect
local prefabs = require("mia_artifacts")
for i, v in ipairs(t) do if not prefabs[v.item[1]] then table.remove(t, i) end end
return t
