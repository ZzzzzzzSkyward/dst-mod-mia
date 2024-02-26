local function _onequip(inst, owner, build, symbol_override)
  if type(symbol_override) ~= "string" then
    symbol_override = inst.bodysymbol or "swap_body"
  end
  if type(build) ~= "string" then build = inst.build or "armor_wood" end
  local skin_build = inst:GetSkinBuild()
  if skin_build ~= nil then
    owner:PushEvent("equipskinneditem", inst:GetSkinName())
    owner.AnimState:OverrideItemSkinSymbol("swap_body", skin_build,
                                           symbol_override, inst.GUID, build)
  else
    owner.AnimState:OverrideSymbol("swap_body", build, symbol_override)
  end
  if inst.components.fueled ~= nil then inst.components.fueled:StartConsuming() end
  if inst._onblocked then
    inst:ListenForEvent("blocked", inst._onblocked, owner)
  end
  if inst.components.container ~= nil then
    inst.components.container:Open(owner)
  end
end

local function _onunequip(inst, owner, symbol_override)
  if type(symbol_override) ~= "string" then
    symbol_override = inst.bodysymbol or "swap_body"
  end
  local skin_build = inst:GetSkinBuild()
  if skin_build ~= nil then
    owner:PushEvent("unequipskinneditem", inst:GetSkinName())
  end
  owner.AnimState:ClearOverrideSymbol(symbol_override)
  if inst.components.fueled ~= nil then inst.components.fueled:StopConsuming() end
  if inst._onblocked then
    inst:RemoveEventCallback("blocked", inst._onblocked, owner)
  end
  if inst.components.container ~= nil then
    inst.components.container:Close(owner)
  end
end
local function _onequiptomodel(inst, owner)
  if inst.components.fueled then inst.components.fueled:StopConsuming() end
  if owner.components.hunger ~= nil then
    owner.components.hunger.burnratemodifiers:RemoveModifier(inst)
  end
  if inst.components.container then inst.components.container:Close(owner) end
  if inst._light and inst._light.Light then inst._light.Light:Enable(false) end
  if owner.components.maprevealable ~= nil then
    owner.components.maprevealable:RemoveRevealSource(inst)
  end
  if inst.components.container ~= nil then
    inst.components.container:Close(owner)
  end
end
return {
  _onequip = _onequip,
  _onunequip = _onunequip,
  _onequiptomodel = _onequiptomodel
}
