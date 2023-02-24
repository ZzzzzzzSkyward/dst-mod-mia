local UIAnim = require "widgets/uianim"
local Badge = require "widgets/badge"
local Text = require "widgets/text"
local XZMinibadge = require "widgets/xzminibadge"
local xz_exp = Class(Badge, function(self, owner)
    Badge._ctor(self, "xz_exp")
    self.owner = owner
    self:SetPosition(0, 0, 0)
    self:SetScale(1, 1, 1)
    self.anim = self.underNumber:AddChild(UIAnim())
    self.anim:GetAnimState():SetBank("health")
    self.anim:GetAnimState():SetBuild("xz_exp")
    self.anim:GetAnimState():PlayAnimation("anim")
    self.anim:GetAnimState():SetPercent("anim", 1 - self.percent)
    self.anim:SetClickable(true)
    self.level = self:AddChild(XZMinibadge("level", self.owner))
    self.level:SetPosition(0, -10, 0)
    local function OnLevelDirty(owner)
        self.level.num:SetString("level:" .. owner.exp_level:value())
    end
    self.owner:ListenForEvent("exp_leveldirty", OnLevelDirty)
    OnLevelDirty(self.owner)
    local function OnMaxDirty(owner)
        self:SetPercent(owner.exp_current:value() / owner.exp_max:value(), owner.exp_max:value())
    end
    self.owner:ListenForEvent("exp_maxdirty", OnMaxDirty)
    OnMaxDirty(self.owner)
    self.owner:ListenForEvent("exp_currentdirty", OnMaxDirty)
end)
function xz_exp:SetPercent(val, max, penaltypercent)
    Badge.SetPercent(self, val, max)
    self.anim:GetAnimState():SetPercent("anim", 1 - val)
end
return xz_exp
