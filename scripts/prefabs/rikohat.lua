local assets = {Asset("ANIM", "anim/hat_rikohat.zip")}
local function _onequip(inst, owner, build, symbol_override, headbase_hat_override)

    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_hat", skin_build, symbol_override or "swap_hat", inst.GUID, fname)
    else
        owner.AnimState:OverrideSymbol("swap_hat", build, symbol_override or "swap_hat")
    end

    owner.AnimState:ClearOverrideSymbol("headbase_hat") -- clear out previous overrides
    if headbase_hat_override ~= nil then
        local skin_build = owner.AnimState:GetSkinBuild()
        if skin_build ~= "" then
            owner.AnimState:OverrideSkinSymbol("headbase_hat", skin_build, headbase_hat_override)
        else
            local build = owner.AnimState:GetBuild()
            owner.AnimState:OverrideSymbol("headbase_hat", build, headbase_hat_override)
        end
    end

    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAIR_HAT")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Hide("HEAD")
        owner.AnimState:Show("HEAD_HAT")
    end

    if inst.components.fueled ~= nil then inst.components.fueled:StartConsuming() end

    if inst.skin_equip_sound and owner.SoundEmitter then owner.SoundEmitter:PlaySound(inst.skin_equip_sound) end
end

local function _onunequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then owner:PushEvent("unequipskinneditem", inst:GetSkinName()) end

    owner.AnimState:ClearOverrideSymbol("headbase_hat") -- it might have been overriden by _onequip
    if owner.components.skinner ~= nil then owner.components.skinner.base_change_cb = owner.old_base_change_cb end

    owner.AnimState:ClearOverrideSymbol("swap_hat")
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
    end

    if inst.components.fueled ~= nil then inst.components.fueled:StopConsuming() end
end

local function onequip(inst, owner, symbol_override)
    _onequip(inst, owner, "hat_rikohat", symbol_override)
end
local function onunequip(inst, owner)
    _onunequip(inst, owner)
end

local function miner_turnon(inst)
    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
    if not inst.components.fueled:IsEmpty() then
        if inst._light == nil or not inst._light:IsValid() then
            local light = SpawnPrefab("minerhatlight")
            inst._light = light
            local Light = light.Light
            Light:SetFalloff(0.6)
            Light:SetIntensity(.8)
            Light:SetRadius(3.5)
            Light:SetColour(225 / 255, 195 / 255, 155 / 255)
        end
        if owner ~= nil then
            onequip(inst, owner)
            inst._light.entity:SetParent(owner.entity)
        end
        inst.components.fueled:StartConsuming()
        local soundemitter = owner ~= nil and owner.SoundEmitter or inst.SoundEmitter
        soundemitter:PlaySound("dontstarve/common/minerhatAddFuel")
    elseif owner ~= nil then
        onequip(inst, owner, "swap_hat_off")
    end
end

local function miner_turnoff(inst)
    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
    if owner ~= nil and inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then
        onequip(inst, owner, "swap_hat_off")
    end
    inst.components.fueled:StopConsuming()
    if inst._light ~= nil then
        if inst._light:IsValid() then inst._light:Remove() end
        inst._light = nil
        local soundemitter = owner ~= nil and owner.SoundEmitter or inst.SoundEmitter
        soundemitter:PlaySound("dontstarve/common/minerhatOut")
    end
end

local function miner_unequip(inst, owner)
    onunequip(inst, owner)
    miner_turnoff(inst)
end
local simple_onequiptomodel = function(inst, owner, from_ground)
    if inst.components.fueled ~= nil then inst.components.fueled:StopConsuming() end
end
local miner_onequiptomodel = function(inst, owner, from_ground)
    simple_onequiptomodel(inst, owner, from_ground)
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

local function miner_onremove(inst)
    if inst._light ~= nil and inst._light:IsValid() then inst._light:Remove() end
end
local function simple()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst:AddTag("hat")
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("tradable")
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(simple_onequiptomodel)
    MakeHauntableLaunch(inst)
    return inst
end
local function riko_custom_init(inst)
    inst.AnimState:SetBank("rikohat")
    inst.AnimState:SetBuild("hat_rikohat")
    inst.AnimState:PlayAnimation("anim")
    if not TheWorld.ismastersim then return inst end
    inst.components.fueled:InitializeFuelLevel(TUNING.RIKOHAT_LIGHTTIME)
end
local function reg_custom_init(inst)
    inst:AddTag("regerhat")
    inst.AnimState:SetBank("regerhat")
    inst.AnimState:SetBuild("hat_regerhat")
    inst.AnimState:PlayAnimation("anim")
    if not TheWorld.ismastersim then return inst end
    inst.components.fueled:InitializeFuelLevel(TUNING.RIKOHAT_LIGHTTIME)
end
local function miner_custom_init(inst)
    -- waterproofer (from waterproofer component) added to pristine state for optimization
    inst:AddTag("waterproofer")
    inst.entity:AddSoundEmitter()
    inst.components.floater:SetSize("med")
    inst.components.floater:SetScale(0.6)

    if not TheWorld.ismastersim then return inst end

    inst.components.inventoryitem:SetOnDroppedFn(miner_turnoff)
    inst.components.equippable:SetOnEquip(miner_turnon)
    inst.components.equippable:SetOnUnequip(miner_unequip)
    inst.components.equippable:SetOnEquipToModel(miner_onequiptomodel)
    inst.components.equippable.restrictedtag = "riko"

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.CAVE
    inst.components.fueled.secondaryfueltype = FUELTYPE.WORMLIGHT
    inst.components.fueled:SetDepletedFn(miner_perish)
    inst.components.fueled:SetTakeFuelFn(miner_takefuel)
    inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
    inst.components.fueled.accepting = true

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

    inst._light = nil
    inst.OnRemoveEntity = miner_onremove
end
local function rikohat()
    local inst = simple()
    miner_custom_init(inst)
    riko_custom_init(inst)
    return inst
end
return Prefab("rikohat", rikohat, assets)
