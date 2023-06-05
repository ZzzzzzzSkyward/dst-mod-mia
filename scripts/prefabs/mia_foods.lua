local food_defs = require("mia_foods")
-- 以下内容照抄即可
local function MakeFood(name, def)
  local assets = {Asset("ANIM", "anim/" .. (def.overridebuild or name) .. ".zip")}
  local prefabs = {"spoiled_food"}
  local spicename = def.spice ~= nil and string.lower(def.spice) or nil
  if spicename ~= nil then
    table.insert(assets, Asset("ANIM", "anim/spices.zip"))
    table.insert(assets, Asset("ANIM", "anim/plate_food.zip"))
    table.insert(assets, Asset("INV_IMAGE", spicename .. "_over"))
  end
  -- #NOTPLANNED 某处调用显示[prefab ""]，但不是这里
  local function DisplayNameFn(inst)
    return subfmt(STRINGS.NAMES[def.spice .. "_FOOD"], {
      food = STRINGS.NAMES[string.upper(def.basename)]
    })
  end
  local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)
    inst:AddTag("preparedfood")
    if def.tag then
      if type(def.tag) == "string" then
        inst:AddTag(def.tag)
      elseif type(def.tag) == "table" and def.tag[1] then
        for i, v in pairs(def.tag) do inst:AddTag(v) end
      end
    end
    local food_symbol_build
    if spicename ~= nil then
      inst.AnimState:SetBuild("plate_food")
      inst.AnimState:SetBank("plate_food")
      inst.AnimState:OverrideSymbol("swap_garnish", "spices", spicename)

      inst:AddTag("spicedfood")

      inst.inv_image_bg = {
        image = (def.basename or def.name) .. ".tex"
      }
      inst.inv_image_bg.atlas = GetInventoryItemAtlas(inst.inv_image_bg.image)

      food_symbol_build = def.overridebuild or "cook_pot_food"
    else
      inst.AnimState:SetBuild(def.overridebuild or "cook_pot_food")
      inst.AnimState:SetBank("cook_pot_food")
    end
    inst.AnimState:OverrideSymbol("swap_food", def.overridebuild or "cook_pot_food", def.basename or def.name)
    inst.AnimState:PlayAnimation("idle")
    if def.basename ~= nil then
      inst:SetPrefabNameOverride(def.basename)
      if def.spice ~= nil then inst.displaynamefn = DisplayNameFn end
    end

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst.food_symbol_build = food_symbol_build or def.overridebuild
    inst.food_basename = def.basename
    inst:AddComponent("edible")
    inst.components.edible.foodtype = def.foodtype or FOODTYPE.GENERIC
    inst.components.edible.secondaryfoodtype = def.secondaryfoodtype or nil
    inst.components.edible.healthvalue = def.health or 0
    inst.components.edible.hungervalue = def.hunger or 0
    inst.components.edible.sanityvalue = def.sanity or 0
    inst.components.edible.temperaturedelta = def.temperature or 0
    inst.components.edible.temperatureduration = def.temperatureduration or 0
    inst.components.edible.nochill = def.nochill or nil
    inst.components.edible.spice = def.spice
    inst.components.edible:SetOnEatenFn(def.oneatenfn)
    inst:AddComponent("inspectable")
    inst.wet_prefix = def.wet_prefix

    inst:AddComponent("tradable")
    inst:AddComponent("inventoryitem")
    if def.OnPutInInventory then inst:ListenForEvent("onputininventory", def.OnPutInInventory) end
    if spicename ~= nil then
      inst.components.inventoryitem:ChangeImageName(spicename .. "_over")
    elseif def.basename ~= nil then
      inst.components.inventoryitem:ChangeImageName(def.basename)
    end

    inst:AddComponent("stackable")
    inst:AddComponent("bait")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    if def.perishtime ~= nil and def.perishtime > 0 then
      inst:AddComponent("perishable")
      inst.components.perishable:SetPerishTime(def.perishtime)
      inst.components.perishable:StartPerishing()
      inst.components.perishable.onperishreplacement = "spoiled_food"
    end
    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    if not def.fireproof then MakeSmallPropagator(inst) end
    MakeHauntableLaunchAndPerish(inst)
    return inst
  end
  return Prefab(name, fn, assets, prefabs)
end
local ret = {}
for name, def in pairs(food_defs) do table.insert(ret, MakeFood(name, def)) end

return unpack(ret)
