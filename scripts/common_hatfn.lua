local function _onequip(inst, owner, build, symbol_override, headbase_hat_override, opentop, helm)
  if type(symbol_override) ~= "string" then symbol_override = "swap_hat" end
  local skin_build = inst:GetSkinBuild()
  if skin_build ~= nil then
    owner:PushEvent("equipskinneditem", inst:GetSkinName())
    owner.AnimState:OverrideItemSkinSymbol("swap_hat", skin_build, symbol_override, inst.GUID)
  else
    owner.AnimState:OverrideSymbol("swap_hat", build, symbol_override)
  end

  owner.AnimState:ClearOverrideSymbol("headbase_hat") -- clear out previous overrides
  if headbase_hat_override ~= nil then
    local skin_build = owner.AnimState:GetSkinBuild()
    if skin_build ~= "" then
      owner.AnimState:OverrideSkinSymbol("headbase_hat", skin_build, headbase_hat_override)
    else
      local build = owner.AnimState:GetBuild()
      owner.AnimState:OverrideSymbol("headbase_hat", build, headbase_hat_override)
    end
  end
  if not opentop and not helm then
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAIR_HAT")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")
  elseif not helm then
    owner.AnimState:Show("HAT")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")
  else
    owner.AnimState:Show("HAT")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")
  end

  if owner:HasTag("player") then
    if not helm and not opentop then
      owner.AnimState:Hide("HEAD")
      owner.AnimState:Show("HEAD_HAT")
      owner.AnimState:Show("HEAD_HAT_NOHELM")
      owner.AnimState:Hide("HEAD_HAT_HELM")
    elseif not helm then
      owner.AnimState:Show("HEAD")
      owner.AnimState:Hide("HEAD_HAT")
      owner.AnimState:Hide("HEAD_HAT_NOHELM")
      owner.AnimState:Hide("HEAD_HAT_HELM")
    else
      owner.AnimState:Hide("HAT")
      owner.AnimState:Hide("HEAD")
      owner.AnimState:Show("HEAD_HAT")
      owner.AnimState:Hide("HEAD_HAT_NOHELM")
      owner.AnimState:Show("HEAD_HAT_HELM")

      owner.AnimState:HideSymbol("face")
      owner.AnimState:HideSymbol("swap_face")
      owner.AnimState:HideSymbol("beard")
      owner.AnimState:HideSymbol("cheeks")

    end
  end
  if helm then owner.AnimState:UseHeadHatExchange(true) end

  if inst.components.fueled ~= nil then inst.components.fueled:StartConsuming() end

  if inst.skin_equip_sound and owner.SoundEmitter then owner.SoundEmitter:PlaySound(inst.skin_equip_sound) end
end

local function _onunequip(inst, owner, opentop, helm)
  local skin_build = inst:GetSkinBuild()
  if skin_build ~= nil then owner:PushEvent("unequipskinneditem", inst:GetSkinName()) end

  owner.AnimState:ClearOverrideSymbol("headbase_hat") -- it might have been overriden by _onequip
  if owner.components.skinner ~= nil then owner.components.skinner.base_change_cb = owner.old_base_change_cb end

  owner.AnimState:ClearOverrideSymbol("swap_hat")
  owner.AnimState:Hide("HAT")
  owner.AnimState:Hide("HAIR_HAT")
  owner.AnimState:Show("HAIR_NOHAT")
  owner.AnimState:Show("HAIR")

  if owner:HasTag("player") then
    owner.AnimState:Show("HEAD")
    owner.AnimState:Hide("HEAD_HAT")
    owner.AnimState:Hide("HEAD_HAT_NOHELM")
    owner.AnimState:Hide("HEAD_HAT_HELM")
    if helm then
      owner.AnimState:ShowSymbol("face")
      owner.AnimState:ShowSymbol("swap_face")
      owner.AnimState:ShowSymbol("beard")
      owner.AnimState:ShowSymbol("cheeks")
      owner.AnimState:UseHeadHatExchange(false)
    end
  end

  if inst.components.fueled ~= nil then inst.components.fueled:StopConsuming() end
end
local function _onequiptomodel(inst, owner)
  if inst.components.fueled then inst.components.fueled:StopConsuming() end
  if owner.components.hunger ~= nil then owner.components.hunger.burnratemodifiers:RemoveModifier(inst) end
  if inst.components.container then inst.components.container:Close(owner) end
  if inst._light and inst._light.Light then inst._light.Light:Enable(false) end
  if owner.components.maprevealable ~= nil then owner.components.maprevealable:RemoveRevealSource(inst) end
end
return {_onequip = _onequip, _onunequip = _onunequip, _onequiptomodel = _onequiptomodel}
