local function MakeFood(name, def)
    local assets = {Asset("ANIM", "anim/" .. name .. ".zip")}
    local prefabs = {"spoiled_food"}
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        MakeInventoryPhysics(inst)
        MakeInventoryFloatable(inst)
        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle")
        inst:AddTag("preparedfood")
        if def.tag then
            if type(def.tag) == "string" then
                inst:AddTag(def.tag)
            elseif type(def.tag) == "table" and def.tag[1] then
                inst:AddTags(def.tag)
            end
        else
            inst:AddTag("rikofood")
        end
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end
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
        inst:AddComponent("tradable")
        inst:AddComponent("inventoryitem")
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
local food_defs = require("mia_foods")
local ret = {}
for name, def in pairs(food_defs) do table.insert(ret, MakeFood(name, def)) end

return unpack(ret)
