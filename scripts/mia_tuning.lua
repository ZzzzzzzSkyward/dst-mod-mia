local function ret()
    return {
        RIKO_HEALTH = wilson_health,
        RIKO_HUNGER = wilson_hunger,
        RIKO_SANITY = wilson_sanity,
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
        ABYSSUSES = 200,
        REGER_SLOW_HUNGER = 0.6,
        REG_HUNGERRATE = 1.7 * WILSON_HUNGER_RATE,
        REG_DAMAGEMULTIPLIER = 1,
        REG_ABSORPTION = 0.4,
        RIKOHAT_LIGHTTIME = MINERHAT_LIGHTTIME * 2
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
