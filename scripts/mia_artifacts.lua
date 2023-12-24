local function inscinerator_ReticuleTarget()
  return Vector3(ThePlayer.entity:LocalToWorldSpace(6.5, 0, 0)) -- this is for controller to get player face direction
end

local function inscinerator_ReticuleMouseTarget(inst, mousepos)
  if mousepos ~= nil then
    local x, y, z = inst.Transform:GetWorldPosition()
    local dx = mousepos.x - x
    local dz = mousepos.z - z
    local l = dx * dx + dz * dz
    if l <= 0 then return inst.components.reticule.targetpos end
    l = 6.5 / math.sqrt(l)
    return Vector3(x + dx * l, 0, z + dz * l)
  end
end

local function inscinerator_ReticuleUpdate(inst, pos, reticule, ease, smoothing, dt)
  local x, y, z = inst.Transform:GetWorldPosition()
  reticule.Transform:SetPosition(x, 0, z)
  local rot = -math.atan2(pos.z - z, pos.x - x) / DEGREES
  if ease and dt ~= nil then
    local rot0 = reticule.Transform:GetRotation()
    local drot = rot - rot0
    rot = Lerp((drot > 180 and rot0 + 360) or (drot < -180 and rot0 - 360) or rot0, rot, dt * smoothing)
  end
  reticule.Transform:SetRotation(rot)
end
local function Inscinerator_CreateLight(def)
  local inst = CreateEntity()
  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddLight()
  inst.entity:AddNetwork()
  inst.AnimState:SetBank("fx_mia_star")
  inst.AnimState:SetBuild("fx_mia_star")
  inst.AnimState:PlayAnimation("idle_loop", true)
  inst.AnimState:SetScale(0.3, 0.3, 0.3)
  inst:AddTag("FX")
  inst.entity:SetCanSleep(false)
  inst.persists = false
  inst.Light:SetFalloff(def.falloff)
  inst.Light:SetIntensity(def.intensity)
  inst.Light:SetRadius(def.radius)
  inst.Light:SetColour(unpack(def.color))
  inst.Light:Enable(true)
  inst.entity:SetPristine()
  return inst
end
-- AOE targeted explosion
local explosion_spawner = function(name, target) return SpawnAt(name, target) end
local aoe_must_tags = {"_combat", "_health"}
local aoe_cant_tags = {"playerghost", "INLIMBO", "FX", "NOCLICK", "DECOR", "notarget", "shadow", "structure", "ghost"}
if not TheNet:GetPVPEnabled() then table.insert(aoe_cant_tags, "player") end
local function blaze_reap_onattack(inst, owner, target)
  if inst.components.fueled:IsEmpty() then return end
  local user_is_reg = owner:HasTag("mia_reg")
  local explosion_damage = user_is_reg and 150 or 15 -- math shows that the gunpowder is less effective
  -- common 51+15=66
  -- reg 51+150=201
  local fuel_cost = user_is_reg and 10 or 1
  local stimuli = nil
  local spdamage = nil -- special damage {}
  local explosion_type = user_is_reg and "explode_small_slurtlehole" or "explode_small"
  if target.components.health then
    if target.components.combat then
      target.components.combat:GetAttacked(owner, explosion_damage, inst, stimuli, spdamage)
    else
      target.components.health:DoDelta(-explosion_damage)
    end
    inst.components.fueled:DoDelta(-fuel_cost)
    local explode = explosion_spawner(explosion_type, target)
  end
  -- aoe part
  local x, y, z = inst.Transform:GetWorldPosition()
  local ents = TheSim:FindEntities(x, y, z, 5, aoe_must_tags, aoe_cant_tags)
  for i, v in ipairs(ents) do
    if v ~= target and v:IsValid() and v.entity:IsVisible() and not v.components.health:IsDead() then
      if v.components.combat then
        v.components.combat:GetAttacked(owner, explosion_damage, inst, stimuli, spdamage)
      else
        v.components.health:DoDelta(-explosion_damage)
      end
    end
  end
