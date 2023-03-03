WallPaper = {
    images = {},
    anims = {},
    add = function(id)
        table.insert(Assets, Asset("ATLAS", "images/" .. id .. ".xml"))
        table.insert(Assets, Asset("IMAGE", "images/" .. id .. ".tex"))
        table.insert(WallPaper.images, {"images/" .. id .. ".xml", id .. ".tex"})
    end,
    create = function(type)
        local selected = WallPaper.choose(type)
        return selected and Image(selected[1], selected[2]) or nil
    end,
    choose = function(type)
        if GetModConfigData("persist")==true and WallPaper.previousChosenPaper then
            return WallPaper.previousChosenPaper
        end
        if #WallPaper.images == 0 then
            print("error: no wallpapers")
            return nil
        end
        local ret = WallPaper.images[math.floor(math.random() * #WallPaper.images) + 1]
        if GetModConfigData("persist")==true then
            WallPaper.previousChosenPaper = ret
        end
        return ret
    end,
    position = function(element)
        element:SetPosition(0, 0)
        element:SetHAnchor(0)
        element:SetVAnchor(0)
        element:SetScaleMode(SCALEMODE_FILLSCREEN)
        element:MoveToBack()
    end,
    load = function()
        TheSim:GetPersistentString("wallpaper", WallPaper.onload)
    end,
    onload = function(load_success, data)
        if load_success and data ~= nil then
            local status, data = pcall(function()
                return json.decode(data)
            end)
            if status and data then
                WallPaper.images = data.images or {}
                WallPaper.anims = data.anims or {}
            else
                print("Faild to load the cookbook!", status, data)
            end
        end
    end,
    save = function()
        local str = json.encode({images = WallPaper.images, anims = WallPaper.anims})
        TheSim:SetPersistentString("wallpaper", str, false)
    end,
    onsave = function(data)

    end,
    maininit = function(self)
        local a = WallPaper.create("main")
        if not a then
            return
        end
        WallPaper.mainelement = a
        if self.fixed_root then
            self.fixed_root:AddChild(a)
        else
            self:AddChild(a)
        end
        WallPaper.position(a)
    end,
    multiinit = function(self)
        local a = WallPaper.create("multi")
        if not a then
            return
        end
        if self.banner_root then
            self.banner_root:Hide()
        end
        WallPaper.multielement = a
        if self.fixed_root then
            self.fixed_root:AddChild(a)
        else
            self:AddChild(a)
        end
        WallPaper.position(a)
    end,
    loadinginit = function(self)
        if not self.bg then
            return
        end
        local selected = WallPaper.choose("loading")
        if not selected then
            return
        end
        self.bg:SetTexture(selected[1], selected[2], selected[2])
        WallPaper.loadingelement = self.bg
    end,
    modinit = function()
        -- no need to save data now.
        -- WallPaper.load()
        -- load assets
        if rawget(GLOBAL,"WallPaperCall") then
            for i,v in ipairs(WallPaperCall) do
                v()
            end
        end
    end,
    serverinit=function(self)
        if not self.bg then return end
        local img=self.bg.bgplate.image
        WallPaper.serverelement=img
        local selected = WallPaper.choose("loading")
        if not selected then
            return
        end
        img:SetTexture(selected[1], selected[2], selected[2])
        WallPaper.position(img)
    end
}
GLOBAL.WallPaper=rawget(GLOBAL,"WallPaper") or WallPaper
local waitfor = AddClassPostConstruct
local screens = {mainscreen = WallPaper.maininit, multiplayermainscreen = WallPaper.multiinit,serverlistingscreen=WallPaper.serverinit}
for k, v in pairs(screens) do
    waitfor("screens/redux/" .. k, v)
end
local widgets = {
    mainmenu_motdpanel = function(self)
        if GetModConfigData("hidepanel")==true then
            self:Hide()
        end
    end,
    -- why, the asset is not loaded!
    -- loadingwidget = WallPaper.loadinginit
}
for k, v in pairs(widgets) do
    waitfor("widgets/redux/" .. k, v)
end
WallPaper.modinit()
