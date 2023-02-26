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
    inst.components.tool:SetAction(ACTIONS.MINE, TUNING.BLAZEREAP_MINE_EFFECTIVENESS)
    inst.build = "swap_abyssweapon"
    inst.handsymbol = "abyssweapon"
    inst.components.weapon:SetDamage(TUNING.BLAZEREAP_DAMAGE)
    inst.components.weapon:SetOnAttack(blaze_reap_onattack)
    inst:AddComponent("submersible")
    inst.components.inventoryitem:SetSinks(true)
    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.POWER
    inst.components.fueled:InitializeFuelLevel(TUNING.BLAZEREAP_USE)
    inst.components.fueled:SetDepletedFn(blaze_reap_ondepleted)
    inst.components.fueled:SetTakeFuelFn(blaze_reap_onfueled)
    MakeHauntableLaunch(inst)
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
    inst._lasttime = now
    inst.Light:SetIntensity(intensity)
    if inst._chargeprogress <= 0 then inst.components.updatelooper:RemoveOnUpdateFn(sun_sphere_diminish) end
end
local function sun_sphere_charge(inst)
    inst._chargeprogress = 1
    inst._lasttime = nil
    inst.components.updatelooper:AddOnUpdateFn(sun_sphere_diminish)
end
local defs = {
    --[[
        unheard_bell={
            assets={Asset("ANIM", "anim/artifact_unheard_bell.zip")}
            ,postinit=function(inst)
                if not TheWorld.ismastersim then return inst end
                inst:AddComponent("activatable")
            end
    } ]]
    longetivity_drink = {
        assets = {Asset("ANIM", "anim/longetivity_drink.zip")},
        bank = "longetivity_drink",
        build = "longetivity_drink",
        anim = "idle",
        postinit = function(inst)
            inst:AddComponent("edible")
            inst:AddComponent("finiteuses")
            inst.components.finiteuses:SetMaxUses(1)
            inst.components.finiteuses:SetUses(1)
            inst.components.edible:SetGetHealthFn(function(inst, eater)
                local health = eater.components.health
                if health then return health:GetMaxWithPenalty() end
                return 0
            end)
            inst.components.edible:SetOnEatenFn(function(inst, eater)
                local oldager = eater.components.oldager
                if oldager then
                    oldager:AddValidHealingCause(inst.prefab)
                    oldager:StopDamageOverTime()
                end
                local poisonable = eater.components.poisonable
                if poisonable then poisonable:Cure(nil, true, TUNING.LONGETIVITY_DRINK_IMMUNITY) end
            end)
        end,
        desc = [[（命を延ばす酒（））
        于第4话被首次提到，莉可等人查阅的《遗物目录》中记载的遗物之一。
        拍卖名中“Dipsy”意为“嗜酒”，“Aeon”是拉丁语中“永恒”的意思。 ]],
        desc_en = [[It is a liquid Artifact, contained in an unusual shaped container. Upon consumption, it greatly extends the lifespan of the user.]]
    },
    grim_reaper = {
        slot = "hand",
        assets = {Asset("ANIM", "anim/grim_reaper.zip"), Asset("ANIM", "anim/swap_grim_reaper.zip")},
        bank = "grim_reaper",
        build = "grim_reaper",
        anim = "idle",
        tags = {"tool", "heavy"},
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
            inst.components.finiteuses:SetOnFinished(inst.Remove)
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
        postinit = blaze_reap,
        desc_en = [[The Blaze Reap is an abnormally large pickaxe that contains Everlasting Gunpowder, which causes ongoing explosions on whatever it is struck on and thus allowing it to serve as an impact explosive type weapon and earning it the epithet of the Everlasting Pickaxe]]
    },
    thousand_pin = {
        assets = {Asset("ANIM", "anim/thousand_pin.zip")},
        bank = "thousand_pin",
        build = "thousand_pin",
        anim = "idle",
        postinit = function(inst)
        end,
        desc_en = [[Thousand-Men Pins are Artifacts said to grant their user the strength of a thousand men with a single pin when thrust into the skin. Its auction name is Health Junkie]]
    },
    gold_shaker = {
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
        tags = {"nopunch", "umbrella"},
        postinit = function(inst)
            inst:AddComponent("weapon")
            inst.components.weapon:SetDamage(TUNING.SCALED_UMBRELLA_DAMAGE)
            inst:AddComponent("armor")
            inst.components.armor:InitCondition(TUNING.SCALED_UMBRELLA_DURABILITY, 0)
            inst:AddComponent("waterproofer")
            inst.components.waterproof:SetEffectiveness(0)
            inst:AddComponent("insulator")
            inst.components.insulator:SetSummer()
        end,
        should_sink = true,
        desc = [[
            It is a processed Artifact created from Charcoal Sand, a Third Grade Artifact, by being compressed into bars to form an umbrella. However poor craftsmanship resulted in an overall degradation of the grade. Nevertheless, the light weight and strength of Charcoal Sand hasn't been lost, meaning Riko can use the Scale Umbrella as a shield
        ]]
    },
    sun_sphere = {
        assets = {Asset("ANIM", "anim/sun_sphere.zip")},
        bank = "sun_sphere",
        build = "sun_sphere",
        light = {enable = false, radius = 20, intensity = .7, falloff = .9},
        anim = "idle",
        postinit = function(inst)
            inst:AddComponent("activatable")
            inst:AddComponent("timer")
            inst:AddComponent("updatelooper")
            inst._chargeprogress = 0
            inst.Recharge = sun_sphere_recharge
            inst.StartCharge = sun_sphere_charge
            inst.components.activatable.OnActivate = function(inst)
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
    -- inscinerator={
    -- desc=[[火葬炮]]
    -- }
    fruitful_orb = {
        assets = {Asset("ANIM", "anim/friutful_orb.zip")},
        bank = "friutful_orb",
        build = "friutful_orb",
        light = {enable = false, radius = 20, intensity = .7, falloff = .9},
        anim = "idle",
        postinit = function(inst)
        end,
        desc_en = [[A Relic used by Detchuanga. Equipping it significantly increases one's physical abilities.
        It heals injuries, but can't cure disease]]
    }
}
-- retrofit
defs.blazereap = defs.blaze_reap
defs.blazereap.postinit = function(inst)
    inst:DoTaskInTime(0, function()
        local olddata = inst:GetSaveRecord()
        olddata.prefab = "blaze_reap"
        SpawnSaveRecord(olddata)
        inst:Remove()
    end)
end
return defs
