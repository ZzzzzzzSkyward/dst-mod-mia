local function ret()
    return {
        RIKO_HEALTH = wilson_health,
        RIKO_HUNGER = wilson_hunger,
        RIKO_SANITY = wilson_sanity,
        RIKO_NIGHT_SANITY_MULT = 0.2,
        RIKO_NEG_SANITY_MULT = -1,
        NANACHI_HEALTH = wilson_health,
        NANACHI_HUNGER = 150,
        NANACHI_SANITY = 200,
        NANACHI_SPEED_MULTIPLIER = 1.1,
        REG_HEALTH = wilson_health,
        REG_HUNGER = 100,
        REG_SANITY = 100,
        RIKO_DAMAGE_MULTIPLIER = 0.7,
        MITTY_CD = 30,
        MITTY_NUM = 5,
        REGBOMB_HELATH = 40,
        REGBOMB_HUNGER = 40,
        REGBOMB_SANITY = 40,
        REGBOMB_DAMAGE = 800,
        REGBOMB_CONSUME = 1,
        REGERMAXTIME = 5,
        BLAZEREAP_USES = 200,
        REGER_SLOW_HUNGER = 0.6,
        REG_HUNGERRATE = 1.7 * WILSON_HUNGER_RATE,
        REG_DAMAGEMULTIPLIER = 1,
        REG_ABSORPTION = 0.4,
        RIKOHAT_LIGHTTIME = MINERHAT_LIGHTTIME * 2,
        REGHAT_ABSORPTION = 0.9,
        BLAZEREAP_DAMAGE = 51,
        REG_FIRE_DAMAGE = .2,
        REG_FREEZE_DAMAGE_RATE = .1,
        REG_HEAT_DAMAGE_RATE = .1,
        BLAZEREAP_MINE_EFFECTIVENESS = 1.5,
        GRIM_REAPER_USES = AXE_USES,
        GRIM_REAPER_HUNGER = -5,
        GRIM_REAPER_HUNGER_MODIFIER = 2,
        SCALED_UMBRELLA_DAMAGE = 20,
        SCALED_UMBRELLA_DURABILITY = 3000,
        SCALED_UMBRELLA_ARMOR = 1,
        SUN_SPHERE_INTENSITY = .8,
        SUN_SPHERE_DURATION = 60,
        SUN_SPHERE_RADIUS_MIN = 1,
        SUN_SPHERE_RADIUS_MAX = 20,
        LONGETIVITY_DRINK_IMMUNITY = 60 * 8
    }
end
local TuningHack = {}
setmetatable(TuningHack, {
    __index = function(_, k)
        if k == nil then return nil end
        if type(k) == "string" and TUNING[string.upper(k)] then
            return TUNING[string.upper(k)]
        else
            return _G[k]
        end
    end
})
setfenv(ret, TuningHack)
return ret
