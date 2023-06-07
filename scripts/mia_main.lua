RELICSLOTS = RELICSLOTS or {
  SKIN = "SKIN",
  EYE = "EYE",
  ARM = "ARM",
  BODY = "BODY"
}
GLOBAL.RELICSLOTS = RELICSLOTS
local function import(path) return modimport("scripts/" .. path .. ".lua") end
local dishes = dig("foods")
for k, recipe in pairs(dishes) do
  if recipe.spice then
    AddCookerRecipe("portablespicer", recipe)
  elseif k:find("riko_") then
    AddCookerRecipe("rikocookpot", recipe)
  else
    AddCookerRecipe("rikocookpot", recipe)
    AddCookerRecipe("cookpot", recipe)
    AddCookerRecipe("portablecookpot", recipe)
    AddCookerRecipe("archivecookpot", recipe)
  end
end
local imports = {"mia_recipes", "hamlet_dodge", "mia_actions", "mia_shader", "mia_compatibility"}
for k, v in pairs(imports) do import(v) end
local preinit = {
  components = {"portablestructure", "playeractionpicker", "stewer"},
  scenarios = {"chestfunctions"}
}
local postinit = {
  Prefab = {}
}
for k, v in pairs(preinit) do for k2, v2 in pairs(v) do dig("postinit/" .. k .. "/" .. v2)(require(k .. "/" .. v2)) end end
for k, v in pairs(postinit) do
  local key = k .. "PostInit"
  if not env.postinitfns[key] then env.postinitfns[key] = {} end
  for k2, v2 in pairs(v) do
    if not env.postinitfns[key][v2] then env.postinitfns[key][v2] = {} end
    table.insert(env.postinitfns[k .. "PostInit"][v2], dig("postinit/" .. k:lower() .. "/" .. v2))
  end
end
local containers = require("containers")
containers.params.riko_sack = containers.params.krampus_sack or {
  widget = {
    slotpos = {},
    animbank = "ui_krampusbag_2x8",
    animbuild = "ui_krampusbag_2x8",
    pos = Vector3(-5, -120, 0)
  },
  issidewidget = true,
  type = "pack",
  openlimit = 1
}
containers.params.rikocookpot = containers.params.portablecookpot
-- prushkahat
local h = deepcopy(containers.params.antlionhat)
h.widget.animbuild = "ui_prushkahat_1x1"
h.excludefromcrafting = nil
h.itemtestfn = function(container, item, slot) return item:HasTag("smallcreature") end
containers.params.prushkahat = h

-- blaze reap
FUELTYPE.POWER = "power"
local powerlevel = {
  gunpowder = 10,
  slurtleslime = 2
}
for k, v in pairs(powerlevel) do
  AddPrefabPostInit(k, function(inst)
    inst:AddTag("power_fuel")
    if not TheWorld.ismastersim then return inst end
    if not inst.components.fuel then inst:AddComponent("fuel") end
    inst.components.fuel.fueltype = FUELTYPE.POWER
    inst.components.fuel.fuelvalue = v
  end)
end
