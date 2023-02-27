local prushka_assets = {Asset("ANIM", "anim/artifact_prushka.zip"), Asset("ANIM", "anim/swap_artifact_prushka.zip")}
local fns = require("common_equip_hand")
local hand_onequip, hand_onunequip = fns._onequip, fns._onunequip
local function reverberate(inst, owner)
    if not owner then return end
    local talker = owner.components.talker
    if owner.prefab == "riko" then
        local x, y, z = owner.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 40, {"player", "reg"})
        for i, reg in ipairs(ents) do reg:TransformToWhite(inst, owner) end
        if talker then
            local str = GetString(owner, "ANNOUNCE_REVERBERATE")
            talker:Say(str)
        end
    else
        if talker then
            local str = GetActionFailString(owner, "REVERBERATE", "PRUSHKA")
            talker:Say(str)
        end
    end
end

local function _onequip(inst, owner, build, symbol)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_body", skin_build, symbol or inst.bodysymbol, inst.GUID,
            build or inst.build)
    else
        owner.AnimState:OverrideSymbol("swap_body", build or inst.build, symbol or inst.bodysymbol)
    end
end

local function _onunequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then owner:PushEvent("unequipskinneditem", inst:GetSkinName()) end
end

local function prushka_onequip(inst, owner)
    _onequip(inst, owner, "artifact_prushka", "swap_body")
    inst:reverberate()
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
    if def.tags then inst:AddTags(def.tags) end
        if not def.should_sink then MakeInventoryFloatable(inst, "med", nil, 0.6) end
    if not TheWorld.ismastersim then return inst end
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
        inst:AddComponent("equippable")
        if def.should_sink then inst.components.inventoryitem:SetSinks(true) end

    MakeHauntableLaunch(inst)
    return inst
end
local function common_amulet(bank, build, anim, postinit, tag, should_sink)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation(anim)

    if tag ~= nil then inst:AddTag(tag) end

    inst.foleysound = "dontstarve/movement/foley/jewlery"

    if not should_sink then MakeInventoryFloatable(inst, "med", nil, 0.6) end
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("inspectable")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.NECK or EQUIPSLOTS.BODY
    -- inst.components.equippable.is_magic_dapperness = true

    inst:AddComponent("inventoryitem")
    if should_sink then inst.components.inventoryitem:SetSinks(true) end

    if postinit then postinit(inst) end
    return inst
end
local function common_hand(def)
    local inst = common()if def.common_postinit then def.common_postinit(inst)end
        inst.entity:SetPristine()
if not TheWorld.ismastersim then return end
    inst.components.equippable.equipslot=EQUIPSLOTS.HANDS
    inst.components.equippable:SetOnEquip(def.onequip or hand_onequip)
    inst.components.equippable:SetOnUnequip(def.onunequip or hand_onunequip)
    if def.postinit then def.postinit(inst) end
    return inst
end
local function prushka(inst)
    inst.equippable:SetOnEquip(prushka_onequip)
    inst.equippable:SetOnUnequip(_onunequip)
    inst.reververate = reverberate
end
local function makeamulet(...)
    local args = {...}
    return function()
        return common_amulet(unpack(args))
    end
end
local function makehand(def)
    return function()
        return common_hand(def)
    end
end
local prefs = {}
for k, v in pairs(require("mia_artifacts")) do
    if v.slot == "hand" then table.insert(Prefab(k, makehand(v), v.assets)) end
    if v.slot == "amulet" then table.insert(Prefab(k, makeamulet(v), v.assets)) end
end
table.insert(prefs, Prefab("prushka",
    makeamulet("artifact_prushka", "artifact_prushka", "anim", prushka, "prushka", false), prushka_assets))
return unpack(prefs)
