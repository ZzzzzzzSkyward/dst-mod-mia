local riko_assets = {Asset("ANIM", "anim/hat_rikohat.zip")}
local fns = require("common_hatfn")
local function onequip(inst, owner, ...) fns._onequip(inst, owner, inst.build, ...) end
local function onunequip(inst, owner) fns._onunequip(inst, owner) end

local function miner_turnon(inst)
  local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
  if not inst.components.fueled:IsEmpty() then
    if inst._light == nil or not inst._light:IsValid() then
      local light = SpawnPrefab("minerhatlight")
      inst._light = light
      local Light = light.Light
      Light:SetFalloff(0.6)
      Light:SetIntensity(.8)
      Light:SetRadius(3.5)
      Light:SetColour(225 / 255, 195 / 255, 155 / 255)
    end
    if owner ~= nil then
      onequip(inst, owner)
      inst._light.entity:SetParent(owner.entity)
    end
    inst.components.fueled:StartConsuming()
    local soundemitter = owner ~= nil and owner.SoundEmitter or inst.SoundEmitter
    soundemitter:PlaySound("dontstarve/common/minerhatAddFuel")
  elseif owner ~= nil then
    onequip(inst, owner, "swap_hat_off")
  end
end

local function miner_turnoff(inst)
  local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
  if owner ~= nil and inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then
    onequip(inst, owner, inst.build, "swap_hat_off")
  end
  inst.components.fueled:StopConsuming()
  if inst._light ~= nil then
    if inst._light:IsValid() then inst._light:Remove() end
    inst._light = nil
    local soundemitter = owner ~= nil and owner.SoundEmitter or inst.SoundEmitter
    soundemitter:PlaySound("dontstarve/common/minerhatOut")
  end
end

local function miner_unequip(inst, owner)
  onunequip(inst, owner)
  miner_turnoff(inst)
end
local simple_onequiptomodel = function(inst, owner, from_ground)
  if inst.components.fueled ~= nil then inst.components.fueled:StopConsuming() end
end
local miner_onequiptomodel = function(inst, owner, from_ground)
  simple_onequiptomodel(inst, owner, from_ground)
  miner_turnoff(inst)
end

local function miner_perish(inst)
  local equippable = inst.components.equippable
  if equippable ~= nil and equippable:IsEquipped() then
    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
    if owner ~= nil then
      local data = {prefab = inst.prefab, equipslot = equippable.equipslot}
      miner_turnoff(inst)
      owner:PushEvent("torchranout", data)
      return
    end
  end
  miner_turnoff(inst)
end

local function miner_takefuel(inst)
  if inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then miner_turnon(inst) end
end

local function miner_onremove(inst) if inst._light ~= nil and inst._light:IsValid() then inst._light:Remove() end end
local function simple(common_postinit, postinit)
  local inst = CreateEntity()
  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddNetwork()
  inst:AddTag("hat")
  MakeInventoryPhysics(inst)
  MakeInventoryFloatable(inst)
  common_postinit(inst)
  inst.entity:SetPristine()
  if not TheWorld.ismastersim then return inst end
  inst:AddComponent("inspectable")
  inst:AddComponent("inventoryitem")
  inst:AddComponent("tradable")
  inst:AddComponent("equippable")
  inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
  inst.components.equippable:SetOnEquip(onequip)
  inst.components.equippable:SetOnUnequip(onunequip)
  inst.components.equippable:SetOnEquipToModel(simple_onequiptomodel)
  MakeHauntableLaunch(inst)
  postinit(inst)
  return inst
end
local function miner(inst)
  -- waterproofer (from waterproofer component) added to pristine state for optimization
  inst:AddTag("waterproofer")
  inst.entity:AddSoundEmitter()
  inst.components.floater:SetSize("med")
  inst.components.floater:SetScale(0.6)
end
local function miner2(inst)
  inst.components.inventoryitem:SetOnDroppedFn(miner_turnoff)
  inst.components.equippable:SetOnEquip(miner_turnon)
  inst.components.equippable:SetOnUnequip(miner_unequip)
  inst.components.equippable:SetOnEquipToModel(miner_onequiptomodel)

  inst:AddComponent("fueled")
  inst.components.fueled.fueltype = FUELTYPE.CAVE
  inst.components.fueled.secondaryfueltype = FUELTYPE.WORMLIGHT
  inst.components.fueled:SetDepletedFn(miner_perish)
  inst.components.fueled:SetTakeFuelFn(miner_takefuel)
  inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
  inst.components.fueled.accepting = true

  inst:AddComponent("waterproofer")
  inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

  inst._light = nil
  inst.OnRemoveEntity = miner_onremove
