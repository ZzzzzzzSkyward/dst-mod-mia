-- fix the bug when mouse point water or void, the action picker will not show the actions
return function(PlayerActionPicker)
  local GetRightClickActions = PlayerActionPicker.GetRightClickActions
  function PlayerActionPicker:GetRightClickActions(position, target, spellbook)
    local ret = GetRightClickActions(self, position, target, spellbook)
    local a = self:GetPointSpecialActions(position, nil, true)
    if #a > 0 then
      if a[1].action and a[1].action.disable_platform_hopping then
        if ret[1] == nil or ret[1].action.priority < a[1].action.priority then return a end
      end
    end
    return ret
  end
  local GetLeftClickActions = PlayerActionPicker.GetLeftClickActions
  function PlayerActionPicker:GetLeftClickActions(position, target, spellbook)
    local ret = GetLeftClickActions(self, position, target, spellbook)
    local a = self:GetPointSpecialActions(position, nil, false)
    if #a > 0 then
      if a[1].action and a[1].action.disable_platform_hopping then
        if ret[1] == nil or ret[1].action.priority < a[1].action.priority then return a end
      end
    end
    return ret
  end
end
