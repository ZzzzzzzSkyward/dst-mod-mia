local MakePlayerCharacter = require "prefabs/player_common"
local assets = {Asset("ANIM", "anim/reg.zip"), Asset("ANIM", "anim/ghost_reg_build.zip")}
local prefabs = {}
local start_inv = TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.RIKO or {}
for i, v in ipairs(start_inv) do table.insert(prefabs, v) end
local function onload(inst, data)
    if inst.components and inst.components.exp then inst.components.exp:ApplyUpgrades() end
end
local function oneat(inst, food)
    if food:HasTag("rikofood") then inst.components.exp:DoDelta(1) end
end
local function onlightingstrike(inst)
    local headitem = nil
    if inst.components.inventory then
        headitem = inst.components.inventory.equipslots[EQUIPSLOTS.HEAD]
    elseif inst.replica.inventory then
        headitem = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
    end
    if inst.components.health ~= nil and not (inst.components.health:IsDead() or inst.components.health:IsInvincible()) then
        if inst.components.inventory:IsInsulated() then
            inst:PushEvent("lightningdamageavoided")
        else
            inst.components.health:DoDelta(TUNING.HEALING_SUPERHUGE, false, "lightning")
            inst.components.sanity:DoDelta(-TUNING.SANITY_LARGE)
            if headitem and headitem:HasTag("reghat") then
                headitem.components.fueled:DoDelta(TUNING.REGBOMB_CONSUME)
                headitem.components.fueled.ontakefuelfn(headitem)
            end
        end
    end
end
local common_postinit = function(inst)
    inst.MiniMapEntity:SetIcon("reg.png")
    inst:AddTag("mia_reg")
    inst:AddTag("heatresistant")
    inst:AddTag("soulless") -- non human representation
    inst:AddTag("electricdamageimmune")
    inst:RemoveTag("poisonable")
    if TheNet:GetServerGameMode() == "quagmire" then inst:AddTag("quagmire_grillmaster") end
end
local master_postinit = function(inst)
    inst.starting_inventory = start_inv
    inst.soundsname = "walter" -- #TODO sound for reg
    inst.components.health:SetMaxHealth(TUNING.REG_HEALTH)
    inst.components.health.vulnerabletopoisondamage = false
    inst.components.health.poison_damage_scale = 0
    inst.components.hunger:SetMax(TUNING.REG_HUNGER)
    inst.components.sanity:SetMax(TUNING.REG_SANITY)
    inst.components.combat.damagemultiplier = TUNING.REG_DAMAGEMULTIPLIER
    inst.components.health:SetAbsorptionAmount(TUNING.REG_ABSORPTION)
    inst.components.health.fire_damage_scale = 0
    inst.components.eater:SetOnEatFn(oneat)
    inst.components.playerlightningtarget:SetHitChance(1)
    inst.components.playerlightningtarget:SetOnStrikeFn(onlightingstrike)
    inst.components.hunger.hungerrate = TUNING.REG_HUNGERRATE
    inst.components.temperature.inherentinsulation = -TUNING.INSULATION_MED
    inst.components.temperature.inherentsummerinsulation = -TUNING.INSULATION_MED
    inst.components.temperature:SetFreezingHurtRate(TUNING.REG_FREEZE_DAMAGE_RATE)
    inst.components.temperature:SetOverheatHurtRate(TUNING.REG_HEAT_DAMAGE_RATE)
    inst.regweapon = SpawnPrefab("regweapon")
    inst.regweapon.entity:SetParent(inst.entity)
    inst.OnLoad = onload
end
return MakePlayerCharacter("reg", prefabs, assets, common_postinit, master_postinit, start_inv)
