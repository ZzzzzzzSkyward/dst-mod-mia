local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local easing = require "easing"
local Widget = require "widgets/widget"
local XZMinibadge = Class(Widget, function(self, name, owner)
    Widget._ctor(self, "XZMinibadge")
    self.owner = owner
    self.name = name
    self:SetScale(.9, .9, .9)
    self.bg = self:AddChild(Image("images/status_bgs.xml", "status_bgs.tex"))
    self.bg:SetScale(.7, .43, 1)
    self.bg:SetPosition(-.45, -40)
    self.num = self:AddChild(Text(NUMBERFONT, 28))
    self.num:SetHAlign(ANCHOR_MIDDLE)
    self.num:SetPosition(3.5, -40.5)
    self.num:SetScale(1, .78, 1)
end)
return XZMinibadge