end
local inscinerator_light = {
  falloff = 3,
  radius = 1,
  intensity = 0.1,
  color = RGB(249, 123, 21),
  postpos = {0, 50, 0},
  pos = {0, 60, 0.2}
}
local function tracktask(inst)
  return function()
    local pos = Point(TheSim:ProjectScreenPos(TheSim:GetPosition()))
    inst:ForceFacePoint(pos)
  end
end
local function TrackMouse(inst)
  if inst._inscinerator_tracktask then return end
  -- inst._inscinerator_tracktask = inst:DoPeriodicTask(0, tracktask(inst))
end
local function StopTrackMouse(inst)
  if inst._inscinerator_tracktask then
    inst._inscinerator_tracktask:Cancel()
    inst._inscinerator_tracktask = nil
  end
end
local function GetMouse() return Point(TheSim:ProjectScreenPos(TheSim:GetPosition())) end
local function GetRadius()
  local dis = TheCamera:GetDistance()
  dis = math.clamp(15 / dis, 0, 10)
  return dis
end
local function SetInscineratorParam(...)
  return PostProcessor:SetUniformVariable(UniformVariables.INSCINERATOR_CENTER, ...)
end
local function SetInscineratorFire(enable)
  return PostProcessor:EnablePostProcessEffect(PostProcessorEffects.INSCINERATOR_CENTER, enable)
end
local function EnableInscineratorFire() return SetInscineratorFire(true) end
local function DisableInscineratorFire() return SetInscineratorFire(false) end
local function _postprocesstask(parent)
  return function()
    if parent and parent:IsValid() then
      local x, y = TheSim:GetScreenPos(parent.AnimState:GetSymbolPosition("arm_lower",
       unpack(inscinerator_light.postpos)))
      local radius = parent._GetFXRadius and parent:_GetFXRadius() or GetRadius()
      SetInscineratorParam(x, y, radius)
    end
  end
end
local function EnableInscineratorShaderTask(inst, parent)
  if inst._postprocesstask then return end
  inst._postprocesstask = inst:DoPeriodicTask(0, _postprocesstask(parent))
  inst:DoTaskInTime(0, EnableInscineratorFire)
end
local function DisableInscineratorShaderTask(inst)
  DisableInscineratorFire()
  if inst._postprocesstask then
    inst._postprocesstask:Cancel()
    inst._postprocesstask = nil
  end
end
local function Inscinerator_StartTargeting(inst, doer)
  if inst:HasTag("launching") then return end
  if inst._light then return end
  local lightfx = Inscinerator_CreateLight(inscinerator_light)
  local parent = inst:GetParent()
  lightfx.entity:SetParent(parent.entity)
  lightfx.entity:AddFollower()
  lightfx.Follower:FollowSymbol(parent.GUID, "arm_lower", unpack(inscinerator_light.pos))
  lightfx.AnimState:SetFinalOffset(2)
  inst._light = lightfx
  -- #FIXME revert to before
  doer.AnimState:Show("ARM_carry")
  doer.AnimState:Hide("ARM_normal")
  doer.AnimState:ClearOverrideSymbol("swap_object")
  EnableInscineratorShaderTask(inst, parent)
  TrackMouse(parent)
  inst.components.aoetargeting:StartTargeting()
end
local launch_target_radius = 5
local function launchtask(inst)
  local final = launch_target_radius
  local radius = inst._light.Light:GetRadius()
  if radius < final then
    inst._light.Light:SetRadius(radius + 0.5)
  else
    local parent = inst:GetParent()
    inst._ticktask:Cancel()
    inst._ticktask = nil
    inst._light:Remove()
    inst._light = nil
    DisableInscineratorShaderTask(inst)
    parent._GetFXRadius = nil
    inst:DoTaskInTime(5, function(inst) inst:RemoveTag("launching") end)
    inst.components.aoeprojectile.enable = true
    parent.chargeleft = parent.chargeleft - 1
    inst:UpdateCharge()
    return inst.components.aoeprojectile:Launch()
  end
