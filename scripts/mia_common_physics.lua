local function MakeCharacterNoPassThrough(inst)
    local phys=inst.Physics
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.WORLD)
    phys:CollidesWith(COLLISION.OBSTACLES)
    phys:CollidesWith(COLLISION.SMALLOBSTACLES)
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:CollidesWith(COLLISION.GIANTS)
end
local function MakeCharacterPassThrough(inst)
    local phys=inst.Physics
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.GROUND)
    phys:CollidesWith(COLLISION.OBSTACLES)
    phys:CollidesWith(COLLISION.SMALLOBSTACLES)
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:CollidesWith(COLLISION.GIANTS)
end
return {crossMakeCharacterPassThrough=MakeCharacterPassThrough,MakeCharacterNoPassThrough=MakeCharacterNoPassThrough}