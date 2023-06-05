local MakePlayerCharacter = require"prefabs/player_common"

local assets = {Asset("SOUNDPACKAGE", "sound/nanachi.fev"), Asset("SOUND", "sound/nanachi.fsb"),
                Asset("ANIM", "anim/nanachi.zip"), Asset("ANIM", "anim/nanachihair.zip"),
                Asset("ANIM", "anim/ghost_nanachi_build.zip"), Asset("ANIM", "anim/player_actions_roll.zip")}
local prefabs = {}
local start_inv = TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.NANACHI or {}
for i, v in ipairs(start_inv) do table.insert(prefabs, v) end

local function FindFriend(inst)
  if inst.components.leader:CountFollowers("nanachifriend") >= 1 then return end
  local x, y, z = inst.Transform:GetWorldPosition()
  local ents = TheSim:FindEntities(x, y, z, 3, {"pig"}, {"player", "werepig", "guard", "nanachifriend"})
  for k, v in pairs(ents) do
    if not v:IsAsleep() and not v.components.sleeper:IsAsleep() then
      if not IsEntityDeadOrGhost(v) and v.components.follower then
        inst:PushEvent("makefriend")
        inst.components.leader:AddFollower(v)
        v.components.follower:AddLoyaltyTime(240)
        v:AddTag("nanachifriend")
        v:DoTaskInTime(480, function() v:RemoveTag("nanachifriend") end)
      end
    end
  end
end
local function forcefast(inst)
  inst.components.locomotor.walkspeed = TUNING.WILSON_WALK_SPEED * TUNING.NANACHI_SPEED_MULTIPLIER
  inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED * TUNING.NANACHI_SPEED_MULTIPLIER
end
local function GetPointSpecialActions(inst, pos, useitem, right)
  local ret = {}
  if not right then return ret end

  local rider = inst.replica.rider
  if rider and rider:IsRiding() then return ret end
  local distsq = inst:GetDistanceSqToPoint(pos)
  if distsq < 4 or distsq > 1600 then return ret end
  if useitem then return ret end
  return {ACTIONS.DODGE}
end

local function OnSetOwner(inst)
  if inst.components.playeractionpicker ~= nil then
    local old = inst.components.playeractionpicker.pointspecialactionsfn
    if not old then
      inst.components.playeractionpicker.pointspecialactionsfn = GetPointSpecialActions
    else
      inst.components.playeractionpicker.pointspecialactionsfn = function(...)
        return TableUnion(GetPointSpecialActions(...), old(...))
      end
    end
  end
end
-- watch out for danger, hounds, bosses, etc
local DangerWatcher
DangerWatcher = {
  gethoundtime = function()
    local hounded = TheWorld.components.hounded
    if not hounded then return -1 end

    local timeToAttack = hounded:GetTimeToAttack()
    if timeToAttack == nil then return -1 end
    return timeToAttack
  end,
  getbosstime = function(name)
    local worldTimer = TheWorld.components.worldsettingstimer
    if not worldTimer then return -1 end
    local timeToAttack = worldTimer:GetTimeLeft(name)
    local isstopped = worldTimer:IsTimerPaused(name)
    if timeToAttack == nil then return -1 end
    if isstopped then return -1 end
    return timeToAttack
  end,
  bosstimers = {
    deerclops = "deerclops_timetoattack",
    bearger = "bearger_timetospawn"
    -- walrus = "walrus",--walrus_camp
    -- little_walrus = "little_walrus",
    -- dragonfly= "regen_dragonfly",--dragonfly
  },
  hasdanger = function(key)
    if key == "hound" then
      local hound = DangerWatcher.gethoundtime() or 1e10
      if hound < 1e10 then return "hound", hound end
    end
    for k, v in pairs(DangerWatcher.bosstimers) do
      local time = DangerWatcher.getbosstime(v) or 1e10
      if time < 1e10 then return k, time end
    end
  end,
  neartime = 60 * 8,
  interval = 60 * 2,
  mintime = 60,
  isnear = function(t1, t2)
    if t1 > t2 and t2 < DangerWatcher.neartime and t2 > DangerWatcher.mintime then return true end
  end,
  talkaboutdanger = function(player, danger, time)
    if danger and player.components.talker then
      player.components.talker:Say(GetString(player, "ANNOUNCE_DANGER_" .. danger:upper() .. (math.floor(time / 60))))
    end
  end,
  lastquery = {},
  query = function()
    local danger, time = DangerWatcher.hasdanger()
    if danger then
      local lasttime = DangerWatcher.lastquery[danger]
      local near = lasttime and DangerWatcher.isnear(lasttime, time)
      if near then
        DangerWatcher.lastquery[danger] = time
        return danger, time
      elseif not lasttime then
        DangerWatcher.lastquery[danger] = time
      end
    end
    return nil, -1
  end,
  querytask = function(inst)
    local danger, time = DangerWatcher.query()
    if danger then inst:DoTaskInTime(0, function() DangerWatcher.talkaboutdanger(inst, danger, time) end) end
  end,
  loop = function(inst)
    local timer = inst.components.timer
    if not timer:TimerExists("dangerwatcher") then timer:StartTimer("dangerwatcher", DangerWatcher.interval) end
    inst:ListenForEvent("timerdone", function(inst, data)
      if data.name == "dangerwatcher" then
        DangerWatcher.querytask(inst)
        timer:StartTimer("dangerwatcher", DangerWatcher.interval)
      end
    end)
  end
}
local common_postinit = function(inst)
  inst.MiniMapEntity:SetIcon("nanachi.png")
  inst:AddTag("nanachi")
  inst:AddTag("soulless") -- non human representation
  inst:RemoveTag("scarytoprey")
  -- compatible with hamlet
  inst.dodgetime = net_bool(inst.GUID, "player.dodgetime", "dodgetimedirty")
  inst.last_dodge_time = GetTime()
  inst:ListenForEvent("dodgetimedirty", function()
    -- do a penality here
    if inst.components.hunger then
      if inst.last_dodge_time + 5 > GetTime() then inst.components.hunger:DoDelta(-TUNING.CALORIES_TINY / 5) end
    end
    inst.last_dodge_time = GetTime()
  end)
  inst:ListenForEvent("setowner", OnSetOwner)
end

local master_postinit = function(inst)
  inst.soundsname = "nanachi"
  -- disable invincible dodge
  inst._dodgenotinvincible = true
  inst._nosoundwhendodge = true
  inst.talker_path_override = "nanachi/"
  inst.components.health:SetMaxHealth(TUNING.NANACHI_HEALTH)
  inst.components.hunger:SetMax(TUNING.NANACHI_HUNGER)
  inst.components.sanity:SetMax(TUNING.NANACHI_SANITY)
  inst:AddComponent("sanityaura")
  inst.components.sanityaura.aura = TUNING.SANITYAURA_MED
  inst.components.locomotor:SetTriggersCreep(false)

  inst.attracttask = inst:DoPeriodicTask(5, FindFriend)
  inst:ListenForEvent("ms_respawnedfromghost", forcefast)
  inst:ListenForEvent("death", forcefast)
  inst.OnLoad = forcefast
  inst:ListenForEvent("playeractivated", forcefast)
end

return MakePlayerCharacter("nanachi", prefabs, assets, common_postinit, master_postinit, start_inv)
-- 娜娜奇应该受到雷古的降san光环
