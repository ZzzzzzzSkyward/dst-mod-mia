local function _onequip(inst, owner, build, symbol_override, headbase_hat_override, opentop)
    if type(symbol_override) ~= "string" then symbol_override = "swap_hat" end
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_hat", skin_build, symbol_override, inst.GUID, fname)
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
    owner.AnimState:Show("HAT")
    if not opentop then
        owner.AnimState:Show("HAIR_HAT")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")
    else
        owner.AnimState:Hide("HAIR_HAT")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")
    end

    if owner:HasTag("player") then
        owner.AnimState:Hide("HEAD")
        owner.AnimState:Show("HEAD_HAT")
    end

    if inst.components.fueled ~= nil then inst.components.fueled:StartConsuming() end

    if inst.skin_equip_sound and owner.SoundEmitter then owner.SoundEmitter:PlaySound(inst.skin_equip_sound) end
end

local function _onunequip(inst, owner)
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
    end

    if inst.components.fueled ~= nil then inst.components.fueled:StopConsuming() end
end
return {_onequip = _onequip, _onunequip = _onunequip}
