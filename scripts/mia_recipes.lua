-- #TODO compatible recipe format with DS
if not AddRecipe2 then
    AddRecipe("riko_sack", {Ingredient("bearger_fur", 1), Ingredient("papyrus", 4), Ingredient("rope", 2)},
        RECIPETABS.SURVIVAL, TECH.NONE, nil, nil, nil, nil, "riko")
    AddRecipe("nanachitent", {Ingredient("goose_feather", 5), Ingredient("cutgrass", 12), Ingredient("petals", 5)},
        RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO, "nanachitent_placer", nil, nil, nil, "nanachi")
    return
end
AddRecipe2("riko_sack", {Ingredient("bearger_fur", 1), Ingredient("papyrus", 4), Ingredient("rope", 2)}, TECH.NONE,
    {builder_tag = "riko"}, {"MODS", "CLOTHING", "RIKO"})
DeconstructRecipe("riko_sack", {Ingredient("bearger_fur", 1), Ingredient("papyrus", 4), Ingredient("rope", 2)},
    TECH.NONE)
AddRecipe2("nanachitent", {Ingredient("goose_feather", 5), Ingredient("cutgrass", 12), Ingredient("petals", 5)},
    TECH.SCIENCE_TWO, {placer = "nanachitent_placer", builder_tag = "nanachi"}, {"MODS", "STRUCTURES", "NANACHI"})
DeconstructRecipe("nanachitent", {Ingredient("goose_feather", 5), Ingredient("cutgrass", 12), Ingredient("petals", 5)})
AddRecipe2("scaled_umbrella", {Ingredient("umbrella", 1), Ingredient("charcoal_sand", 60), Ingredient("rope", 8)},
    TECH.NONE, {builder_tag = "riko"}, {"MODS", "STRUCTURES", "RIKO"})
DeconstructRecipe("scaled_umbrella", {Ingredient("umbrella", 1), Ingredient("charcoal_sand", 30), Ingredient("rope", 8)})
-- Gives back a mitty later
-- Health value is set to character's max health*60% later
AddRecipe2("mitty_tea_bundle", {Ingredient("mitty_bottled", 1), Ingredient(CHARACTER_INGREDIENT.MAX_HEALTH, 0)}, TECH.NONE, {},
    {"MODS", "BELAF", "FOOD"})
