local function OnDropped(inst)
    inst.Light:Enable(true)
end

local function OnPickup(inst)
    inst.Light:Enable(false)
end
local function common(def)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    if def.commonpostinit then def.commonpostinit(inst) end
    if not def.silent then inst.entity:AddSoundEmitter() end
    if def.light then
        local light = def.light
        local Light = inst.entity:AddLight()
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        Light:SetFalloff(light.falloff or 0.7)
        Light:SetIntensity(light.intensity or .5)
        Light:SetRadius(light.radius or 0.5)
        Light:SetColour(unpack(light.colour or {237 / 255, 237 / 255, 209 / 255}))
        Light:Enable(not not light.enable)
    end

    inst.AnimState:SetBank(def.bank)
    inst.AnimState:SetBuild(def.build)
    inst.AnimState:PlayAnimation(def.anim)
    inst.is_mia_artifact = true
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
    if def.light then
        inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
        inst.components.inventoryitem:SetOnPickupFn(OnPickup)
    end
    if def.should_sink then inst.components.inventoryitem:SetSinks(true) end
    MakeHauntableLaunch(inst)
    if def.postinit then def.postinit(inst) end

    return inst
end
local function makeartifact(def)
    if def.fn then
        return def.fn
    else
        return function()
            return common(def)
        end
    end
end
local artifacts = require("mia_artifacts")
local prefs = {}
for k, v in pairs(artifacts) do if not v.slot then table.insert(prefs, Prefab(k, makeartifact(v), v.assets)) end end
return unpack(prefs)
