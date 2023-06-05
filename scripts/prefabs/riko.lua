local MakePlayerCharacter = require"prefabs/player_common"
local assets = {Asset("SCRIPT", "scripts/prefabs/player_common.lua"), Asset("ANIM", "anim/riko.zip"),
                Asset("SOUND", "sound/willow.fsb"), Asset("ANIM", "anim/ghost_riko_build.zip"),
                Asset("ANIM", "anim/player_idles_warly.zip")}
local prefabs = {}
local start_inv = TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.RIKO or {}
for i, v in ipairs(start_inv) do table.insert(prefabs, v) end
local common_postinit = function(inst)
  inst.MiniMapEntity:SetIcon("riko.png")
  inst:AddTag("riko") -- referenced by inventoryitem to specify restrictedtag
  inst:AddTag("soulless") -- non human representation
  inst:AddTag("expertchef") -- cook faster on fire
  --inst:AddTag("masterchef")--#PLANNED remove warly items
  inst:AddTag("nowormholesanityloss") -- from walter
  inst.AnimState:AddOverrideBuild("player_idles_warly") -- warly idle
  if TheNet:GetServerGameMode() == "quagmire" then inst:AddTag("quagmire_shopper") end
end
local master_postinit = function(inst)
  inst.customidleanim = "idle_warly"
  inst.starting_inventory = start_inv
  inst.soundsname = "willow"
  inst.components.health:SetMaxHealth(TUNING.RIKO_HEALTH)
  inst.components.hunger:SetMax(TUNING.RIKO_HUNGER)
  inst.components.sanity:SetMax(TUNING.RIKO_SANITY)
  inst.components.combat.damagemultiplier = TUNING.RIKO_DAMAGE_MULTIPLIER
  inst.components.sanity.night_drain_mult = TUNING.RIKO_NIGHT_SANITY_MULT
  inst.components.sanity.neg_aura_mult = TUNING.RIKO_NEG_SANITY_MULT
  inst.components.sanity:SetPlayerGhostImmunity(true)

end
return MakePlayerCharacter("riko", prefabs, assets, common_postinit, master_postinit, start_inv)
