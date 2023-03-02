RELICSLOTS = RELICSLOTS or {SKIN = "SKIN", EYE = "EYE", ARM = "ARM", BODY = "BODY"}
GLOBAL.RELICSLOTS = RELICSLOTS

local delicious_abyss_dishes = dig("foods")
for k, recipe in pairs(delicious_abyss_dishes) do AddCookerRecipe("rikocookpot", recipe) end
modimport("scripts/mia_recipes.lua")
modimport("scripts/hamlet_dodge.lua")
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
FUELTYPE.POWER = "power"
AddPrefabPostInit("gunpowder", function(inst)
    inst:AddComponent("fuel")
    inst:AddTag("power_fuel")
    if inst.components.fuel then
        inst.components.fuel.fuelvalue = 10
        inst.components.fuel.fueltype = FUELTYPE.POWER
    end
end)
local REGBOMB = Action({distance = 36})
REGBOMB.id = "REGBOMB"
REGBOMB.str = "bomb"
REGBOMB.fn = function(act)
    if act.doer ~= nil and act.doer:HasTag("regerbomb") and act.target ~= nil and act.doer:HasTag('player')
        and act.target.components.combat and act.target.components.health then
        local headitem = nil
        if act.doer.components.inventory then
            headitem = act.doer.components.inventory.equipslots[EQUIPSLOTS.HEAD]
        elseif act.doer.replica.inventory then
            headitem = act.doer.replica.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        end
        act.doer.target = act.target
        act.doer.components.health:DoDelta(-TUNING.REGBOMB_HELATH)
        act.doer.components.hunger:DoDelta(-TUNING.REGBOMB_HUNGER)
        act.doer.components.sanity:DoDelta(-TUNING.REGBOMB_SANITY)
        headitem.components.fueled:DoDelta(-TUNING.REGBOMB_CONSUME)
        return true
    else
        return false
    end
end
AddAction(REGBOMB)
AddComponentAction("SCENE", "combat", function(inst, doer, actions, right)
    if right then
        if doer:HasTag("regerbomb") and inst.replica.health ~= nil and not inst:HasTag("player")
            and doer.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) == nil then
            table.insert(actions, ACTIONS.REGBOMB)
        end
    end
end)
local state_regbomb = State {
    name = "regbomb",
    tags = {"doing", "busy"},
    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:OverrideSymbol("swap_object", "reagerweapon", "reagerweapon")
        inst.AnimState:SetPercent("dart_pre", 1)
        inst.sg.statemem.action = inst.bufferedaction
        inst.sg:SetTimeout(2)
        if not TheWorld.ismastersim then inst:PerformPreviewBufferedAction() end
    end,
    timeline = {
        TimeEvent(0 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/charge")
        end),
        TimeEvent(8 * FRAMES, function(inst)
            if TheWorld.ismastersim then inst:PerformBufferedAction() end
        end),
        TimeEvent(15 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("busy")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/explode")
            if TheWorld.ismastersim then
                inst.regweapon.components.weapon:LaunchProjectile(inst.regerweapon, inst.target, inst)
                for i, v in ipairs(AllPlayers) do
                    local distSq = v:GetDistanceSqToInst(inst)
                    local k = math.max(0, math.min(1, distSq / 1600))
                    local intensity = k * (k - 2) + 1
                    if intensity > 0 then
                        v:ScreenFlash(intensity)
                        v:ShakeCamera(CAMERASHAKE.FULL, .7, .02, intensity / 2)
                    end
                end
                inst:PushEvent("yawn", {grogginess = 4, knockoutduration = 10})
            end
        end)
    },
    onupdate = function(inst)
        if not TheWorld.ismastersim then
            if inst:HasTag("doing") then
                if inst.entity:FlattenMovementPrediction() then inst.sg:GoToState("idle", "noanim") end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle", true)
            end
        end
    end,
    ontimeout = function(inst)
        if not TheWorld.ismastersim then inst:ClearBufferedAction() end
        inst.sg:GoToState("idle")
    end,
    onexit = function(inst)
        if inst.bufferedaction == inst.sg.statemem.action then inst:ClearBufferedAction() end
        inst.sg.statemem.action = nil
    end
}
AddStategraphState("wilson", state_regbomb)
AddStategraphState("wilson_client", state_regbomb)
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.REGBOMB, "regbomb"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.REGBOMB, "regbomb"))
if not package.loaded["scripts/apis.lua"] then return end
do return end
modimport("scripts/mia_test.lua")
