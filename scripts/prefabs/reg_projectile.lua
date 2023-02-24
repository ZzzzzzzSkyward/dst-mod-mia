local assets = {Asset("ANIM", "anim/lavaarena_blowdart_attacks.zip"), Asset("ANIM", "anim/explode.zip")}
local FADE_FRAMES = 5
local function CreateTail()
    local inst = CreateEntity()
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst.entity:SetCanSleep(false)
    inst.persists = false
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.AnimState:SetBank("lavaarena_blowdart_attacks")
    inst.AnimState:SetBuild("lavaarena_blowdart_attacks")
    inst.AnimState:PlayAnimation("tail_1")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst:ListenForEvent("animover", inst.Remove)
    return inst
end
local function OnUpdateProjectileTail(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 3, nil, {"player"})
    for k, v in pairs(ents) do
        if v and v.components.health and not v.components.health:IsDead() then
            v.components.health:DoDelta(-TUNING.REGBOMB_DAMAGE)
            if v.components.combat and v.components.combat:HasTarget() then v.components.combat:DropTarget() end
        end
    end
    print("Spawn HoundFire!")
    SpawnPrefab("houndfire").Transform:SetPosition(inst.Transform:GetWorldPosition())
end
local function common()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    inst.Transform:SetScale(3, 3, 3)
    inst.AnimState:SetBank("lavaarena_blowdart_attacks")
    inst.AnimState:SetBuild("lavaarena_blowdart_attacks")
    inst.AnimState:PlayAnimation("attack_1", true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst:AddTag("projectile")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(25)
    inst.components.projectile:SetOnHitFn(inst.Remove)
    inst.components.projectile:SetOnMissFn(inst.Remove)
    inst:DoPeriodicTask(0, OnUpdateProjectileTail)
    return inst
end
return Prefab("reg_projectile", common, assets)
