local fns = require("common_equip_hand")
local hand_onequip, hand_onunequip = fns._onequip, fns._onunequip

local function body_onequip(inst, owner, build, symbol)
    if type(symbol) ~= "string" then symbol = inst.bodysymbol or "swap_body" end
    if type(build) ~= "string" then build = inst.build or "armor_wood" end
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_body", skin_build, symbol, inst.GUID, build)
    else
        owner.AnimState:OverrideSymbol("swap_body", build, symbol)
    end
    if inst.components.fueled then inst.components.fueled:StartConsuming() end
end

local function body_onunequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then owner:PushEvent("unequipskinneditem", inst:GetSkinName()) end
    owner.AnimState:ClearOverrideSymbol("swap_body")
    if inst.components.fueled then inst.components.fueled:StopConsuming() end
end
local function _onequip(inst, owner)
    body_onequip(inst, owner, inst.build, inst.bodysymbol)
end
local function common(def)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    inst.AnimState:SetBank(def.bank)
    inst.AnimState:SetBuild(def.build)
    inst.AnimState:PlayAnimation(def.anim)
    if def.tag ~= nil then inst:AddTag(def.tag) end
    if def.tags then for i, v in pairs(def.tags) do inst:AddTag(v) end end
    if not def.should_sink then
        if def.floatsymbol then
            MakeInventoryFloatable(inst, "med", 0, {1.0, 0.4, 1.0}, true, -20,
                {sym_name = def.floatsymbol, sym_build = def.build, bank = def.bank})
        else
            MakeInventoryFloatable(inst, "med", nil, 0.6)
        end
    end
    if def.common_postinit then def.common_postinit(inst) end
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("equippable")
    if def.should_sink then inst.components.inventoryitem:SetSinks(true) end
    MakeHauntableLaunch(inst)
    return inst
end
local function common_amulet(def)
    local inst = common(def)
    -- inst.foleysound = "dontstarve/movement/foley/jewlery"
    if not TheWorld.ismastersim then return inst end
    inst.components.equippable.equipslot = EQUIPSLOTS.NECK or EQUIPSLOTS.BODY
    -- inst.components.equippable.is_magic_dapperness = true
    inst.components.equippable:SetOnEquip(def.onequip or _onequip)
    inst.components.equippable:SetOnUnequip(def.onunequip or body_onunequip)
    if def.postinit then def.postinit(inst) end
    return inst
end
local function common_hand(def)
    local inst = common(def)
    if not TheWorld.ismastersim then return inst end
    inst.components.equippable.equipslot = EQUIPSLOTS.HANDS
    inst.components.equippable:SetOnEquip(def.onequip or hand_onequip)
    inst.components.equippable:SetOnUnequip(def.onunequip or hand_onunequip)
    if def.postinit then def.postinit(inst) end
    return inst
end
local function makeamulet(def)
    return function()
        return common_amulet(def)
    end
end
local function makehand(def)
    return function()
        return common_hand(def)
    end
end
local prefs = {}
for k, v in pairs(require("mia_artifacts")) do
    if v.slot == "hand" then table.insert(prefs, Prefab(k, makehand(v), v.assets)) end
    if v.slot == "neck" then table.insert(prefs, Prefab(k, makeamulet(v), v.assets)) end
end
return unpack(prefs)
