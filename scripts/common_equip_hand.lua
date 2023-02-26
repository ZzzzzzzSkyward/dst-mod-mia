local function hand_onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", inst.build, inst.handsymbol)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end
local function hand_onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then owner:PushEvent("unequipskinneditem", inst:GetSkinName()) end
end
return {_onequip = hand_onequip, _onunequip = hand_onunequip}
