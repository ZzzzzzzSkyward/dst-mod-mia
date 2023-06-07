local MakePlayerCharacter = require"prefabs/player_common"
local assets = {Asset("ANIM", "anim/reg.zip"), Asset("ANIM", "anim/ghost_reg_build.zip")}
local prefabs = {}
local start_inv = TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.REG or {}
for i, v in ipairs(start_inv) do table.insert(prefabs, v) end
------------------------------------------------------------------------------------------------------------------------
-- Lightning
local lightning_target_hits = 10
local lightning_forget_elapse = 3
local lightning_counter = 0
local function DoEnoughHit(inst)
  inst.components.hunger:DoDelta(TUNING.REG_HUNGER)
  inst.components.sanity:DoDelta(TUNING.REG_SANITY)
  inst.components.health:DoDelta(TUNING.REG_HEALTH, false, "lightning")
  inst.chargeleft = TUNING.REG_INSCINERATOR_USE
  lightning_counter = 0
  local t = inst.components.timer
  if t:TimerExists("forgetlightninghit") then t:StopTimer("forgetlightninghit") end
  -- #PLANNED add recharge anim and fx and effect
end
local function RecordLightningHit(inst)
  lightning_counter = lightning_counter + 1
  if lightning_counter >= lightning_target_hits then
    DoEnoughHit(inst)
    lightning_counter = 0
  else
    if inst.components.timer:TimerExists("forgetlightninghit") then
      inst.components.timer:SetTimeLeft("forgetlightninghit", lightning_forget_elapse)
    else
      inst.components.timer:StartTimer("forgetlightninghit", lightning_forget_elapse)
    end
  end
end
local function ForgetLightningHit(inst) lightning_counter = 0 end
local function onlightingstrike(inst)
  if inst.components.health ~= nil and not (inst.components.health:IsDead() or inst.components.health:IsInvincible()) then
    if inst.components.inventory:IsInsulated() then
      inst:PushEvent("lightningdamageavoided")
    else
      inst.components.health:DoDelta(TUNING.HEALING_TINY, false, "lightning")
      inst.components.sanity:DoDelta(-TUNING.SANITY_TINY)
      RecordLightningHit(inst)
    end
  end
end
------------------------------------------------------------------------------------------------------------------------
-- Inscienerator
local function DisableInscinerator(inst)
  if inst.inscinerator then inst.inscinerator:StopTargeting() end
end
local function KillInscinerator(inst)
  if inst.inscinerator then
    inst.inscinerator:StopTargeting()
    inst.inscinerator:Remove()
    inst.inscinerator = nil
  end
end
local function TrySpawnInscinerator(inst)
  if inst.inscinerator then return end
  if not TheWorld.ismastersim then
    local x, y, z = inst.Transform:GetWorldPosition()
    local alreadyexist = TheSim:FindEntities(x, y, z, 1)
    for k, v in pairs(alreadyexist) do
      if v.prefab == "inscinerator" and not v:GetParent() then
        inst.inscinerator = v
        return
      end
    end
    return
  end
  inst.chargeleft = inst.chargeleft or TUNING.REG_INSCINERATOR_USE
  local i = SpawnPrefab("inscinerator")
  inst.inscinerator = i
  i.entity:SetParent(inst.entity)
  i.Transform:SetPosition(0, 0, 0) -- force teleport to player
  if inst.chargeleft <= 0 then
    inst.chargeleft = 0
    i:AddTag("inscinerator_depleted")
  end
end
local function onload(inst, data)
  inst:ListenForEvent("death", DisableInscinerator)
  inst:ListenForEvent("seamlessplayerswap", KillInscinerator)
  -- if this is considered a worldly data then move it to TheWorld.abyss
  if not data then return end
  inst.chargeleft = data.chargeleft or TUNING.REG_INSCINERATOR_USE
  inst.inscinerator = data.inscinerator and SpawnSaveRecord(data.inscinerator) or SpawnPrefab("inscinerator")
  inst.inscinerator.entity:SetParent(inst.entity)
  inst.inscinerator.Transform:SetPosition(0, 0, 0) -- force teleport to player
  if inst.chargeleft <= 0 then
    inst.chargeleft = 0
    inst.inscinerator:AddTag("inscinerator_depleted")
  end
