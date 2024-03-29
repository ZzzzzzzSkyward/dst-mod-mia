local assets = {
    Asset("ANIM", "anim/swap_nanachi_mitty.zip"),
    Asset("ANIM", "anim/nanachi_mitty.zip"),
    Asset("ANIM", "anim/ui_krampusbag_2x5.zip"),
    Asset("IMAGE", "images/mia_minimap.tex"),
    Asset("ATLAS", "images/mia_minimap.xml")
}

local function onequip(inst, owner)
    local image = "swap_nanachi_mitty"
    owner.AnimState:OverrideSymbol("swap_body", image, "backpack")
    owner.AnimState:OverrideSymbol("swap_body", image, "swap_body")
    owner:AddTag("toadstool")
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    owner.AnimState:ClearOverrideSymbol("backpack")
    owner:RemoveTag("toadstool")
end

local function OnTimerDone(inst, data)
    if data.name == "sleep" then
        inst.mitty_num = 0
        inst:RemoveTag("sleep")
        inst.AnimState:PlayAnimation("idle", true)
    end
end

local function ShouldAcceptItem(inst, item)
    return (item.prefab == "monstermeat" or item.prefab == "cookedmonstermeat" or item.prefab == "monstermeat_dried")
               and not inst:HasTag("sleep")
end

local function OnGetItem(inst, giver, item)
    local itemname = "meat"
    if item.prefab == "cookedmonstermeat" then
        itemname = "cookedmeat"
    elseif item.prefab == "monstermeat_dried" then
        itemname = "meat_dried"
    end
    inst.components.lootdropper:SpawnLootPrefab(itemname)
    if inst.mitty_num == TUNING.MITTY_NUM then
        inst:AddTag("sleep")
        inst.AnimState:PlayAnimation("sleep")
        inst.components.timer:StartTimer("sleep", TUNING.MITTY_CD)
    else
        inst.mitty_num = inst.mitty_num + 1
    end
end

local function OnRefuseItem(inst, item)
    return
end

local function onload(inst, data)
    if data then
        inst.mitty_num = data.mitty_num or 0
    else
        inst.mitty_num = 0
    end
    if inst.mitty_num == TUNING.MITTY_NUM then
        inst.AnimState:PlayAnimation("sleep", true)
        inst:AddTag("sleep")
    end
end

local function onsave(inst, data)
    data.mitty_num = inst.mitty_num or 0
end

local function bottled()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:AddTag("mitty")
    inst:AddTag("irreplaceable")
    -- inst:AddTag("nonpotatable")

    inst.mitty_num = 0

    MakeInventoryPhysics(inst)

    inst.MiniMapEntity:SetIcon("mitty_bottled.png")

    inst.AnimState:SetBank("nanachi_mitty")
    inst.AnimState:SetBuild("nanachi_mitty")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetScale(0.4, 0.4, 0.4)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.cangoincontainer = false

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BACK or EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItem
    inst.components.trader.onrefuse = OnRefuseItem

    inst:AddComponent("timer")
    inst:AddComponent("lootdropper")

    inst:ListenForEvent("timerdone", OnTimerDone)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end
local tea_assets = {Asset("ANIM", "anim/mitty_tea.zip")}
local defsanity = 5
local function GetSanity(eater)
    if not eater then return end
    if eater.components.sanity then
        if eater.prefab == "nanachi" then
            return -defsanity
        elseif eater.prefab == "belaf" then
            return defsanity
        end
    end
end
local def = {
    foodtype = FOODTYPE.MEAT,
    hunger = 10,
    oneatenfn = function(inst, eater)
        -- local sanity = GetSanity(eater)
        -- if sanity then eater.components.sanity:DoDelta(sanity) end
    end
}
local function tea()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:AddTag("mitty")
    inst:AddTag("irreplaceable")
    -- inst:AddTag("nonpotatable")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)

    inst.MiniMapEntity:SetIcon("mitty_bottled.png")

    inst.AnimState:SetBank("mitty_tea")
    inst.AnimState:SetBuild("mitty_tea")--https://www.bilibili.com/video/BV1ke4y1k7Ra/
    inst.AnimState:PlayAnimation("idle", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

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
    local old = inst.components.edible.GetSanity
    function inst.components.edible:GetSanity(eater)
        return GetSanity(eater) or old(self, eater)
    end
    MakeHauntableLaunch(inst)
    return inst
end
local function mitty_bundle()
    local inst = CreateEntity()
    inst:AddTransform()
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    local DropLoot = function(inst)
        local mitty = SpawnPrefab("mitty")
        local tea = SpawnPrefab("mitty_tea")
        if mitty and tea then
            local x, y, z = inst.Transform:GetWorldPosition()
            mitty.Transform:SetPosition(x, y, z)
            tea.Transform:SetPosition(x, y, z)
        end
        inst:Remove()
    end
    inst:DoTaskInTime(0, DropLoot)
    return inst
end
return Prefab("mitty_bottled", bottled, assets),
-- Prefab("mitty_tea", tea, tea_assets),
    Prefab("mitty_tea_bundle", mitty_bundle)
