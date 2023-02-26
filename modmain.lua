GLOBAL.setmetatable(env, {
    __index = function(t, k)
        return GLOBAL.rawget(GLOBAL, k)
    end
})
function dig(x)
    return require("mia_" .. x)
end
PrefabFiles = dig("prefablist")
Assets = dig("assets")
modimport("scripts/mia_inventoryimages.lua")
modimport("scripts/mia_language.lua")
do
    local minimapatlas = "images/mia_minimap.xml"
    AddMinimapAtlas(minimapatlas)
    local characters = dig("characters")
    for name, data in pairs(characters) do
        AddModCharacter(name, data.gender, {
            {type = "ghost_skin", anim_bank = "ghost", idle_anim = "idle", scale = 0.75, offset = {0, 25}}
        })
        if data.skin then PREFAB_SKINS[name] = data.skin end
    end
    local tuning = dig("tuning")()
    for k, v in pairs(tuning) do TUNING[k] = TUNING[k] or v end
end
if not env.ismim and (TheNet:GetIsServer() or TheNet:GetIsClient()) then modimport("scripts/mia_main.lua") end