end
local function onsave(inst, data)
  data.chargeleft = inst.chargeleft
  data.inscinerator = inst.inscinerator and inst.inscinerator:GetSaveRecord()
end
-- add action for inspection button
--[[
local function hack_button(inst, self)
    local old = self.OnMouseButton
    function self:OnMouseButton(control, down, ...)
        if down then return old(self, control, down, ...) end
        if control == MOUSEBUTTON_RIGHT then
            if inst.components.reticule then
                inst:PushEvent("aoetargetingstop", {target = inst.components.reticule.targetpos})
                inst.components.aoetargeting:StopTargeting()
            else
                inst.components.aoetargeting:StartTargeting()
                inst:PushEvent("aoetargetingstart")
            end
        else
            return old(self, control, down, ...)
        end
    end
end
local function hudpostinit(inst)
    local success, inspect = pcall(function(inst)
        return inst.HUD.controls.inv.inspectcontrol
    end, inst)
    if not success then return end
    if inspect.hudinited then return end
    if not inst.inscinerator then return end
    inspect.hudinited = true
    hack_button(inst.inscinerator, inspect)
end
]]
local common_postinit = function(inst)
  inst.MiniMapEntity:SetIcon("reg.png")
  inst:AddTag("mia_reg")
  inst:AddTag("heatresistant")
  inst:AddTag("soulless") -- non human representation
  inst:AddTag("electricdamageimmune")
  inst:RemoveTag("poisonable")
  inst:DoTaskInTime(0, TrySpawnInscinerator)
  -- #TODO add a hud
  -- inst.hud=
  -- #NOTPLANNED rethink about forge and gorge
  -- if TheNet:GetServerGameMode() == "quagmire" then inst:AddTag("quagmire_grillmaster") end
end
local master_postinit = function(inst)
  inst.starting_inventory = start_inv
  inst.soundsname = "walter" -- #NOTPLANNED sound for reg

  inst.components.health:SetMaxHealth(TUNING.REG_HEALTH)
  inst.components.health.vulnerabletopoisondamage = false
  inst.components.health.poison_damage_scale = 0
  inst.components.health:SetAbsorptionAmount(TUNING.REG_ABSORPTION)
  inst.components.health.fire_damage_scale = 0

  inst.components.hunger:SetMax(TUNING.REG_HUNGER)

  inst.components.sanity:SetMax(TUNING.REG_SANITY)

  inst.components.combat.damagemultiplier = TUNING.REG_DAMAGEMULTIPLIER

  inst.components.playerlightningtarget:SetHitChance(1)
  inst.components.playerlightningtarget:SetOnStrikeFn(onlightingstrike)

  inst.components.temperature.inherentinsulation = -TUNING.INSULATION_MED
  inst.components.temperature.inherentsummerinsulation = -TUNING.INSULATION_MED
  inst.components.temperature:SetFreezingHurtRate(TUNING.REG_FREEZE_DAMAGE_RATE)
  inst.components.temperature:SetOverheatHurtRate(TUNING.REG_HEAT_DAMAGE_RATE)
  inst.OnLoad = onload
  inst.OnSave = onsave
  -- spawn custom relic inscinerator
  inst:DoTaskInTime(0, TrySpawnInscinerator)
  inst:ListenForEvent("timerdone",
   function(inst, data) if data.name == "forgetlightninghit" then ForgetLightningHit(inst) end end)
  inst:ListenForEvent("death", DisableInscinerator)
  inst:ListenForEvent("equip", DisableInscinerator)
end
return MakePlayerCharacter("reg", prefabs, assets, common_postinit, master_postinit, start_inv)
