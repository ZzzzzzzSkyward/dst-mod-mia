local invimages = {
    "abyssweapon",
    "mitty",
    "nanachi_soup",
    "nanachihat",
    "nanachitent",
    "regcloak",
    "reghat",
    "riko_dashi",
    "riko_friedfish",
    "riko_grill",
    "riko_onigiri",
    "riko_sack",
    "riko_snack",
    "rikocookpot_item",
    "rikohat"
}
local atlas = resolvefilepath("images/mia_inventoryimages.xml")
for i, v in ipairs(invimages) do RegisterInventoryItemAtlas(atlas, v .. ".tex") end
