local assets = {Asset("ANIM", "anim/%s.zip"), Asset("ANIM", "anim/ghost_%s_build.zip")}

local skins = {normal_skin = "%s", ghost_skin = "ghost_%s_build"}
-- #TODO this is simplified because there is actually no skins
local params = {
    base_prefab = "%s",
    type = "base",
    assets = assets,
    skins = skins,
    skin_tags = {"%s", "CHARACTER", "BASE"},
    build_name = "%s",
    rarity = "Character",
    build_name_override="%s"
}
local prefs = {}
local chars = require("mia_characters")
local name_pattern = "%s_none"
local function fmt(tb, name)
    local t = shallowcopy(tb)
    for i, v in pairs(t) do t[i] = type(v) == "string" and v:format(name) or (type(v)=="table" and fmt(v,name) or v) end
    return t
end
for name, v in pairs(chars) do
    local this_param = fmt(params, name)
    table.insert(prefs, CreatePrefabSkin(name_pattern:format(name), this_param))
end
return unpack(prefs)