end
local function MakeRadiusFn(startrad, endrad, duration)
  local starttime = GetTime()
  return function()
    local t = GetTime()
    local dt = t - starttime
    if dt > duration then return endrad end
    local r = startrad + (endrad - startrad) * dt / duration
    return r
  end
end
local function Inscinerator_StopTargeting(inst)
  inst.components.aoetargeting:StopTargeting()
  if not inst._light then return end
  inst._light:Remove()
  inst._light = nil
  DisableInscineratorShaderTask(inst)
  StopTrackMouse(inst:GetParent())
  -- revert arm
  local parent = inst:GetParent()
  if parent then
    if parent.components.inventory and not parent.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
      --revert if bare hand
      parent.AnimState:Hide("ARM_carry")
      parent.AnimState:Show("ARM_normal")
    end
  end
end
local function Inscinerator_Launch(inst, doer, pos, target)
  if inst:HasTag("launching") then return end
  if not inst._light then return end
  inst:AddTag("launching")
  inst.components.aoetargeting:StopTargeting()
  local parent = doer or inst:GetParent()
  StopTrackMouse(parent)
  parent._GetFXRadius = MakeRadiusFn(GetRadius(), math.clamp(GetRadius() * 4, 1, launch_target_radius), 1)
  local tick = 0.2
  inst.components.aoeprojectile.pos = GetMouse()
  inst.components.aoeprojectile.target = target
  if not inst._ticktask then
    inst._ticktask = inst:DoPeriodicTask(tick, launchtask)
  end
end

local function blaze_reap_ondepleted(inst) inst.components.tool:SetAction(ACTIONS.MINE, 0.5) end
local function blaze_reap_onfueled(inst)
  inst.components.tool:SetAction(ACTIONS.MINE, TUNING.BLAZEREAP_MINE_EFFECTIVENESS)
end
local function blaze_reap_UpdateState(inst)
  if inst.components.fueled:IsEmpty() then
    blaze_reap_ondepleted(inst)
  else
    blaze_reap_onfueled(inst)
  end
end
local function blaze_reap(inst)
  inst:AddComponent("weapon")
  inst:AddComponent("tool")
  blaze_reap_onfueled(inst)
  inst.build = "swap_abyssweapon"
  inst.handsymbol = "abyssweapon"
  inst.components.weapon:SetDamage(TUNING.BLAZEREAP_DAMAGE)
  inst.components.weapon:SetOnAttack(blaze_reap_onattack)
  inst:AddComponent("submersible")
  inst:AddComponent("fueled")
  inst.components.fueled.fueltype = FUELTYPE.POWER
  inst.components.fueled:InitializeFuelLevel(TUNING.BLAZEREAP_USES)
  inst.components.fueled:SetDepletedFn(blaze_reap_ondepleted)
  inst.components.fueled:SetTakeFuelFn(blaze_reap_onfueled)
  inst.components.fueled.accepting = true
  -- seems that it is not called when start, so I do it
  inst:DoTaskInTime(0, blaze_reap_UpdateState)
  return inst
end
local function sun_sphere_recharge(inst) inst._chargeprogress = 1 end
local function sun_sphere_diminish(inst)
  local now = GetTime()
  local lasttime = inst._lasttime or now
  local dt = now - lasttime
  local dcharge = dt / TUNING.SUN_SPHERE_DURATION
  inst._chargeprogress = inst._chargeprogress - dcharge
  if inst._chargeprogress <= 0 then inst._chargeprogress = 0 end
  local intensity = Lerp(0, TUNING.SUN_SPHERE_INTENSITY, inst._chargeprogress)
  local radius = Lerp(TUNING.SUN_SPHERE_RADIUS_MIN, TUNING.SUN_SPHERE_RADIUS_MAX, inst._chargeprogress)
  inst._lasttime = now
  inst.Light:SetIntensity(intensity)
  inst.Light:SetRadius(radius)
  if inst._chargeprogress <= 0 then inst:StopCharge() end
end
local function sun_sphere_charge(inst)
  inst._chargeprogress = 1
  inst._lasttime = nil
  if inst.components.fueled then inst.components.fueled:StartConsuming() end
  inst.components.updatelooper:AddOnUpdateFn(sun_sphere_diminish)
