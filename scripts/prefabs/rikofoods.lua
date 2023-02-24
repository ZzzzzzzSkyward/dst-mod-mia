local function MakeFood(name, type, health, hunger, sanity, perishtime)
    local assets = {Asset("ANIM", "anim/" .. name .. ".zip")}
    local prefabs = {"spoiled_food"}
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        MakeInventoryPhysics(inst)
        MakeSmallBurnable(inst)
        MakeSmallPropagator(inst)
        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle")
        inst:AddTag("preparedfood")
        inst:AddTag("rikofood")
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end
        inst:AddComponent("edible")
        inst.components.edible.foodtype = type
        inst.components.edible.healthvalue = health
        inst.components.edible.hungervalue = hunger
        inst.components.edible.sanityvalue = sanity
        inst:AddComponent("inspectable")
        inst:AddComponent("tradable")
        inst:AddComponent("inventoryitem")
        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
        if perishtime ~= nil then
            inst:AddComponent("perishable")
            inst.components.perishable:SetPerishTime(perishtime)
            inst.components.perishable:StartPerishing()
            inst.components.perishable.onperishreplacement = "spoiled_food"
        end
        return inst
    end
    return Prefab(name, fn, assets, prefabs)
end
return MakeFood("riko_onigiri", FOODTYPE.VEGGIE, 12, 62.5, 5, TUNING.PERISH_ONE_DAY * 15),
    MakeFood("riko_dashi", FOODTYPE.MEAT, 60, 37.5, 33, TUNING.PERISH_ONE_DAY * 6),
    MakeFood("riko_grill", FOODTYPE.MEAT, 3, 37.5, 5, TUNING.PERISH_ONE_DAY * 9),
    MakeFood("riko_friedfish", FOODTYPE.MEAT, 80, 50, 15, TUNING.PERISH_ONE_DAY * 5),
    MakeFood("riko_snack", FOODTYPE.VEGGIE, 10, 12.5, 50, TUNING.PERISH_ONE_DAY * 7)
