local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SOUNDPACKAGE", "sound/nanachi.fev"),
    Asset("SOUND", "sound/nanachi.fsb"),
    Asset("ANIM", "anim/nanachi.zip"),
    Asset("ANIM", "anim/nanachihair.zip"),
    Asset("ANIM", "anim/ghost_nanachi_build.zip"),
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

local function onbecamehuman(inst)
    inst.components.locomotor.walkspeed = 4 * 1.35
    inst.components.locomotor.runspeed = 6 * 1.35

    local hat = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
    if hat ~= nil and hat:HasTag("nanachihat") then
        inst.AnimState:AddOverrideBuild("nanachihair")
        inst.AnimState:OverrideSymbol("swap_hat", "hat_nanachihat", "swap_hat")
        inst.AnimState:Show("HAT")
        inst.AnimState:Show("HAT_HAIR")
    end
end

local function onload(inst)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:RemoveTag("scarytoprey")
    if not inst:HasTag("playerghost") then onbecamehuman(inst) end
end

local common_postinit = function(inst)
    inst.MiniMapEntity:SetIcon("nanachi.png")
    inst:AddTag("nanachi")
    inst:RemoveTag("scarytoprey")
end

local master_postinit = function(inst)
    inst.soundsname = "nanachi"
    inst.talker_path_override = "nanachi/"
    inst.components.health:SetMaxHealth(150)
    inst.components.hunger:SetMax(150)
    inst.components.sanity:SetMax(300)
    inst.components.combat.damagemultiplier = 1
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = TUNING.SANITYAURA_MED

    inst.components.locomotor.walkspeed = 4 * 1.35
    inst.components.locomotor.runspeed = 6 * 1.35

    if TUNING.NANACHIFRIEND == 1 and inst.task == nil then inst.task = inst:DoPeriodicTask(1, FindFriend) end

    inst.OnLoad = onload
    inst.OnNewSpawn = onload
end

return MakePlayerCharacter("nanachi", prefabs, assets, common_postinit, master_postinit, start_inv)
