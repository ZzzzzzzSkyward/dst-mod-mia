local function _onequip(inst, owner, build, symbol_override)
  if type(symbol_override) ~= "string" then
    symbol_override = inst.handsymbol or "swap_object"
  end
  if type(build) ~= "string" then build = inst.build or "swap_axe" end
  local skin_build = inst:GetSkinBuild()
  if skin_build ~= nil then
    owner:PushEvent("equipskinneditem", inst:GetSkinName())
    owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build,
                                           symbol_override, inst.GUID, build)
  else
    owner.AnimState:OverrideSymbol("swap_object", build, symbol_override)
  end
  if inst.components.fueled ~= nil then inst.components.fueled:StartConsuming() end
  owner.AnimState:Show("ARM_carry")
  owner.AnimState:Hide("ARM_normal")
end
local function _onunequip(inst, owner, symbol_override)
  if type(symbol_override) ~= "string" then
    symbol_override = inst.handsymbol or "swap_object"
  end
  local skin_build = inst:GetSkinBuild()
  if skin_build ~= nil then
    owner:PushEvent("unequipskinneditem", inst:GetSkinName())
  end
  owner.AnimState:ClearOverrideSymbol(symbol_override)
  if inst.components.fueled ~= nil then inst.components.fueled:StopConsuming() end
  owner.AnimState:Hide("ARM_carry")
  owner.AnimState:Show("ARM_normal")
end
return {_onequip = _onequip, _onunequip = _onunequip}
