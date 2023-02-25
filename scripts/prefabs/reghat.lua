local assets = {Asset("ANIM", "anim/hat_regerhat.zip")}
local function onequip(inst, owner, symbol_override)
    owner.AnimState:OverrideSymbol("swap_hat", "hat_regerhat", symbol_override or "swap_hat")
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAIR_HAT")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")
    if owner:HasTag("player") then
        owner.AnimState:Hide("HEAD")
        owner.AnimState:Show("HEAD_HAT")
    end
end
local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_hat")
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")
    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
    end
end
local function miner_turnon(inst)
    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
    if not inst.components.fueled:IsEmpty() then
        if owner ~= nil then
            owner:AddTag("regerbomb")
            onequip(inst, owner)
        end
        local soundemitter = owner ~= nil and owner.SoundEmitter or inst.SoundEmitter
        soundemitter:PlaySound("dontstarve/common/minerhatAddFuel")
    elseif owner ~= nil then
        onequip(inst, owner, "swap_hat_off")
    end
end
local function miner_turnoff(inst)
    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
    if owner ~= nil and inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then
        owner:RemoveTag("regerbomb")
        onequip(inst, owner, "swap_hat_off")
    end
end
local function miner_unequip(inst, owner)
    owner:RemoveTag("regerbomb")
    onunequip(inst, owner)
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
local function custom_init(inst)
    inst.entity:AddSoundEmitter()
    inst:AddTag("waterproofer")
end
local function miner_onremove(inst)
    if inst._light ~= nil and inst._light:IsValid() then inst._light:Remove() end
end
local function simple()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    inst.entity:AddNetwork()
    inst:AddTag("hat")
    inst:AddTag("regerhat")
    anim:SetBank("regerhat")
    anim:SetBuild("hat_regerhat")
    anim:PlayAnimation("anim")
    inst:AddComponent("inspectable")
    if not TheWorld.ismastersim then return inst end
    inst:AddComponent("inventoryitem")
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    return inst
end
local function fn()
    local inst = simple()
    custom_init(inst)
    if not TheWorld.ismastersim then return inst end
    inst.components.inventoryitem:SetOnDroppedFn(miner_turnoff)
    inst.components.equippable:SetOnEquip(miner_turnon)
    inst.components.equippable:SetOnUnequip(miner_unequip)


    inst.components.equippable.restrictedtag = "reg"

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.MAGIC
    inst.components.fueled:InitializeFuelLevel(TUNING.REGERMAXTIME)
    inst.components.fueled:SetDepletedFn(miner_perish)
    inst.components.fueled:SetTakeFuelFn(miner_takefuel)
    inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
    inst.components.fueled.accepting = true
    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)
    inst._light = nil
    inst.OnRemoveEntity = miner_onremove
    return inst
end
return Prefab("reghat", fn, assets)
