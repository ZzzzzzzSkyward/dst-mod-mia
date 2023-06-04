RELICSLOTS = RELICSLOTS or {
  SKIN = "SKIN",
  EYE = "EYE",
  ARM = "ARM",
  BODY = "BODY"
}
GLOBAL.RELICSLOTS = RELICSLOTS
local function import(path) return modimport("scripts/" .. path .. ".lua") end
local delicious_abyss_dishes = dig("foods")
for k, recipe in pairs(delicious_abyss_dishes) do AddCookerRecipe("rikocookpot", recipe) end
import("mia_recipes")
import("hamlet_dodge")
import("mia_actions")
local preinit = {
  components = {"portablestructure", "playeractionpicker"},
  scenarios = {"chestfunctions"}
}
local postinit = {
  Prefab = {"riko"}
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

do return end
AddModShadersInit(function()
  -- 变量: x,y
  UniformVariables.INSCINERATOR_CENTER = PostProcessor:AddUniformVariable("INSCINERATOR_CENTER", 2)
  local path = resolvefilepath("shaders/glow.ksh")
  PostProcessorEffects.INSCINERATOR_CENTER = PostProcessor:AddPostProcessEffect(path)
  PostProcessor:SetEffectUniformVariables(PostProcessorEffects.INSCINERATOR_CENTER, UniformVariables.INSCINERATOR_CENTER)
end)
AddModShadersSortAndEnable(function()
  PostProcessor:SetPostProcessEffectAfter(PostProcessorEffects.INSCINERATOR_CENTER,
   PostProcessorEffects.INSCINERATOR_CENTER)
  PostProcessor:EnablePostProcessEffect(PostProcessorEffects.INSCINERATOR_CENTER, false)
  PostProcessor:SetUniformVariable(UniformVariables.INSCINERATOR_CENTER, 0, 0)
end)
AddPlayerPostInit(function(inst)
  inst:DoPeriodicTask(1, function()
    local x, y, z = TheInput:GetScreenPosition():Get()
    PostProcessor:SetUniformVariable(UniformVariables.INSCINERATOR_CENTER, x, y)
  end)
end)
