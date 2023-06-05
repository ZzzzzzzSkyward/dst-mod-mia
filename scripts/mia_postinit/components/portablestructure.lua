local function CannotDismantle(self, inst, doer)
  local tag = self.restrictedtag
  if doer and tag and not doer:HasTag(tag) then return true end
  return false
end
return function(PortableStructure)
  local old = PortableStructure.Dismantle
  function PortableStructure:Dismantle(doer, ...)
    if CannotDismantle(self, self.inst, doer, ...) then
      if doer and doer.components.talker and doer:HasTag("player") then
        doer.components.talker:Say(GetActionFailString(doer, "DISMANTLE"))
      end
    else
      return old(self, doer, ...)
    end
  end
end
