local function CannotDismantle(self, inst, doer)
    local tag = self.restrictedtag
    if doer and tag and not doer:HasTag(tag) then return true end
    return false
end
return function(PortableStructure)
    local old = PortableStructure.OnDismantle
    function PortableStructure:OnDismantle(inst, doer, ...)
        if CannotDismantle(self, inst, doer, ...) then
            if doer and doer.components.talker and doer:HasTag("player") then
                doer.components.talker:Say(GetActionFailString(doer, "DISMANTLE"))
            end
        else
            return old(self, inst, doer, ...)
        end
    end
end
