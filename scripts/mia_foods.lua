local foods = {
  -- riko
  riko_onigiri = {
    test = function(cooker, names, tags) return not tags.meat and tags.veggie and not tags.inedible end,
    priority = 1,
    weight = 1,
    foodtype = FOODTYPE.VEGGIE,
    health = 12,
    hunger = 62.5,
    perishtime = 15,
    sanity = 5,
    cooktime = .5,
    str = "莉可爆弹"
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
    perishtime = 6,
    sanity = 33,
    cooktime = 2,
    str = "莉可汤"
  },
  riko_grill = {
    test = function(cooker, names, tags) return tags.meat and names.twigs and not tags.fish end,
    priority = 10,
    weight = 1,
    foodtype = FOODTYPE.MEAT,
    health = 3,
    hunger = 37.5,
    perishtime = 9,
    sanity = 5,
    cooktime = .25,
    str = "莉可石板烧"
  },
  riko_friedfish = {
    test = function(cooker, names, tags)
      return tags.fish and tags.fish >= 1.5 and (names.green_cap or names.red_cap or names.blue_cap) and tags.sweetener
    end,
    priority = 50,
    weight = 1,
    foodtype = FOODTYPE.MEAT,
    health = 80,
    hunger = 50,
    perishtime = 7,
    sanity = 15,
    cooktime = 2,
    str = "煎炸岩辉鳟" -- ???
  },
  riko_snack = {
    test = function(cooker, names, tags) return tags.fruit and tags.egg and tags.egg > 1 end,
    priority = 50,
    weight = 1,
    foodtype = FOODTYPE.VEGGIE,
    health = 10,
    hunger = 12.5,
    perishtime = 8,
    sanity = 50,
    cooktime = 2,
    str = "莉可小碟"
  },
  riko_sashimi = {
    disabled = true,
    str = "莉可刺身"
  },
  riko_half_hatched_egg = {
    disabled = true,
    str = "莉可半孵化蜥蛋烧"
  },
  riko_meat_pot = {
    disabled = true,
    str = "莉可肉锅"
  },
  -- nanachi
  nanachi_soup = {
    test = function(cooker, names, tags) return tags.egg and tags.veggie and tags.veggie >= 2 and tags.fish end,
    tag = {"nanachisoup"},
    priority = 6,
    weight = 1,
    foodtype = FOODTYPE.VEGGIE,
    health = 40,
    hunger = 50,
    perishtime = 10,
    sanity = -20,
    cooktime = 2,
    fireproof = true,
    oneatenfn = function(food, eater)
      if eater and eater:IsValid() and eater.components.domesticatable then
        eater.components.domesticatable:DeltaDomestication(0.05)
      end
    end,
    str = "奈落炖锅"
  },
  -- mitty_egg_rice={}
  -- belaf
  mitty_tea = {
    disabled = true,
    str = "米蒂奶茶"
  }
}
for k, v in pairs(foods) do
  if v.disabled then foods[k] = nil end
  if v.spice then foods[k] = nil end
  v.name = k
  v.weight = v.weight or 1
  v.overridebuild = "mia_cook_pot_food"
  v.cookbook_atlas = "images/mia_cookbook.xml"
  v.priority = v.priority or 0
  v.perishtime = v.perishtime and (v.perishtime * TUNING.PERISH_ONE_DAY)
end
-- spiced foods
-- official function goes to spicedfoods
GenerateSpicedFoods(foods)

local spices = require("spicedfoods")
for k, data in pairs(spices) do
  for name, _ in pairs(foods) do
    if data.basename == name then
      foods[k] = data
      spices[k] = nil
    end
  end
end

return foods
