local function oninactive(self, inactive)
    if inactive then
        self.inst:AddTag("inactive")
    else
        self.inst:RemoveTag("inactive")
    end
end

local function onstandingaction(self, standingaction)
    if standingaction then
        self.inst:AddTag("standingactivation")
    else
        self.inst:RemoveTag("standingactivation")
    end
end

local function onquickaction(self, quickaction)
    if quickaction then
        self.inst:AddTag("quickactivation")
    else
        self.inst:RemoveTag("quickactivation")
    end
end

local Activatable = Class(function(self, inst, activcb)
    self.inst = inst
    self.OnActivate = activcb
    self.inactive = true
    self.standingaction = false
    self.quickaction = false
end, nil, {inactive = oninactive, standingaction = onstandingaction, quickaction = onquickaction})

function Activatable:OnRemoveFromEntity()
    self.inst:RemoveTag("inactive")
    self.inst:RemoveTag("quickactivation")
    self.inst:RemoveTag("standingactivation")
end

function Activatable:CanActivate(doer)
    return self.CanActivateFn == nil or self.CanActivateFn(self.inst, doer)
end

function Activatable:DoActivate(doer)
    if self.OnActivate ~= nil then
        self.inactive = false
        local success, msg = self.OnActivate(self.inst, doer)
        if success then self.inst:PushEvent("onactivated", {doer = doer}) end
        return success, msg
    end
    return nil
end
function Activatable:SetOnActivate(fn)
    self.OnActivate = fn
end
function Activatable:SetOnDeactivate(fn)
    self.OnDeactivate = fn
end

function Activatable:GetDebugString()
    return tostring(self.inactive)
end

return Activatable
