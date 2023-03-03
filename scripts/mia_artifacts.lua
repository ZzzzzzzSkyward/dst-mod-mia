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

local function BloomOrange(inst)
    inst:AddLight()
    --    inst.AnimState:SetMultColour(204/255,131/255,57/255,1)
    inst.Light:SetColour(219 / 255, 168 / 255, 117 / 255, 1)
    inst.Light:SetRadius(1)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetIntensity(1)
end
local function makefx(t)
    local function startfx(proxy)
        -- print ("SPAWN", debugstack())
        local inst = CreateEntity(t.name)

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        local parent = proxy.entity:GetParent()
        if parent ~= nil then inst.entity:SetParent(parent.entity) end

        if t.nameoverride == nil and t.description == nil then inst:AddTag("FX") end
        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst.Transform:SetFromProxy(proxy.GUID)

        if t.autorotate and parent ~= nil then inst.Transform:SetRotation(parent.Transform:GetRotation()) end

        if t.sound ~= nil then
            inst.entity:AddSoundEmitter()
            if t.update_while_paused then
                inst:DoStaticTaskInTime(t.sounddelay or 0, PlaySound, t.sound)
            else
                inst:DoTaskInTime(t.sounddelay or 0, PlaySound, t.sound)
            end
        end

        if t.sound2 ~= nil then
            if inst.SoundEmitter == nil then inst.entity:AddSoundEmitter() end
            if t.update_while_paused then
                inst:DoStaticTaskInTime(t.sounddelay2 or 0, PlaySound, t.sound2)
            else
                inst:DoTaskInTime(t.sounddelay2 or 0, PlaySound, t.sound2)
            end
        end

        inst.AnimState:SetBank(t.bank)
        inst.AnimState:SetBuild(t.build)
        inst.AnimState:PlayAnimation(FunctionOrValue(t.anim)) -- THIS IS A CLIENT SIDE FUNCTION
        if t.update_while_paused then inst.AnimState:AnimateWhilePaused(true) end
        if t.tint ~= nil then
            inst.AnimState:SetMultColour(t.tint.x, t.tint.y, t.tint.z, t.tintalpha or 1)
        elseif t.tintalpha ~= nil then
            inst.AnimState:SetMultColour(t.tintalpha, t.tintalpha, t.tintalpha, t.tintalpha)
        end
        -- print(inst.AnimState:GetMultColour())
        if t.transform ~= nil then inst.AnimState:SetScale(t.transform:Get()) end

        if t.nameoverride ~= nil then
            if inst.components.inspectable == nil then inst:AddComponent("inspectable") end
            inst.components.inspectable.nameoverride = t.nameoverride
            inst.name = t.nameoverride
        end

        if t.description ~= nil then
            if inst.components.inspectable == nil then inst:AddComponent("inspectable") end
            inst.components.inspectable.descriptionfn = t.description
        end

        if t.bloom then inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh") end

        if t.animqueue then
            inst:ListenForEvent("animqueueover", inst.Remove)
        else
            inst:ListenForEvent("animover", inst.Remove)
        end

        if t.fn ~= nil then
            if t.fntime ~= nil then
                if t.update_while_paused then
                    inst:DoStaticTaskInTime(t.fntime, t.fn)
                else
                    inst:DoTaskInTime(t.fntime, t.fn)
                end
            else
                t.fn(inst)
            end
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        -- Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            -- Delay one frame so that we are positioned properly before starting the effect
            -- or in case we are about to be removed
            if t.update_while_paused then
                inst:DoStaticTaskInTime(0, startfx, inst)
            else
                inst:DoTaskInTime(0, startfx, inst)
            end
        end

        if t.twofaced then
            inst.Transform:SetTwoFaced()
        elseif t.eightfaced then
            inst.Transform:SetEightFaced()
        elseif t.sixfaced then
            inst.Transform:SetSixFaced()
        elseif not t.nofaced then
            inst.Transform:SetFourFaced()
        end

        inst:AddTag("FX")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then return inst end

        inst.persists = false
        inst:DoTaskInTime(1, inst.Remove)

        return inst
    end

    return fn