end
local function sun_sphere_stop(inst)
  inst._chargeprogress = 1
  inst._lasttime = nil
  inst.components.updatelooper:RemoveOnUpdateFn(sun_sphere_diminish)
  if inst.components.fueled then inst.components.fueled:StopConsuming() end
end
local lookupval = nil
local lookupsize = nil
local function CalcMult(size, mult)
  if size == lookupsize then return lookupval end
  local v = 1
  for i = 1, size do v = v * mult end
  lookupsize = size
  lookupval = v
  return v
end
local function scaled_umbrella_transform(inst)
  if inst.opened then
    inst.components.weapon:SetDamage(TUNING.SCALED_UMBRELLA_DAMAGE_WEAPON)
    inst.components.weapon:SetRange(TUNING.SCALED_UMBRELLA_RANGE)
    inst.components.armor:SetAbsorption(0)
    inst.components.insulator:SetInsulation(0)
    inst:AddTag("jab")
    inst.handsymbol = "swap_scaled_umbrella"
    inst.components.inventoryitem.imagename = "scaled_umbrella"
    inst.components.inventoryitem:ChangeImageName("scaled_umbrella")
    inst.components.waterproofer:SetEffectiveness(0)
    -- #TODO hack GetAbsorption
  else
    inst:RemoveTag("jab")
    inst.components.armor:SetAbsorption(TUNING.SCALED_UMBRELLA_ARMOR)
    inst.components.weapon:SetDamage(TUNING.SCALED_UMBRELLA_DAMAGE)
    inst.components.weapon:SetRange(1)
    inst.components.insulator:SetInsulation(TUNING.SCALED_UMBRELLA_INSULATION)
    inst.handsymbol = "swap_scaled_umbrella_open"
    inst.components.inventoryitem.imagename = "scaled_umbrella_open"
    inst.components.inventoryitem:ChangeImageName("scaled_umbrella_open")
    inst.components.waterproofer:SetEffectiveness(TUNING.SCALED_UMBRELLA_WATERPROOF)
  end
  if inst.components.equippable:IsEquipped() then
    local owner = inst.components.inventoryitem.owner
    if owner then
      inst.components.equippable:Unequip(owner)
      inst.components.equippable:Equip(owner)
    end
  end
  inst.opened = not inst.opened
end
local function scaled_umbrella_onload(inst, data)
  inst.opened = data and data.opened
  if inst.opened then scaled_umbrella_transform(inst) end
end
local function scaled_umbrella_onsave(inst, data)
  data.opened = inst.opened
  return data
end
local function scaled_umbrella_getstatus(inst)
  local opened = inst.opened
  if opened then return "OPEN" end
