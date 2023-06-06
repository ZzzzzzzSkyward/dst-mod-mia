local assets = {Asset("ATLAS_BUILD", "images/mia_inventoryimages.xml", 256), Asset("SHADER", resolvefilepath"shaders/glow.ksh"),
                Asset("DYNAMIC_ATLAS", "images/mia_cookbook.xml"), Asset("PKGREF", "images/mia_cookbook.tex"),Asset("ANIM","anim/fx_mia_star.zip")}
local mia_assets = {"images/mia_inventoryimages", "images/mia_minimap"}
for i, v in ipairs(mia_assets) do
  table.insert(assets, Asset("IMAGE", v .. ".tex"))
  table.insert(assets, Asset("ATLAS", v .. ".xml"))
end
local chars = require("mia_characters")
local mia_paths = {"images/saveslot_portraits/%s", "images/selectscreen_portraits/%s",
                   "images/selectscreen_portraits/%s_silho", "bigportraits/%s_none", "bigportraits/%s",
                   "images/names_%s", "images/names_gold_%s", "images/avatars/avatar_%s",
                   "images/avatars/avatar_ghost_%s", "images/avatars/self_inspect_%s"}
for name, v in pairs(chars) do
  for i, path_pattern in ipairs(mia_paths) do
    local path = path_pattern:format(name)
    table.insert(assets, Asset("ATLAS", path .. ".xml", ...))
    table.insert(assets, Asset("IMAGE", path .. ".tex", ...))
  end
end
return assets