end
local glow_fx = makefx({
    name = "inscinerator_glowfx",
    bank = "",
    build = "",
    anim = "",
    fn = function(inst)
        BloomOrange(inst)
    end
})
local fireball_hit_fx = function()
    return Prefabs.fireball_hit_fx.fn()
end

local function blaze_reap_onattack(inst, owner, target)
    if target.components.health and not inst.components.fueled:IsEmpty() then
        if owner:HasTag("mia_reg") then
            SpawnPrefab("explode_small").Transform:SetPosition(target.Transform:GetWorldPosition())
            target.components.health:DoDelta(-150)
            inst.components.fueled:DoDelta(-10)
        else
            local explode = SpawnPrefab("explode_small")
            explode.Transform:SetScale(0.3, 0.3, 0.3)
            explode.Transform:SetPosition(target.Transform:GetWorldPosition())
            target.components.health:DoDelta(-15)
            inst.components.fueled:DoDelta(-1)
        end
    end
end

local function blaze_reap_ondepleted(inst)
    inst.components.tool:SetAction(ACTIONS.MINE, 0)
end
local function blaze_reap_onfueled(inst)
    inst.components.tool:SetAction(ACTIONS.MINE, TUNING.BLAZEREAP_MINE_EFFECTIVENESS)
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
    return inst
end
local function sun_sphere_recharge(inst)
    inst._chargeprogress = 1
end
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
    inst:DoTaskInTime(prushka_cooldown, function()
        inst.components.useableitem.inuse = false
    end)
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
        assets = {Asset("ANIM", "anim/artifact_unheard_bell.zip")},
        postinit = function(inst)
            inst:AddComponent("activatable")
        end
    },
    longetivity_drink = {
        disabled = true,
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
            local actions = {"MINE", "CHOP", "HACK", "SHEAR"}
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
                    if owner.components.hunger then
                        owner.components.hunger:DoDelta(TUNING.GRIM_REAPER_HUNGER)
                    end
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
        postinit = function(inst)
        end,
        desc_en = [[It is a dust collecting pot]],
        desc = [[收集沙尘的壶]]
    },
    --[[your_worth={
        desc="生命回响之石"
        --},]]
    tomorrow_signal = {
        disabled = true,
        assets = {Asset("ANIM", "anim/tomorrow_signal.zip")},
        bank = "tomorrow_signal",
        build = "tomorrow_signal",
        anim = "idle",
        postinit = function(inst)
        end,
        desc_en = [[It is a strangely shaped Artifact allowing its user to control the weather]],
        desc = [[预测天气的风信鸡]]
    },
    princess_bosom = {
        disabled = true,
        assets = {Asset("ANIM", "anim/princess_bosom.zip")},
        bank = "princess_bosom",
        build = "princess_bosom",
        anim = "idle",
        postinit = function(inst)
        end,
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
        tags = {"umbrella", "pointy", "jab", "weapon"},
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
        light = {enable = true, radius = TUNING.SUN_SPHERE_RADIUS_MIN, intensity = .7, falloff = .9},
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
                if player:HasTag("playerghost") then return end
                if player.replica.health:IsDead() then return end
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
            -- "red glow glimmer unstable fx"
            -- simplified
            inst.instant_fire_fx = fireball_hit_fx

            -- below are not realized fx
            inst.heat_glow = glow_fx
            inst.energy_absorb = "sparks flying into fx"
            inst.emit_before = "electric shock fx"
            inst.emit_stream = {"electricity ring around fx", "particle send fx", "unstable x-ray fx"}
            inst.ember_after = "spark scatter fx"
            inst.steam_after = "steam fx"
            -- other.burnt = "?"
            -- ground.burnt = "meteor ground fx"
            return inst
        end,

        desc = [[火葬炮]]
    },
    fruitful_orb = {
        disabled= true,
        assets = {Asset("ANIM", "anim/fruitful_orb.zip")},
        bank = "fruitful_orb",
        build = "fruitful_orb",
        light = {enable = false, radius = 0.5, intensity = .2, falloff = 1},
        anim = "idle",
        postinit = function(inst)
            -- inst.AnimState:SetMultColour(1,1,1,0.8)--#TODO change anim
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
        disabled = true,
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
    }
}
-- protect
for k, v in pairs(defs) do if v.disabled then defs[k] = nil end end
return defs
