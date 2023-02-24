
local NanachiIndicator = Class(function(self, inst)
    self.inst = inst

    self.max_range = TUNING.MAX_INDICATOR_RANGE * 1.5
    self.offScreenBosses = {}
    self.onScreenBossesLastTick = {}

    inst:StartUpdatingComponent(self)
end)

function NanachiIndicator:OnRemoveFromEntity()
    if self.offScreenBosses ~= nil then
        for i, v in ipairs(self.offScreenBosses) do
            self.inst.HUD:RemoveNanachiIndicator(v)
        end
        self.offScreenBosses = nil
    end
end

NanachiIndicator.OnRemoveEntity = NanachiIndicator.OnRemoveFromEntity

function NanachiIndicator:ShouldShowIndicator(target)
    return not self:ShouldRemoveIndicator(target) and (table.contains(self.onScreenBossesLastTick, target))
end

function NanachiIndicator:ShouldRemoveIndicator(target)
    return 	not target:IsValid() or
			target:HasTag("nobossindicator") or
            target:HasTag("hiding") or
            not target:IsNear(self.inst, self.max_range) or
            target.entity:FrustumCheck() 
end

function NanachiIndicator:OnUpdate()
	if not self.inst or not self.inst.HUD then return end

    local checked = {}

    for i, v in ipairs(self.offScreenBosses) do
        checked[v] = true

        while self:ShouldRemoveIndicator(v) do
            self.inst.HUD:RemoveNanachiIndicator(v)
            table.remove(self.offScreenBosses, i)
            v = self.offScreenBosses[i]
            if v == nil then
                break
            end
            checked[v] = true
        end
    end

    for i, v in ipairs(MOD_NANACHIINDICATORS.BOSSES) do
        if not (checked[v] or v == self.inst) and self:ShouldShowIndicator(v) then
            self.inst.HUD:AddNanachiIndicator(v)
            table.insert(self.offScreenBosses, v)
        end
    end

    self.onScreenBossesLastTick = {}
    for i, v in ipairs(MOD_NANACHIINDICATORS.BOSSES) do
        if v ~= self.inst then
            table.insert(self.onScreenBossesLastTick, v)
        end
    end
end

return NanachiIndicator