require "prefabutil"

local nanachitent_assets =
{
    Asset("ANIM", "anim/nanachitent.zip"),
    Asset("ANIM", "anim/nanachitent_mitty.zip"),
    Asset("ANIM", "anim/nanachitent_mittywake.zip"),
}

local function PlaySleepLoopSoundTask(inst, stopfn)
    inst.SoundEmitter:PlaySound("dontstarve/common/tent_sleep")
end

local function stopsleepsound(inst)
    if inst.sleep_tasks ~= nil then
        for i, v in ipairs(inst.sleep_tasks) do
            v:Cancel()
        end
        inst.sleep_tasks = nil
    end
end

local function startsleepsound(inst, len)
    stopsleepsound(inst)
    inst.sleep_tasks =
    {
        inst:DoPeriodicTask(len, PlaySleepLoopSoundTask, 33 * FRAMES),
        inst:DoPeriodicTask(len, PlaySleepLoopSoundTask, 47 * FRAMES),
    }
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        stopsleepsound(inst)
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle", true)
    end
    if inst.components.sleepingbag ~= nil and inst.components.sleepingbag.sleeper ~= nil then
        inst.components.sleepingbag:DoWakeUp()
    end
end

local function onignite(inst)
    inst.components.sleepingbag:DoWakeUp()
end

local function onwake(inst, sleeper, nostatechange)
    if inst.sleeptask ~= nil then
        inst.sleeptask:Cancel()
        inst.sleeptask = nil
    end

    sleeper:RemoveEventCallback("onignite", onignite, inst)

    if not nostatechange then
        if sleeper.sg:HasStateTag("tent") then
            sleeper.sg.statemem.iswaking = true
        end
        sleeper.sg:GoToState("wakeup")
    end

    if inst.sleep_anim ~= nil then
        inst.AnimState:PushAnimation("idle", true)
        stopsleepsound(inst)
    end

    local item = sleeper.components.inventory:GetEquippedItem(EQUIPSLOTS.BACK or EQUIPSLOTS.BODY)
    if sleeper:HasTag("nanachi") and item and item:HasTag("mitty") then
        local lefttime = inst.components.timer:GetTimeLeft("mittysleep")
        if lefttime == nil or lefttime < 0 then lefttime = 0 end
        inst.components.timer:StopTimer("mittysleep")
        if item:HasTag("sleep") then
            item.components.timer:StartTimer("sleep",lefttime*3)
        end
        inst.AnimState:ClearOverrideBuild("nanachitent_mitty")
        inst.AnimState:ClearOverrideBuild("nanachitent_mittywake")
    end
end

local function onsleeptick(inst, sleeper)
    local isstarving = sleeper.components.beaverness ~= nil and sleeper.components.beaverness:IsStarving()

    if sleeper.components.hunger ~= nil then
        sleeper.components.hunger:DoDelta(inst.hunger_tick, true, true)
        isstarving = sleeper.components.hunger:IsStarving()
    end

    if sleeper.components.sanity ~= nil and sleeper.components.sanity:GetPercentWithPenalty() < 1 then
        sleeper.components.sanity:DoDelta(TUNING.SLEEP_SANITY_PER_TICK*1.2, true)
    end

    if not isstarving and sleeper.components.health ~= nil then
        sleeper.components.health:DoDelta(TUNING.SLEEP_HEALTH_PER_TICK * 2, true, inst.prefab, true)
    end

    if sleeper.components.temperature ~= nil then
        if sleeper.components.temperature:GetCurrent() > TUNING.SLEEP_TARGET_TEMP_TENT then
                sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() - TUNING.SLEEP_TEMP_PER_TICK)
            end
        if sleeper.components.temperature:GetCurrent() < TUNING.SLEEP_TARGET_TEMP_TENT then
            sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() + TUNING.SLEEP_TEMP_PER_TICK)
        end
    end

    if isstarving then
        inst.components.sleepingbag:DoWakeUp()
    end
end

local function onsleep(inst, sleeper)
    sleeper:ListenForEvent("onignite", onignite, inst)

    if inst.sleep_anim ~= nil then
        inst.AnimState:PlayAnimation(inst.sleep_anim, true)
        startsleepsound(inst, inst.AnimState:GetCurrentAnimationLength())
    end

    if inst.sleeptask ~= nil then
        inst.sleeptask:Cancel()
    end
    inst.sleeptask = inst:DoPeriodicTask(TUNING.SLEEP_TICK_PERIOD, onsleeptick, nil, sleeper)

    local item = sleeper.components.inventory:GetEquippedItem(EQUIPSLOTS.BACK or EQUIPSLOTS.BODY)
    if item then print(item.prefab) end
    if sleeper:HasTag("nanachi") and item and item:HasTag("mitty") then
        print("mitty in sleep!")
        local lefttime = item.components.timer:GetTimeLeft("sleep")
        if lefttime and lefttime > 0 then
            item.components.timer:StopTimer("sleep")
            inst.components.timer:StartTimer("mittysleep",lefttime/3)
        end
        if item:HasTag("sleep") then
            inst.AnimState:AddOverrideBuild("nanachitent_mitty")
        else
            inst.AnimState:AddOverrideBuild("nanachitent_mittywake")
        end
    end
end

local function OnTimerDone(inst, data)
    if data.name == "mittysleep" then
        inst.AnimState:ClearOverrideBuild("nanachitent_mitty")
        inst.AnimState:AddOverrideBuild("nanachitent_mittywake")
    end
end

local function common_fn(bank, build, icon, tag, onbuiltfn)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)

    inst:AddTag("tent")
    inst:AddTag("nanachitent")
    inst:AddTag("structure")
    if tag ~= nil then
        inst:AddTag(tag)
    end

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle", true)

    inst.MiniMapEntity:SetIcon(icon)

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("sleepingbag")
    inst.components.sleepingbag.onsleep = onsleep
    inst.components.sleepingbag.onwake = onwake

    inst:AddComponent("timer")
    
    inst.components.sleepingbag.dryingrate = math.max(0, -TUNING.SLEEP_WETNESS_PER_TICK / TUNING.SLEEP_TICK_PERIOD)

    MakeSnowCovered(inst)

    MakeMediumPropagator(inst)

    MakeHauntableWork(inst)

    inst:ListenForEvent("timerdone", OnTimerDone)

    return inst
end

local function changephase(inst, phase)
    if phase == "day" then
        inst:AddTag("siestahut")
    else
        inst:RemoveTag("siestahut")
    end
end

local function nanachitent()
    local inst = common_fn("nanachitent", "nanachitent", "nanachitent.tex")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.sleep_phase = "day"
    inst.sleep_anim = "sleep_loop"
    inst.hunger_tick = TUNING.SLEEP_HUNGER_PER_TICK

    if TheWorld.worldprefab ~= "cave" then
        inst:WatchWorldState("phase", changephase)
        if TheWorld.state.phase == "day" then
            inst:AddTag("siestahut")
        end
    end

    return inst
end

return Prefab("nanachitent", nanachitent, nanachitent_assets),
    MakePlacer("nanachitent_placer", "nanachitent", "nanachitent", "idle")
