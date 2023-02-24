local foods = {
    riko_onigiri = {
        test = function(cooker, names, tags)
            return not tags.meat and tags.veggie and not tags.inedible
        end,
        priority = 1,
        weight = 1,
        foodtype = FOODTYPE.VEGGIE,
        health = 12,
        hunger = 62.5,
        perishtime = TUNING.PERISH_MED,
        sanity = 5,
        cooktime = .5
    },
    riko_dashi = {
        test = function(cooker, names, tags)
            return tags.fish and tags.fish >= 1.5 and tags.meat and tags.meat >= 2 and names.cutlichen
        end,
        priority = 50,
        weight = 1,
        foodtype = FOODTYPE.MEAT,
        health = 60,
        hunger = 37.5,
        perishtime = TUNING.PERISH_MED,
        sanity = 33,
        cooktime = 2
    },
    riko_grill = {
        test = function(cooker, names, tags)
            return tags.meat and names.twigs and not tags.fish
        end,
        priority = 10,
        weight = 1,
        foodtype = FOODTYPE.MEAT,
        health = 3,
        hunger = 37.5,
        perishtime = TUNING.PERISH_MED,
        sanity = 5,
        cooktime = .25
    },
    riko_friedfish = {
        test = function(cooker, names, tags)
            return tags.fish and tags.fish >= 1.5 and (names.green_cap or names.red_cap or names.blue_cap)
                       and tags.sweetener
        end,
        priority = 50,
        weight = 1,
        foodtype = FOODTYPE.MEAT,
        health = 80,
        hunger = 50,
        perishtime = nil,
        sanity = 15,
        cooktime = 2
    },
    riko_snack = {
        test = function(cooker, names, tags)
            return tags.fruit and tags.egg and tags.egg > 1
        end,
        priority = 50,
        weight = 1,
        foodtype = FOODTYPE.VEGGIE,
        health = 10,
        hunger = 12.5,
        perishtime = TUNING.PERISH_MED,
        sanity = 50,
        cooktime = 2
    },
    nanachi_soup = {
        test = function(cooker, names, tags)
            return tags.egg and tags.veggie and tags.veggie >= 2 and tags.fish
        end,
        priority = 6,
        weight = 1,
        foodtype = FOODTYPE.VEGGIE,
        health = 40,
        hunger = 50,
        perishtime = TUNING.PERISH_MED,
        sanity = -20,
        cooktime = 2
    }

}
for k, v in pairs(foods) do
    v.name = k
    v.weight = v.weight or 1
    v.priority = v.priority or 0
end
return foods
