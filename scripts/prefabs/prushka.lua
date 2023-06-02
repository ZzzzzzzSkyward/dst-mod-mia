local MakePlayerCharacter = require "prefabs/player_common"
local assets = {
  Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
  Asset("ANIM", "anim/prushka.zip"),
  Asset("ANIM", "anim/ghost_prushka_build.zip")
}
local prefabs = {}
local start_inv = TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.PRUSHKA or {}
for i, v in ipairs(start_inv) do table.insert(prefabs, v) end
local common_postinit = function(inst)
  inst.MiniMapEntity:SetIcon("prushka.png")
  inst:AddTag("prushka") -- referenced by inventoryitem to specify restrictedtag
  if TheNet:GetServerGameMode() == "quagmire" then inst:AddTag("quagmire_shopper") end
end
local master_postinit = function(inst)
  inst.starting_inventory = start_inv
  inst.components.health:SetMaxHealth(TUNING.PRUSHKA_HEALTH)
  inst.components.hunger:SetMax(TUNING.PRUSHKA_HUNGER)
  inst.components.sanity:SetMax(TUNING.PRUSHKA_SANITY)
end
return MakePlayerCharacter("prushka", prefabs, assets, common_postinit, master_postinit, start_inv)
