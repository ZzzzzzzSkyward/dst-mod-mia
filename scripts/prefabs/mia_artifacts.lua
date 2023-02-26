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
    if def.tags then inst:AddTags(def.tags) end
    if not def.should_sink then MakeInventoryFloatable(inst, "med", nil, 0.6) end
    if def.postinit then def.postinit(inst) end
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    if def.should_sink then inst.components.inventoryitem:SetSinks(true) end

    return inst
end

local function makeartifact(def)
    return function()
        return common(def)
    end
end
local artifacts = require("mia_artifacts")
local prefs = {}
for k, v in pairs(artifacts) do table.insert(prefs, Prefab(k, makeartifact(v), v.assets)) end
return unpack(prefs)
