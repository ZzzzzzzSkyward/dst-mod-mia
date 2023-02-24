local assets = {Asset("ANIM", "anim/hat_nanachihat.zip")}
local prefabs = {}
local function storeincontainer(inst, container)
    if container ~= nil and container.components.container ~= nil then
        inst:ListenForEvent("onputininventory", inst._oncontainerownerchanged, container)
        inst:ListenForEvent("ondropped", inst._oncontainerownerchanged, container)
        inst._container = container
    end
end

local function unstore(inst)
    if inst._container ~= nil then
        inst:RemoveEventCallback("onputininventory", inst._oncontainerownerchanged, inst._container)
        inst:RemoveEventCallback("ondropped", inst._oncontainerownerchanged, inst._container)
        inst._container = nil
    end
end

local function topocket(inst, owner)
    if inst._container ~= owner then
        unstore(inst)
        storeincontainer(inst, owner)
    end
end

local function toground(inst)
    unstore(inst)
end

local function OnEquip(inst, owner)
    if owner:HasTag("nanachi") then owner.AnimState:AddOverrideBuild("nanachihair") end
    owner.AnimState:OverrideSymbol("swap_hat", "hat_nanachihat", "swap_hat")
    owner.AnimState:Show("HAT")
end

local function OnUnequip(inst, owner)
    if owner:HasTag("nanachi") then owner.AnimState:ClearOverrideBuild("nanachihair") end
    owner.AnimState:Hide("HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("nanachihat")
    inst.AnimState:SetBuild("hat_nanachihat")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("hat")
    inst:AddTag("nanachihat")

    if not TheWorld.ismastersim then return inst end

    inst.entity:SetPristine()

    inst._container = nil

    inst._oncontainerownerchanged = function(container)
        topocket(inst, container)
    end

    inst._oncontainerremoved = function()
        unstore(inst)
    end

    inst:AddComponent("chosennanachi")
    inst:ListenForEvent("onputininventory", topocket)
    inst:ListenForEvent("ondropped", toground)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.inventoryitem.keepondeath = true

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0.35)

    inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("nanachihat", fn, assets, prefabs)
