env.ismim = true
modimport("modmain.lua")
env.ismim = false
modimport("scripts/wallpaper.lua")
local function call() WallPaper.add("mia_bg") end
if WallPaper then
  call()
else
  if not WallPaperCall then rawset(GLOBAL, "WallPaperCall", {}) end
  table.insert(WallPaperCall, call)
end
