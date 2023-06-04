-- fix the bug when mouse point water or void, the action picker will not show the actions
return function(PlayerActionPicker)
  local GetRightClickActions = PlayerActionPicker.GetRightClickActions
  function PlayerActionPicker:GetRightClickActions(position, target, spellbook)
    local ret = GetRightClickActions(self, position, target, spellbook)
    if not next(ret) then
      ret = self:GetPointSpecialActions(position, nil, true)
      if #ret > 0 and ret[1].disable_platform_hopping then return ret end
    end
    return {}
  end
  local GetLeftClickActions = PlayerActionPicker.GetLeftClickActions
  function PlayerActionPicker:GetLeftClickActions(position, target, spellbook)
    local ret = GetLeftClickActions(self, position, target, spellbook)
    if not next(ret) then
      ret = self:GetPointSpecialActions(position, nil, false)
      if #ret > 0 and ret[1].disable_platform_hopping then return ret end
    end
    return {}
  end
end
