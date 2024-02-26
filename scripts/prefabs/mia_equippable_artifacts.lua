local fns_hand = require("common_handfn")
local fns_body = require("common_bodyfn")
local hand_onequip, hand_onunequip = fns_hand._onequip, fns_hand._onunequip
local body_onequip, body_onunequip = fns_body._onequip, fns_body._onunequip
local function common(def)
  local inst = CreateEntity()
  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddSoundEmitter()
  inst.entity:AddNetwork()
  MakeInventoryPhysics(inst)
  inst.AnimState:SetBank(def.bank)
  inst.AnimState:SetBuild(def.build)
  inst.AnimState:PlayAnimation(def.anim)
  if def.tag ~= nil then inst:AddTag(def.tag) end
  if def.tags then for i, v in pairs(def.tags) do inst:AddTag(v) end end
  if not def.should_sink then
    if def.floatsymbol then
      MakeInventoryFloatable(inst, "med", 0, {1.0, 0.4, 1.0}, true, -20, {
        sym_name = def.floatsymbol,
        sym_build = def.build,
        bank = def.bank
      })
    else
      MakeInventoryFloatable(inst, "med", nil, 0.6)
    end
  end
  if def.common_postinit then def.common_postinit(inst) end
  inst.entity:SetPristine()
  if not TheWorld.ismastersim then return inst end
  inst:AddComponent("inspectable")
  inst:AddComponent("inventoryitem")
  inst:AddComponent("equippable")
  if def.should_sink then inst.components.inventoryitem:SetSinks(true) end
  MakeHauntableLaunch(inst)
  return inst
end
local function common_amulet(def)
  local inst = common(def)
  -- inst.foleysound = "dontstarve/movement/foley/jewlery"
  if not TheWorld.ismastersim then return inst end
  inst.components.equippable.equipslot = EQUIPSLOTS.NECK or EQUIPSLOTS.BODY
  -- inst.components.equippable.is_magic_dapperness = true
  inst.components.equippable:SetOnEquip(def.onequip or body_onequip)
  inst.components.equippable:SetOnUnequip(def.onunequip or body_onunequip)
  if def.postinit then def.postinit(inst) end
  return inst
end
local function common_hand(def)
  local inst = common(def)
  if not TheWorld.ismastersim then return inst end
  inst.components.equippable.equipslot = EQUIPSLOTS.HANDS
  inst.components.equippable:SetOnEquip(def.onequip or hand_onequip)
  inst.components.equippable:SetOnUnequip(def.onunequip or hand_onunequip)
  if def.postinit then def.postinit(inst) end
  return inst
end
local function makeamulet(def) return function() return common_amulet(def) end end
local function makehand(def) return function() return common_hand(def) end end
local prefs = {}
for k, v in pairs(require("mia_artifacts")) do
  if v.slot == "hand" then
    table.insert(prefs, Prefab(k, makehand(v), v.assets))
  end
  if v.slot == "neck" then
    table.insert(prefs, Prefab(k, makeamulet(v), v.assets))
  end
end
return unpack(prefs)
