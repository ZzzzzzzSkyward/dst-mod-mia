local delicious_abyss_dishes = dig("foods")
for k, recipe in pairs(delicious_abyss_dishes) do AddCookerRecipe("rikocookpot", recipe) end
modimport("scripts/mia_recipes.lua")
modimport("scripts/hamlet_dodge.lua")
local postinit = {components = {"portablestructure"}}
for k, v in pairs(postinit) do
    for k2, v2 in pairs(v) do require("mia_postinit/" .. k .. "/" .. v2)(require(k .. "/" .. v2)) end
end
local containers = require("containers")
containers.params.riko_sack = containers.params.krampus_sack or {
    widget = {slotpos = {}, animbank = "ui_krampusbag_2x8", animbuild = "ui_krampusbag_2x8", pos = Vector3(-5, -120, 0)},
    issidewidget = true,
    type = "pack",
    openlimit = 1
}
containers.params.rikocookpot = containers.params.portablecookpot
AddPrefabPostInit("shadowmeteor", function(inst)
    if not TheWorld.ismastersim then return inst end
    local oldSetSize = inst.SetSize
    inst.SetSize = function(inst, sz, mod)
        local size = 0.7
        if sz ~= nil then
            if sz == "medium" then
                size = 1
            elseif sz == "large" then
                size = 1.3
            end
        end
        local x1, y1, z1 = inst.Transform:GetWorldPosition()
        local entis = TheSim:FindEntities(x1, y1, z1, size * TUNING.METEOR_RADIUS)
        for i, v in ipairs(entis) do if v.prefab == "rikocookpot" then return end end
        oldSetSize(inst, sz, mod)
    end
end)
AddPrefabPostInit("beefalo", function(inst)
    if inst.components and inst.components.eater then
        local OldOnEat = inst.components.eater.oneatfn
        inst.components.eater:SetOnEatFn(function(inst, food)
            if food:HasTag("nanachisoup") then inst.components.domesticatable:DeltaDomestication(0.05) end
            OldOnEat(inst, food)
        end)
    end
end)
local xz_exp = require("widgets/xz_exp")
local function AddExp(self)
    if self.owner and self.owner:HasTag("mia_reg") then
        self.xz_exp = self.status:AddChild(xz_exp(self.owner))
        self.xz_exp:SetPosition(-80, -40, 0)
    end
end
AddClassPostConstruct("widgets/controls", AddExp)
local function onupdate(inst)
    inst.components.health:SetMaxHealth(150 + inst.components.exp.levelpoint * 50)
    inst.components.hunger:SetMax(100 + inst.components.exp.levelpoint * 25)
    inst.components.sanity:SetMax(100 + inst.components.exp.levelpoint * 25)
    inst.components.combat.damagemultiplier = 1 + inst.components.exp.levelpoint * 0.25
    inst.components.exp.maxtimepiont = inst.components.exp.levelpoint * 20 + 20
end
AddPlayerPostInit(function(inst)
    if inst:HasTag("mia_reg") then
        inst.exp_max = net_shortint(inst.GUID, "exp_max", "exp_maxdirty")
        inst.exp_current = net_shortint(inst.GUID, "exp_current", "exp_currentdirty")
        inst.exp_level = net_shortint(inst.GUID, "exp_level", "exp_leveldirty")
        if TheWorld.ismastersim then
            inst:AddComponent("exp")
            inst.components.exp.updatefn = onupdate
            inst.components.exp.maxlevel = 2
        end
    end
end)
FUELTYPE.POWER = "power"
table.insert(FUELTYPE, FUELTYPE.POWER)
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
TUNING.NANACHIFRIEND = GetModConfigData("attract") == "true"
if not package.loaded["scripts/apis.lua"] then return end
do return end
modimport("scripts/mia_test.lua")
