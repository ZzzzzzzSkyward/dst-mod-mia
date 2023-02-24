local assets = {Asset("ANIM", "anim/abyssweapon.zip"), Asset("ANIM", "anim/swap_abyssweapon.zip")}
local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_abyssweapon", "abyssweapon")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end
local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end
local function onattack(inst, owner, target)
    if target.components.health and not inst.components.fueled:IsEmpty() then
        if owner:HasTag("reger") then
            SpawnPrefab("explode_small").Transform:SetPosition(target.Transform:GetWorldPosition())
            target.components.health:DoDelta(-150)
            inst.components.fueled:DoDelta(-10)
        elseif owner:HasTag("riko") then
            local explode = SpawnPrefab("explode_small")
            explode.Transform:SetScale(0.3, 0.3, 0.3)
            explode.Transform:SetPosition(target.Transform:GetWorldPosition())
            target.components.health:DoDelta(-15)
            inst.components.fueled:DoDelta(-1)
        end
    end
end
local function simple(name)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    inst.AnimState:SetBank(name)
    inst.AnimState:SetBuild(name)
    inst.AnimState:PlayAnimation("idle")
    inst:AddTag("abyssweapon")
    inst:AddTag("power_fueled")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst:AddComponent("weapon")
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.POWER
    inst.components.fueled:InitializeFuelLevel(TUNING.ABYSSUSES)
    inst.components.fueled.accepting = true
    MakeHauntableLaunch(inst)
    return inst
end
local function fn()
    local inst = simple("abyssweapon")
    if not TheWorld.ismastersim then return inst end
    inst.components.weapon:SetDamage(51)
    inst.components.weapon:SetOnAttack(onattack)
    return inst
end
return Prefab("abyssweapon", fn, assets)
