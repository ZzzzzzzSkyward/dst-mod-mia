local artifacts = dig("artifacts")
local foods = dig("foods")
local atlas = "images/mia_inventoryimages.xml"
local function ProcessAtlas(atlas, ...)
  local path = resolvefilepath_soft(atlas)
  if not path then
    print("[API]: The atlas \"" .. atlas .. "\" cannot be found.")
    return
  end
  local success, file = pcall(io.open, path)
  if not success or not file then
    print("[API]: The atlas \"" .. atlas .. "\" cannot be opened.")
    return
  end
  local xml = file:read("*all")
  file:close()
  local images = xml:gmatch("<Element name=\"(.-)\"")
  for tex in images do
    RegisterInventoryItemAtlas(path, tex)
    RegisterInventoryItemAtlas(path, hash(tex))
  end
end
ProcessAtlas(atlas)
