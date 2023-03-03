local AOEProjectile = Class(function(self, inst)
    self.inst = inst
    self.range = 1
    self.method = "Sim" -- Sim=TheSim:FindEntities, Ent=for k,v in pairs(Ents)
    self.canhitfn = nil
    self.musttags = {}
    self.canttags = {"FX", "INLIMBO", "DECOR", "NOCLICK", "noattack"}
    self.onhitfn = nil
    self.distance = 1
    self.interval = 1
    self.cannons = {}
    self.enabled = true
end, nil, {})
function AOEProjectile:InitAttack(cannon, vec)
    table.insert(self.cannons, {cannon = cannon, vec = vec, pos = cannon:GetPosition(), time = GetTime()})
end
function AOEProjectile:AutoUpdatePosition(data)
    local inst = data.cannon
    data.auto = true
    inst.Physics:SetMotorVel(data.vec:Get())
end
function AOEProjectile:SetCanHitFn(fn)
    self.canhitfn = fn
end
function AOEProjectile:SetOnHitFn(fn)
    self.onhitfn = fn
end
function AOEProjectile:ManualUpdatePosition(data)
    local t = GetTime()
    local dt = t - data.time
    local dp = data.vec * dt
    local nextpos = data.pos + dp
    data.pos = nextpos
    data.time = t
    data.cannon.Transform:SetPosition(nextpos:Get())
end
function AOEProjectile:SearchSingleTarget(data)
    local inst = data.cannon
    local range = data.range or self.range
    local x, y, z = inst.Transform:GetPosition()
    local ret = {}
    if self.method == "Sim" then
        local ents = TheSim:FindEntities(x, y, z, range, self.musttags, self.canttags)
        for k, v in pairs(ents) do if not self.canhitfn or self.canhitfn(v) then table.insert(ret, v) end end
    else
        -- method=Ent
        local ents = Ents
        for k, v in pairs(ents) do
            if v:GetDistanceSqToInst(inst) < range and not v:HasOneOfTags(self.canttags) and v:HasTags(self.musttags)
                and (not self.canhitfn or self.canhitfn(self.inst, v)) then table.insert(ret, v) end
        end
    end
    return ret
end
function AOEProjectile:SearchAllTargets()
    local cannons = self.cannons

end
function AOEProjectile:CleanCannons()
    for i = #self.cannons, 1, -1 do
        if self.cannons[i] then
            if self.cannons[i]:IsValid() then
            else
                table.remove(self.cannons, i)
            end
        else
        end
    end
end
function AOEProjectile:Render() -- single
    self:CleanCannons()
    local targets = {}
    for i, v in ipairs(self.cannons) do
        if v.auto then
        else
            self:ManualUpdatePosition(v)
        end
        local targs = self:SearchSingleTarget(v)
        if not targs then
        else
            for k, v in pairs(targs) do targets[v] = true end
        end
    end
    for target, _ in pairs(targets) do if self.onhitfn then self.onhitfn(self.inst, target) end end
end
function AOEProjectile:BatchRender()
    self:CleanCannons()
    local targets = self:SearchAllTargets()
    for target, _ in pairs(targets) do if self.onhitfn then self.onhitfn(self.inst, target) end end
end
function AOEProjectile:Run()
    self:CleanCannons()
    if #self.cannons == 0 then return end
    if self.task then return end
    self.task = self.inst:DoPeriodicTask(self.interval, function()
        self:Render()
    end)
end
function AOEProjectile:Stop()
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
end
-- export function
function AOEProjectile:Launch(data)
    if not self.enabled then return false, "DISABLED" end
    local target, pos = data.target, data.pos
    if type(target) == "table" then
        if target.entity and target.entity:IsValid() then return self:LaunchToTarget(target) end
    end
    if pos then if type(pos) == "table" and pos.x then return self:LaunchToPos(pos) end end
    return false
end
function AOEProjectile:LaunchToTarget(inst)
    return true
end
function AOEProjectile:LaunchToPos(pos)
    return false
end
return AOEProjectile
