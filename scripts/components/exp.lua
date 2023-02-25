local function onmax(self, max)
    self.inst.exp_max:set(max)
end
local function oncurrent(self, current)
    self.inst.exp_current:set(current)
end
local function onlevel(self, level)
    self.inst.exp_level:set(level)
end
local exp = Class(function(self, inst)
    self.inst = inst
    self.maxtimepiont = 20
    self.currenttimepiont = 0
    self.levelpoint = 0
    self.updatefn = nil
    self.maxlevel = nil
end, nil, {maxtimepiont = onmax, currenttimepiont = oncurrent, levelpoint = onlevel})
function exp:DoDelta(delta)
    local val = self.currenttimepiont + delta
    if self.levelpoint == self.maxlevel then
        self.currenttimepiont = self.maxtimepiont
        return
    end
    while val >= self.maxtimepiont do
        val = val - self.maxtimepiont
        if self.levelpoint < self.maxlevel then
            self:LevelUp()
        else
            self.currenttimepiont = self.maxtimepiont
            return
        end
    end
    self.currenttimepiont = val
end
function exp:GetPercent()
    return self.currenttimepiont / self.maxtimepiont
end
function exp:ApplyUpgrades()
    local hunger_percent = self.inst.components.hunger:GetPercent()
    local health_percent = self.inst.components.health:GetPercent()
    local sanity_percent = self.inst.components.sanity:GetPercent()
    if self.updatefn ~= nil then self.updatefn(self.inst) end
    self.inst.components.hunger:SetPercent(hunger_percent)
    self.inst.components.health:SetPercent(health_percent)
    self.inst.components.sanity:SetPercent(sanity_percent)
end
function exp:SetUpdateFn(fn)
    self.updatefn = fn
end
function exp:LevelUp()
    self.levelpoint = self.levelpoint + 1
    self.currenttimepiont = 0
    self:ApplyUpgrades()
end
function exp:OnSave()
    return {currenttimepiont = self.currenttimepiont, maxtimepiont = self.maxtimepiont, levelpoint = self.levelpoint}
end
function exp:OnLoad(data)
    self.currenttimepiont = data.currenttimepiont
    self.maxtimepiont = data.maxtimepiont
    self.levelpoint = data.levelpoint
end
return exp
