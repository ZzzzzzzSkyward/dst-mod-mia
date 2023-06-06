local cooking = require("cooking")
local function hacktag()
  local cookerrecipes = cooking.recipes
  local CalculateRecipe = cooking.CalculateRecipe
  -- remove and add to skip recipes that the chef cannot cook
  -- as recipedef.cheftag
  function cooking.CalculateRecipe(cooker, names, chef)
    chef = chef or cooking.chef
    local rec = cookerrecipes[names]
    if not rec then return CalculateRecipe(cooker, names, chef) end
    local oldvals = {}
    for k, v in pairs(rec) do
      if v.cheftag and chef and not chef:HasTag(v.cheftag) then
        oldvals[k] = v
        rec[k] = nil
      end
    end
    if chef and chef.ChangeRecipe then chef:ChangeRecipe(rec, cooker, names) end
    local ret = {CalculateRecipe(cooker, names, chef)}
    for k, v in pairs(oldvals) do rec[k] = v end
    if chef and chef.ChangeRecipe then chef:ChangeRecipe(rec, cooker, names, true) end
    return unpack(ret)
  end

  local warlys = cookerrecipes.portablecookpot
  if warlys then for k, v in pairs(warlys) do v.cheftag = "masterchef" end end
end
AddGamePostInit(hacktag)
return function(Stewer)
  local StartCooking = Stewer.StartCooking
  function Stewer:StartCooking(doer)
    cooking.chef = doer
    local ret = StartCooking(self, doer)
    if cooking.chef == doer then cooking.chef = nil end
    return ret
  end
end
