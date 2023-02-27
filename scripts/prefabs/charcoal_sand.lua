local assets = {Asset("ANIM", "anim/charcoal_sand.zip")}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("charcoal_sand")
    inst.AnimState:SetBuild("charcoal_sand")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("molebait")

    MakeInventoryFloatable(inst, "med", 0.05, 0.6)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then return inst end
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_TINYITEM
    inst:AddComponent("tradable")
    inst:AddComponent("bait")
    MakeHauntableLaunch(inst)
    return inst
end

return Prefab("charcoal_sand", fn, assets)
