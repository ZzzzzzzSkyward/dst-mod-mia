local empty = {}
local function HasEquip(inst)
  if inst.replica.inventory then
    return inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil or inst.replica.inventory:GetActiveItem() ~=
            nil
  end
  return true
end
return {
  -- hamlet dodge
  DODGE = {
    str = "Dodge",
    fn = function(act, data)
      act.doer:PushEvent("redirect_locomote", {
        pos = act.pos or Vector3(act.target.Transform:GetWorldPosition())
      })
      return true
    end,
    distance = math.huge,
    instant = true
  },
  -- #FIXME once relicinventory is established, change these things to usepointwiserelicitem
  LAUNCHAOEPROJECTILE = {
    str = "LAUNCHAOEPROJECTILE",
    instant = true,
    canforce = true,
    priority = 100,
    disable_platform_hopping=true,
    distance = 40,
    pre_action_cb = function(act)
      local doer = act.doer
      local obj = doer.inscinerator
      obj:Launch(doer, act.pos, act.target)
      return true
    end,
    fn = function(act)
      local doer = act.doer
      local obj = doer.inscinerator
      obj:Launch(doer, act.pos, act.target)
      return true
    end
  },
  AOEPROJECTILE = {
    str = "AOEPROJECTILE",
    instant = true,
    rmb = true,
    canforce = true,
    priority = -3,
    paused_valid = true,
    distance = 40,
    disable_platform_hopping = true,
    pre_action_cb = function(act)
      local doer = act.doer
      local obj = doer.inscinerator
      obj:StartTargeting(doer)
      return true
    end,
    fn = function(act)
      local doer = act.doer
      local obj = doer.inscinerator
      obj:StartTargeting(doer)
      return true
    end,
    _actionhandler = function(inst) return "aoeprojectile" end
  },
  CANCELAOEPROJECTILE = {
    str = "CANCELAOEPROJECTILE",
    instant = true,
    paused_valid = true,
    canforce = true,
    rmb = true,
    encumbered_valid = true,
    mount_valid = true,
    disable_platform_hopping = true,
    priority = 100,
    distance = 40,
    pre_action_cb = function(act)
      local doer = act.doer
      local obj = doer.inscinerator
      obj:StopTargeting(doer)
      return true
    end,
    fn = function(act)
      local doer = act.doer
      local obj = doer.inscinerator
      obj:StopTargeting(doer)
      return true
    end
  }
}, {
  _reg = {
    type = "POINTSPECIAL",
    str = "发射",
    fn = function(inst, pos, useitem, right)
      if not inst.inscinerator then return empty end
      local active = inst.inscinerator.components.reticule ~= nil
      if inst.inscinerator:HasTag("launching") then return empty end
      if active and right then return {ACTIONS.CANCELAOEPROJECTILE} end
      if inst.inscinerator:HasTag("inscinerator_depleted") then return empty end
      if useitem then return empty end
      if inst:HasTag("playerghost") then return empty end
      -- #TODO filter out other circumstances
      local hasequip = HasEquip(inst)
      if hasequip then return empty end
      if not active and right then return {ACTIONS.AOEPROJECTILE} end
      if active and not right then return {ACTIONS.LAUNCHAOEPROJECTILE} end
      return empty
    end
  }
}