end
local function riko(inst)
  miner(inst)
  inst.AnimState:SetBank("rikohat")
  inst.AnimState:SetBuild("hat_rikohat")
  inst.AnimState:PlayAnimation("anim")
end
local function riko2(inst)
  miner2(inst)
  inst.build = "hat_rikohat"
  inst.components.fueled:InitializeFuelLevel(TUNING.RIKOHAT_LIGHTTIME)
  inst.components.equippable.restrictedtag = "riko"
end

local nanachi_assets = {Asset("ANIM", "anim/hat_nanachihat.zip")}

local function nanachi_onequip(inst, owner)
  onequip(inst, owner)
  if owner.prefab == "nanachi" then
    owner.AnimState:AddOverrideBuild("nanachihair")
    owner.AnimState:Show("HAIR")
  end
end

local function nanachi_onunequip(inst, owner)
  if owner.prefab == "nanachi" then owner.AnimState:ClearOverrideBuild("nanachihair") end
  onunequip(inst, owner)
end

local function nanachi(inst)
  inst.AnimState:SetBank("nanachihat")
  inst.AnimState:SetBuild("hat_nanachihat")
  inst.AnimState:PlayAnimation("anim")
  inst:AddTag("nanachihat")
  inst:AddTag("waterproofer")
end
local function nanachi2(inst)
  inst.build = "hat_nanachihat"
  inst.components.equippable.restrictedtag = "nanachi"

  inst.components.equippable:SetOnEquip(nanachi_onequip)
  inst.components.equippable:SetOnUnequip(nanachi_onunequip)
  inst.components.inventoryitem.keepondeath = true

  inst:AddComponent("waterproofer")
  inst.components.waterproofer:SetEffectiveness(0.35)

  inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE

  inst:AddComponent("insulator")
  inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)

  return inst
end
local reg_assets = {Asset("ANIM", "anim/hat_regerhat.zip")}
local function reg(inst)
  inst.AnimState:SetBank("regerhat")
  inst.AnimState:SetBuild("hat_regerhat")
  inst.AnimState:PlayAnimation("anim")
  inst.entity:AddSoundEmitter()
  inst:AddTag("reghat")
  inst:AddTag("waterproofer")
  inst:RemoveComponent("floater")
end
local function reg2(inst)
  inst:RemoveComponent("floater")
  inst.build = "hat_regerhat"
  inst.components.equippable.restrictedtag = "mia_reg"

  inst:AddComponent("armor")
  inst.components.armor:InitIndestructible(TUNING.REGHAT_ABSORPTION)

  inst:AddComponent("waterproofer")
  inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)
  inst:AddComponent("submersible")
  inst.components.inventoryitem:SetSinks(true)
  inst.components.inventoryitem.keepondeath = true
end
local function DoContainerSetup()
  local params = require "containers"
  params = params.params
  if params.prushkahat then return end
  local h = deepcopy(params.antlionhat)
  h.widget.animbuild = "ui_prushkahat_1x1"
  h.excludefromcrafting = nil
  h.itemtestfn = function(container, item, slot) return item:HasTag("smallcreature") end
  params.prushkahat = h
end
local function prushka(inst)
  inst.AnimState:SetBank("prushkahat")
  inst.AnimState:SetBuild("hat_prushka")
  inst.AnimState:PlayAnimation("anim")
  inst:AddTag("prushkahat")
  inst:AddTag("waterproofer")
  inst:AddTag("good_sleep_aid")
  inst:AddTag("fridge")
  DoContainerSetup()
end
local function prushka_getcreature()
    --handler for lightbulb flies and mi miao
end
local function prushka_losecreature()
end
local function prushka_removed(inst)
    local inv=inst.components.inventory
    inv:DropEverything()
end
local function prushka2(inst)
  inst.build = "hat_regerhat"
  inst:AddComponent('waterproofer')
  inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)
  inst.components.equippable.dapperness = -TUNING.DAPPERNESS_TINY
  inst:AddComponent("container")
  inst.components.container:WidgetSetup("prushkahat")
  inst.components.container.acceptsstacks = false
  inst:AddComponent("preserver")
  inst.components.preserver:SetPerishRateMultiplier(TUNING.PERISH_SALTBOX_MULT)
  inst:ListenForEvent("itemget", prushka_getcreature)
  inst:ListenForEvent("itemlose", prushka_losecreature)
  inst:ListenForEvent("onremove", prushka_removed)
end
local function makehat(a, b)
  return function()
    local inst = simple(a, b)
    return inst
  end
end
return Prefab("rikohat", makehat(riko, riko2), riko_assets),
  Prefab("nanachihat", makehat(nanachi, nanachi2), nanachi_assets), Prefab("reghat", makehat(reg, reg2), reg_assets),
  Prefab("prushkahat", makehat(prushka, prushka2), prushka_assets)
