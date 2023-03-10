local assets = {Asset("ANIM", "anim/swap_riko_sack.zip"), Asset("ANIM", "anim/ui_krampusbag_2x5.zip")}
local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("backpack", "swap_riko_sack", "backpack")
    owner.AnimState:OverrideSymbol("swap_body", "swap_riko_sack", "swap_body")
    inst.components.container:Open(owner)
end
local function onunequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then owner:PushEvent("unequipskinneditem", inst:GetSkinName()) end
    owner.AnimState:ClearOverrideSymbol("swap_body")
    owner.AnimState:ClearOverrideSymbol("backpack")
    inst.components.container:Close(owner)
end
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    inst.MiniMapEntity:SetIcon("riko_sack.png")
    inst.AnimState:SetBank("rikosack")
    inst.AnimState:SetBuild("swap_riko_sack")
    inst.AnimState:PlayAnimation("anim")
    inst.foleysound = "dontstarve/movement/foley/krampuspack"
    inst:AddTag("backpack")
    inst:AddTag("waterproofer")
    local swap_data = {bank = "swap_riko_sack", anim = "anim"}
    MakeInventoryFloatable(inst, "med", 0.1, 0.65, nil, nil, swap_data)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.cangoincontainer = false
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BACK or EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.walkspeedmult = TUNING.PIGGYBACK_SPEED_MULT
    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0)
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("krampus_sack")
    MakeHauntableLaunchAndDropFirstItem(inst)
    return inst
end
return Prefab("riko_sack", fn, assets)
