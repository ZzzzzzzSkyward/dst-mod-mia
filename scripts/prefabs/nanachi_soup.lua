local assets = {Asset("ANIM", "anim/nanachi_soup.zip")}

local prefabs = {"spoiled_food"}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)

    inst.AnimState:SetBank("nanachi_soup")
    inst.AnimState:SetBuild("nanachi_soup")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("preparedfood")
    inst:AddTag("nanachisoup")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.VEGGIE
    inst.components.edible.healthvalue = 40
    inst.components.edible.hungervalue = 50
    inst.components.edible.sanityvalue = -20

    inst:AddComponent("inspectable")
    inst:AddComponent("tradable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    return inst
end

return Prefab("nanachi_soup", fn, assets, prefabs)
