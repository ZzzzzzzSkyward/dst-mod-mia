RELICSLOTS = RELICSLOTS or {SKIN = "SKIN", EYE = "EYE", ARM = "ARM", BODY = "BODY"}
GLOBAL.RELICSLOTS = RELICSLOTS
local function import(path)
    return modimport("scripts/" .. path .. ".lua")
end
local delicious_abyss_dishes = dig("foods")
for k, recipe in pairs(delicious_abyss_dishes) do AddCookerRecipe("rikocookpot", recipe) end
import("mia_recipes")
import("hamlet_dodge")
import("mia_actions")
local preinit = {components = {"portablestructure"}, scenarios = {"chestfunctions"}}
local postinit = {Prefab = {"riko"}}
for k, v in pairs(preinit) do for k2, v2 in pairs(v) do dig("postinit/" .. k .. "/" .. v2)(require(k .. "/" .. v2)) end end
for k, v in pairs(postinit) do
    local key = k .. "PostInit"
    if not env.postinitfns[key] then env.postinitfns[key] = {} end
    for k2, v2 in pairs(v) do
        if not env.postinitfns[key][v2] then env.postinitfns[key][v2] = {} end
        table.insert(env.postinitfns[k .. "PostInit"][v2], dig("postinit/" .. k:lower() .. "/" .. v2))
    end
end
local containers = require("containers")
containers.params.riko_sack = containers.params.krampus_sack or {
    widget = {slotpos = {}, animbank = "ui_krampusbag_2x8", animbuild = "ui_krampusbag_2x8", pos = Vector3(-5, -120, 0)},
    issidewidget = true,
    type = "pack",
    openlimit = 1
}
containers.params.rikocookpot = containers.params.portablecookpot
-- blaze reap
FUELTYPE.POWER = "power"
AddPrefabPostInit("gunpowder", function(inst)
    inst:AddTag("power_fuel")
    if not TheWorld.ismastersim then return inst end
    if not inst.components.fuel then inst:AddComponent("fuel") end
    inst.components.fuel.fueltype = FUELTYPE.POWER
    inst.components.fuel.fuelvalue = 10
end)
