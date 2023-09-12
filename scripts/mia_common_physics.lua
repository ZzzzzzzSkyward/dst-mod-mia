local function MakeCharacterNoPassThrough(inst)
  local phys = inst.Physics
  phys:ClearCollisionMask()
  phys:CollidesWith(COLLISION.WORLD)
  phys:CollidesWith(COLLISION.OBSTACLES)
  phys:CollidesWith(COLLISION.SMALLOBSTACLES)
  phys:CollidesWith(COLLISION.CHARACTERS)
  phys:CollidesWith(COLLISION.GIANTS)
end
local function MakeCharacterPassThrough(inst)
  local phys = inst.Physics
  phys:ClearCollisionMask()
  phys:CollidesWith(COLLISION.GROUND)
  phys:CollidesWith(COLLISION.OBSTACLES)
  phys:CollidesWith(COLLISION.SMALLOBSTACLES)
  phys:CollidesWith(COLLISION.CHARACTERS)
  phys:CollidesWith(COLLISION.GIANTS)
end
local function ToggleOffPhysicsNoPassThrough(inst)
  inst.sg.statemem.isphysicstoggle = true
  inst.Physics:ClearCollisionMask()
  inst.Physics:CollidesWith(COLLISION.WORLD)
end
local function ToggleOffPhysics(inst)
  inst.sg.statemem.isphysicstoggle = true
  inst.Physics:ClearCollisionMask()
  inst.Physics:CollidesWith(COLLISION.GROUND)
end

local function ToggleOnPhysics(inst)
  inst.sg.statemem.isphysicstoggle = nil
  MakeCharacterNoPassThrough(inst)
end

return {
  ToggleOnPhysics = ToggleOnPhysics,
  ToggleOffPhysicsNoPassThrough= ToggleOffPhysicsNoPassThrough,
  ToggleOffPhysics = ToggleOffPhysics,
  MakeCharacterPassThrough = MakeCharacterPassThrough,
  MakeCharacterNoPassThrough = MakeCharacterNoPassThrough
}
