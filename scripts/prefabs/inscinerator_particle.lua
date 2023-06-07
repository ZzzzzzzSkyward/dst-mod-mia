-- the particles that influences environment emitted from Reg's inscinerator
local assets = {}
-- valid actions
local actions = {"HAMMER", "CHOP", "MINE", "HACK"}
-- range search fn
local donetag = "inscinerator_particle_done"
-- tags
local canttags = {"INLIMBO", "invisible", "FX", "DECOR", "playerghost"}
local musttags = nil
local ispvp = TheNet:GetPVPEnabled()
if not ispvp then table.insert(canttags, "player") end
local function range_search(inst, range, canhitfn)
  local x, y, z = inst.Transform:GetWorldPosition()
  local ret = {}
  local ents = TheSim:FindEntities(x, y, z, range, musttags, canttags)
  for k, v in pairs(ents) do if not v[donetag] and (not canhitfn or canhitfn(v)) then table.insert(ret, v) end end
  return ret
end
-- on hit fn
local function CheckSpawnedLoot(loot)
  if loot.components.inventoryitem ~= nil then
    loot.components.inventoryitem:TryToSink()
  else
    local lootx, looty, lootz = loot.Transform:GetWorldPosition()
    if ShouldEntitySink(loot, true) or TheWorld.Map:IsPointNearHole(Vector3(lootx, 0, lootz)) then SinkEntity(loot) end
  end
end
local function SpawnLootPrefab(inst, lootprefab)
  if lootprefab == nil then return end

  local loot = SpawnPrefab(lootprefab)
  if loot == nil then return end

  local x, y, z = inst.Transform:GetWorldPosition()

  if loot.Physics ~= nil then
    local angle = math.random() * 2 * PI
    loot.Physics:SetVel(2 * math.cos(angle), 10, 2 * math.sin(angle))

    if inst.Physics ~= nil then
      local len = loot:GetPhysicsRadius(0) + inst:GetPhysicsRadius(0)
      x = x + math.cos(angle) * len
      z = z + math.sin(angle) * len
    end

    loot:DoTaskInTime(1, CheckSpawnedLoot)
  end

  loot.Transform:SetPosition(x, y, z)

  loot:PushEvent("on_loot_dropped", {
    dropper = inst
  })

  return loot
end

local function destroystructure(target, inst)
  local recipe = AllRecipes[target.prefab]
  local ingredient_percent = ((target.components.finiteuses ~= nil and target.components.finiteuses:GetPercent()) or
                              (target.components.fueled ~= nil and target.components.inventoryitem ~= nil and
                               target.components.fueled:GetPercent()) or
                              (target.components.armor ~= nil and target.components.inventoryitem ~= nil and
                               target.components.armor:GetPercent()) or 1) / recipe.numtogive

  for i, v in ipairs(recipe.ingredients) do
    -- allow gems
    -- if string.sub(v.type, -3) ~= "gem" or string.sub(v.type, -11, -4) == "precious" then
    -- V2C: always at least one in case ingredient_percent is 0%
    local amt = v.amount == 0 and 0 or math.max(1, math.ceil(v.amount * ingredient_percent))
    for n = 1, amt do SpawnLootPrefab(target, v.type) end
    -- end
  end

  if target.components.inventory ~= nil then target.components.inventory:DropEverything() end

  if target.components.container ~= nil then target.components.container:DropEverything() end

  if target.components.spawner ~= nil and target.components.spawner:IsOccupied() then
    target.components.spawner:ReleaseChild()
  end

  if target.components.occupiable ~= nil and target.components.occupiable:IsOccupied() then
    local item = target.components.occupiable:Harvest()
    if item ~= nil then
      item.Transform:SetPosition(target.Transform:GetWorldPosition())
      item.components.inventoryitem:OnDropped()
    end
  end

  if target.components.trap ~= nil then target.components.trap:Harvest() end

  if target.components.dryer ~= nil then target.components.dryer:DropItem() end

  if target.components.harvestable ~= nil then target.components.harvestable:Harvest() end

  if target.components.stewer ~= nil then target.components.stewer:Harvest() end

  target:PushEvent("ondeconstructstructure", inst)

  if target.components.stackable ~= nil then
    -- if it's stackable we only want to destroy one of them.
    target.components.stackable:Get():Remove()
  else
    target:Remove()
  end
end

local hitorder = { -- check if target can be acted on
{
  criteria = function(inst, target)
    return target.components.workable and target.components.workable:CanBeWorked() and
            target.components.workable:GetWorkAction() and
            inst.components.tool:CanDoAction(target.components.workable:GetWorkAction())
  end,
  fn = function(inst, target) target.components.workable:Destroy(inst) end
}, -- check if target can be damaged
{
  criteria = function(inst, target)
    return target.components.health and not target.components.health:IsDead() and
            not target.components.health:IsInvincible()
  end,
  fn = function(inst, target) target.components.health:DoDelta(-100) end
}, -- check if target can burn
{
  criteria = function(inst, target) return target.components.burnable and not target.components.burnable:IsBurning() end,
  fn = function(inst, target) target.components.burnable:Ignite() end
}, -- check if target can be deconstructed
{
  criteria = function(inst, target)
    return AllRecipes[target.prefab] ~= nil and not FunctionOrValue(AllRecipes[target.prefab].no_deconstruction, target)
  end,
  fn = function(inst, target) destroystructure(target, inst) end
}}
local function onhitfn(inst, target)
  for k, v in pairs(hitorder) do
    if v.criteria(inst, target) then
      v.fn(inst, target)
      return true
    end
  end
  return false
end
local function ondestroy(inst, target)
  if target.AnimState then target.AnimState:SetHaunted(true) end
  target:DoTaskInTime(1, function() if target:IsValid() then target:Remove() end end)
end
--#FIXME disable debug
local dbg = true
local function fn()
  local inst = CreateEntity()
  inst.entity:AddTransform()
  -- inst.entity:AddNetwork()
  inst.entity:AddAnimState()
  inst.entity:SetCanSleep(false)
  -- debug purpose
  if dbg then

    inst.entity:AddLabel()
    inst.Label:SetFontSize(20)
    inst.Label:SetFont(DEFAULTFONT)
    inst.Label:SetWorldOffset(0, 3, 0)
    inst.Label:SetUIOffset(0, 0, 0)
    inst.Label:SetColour(1, 1, 1)
    inst.Label:Enable(true)
    inst.Label:SetText("par")

  end
  inst:AddTag("FX")
  inst:AddTag("NOCLICK")
  inst:AddTag("NOBLOCK")
  inst.entity:SetPristine()
  if not TheWorld.ismastersim then return inst end
  -- add tool to work
  inst:AddComponent("tool")
  for k, v in pairs(actions) do if ACTIONS[v] then inst.components.tool:SetAction(ACTIONS[v], 1) end end
  inst.onhit = onhitfn
  inst.gettarget = range_search
  inst.ondestroy = ondestroy
  inst.donetag = donetag
  local lifetime = 10
  inst:DoTaskInTime(lifetime, function() if inst:IsValid() then inst:Remove() end end)
  return inst
end
return Prefab("inscinerator_particle", fn, assets)
