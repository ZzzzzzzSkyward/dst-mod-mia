local artifacts = dig("artifacts")
local foods = dig("foods")
local atlas = resolvefilepath("images/mia_inventoryimages.xml")
local invimages = {
    "mitty_bottled",
    "nanachitent",
    "riko_sack",
    "regcloak",
    "nanachihat",
    "reghat",
    "rikohat",
    "rikocookpot_item",
    "scaled_umbrella_open",
    "charcoal_sand"
}
for k, v in pairs(artifacts) do table.insert(invimages, k) end
for k, v in pairs(foods) do table.insert(invimages, k) end
for i, v in ipairs(invimages) do
    RegisterInventoryItemAtlas(atlas, v .. ".tex")
    RegisterInventoryItemAtlas(atlas, hash(v .. ".tex"))
end