end
local prushka_cooldown = 3
local prushka_activate_range = 40 -- consider change this into a component if more white whistle are added. but currently we only have prushka
local function prushka_activate(inst)
  local owner = inst.components.inventoryitem.owner
  if not owner then return end
  inst:DoTaskInTime(prushka_cooldown, function() inst.components.useableitem.inuse = false end)
  local talker = owner.components.talker
  if owner.prefab == "riko" then
    local x, y, z = owner.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, prushka_activate_range, {"player", "reg"})
    for i, reg in ipairs(ents) do
      if reg.components.relicactivatable then reg.components.relicactivatable:Activate(inst) end
    end
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
local defs = {
  unheard_bell = {
    disabled = true,
    assets = {Asset("ANIM", "anim/unheard_bell.zip")},
    postinit = function(inst) inst:AddComponent("activatable") end
  },
  longetivity_drink = {
    -- disabled = true,
    assets = {Asset("ANIM", "anim/longetivity_drink.zip")},
    bank = "longetivity_drink",
    build = "longetivity_drink",
    anim = "idle",
    postinit = function(inst)
      inst:AddComponent("edible")
      inst:AddComponent("finiteuses")
      inst.components.finiteuses:SetMaxUses(1)
      inst.components.finiteuses:SetUses(1)
      inst.components.edible.secondaryfoodtype = FOODTYPE.ROUGHAGE
      inst.components.edible.hungervalue = 0
      inst.components.edible:SetGetHealthFn(function(inst, eater)
        if not eater then return 0 end
        local health = eater.components.health
        if health then return health:GetMaxWithPenalty() end
        return 0
      end)
      inst.components.edible:SetOnEatenFn(function(inst, eater)
        local oldager = eater.components.oldager
        if oldager then
          oldager:AddValidHealingCause(inst.prefab)
          if oldager.damage_per_second > 0 then oldager:StopDamageOverTime() end
        end
        local poisonable = eater.components.poisonable
        if poisonable then poisonable:Cure(nil, true, TUNING.LONGETIVITY_DRINK_IMMUNITY) end
        local buff = eater.components.debuffable
        if buff then buff:AddDebuff("longetivity_drink", "ghostlyelixir_slowregen_buff") end
      end)
    end,
    desc = [[（命を延ばす酒（））
        于第4话被首次提到，莉可等人查阅的《遗物目录》中记载的遗物之一。
        拍卖名中“Dipsy”意为“嗜酒”，“Aeon”是拉丁语中“永恒”的意思。 ]],
    desc_en = [[It is a liquid Artifact, contained in an unusual shaped container. Upon consumption, it greatly extends the lifespan of the user.]]
  },
  grim_reaper = {
    disabled = true,
    slot = "hand",
    assets = {Asset("ANIM", "anim/grim_reaper.zip"), Asset("ANIM", "anim/swap_grim_reaper.zip")},
    bank = "grim_reaper",
    build = "grim_reaper",
    anim = "idle",
    tags = {"tool", "heavy"},
    should_sink = true,
    postinit = function(inst)
      inst:AddComponent("tool")
      inst:AddComponent("finiteuses")
      local actions = {"MINE", "CHOP", "HACK", "SHEAR", "REAP"}
      for i, v in ipairs(actions) do
        if ACTIONS[v] then inst.components.tool:SetAction(ACTIONS[v], math.huge) end
        inst.components.finiteuses:SetConsumption(ACTIONS[v], 1)
      end
      inst.components.finiteuses:SetMaxUses(TUNING.GRIM_REAPER_USES)
      inst.components.finiteuses:SetUses(TUNING.GRIM_REAPER_USES)
      -- inst.components.finiteuses:SetOnFinished(inst.Remove)
      inst:AddComponent("submersible")
      inst:ListenForEvent("percentusedchange", function(inst, newpc)
        if newpc < 0 then return end
        if inst:HasTag("usesdepleted") then return end
        local owner = inst.components.inventoryitem.owner
        if owner then
          if owner.components.hunger then owner.components.hunger:DoDelta(TUNING.GRIM_REAPER_HUNGER) end
        end
      end)
    end,
    onequip = function(inst, owner)
      if owner and owner.components.hunger then
        local burn = owner.components.hunger.burnratemodifiers
        if burn then burn:SetModifier(inst, TUNING.GRIM_REAPER_HUNGER_MODIFIER) end
      end
    end,
    onunequip = function(inst, owner)
      if owner and owner.components.hunger then
        local burn = owner.components.hunger.burnratemodifiers
        if burn then burn:RemoveModifier(inst, TUNING.GRIM_REAPER_HUNGER_MODIFIER) end
      end
    end,
    desc_en = [[It is a pair of scissors able to cut iron]],
    desc = "切割钢铁的剪刀"
  },
  blaze_reap = {
    assets = {Asset("ANIM", "anim/abyssweapon.zip"), Asset("ANIM", "anim/swap_abyssweapon.zip")},
    slot = "hand",
    bank = "abyssweapon",
    build = "abyssweapon",
    anim = "idle",
    tags = {"blaze_reap", "sharp", "power_fueled", "weapon"},
    should_sink = true,
    postinit = blaze_reap,
    desc_en = [[The Blaze Reap is an abnormally large pickaxe that contains Everlasting Gunpowder, which causes ongoing explosions on whatever it is struck on and thus allowing it to serve as an impact explosive type weapon and earning it the epithet of the Everlasting Pickaxe]]
  },
  thousand_pin = {
    disabled = true,
    assets = {Asset("ANIM", "anim/thousand_pin.zip")},
    bank = "thousand_pin",
    build = "thousand_pin",
    anim = "idle",
    should_sink = true,
    postinit = function(inst)
      inst:AddComponent("submersible")
      inst:AddComponent("relicequip")
      inst:AddComponent("stackable")
      inst:ListenForEvent("stacksizechange", function(inst, data)
        inst.components.relicequip.damagemult = CalcMult(data.stacksize, TUNING.THOUSAND_PIN_DAMAGE_MULT)
      end)
      inst.components.stackable:SetStackSize(TUNING.THOUSAND_PIN_STACKSIZE)
      inst.components.relicequip.equipslot = RELICSLOTS.SKIN
    end,
    desc_en = [[Thousand-Men Pins are Artifacts said to grant their user the strength of a thousand men with a single pin when thrust into the skin. Its auction name is Health Junkie]]
  },
  gold_shaker = {
    disabled = true,
    assets = {Asset("ANIM", "anim/gold_shaker.zip")},
    bank = "gold_shaker",
    build = "gold_shaker",
    anim = "idle",
    postinit = function(inst) end,
    desc_en = [[It is a dust collecting pot]],
    desc = [[收集沙尘的壶]]
  },
  tomorrow_signal = {
    disabled = true,
    assets = {Asset("ANIM", "anim/tomorrow_signal.zip")},
    bank = "tomorrow_signal",
    build = "tomorrow_signal",
    anim = "idle",
    postinit = function(inst) end,
    desc_en = [[It is a strangely shaped Artifact allowing its user to control the weather]],
    desc = [[预测天气的风信鸡]]
  },
  princess_bosom = {
    disabled = true,
    assets = {Asset("ANIM", "anim/princess_bosom.zip")},
    bank = "princess_bosom",
    build = "princess_bosom",
    anim = "idle",
    postinit = function(inst) end,
    desc_en = [[It is a egg-shaped Artifact with patterns on its surface and has a soft texture that squishes when pressure is applied to it.
        Delvers refer to it as "Boob Stone", due to its softness and feel being very similar to breasts.]],
    desc = [[姬乳房]]
  },
  scaled_umbrella = {
    assets = {Asset("ANIM", "anim/scaled_umbrella.zip")},
    bank = "scaled_umbrella",
    build = "scaled_umbrella",
    slot = "hand",
    anim = "idle",
    tags = {"umbrella", "pointy", "jab", "weapon", "acidrainimmune"},
    floatsymbol = "swap_scaled_umbrella",
    postinit = function(inst)
      inst.handsymbol = "swap_scaled_umbrella"
      inst.build = "scaled_umbrella"
      inst:AddComponent("weapon")
      inst.components.weapon:SetDamage(TUNING.SCALED_UMBRELLA_DAMAGE_WEAPON)
      inst.components.weapon:SetOnAttack(function(inst, attacker)
        local self = inst.components.weapon
        if inst.components.armor ~= nil then
          local uses = (self.attackwear or 1) * self.attackwearmultipliers:Get()
          if attacker ~= nil and attacker:IsValid() and attacker.components.efficientuser ~= nil then
            uses = uses * (attacker.components.efficientuser:GetMultiplier(ACTIONS.ATTACK) or 1)
          end
          inst.components.armor:SetCondition(inst.components.armor.condition - uses)
        end

      end)
      -- inst:AddComponent("parryweapon")
      inst:AddComponent("armor")
      inst.components.armor:InitCondition(TUNING.SCALED_UMBRELLA_DURABILITY, 0)
      inst:AddComponent("useableitem")
      inst.components.useableitem:SetOnUseFn(scaled_umbrella_transform)
      -- hack
      local old = inst.components.useableitem.StartUsingItem
      function inst.components.useableitem:StartUsingItem(...)
        local ret = {old(self, ...)}
        self.inuse = false
        return unpack(ret)
      end
      inst.OnLoad = scaled_umbrella_onload
      inst.OnSave = scaled_umbrella_onsave
      inst:AddComponent("waterproofer")
      inst.components.waterproofer:SetEffectiveness(0)
      inst:AddComponent("insulator")
      inst.components.insulator:SetSummer()
      inst.components.inspectable.getstatus = scaled_umbrella_getstatus
    end,
    desc = [[
            It is a processed Artifact created from Charcoal Sand, a Third Grade Artifact, by being compressed into bars to form an umbrella. However poor craftsmanship resulted in an overall degradation of the grade. Nevertheless, the light weight and strength of Charcoal Sand hasn't been lost, meaning Riko can use the Scale Umbrella as a shield
        ]]
  },
  sun_sphere = {
    disabled = true,
    assets = {Asset("ANIM", "anim/sun_sphere.zip")},
    bank = "sun_sphere",
    build = "sun_sphere",
    light = {
      enable = true,
      radius = TUNING.SUN_SPHERE_RADIUS_MIN,
      intensity = .7,
      falloff = .9
    },
    anim = "idle",
    postinit = function(inst)
      inst:AddComponent("activatable")
      inst:AddComponent("timer")
      inst:AddComponent("updatelooper")
      inst:AddComponent("fueled")
      inst.components.fueled.fueltype = FUELTYPE.MAGIC
      inst.components.fueled:SetDepletedFn(inst.Remove)
      inst.components.fueled.maxfuel = TUNING.SUN_SPHERE_FUEL
      inst.components.fueled.rate = TUNING.SUN_SPHERE_RATE
      inst._chargeprogress = 0
      inst.Recharge = sun_sphere_recharge
      inst.StartCharge = sun_sphere_charge
      inst.StopCharge = sun_sphere_stop
      inst.components.activatable.OnActivate = function(inst)
        inst.components.activatable.inactive = true
        if inst._chargeprogress > 0 then
          inst:Recharge()
          return
        end
        inst:StartCharge()
      end
    end,
    desc_en = [[
The Sun Sphere is shaped like an egg with a round structure in its center and encasements at the top and bottom covering its exterior glass-like structure.
Upon activation, it emits a bright light.
It was used by Riko and Reg to distract the attention of creatures away from them and enable the two to escape.
It was eaten by an aquatic creature in the Sea of Corpses.
        ]]
  },
  inscinerator = {
    assets = {},
    fn = function(inst)
      local inst = CreateEntity()
      inst.entity:AddTransform()
      inst.entity:AddNetwork() -- because of aoetargeting
      inst:AddTag("NOBLOCK")
      inst:AddTag("NOCLICK")
      inst:AddTag("INLIMBO")
      -- direction indicator
      inst:AddComponent("aoetargeting")
      inst.components.aoetargeting:SetAlwaysValid(true)
      inst.components.aoetargeting.reticule.reticuleprefab = "reticulelongmulti"
      inst.components.aoetargeting.reticule.pingprefab = "reticulelongmultiping"
      inst.components.aoetargeting.reticule.targetfn = inscinerator_ReticuleTarget
      inst.components.aoetargeting.reticule.mousetargetfn = inscinerator_ReticuleMouseTarget
      inst.components.aoetargeting.reticule.updatepositionfn = inscinerator_ReticuleUpdate
      inst.components.aoetargeting.reticule.validcolour = {1, .75, 0, 1}
      inst.components.aoetargeting.reticule.invalidcolour = {.5, 0, 0, 1}
      inst.components.aoetargeting.reticule.ease = true
      inst.components.aoetargeting.reticule.mouseenabled = true
      -- hack to bypass non inventoryitem
      function inst.components.aoetargeting:StartTargeting()
        if not inst:IsValid() then return end
        local player = inst:GetParent() or ThePlayer
        if not player then return end
        if player:HasTag("playerghost") or player.replica.health:IsDead() then return end
        local r = inst.components.reticule
        if not r then
          inst:AddComponent("reticule")
          r = inst.components.reticule
          for k, v in pairs(self.reticule) do r[k] = v end
        end
        if r.reticule then return end
        if r.mouseenabled or TheInput:ControllerAttached() then
          --[[
                    if player then
                        local pc = player.components.playercontroller
                        if pc then
                            local rr = pc.reticule
                            if rr ~= r then
                                if rr then rr:DestroyReticule() end
                                pc.reticule = r
                            end
                        end
                    end]]
          -- #TODO sync with playercontroller
          r:CreateReticule()
        end
      end
      function inst.components.aoetargeting:StopTargeting()
        local reticule = self.inst.components.reticule
        if reticule then
          reticule:DestroyReticule()
          self.inst:RemoveComponent("reticule")
        end
      end
      inst.entity:SetPristine()
      if not TheWorld.ismastersim then return inst end
      inst.is_mia_artifact = true
      inst:AddComponent("relicequip")
      inst.components.relicequip.equipslot = RELICSLOTS.ARM
      inst.components.relicequip.un_unequippable = true
      inst:AddComponent("aoeprojectile")
      inst.components.aoeprojectile:SetCannon("inscinerator_particle")
      -- see action def
      inst.StartTargeting = Inscinerator_StartTargeting
      inst.StopTargeting = Inscinerator_StopTargeting
      inst.Launch = Inscinerator_Launch
      inst.UpdateCharge = function()
        local parent = inst:GetParent()
        local charge
        if parent then charge = parent.chargeleft end
        if charge then
          local hat = parent.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
          if hat and hat.prefab == "reg_hat" then
            hat.components.fueled:SetPercent(charge / TUNING.REG_INSCINERATOR_USE)
          end
          if charge<=0 then
            inst:AddTag("inscinerator_depleted")
          else
            inst:RemoveTag("inscinerator_depleted")
          end
        end
      end

      inst:DoTaskInTime(1, function(inst) if not inst:GetParent() then inst:Remove() end end)
      return inst
    end,
    desc = [[火葬炮]]
  },
  fruitful_orb = {
    assets = {Asset("ANIM", "anim/fruitful_orb.zip")},
    bank = "fruitful_orb",
    build = "fruitful_orb",
    light = {
      enable = false,
      radius = 0.5,
      intensity = .2,
      falloff = 1
    },
    anim = "idle",
    postinit = function(inst)
      inst:AddComponent("relicactivatable")
      inst.components.relicactivatable:SetOnActivate(function()
        inst.Light:Enable(true)
        inst.Light:SetRadius(0.5)
        inst.Light:SetIntensity(.2)
        inst.Light:SetFalloff(1)
        inst.AnimState:SetHaunted(true)
        if inst._deactivatetask then inst._deactivatetask:Cancel() end
        inst._deactivatetask = inst:DoTaskInTime(10, inst.deactivate)
      end)
      inst.components.relicactivatable:SetOnDeactivate(function()
        inst.Light:Enable(false)
        inst.AnimState:SetHaunted(false)
      end)
      inst.deactivate = sun_sphere_charge -- #TODO
    end,
    desc_en = [[A Relic used by Detchuanga. Equipping it significantly increases one's physical abilities.
        It heals injuries, but can't cure disease]]
  },
  artifact_prushka = {
    slot = "neck",
    bank = "artifact_prushka",
    build = "artifact_prushka",
    anim = "idle",
    assets = {Asset("ANIM", "anim/artifact_prushka.zip")},
    postinit = function(inst)
      inst.build = "artifact_prushka"
      inst.bodysymbol = "swap_artifact_prushka"
      inst:AddComponent("useableitem")
      inst.components.useableitem:SetOnUseFn(prushka_activate)
      -- inst.components.equippable.restrictedtag = "riko"--others can equip her but nothing happens
    end
  },
  stone_lighter = {
    disabled = true,
    desc = [[在阿比斯里采集到的石头。
打磨之后,施加某种频率的振动就会发出强光。
可以用作机械式的照明灯。
]]
  },
  infinite_gunpowder = {
    disabled = true,
    desc = [[无尽火药]]
  }
}
-- protect
for k, v in pairs(defs) do if v.disabled then defs[k] = nil end end
return defs
