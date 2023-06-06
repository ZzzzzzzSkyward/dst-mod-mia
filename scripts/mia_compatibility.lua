-- Craft Pot
function craftpot()
  if AddCookingPot then
    AddCookingPot("rikocookpot")
    return true
  end
end
if not craftpot() then AddSimPostInit(craftpot) end
