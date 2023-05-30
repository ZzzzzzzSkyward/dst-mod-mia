GLOBAL.setmetatable(env, {
  __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end
})
function GLOBAL.p(...) return print("[log]", ...) end
function dig(x, _env)
  local file = resolvefilepath_soft(table.concat({"scripts/mia_", x, ".lua"}))
  if not file then
    print("error: no such file", x)
    return nil
  end
  local fn = kleiloadlua(file)
  if type(fn) == "function" then
    setfenv(fn, _env or env)
    return fn()
  else
    print("error: invalid file", x)
    return nil
  end
  return nil
end
PrefabFiles = dig("prefablist")
Assets = dig("assets")
modimport("scripts/mia_inventoryimages.lua")
modimport("scripts/mia_language.lua")
modimport("scripts/common_utils.lua")
do
  local minimapatlas = "images/mia_minimap.xml"
  AddMinimapAtlas(minimapatlas)
  local characters = dig("characters")
  for name, data in pairs(characters) do
    AddModCharacter(name, data.gender, {{
      type = "ghost_skin",
      anim_bank = "ghost",
      idle_anim = "idle",
      scale = 0.75,
      offset = {0, 25}
    }})
    if data.skin then PREFAB_SKINS[name] = data.skin end
    if data.start_inv then TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT[name:upper()] = data.start_inv end
  end
  local TuningHack = {}
  setmetatable(TuningHack, {
    __index = function(_, k)
      if k == nil then return nil end
      if type(k) == "string" and TUNING[string.upper(k)] then
        TuningHack[k] = TUNING[string.upper(k)]
        return TuningHack[k]
      else
        return env[k]
      end
    end
  })
  local tuning = dig("tuning", TuningHack)
  for k, v in pairs(tuning) do TUNING[k] = TUNING[k] or v end
end
if not env.ismim and (TheNet:GetIsServer() or TheNet:GetIsClient()) then modimport("scripts/mia_main.lua") end
