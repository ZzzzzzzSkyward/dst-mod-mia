local function onslot()
end
local function onrestrictedtag()
end
local RelicEquip = Class(function(self, inst)
    self.inst = inst
    self.equipslot = nil
    self.restrictedtag = nil
    self.un_unequippable = false
    self.isequipped = false
    self.onequip = nil
    self.onunequip = nil
    self.damageadd = nil
    self.damagemult = nil
    self.healthadd = nil
    self.healthmult = nil
    self.sanityadd = nil
    self.sanitymult = nil
end, nil, {slot = onslot, restrictedtag = onrestrictedtag})
function RelicEquip:Equip(owner)
    self.isequipped = true

    if self.inst.components.burnable ~= nil then self.inst.components.burnable:StopSmoldering() end

    if self.onequipfn ~= nil then self.onequipfn(self.inst, owner) end
    self.inst:PushEvent("relicequipped", {owner = owner})
end
function RelicEquip:Unequip(owner)
    if self.un_unequippable then return end
    self.isequipped = false

    if self.onunequipfn ~= nil then self.onunequipfn(self.inst, owner) end

    self.inst:PushEvent("relicunequipped", {owner = owner})
end
function RelicEquip:IsRestricted(target)
    return self.restrictedtag ~= nil and self.restrictedtag:len() > 0 and not target:HasTag(self.restrictedtag)
end
function RelicEquip:CanUnequip()
    return self.un_unequippable
end
return RelicEquip
