local MakePlayerCharacter = require "prefabs/player_common"
local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("ANIM", "anim/riko.zip"),
    Asset("SOUND", "sound/willow.fsb"),
    Asset("ANIM", "anim/ghost_riko_build.zip")
}
local prefabs = {}
local start_inv = {"rikohat", "rikocookpot_item"}
local common_postinit = function(inst)
    inst.MiniMapEntity:SetIcon("riko.png")
    inst:AddTag("riko")
end
local master_postinit = function(inst)
    inst.soundsname = "willow"
    inst.starting_inventory = start_inv
    inst.components.health:SetMaxHealth(TUNING.RIKO_HEALTH)
    inst.components.hunger:SetMax(TUNING.RIKO_HUNGER)
    inst.components.sanity:SetMax(TUNING.RIKO_SANITY)
    inst.components.combat.damagemultiplier = TUNING.RIKO_DAMAGE_MULTIPLIER
end
return MakePlayerCharacter("riko", prefabs, assets, common_postinit, master_postinit, start_inv)
