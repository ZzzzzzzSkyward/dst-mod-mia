local function RGBA(r, g, b, a) return {r / 255, g / 255, b / 255, a / 255} end
local defaultsetting = {
  texture = "images/fx/ash.tex",
  shader = "shaders/vfx_particle.ksh",
  color = "ashcolourenvelope",
  colorenvelope = {{0, RGBA(50, 50, 50, 120)}, {1, RGBA(50, 50, 50, 180)}},
  vecenvelope = {{0, {0, 1}}, {1, {1, 1}}},
  scale = "ashscaleenvelope",
  minnum = 0,
  maxnum = 100,
  minlife = 1,
  maxlife = 10,
  blendmode = BLENDMODE.Premultiplied,
  sortorder = 1,
  dragco = 0.8,
  depthtest = false,
  acc = {0, 0, 0}
}
local function generator(def)

  local TEXTURE = resolvefilepath(def.texture)

  local SHADER = resolvefilepath(def.shader)

  local COLOUR_ENVELOPE_NAME = def.color
  local SCALE_ENVELOPE_NAME = def.scale

  local assets = {Asset("IMAGE", TEXTURE), Asset("SHADER", SHADER)}

  local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME, def.colorenvelope)

    EnvelopeManager:AddVector2Envelope(SCALE_ENVELOPE_NAME, def.vecenvelope)
    InitEnvelope = nil
  end

  local MAX_LIFETIME = def.maxlife
  local MIN_LIFETIME = def.minlife

  local function emit_fn(effect, emitter_shape)
    local vx, vy, vz = 0, 0, 0
    local lifetime = MIN_LIFETIME + (MAX_LIFETIME - MIN_LIFETIME) * UnitRand()
    local px, py, pz = emitter_shape()

    effect:AddParticle(0, lifetime, -- lifetime
    px, py, pz, -- position
    vx, vy, vz -- velocity
    )
  end

  local function InitParticles(inst)
    -- Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
      return
    elseif InitEnvelope ~= nil then
      InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)
    effect:SetRenderResources(0, TEXTURE, SHADER)
    effect:SetMaxNumParticles(def.minnum, def.maxnum)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, def.blendmode)
    effect:SetSortOrder(0, def.order)
    effect:SetAcceleration(0, unpack(def.acc))
    effect:SetDragCoefficient(0, def.dragco)
    effect:EnableDepthTest(0, def.depthtest)

    -----------------------------------------------------

    local tick_time = TheSim:GetTickTime()

    local desired_particles_per_second = 0
    inst.particles_per_tick = desired_particles_per_second * tick_time

    local num_particles_to_emit = inst.particles_per_tick

    local bx, by, bz = 0, 20, 0
    local emitter_shape = CreateBoxEmitter(bx, by, bz, bx + 20, by, bz + 20)

    EmitterManager:AddEmitter(inst, nil, function()
      while num_particles_to_emit > 1 do
        emit_fn(effect, emitter_shape)
        num_particles_to_emit = num_particles_to_emit - 1
      end
      num_particles_to_emit = num_particles_to_emit + inst.particles_per_tick
    end)
  end

  local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()

    inst:AddTag("FX")
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")

    InitParticles(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then return inst end

    inst.persists = false

    return inst
  end

  return Prefab("ashfx", fn, assets)

end
return generator
