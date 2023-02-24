local assets = {Asset("ANIM", "anim/regercloak.zip")}
local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "regercloak", "swap_body")
    if owner.components.hunger then owner.components.hunger.burnrate = TUNING.REGER_SLOW_HUNGER end
end
local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    if owner.components.hunger then owner.components.hunger.burnrate = 1 end
end
local function onperish(inst)
    inst:Remove()
end
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    inst.AnimState:SetBank("regercloak")
    inst.AnimState:SetBuild("regercloak")
    inst.AnimState:PlayAnimation("anim")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    MakeHauntableLaunch(inst)
    return inst
end
return Prefab("regcloak", fn, assets)
