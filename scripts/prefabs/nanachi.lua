local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SOUNDPACKAGE", "sound/nanachi.fev"),
    Asset("SOUND", "sound/nanachi.fsb"),
    Asset("ANIM", "anim/nanachi.zip"),
    Asset("ANIM", "anim/nanachihair.zip"),
    Asset("ANIM", "anim/ghost_nanachi_build.zip"),
    Asset("ANIM", "anim/player_actions_roll.zip")
}
local prefabs = {"nanachihat"}
local start_inv = {"nanachihat"}

local function FindFriend(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 3, {"pig"}, {"player", "werepig", "guard", "nanachifriend"})
    for k, v in pairs(ents) do
        if not v:IsAsleep() and not v.components.sleeper:IsAsleep() then
            if inst.components.leader:CountFollowers() >= 1 then return end
            if v.components.health and not v.components.health:IsDead() then
                inst:PushEvent("makefriend")
                inst.components.leader:AddFollower(v)
                v.components.follower:AddLoyaltyTime(240)
                v:AddTag("nanachifriend")
                v:DoTaskInTime(480, function()
                    v:RemoveTag("nanachifriend")
                end)
            end
        end
    end
end
local function forcefast(inst)
    inst.components.locomotor.walkspeed = TUNING.WILSON_WALK_SPEED * TUNING.NANACHI_SPEED_MULTIPLIER
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED * TUNING.NANACHI_SPEED_MULTIPLIER
end
local function GetPointSpecialActions(inst, pos, useitem, right)
    if right then
        local rider = inst.replica.rider
        if rider == nil or not rider:IsRiding() then return {ACTIONS.DODGE} end
    end
    return {}
end

local function OnSetOwner(inst)
    if inst.components.playeractionpicker ~= nil then
        inst.components.playeractionpicker.pointspecialactionsfn = GetPointSpecialActions
    end
end
local function onequip(inst, data)
    local slot = data.eslot or false
    local hat = data.item
    if slot == EQUIPSLOTS.HEAD and hat then
        if hat:HasTag("nanachihat") then
            inst.AnimState:AddOverrideBuild("nanachihair")
            inst.AnimState:OverrideSymbol("swap_hat", "hat_nanachihat", "swap_hat")
            inst.AnimState:Show("HAT")
            inst.AnimState:Show("HAT_HAIR")
        end
    end
end
local common_postinit = function(inst)
    inst.MiniMapEntity:SetIcon("nanachi.png")
    inst:AddTag("nanachi")
    inst:AddTag("soulless")-- non human representation
    inst:RemoveTag("scarytoprey")
    -- compatible with hamlet
    inst.dodgetime = net_bool(inst.GUID, "player.dodgetime", "dodgetimedirty")
    inst.last_dodge_time = GetTime()
    inst:ListenForEvent("dodgetimedirty", function()
        inst.last_dodge_time = GetTime()
    end)
    inst:ListenForEvent("setowner", OnSetOwner)
end

local master_postinit = function(inst)
    inst.soundsname = "nanachi"
    -- disable invincible dodge
    inst._dodgenotinvincible = true
    inst.talker_path_override = "nanachi/"
    inst.components.health:SetMaxHealth(TUNING.NANACHI_HEALTH)
    inst.components.hunger:SetMax(TUNING.NANACHI_HUNGER)
    inst.components.sanity:SetMax(TUNING.NANACHI_SANITY)
    -- inst.components.combat.damagemultiplier = 1
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = TUNING.SANITYAURA_MED
    inst.components.locomotor:SetTriggersCreep(false)

    if TUNING.NANACHIFRIEND and inst.task == nil then inst.task = inst:DoPeriodicTask(5, FindFriend) end
    inst:ListenForEvent("ms_respawnedfromghost", forcefast)
    inst:ListenForEvent("death", forcefast)
    inst:ListenForEvent("equip", onequip)
    inst.OnLoad = forcefast
    inst:ListenForEvent("playeractivated", forcefast)
end

return MakePlayerCharacter("nanachi", prefabs, assets, common_postinit, master_postinit, start_inv)
