require "prefabutil"

local assets = {
    Asset("ANIM", "anim/nanachitent.zip"),
    Asset("ANIM", "anim/nanachitent_mitty.zip"),
    Asset("ANIM", "anim/nanachitent_mittywake.zip")
}

local function PlaySleepLoopSoundTask(inst, stopfn)
    inst.SoundEmitter:PlaySound("dontstarve/common/tent_sleep")
end

local function stopsleepsound(inst)
    if inst.sleep_tasks ~= nil then
        for i, v in ipairs(inst.sleep_tasks) do v:Cancel() end
        inst.sleep_tasks = nil
    end
end

local function startsleepsound(inst, len)
    stopsleepsound(inst)
    inst.sleep_tasks = {
        inst:DoPeriodicTask(len, PlaySleepLoopSoundTask, 33 * FRAMES),
        inst:DoPeriodicTask(len, PlaySleepLoopSoundTask, 47 * FRAMES)
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
    sleeper:RemoveEventCallback("onignite", onignite, inst)

    if not nostatechange then
        if sleeper.sg:HasStateTag("tent") then sleeper.sg.statemem.iswaking = true end
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
        if item:HasTag("sleep") then item.components.timer:StartTimer("sleep", lefttime * 3) end
        inst.AnimState:ClearOverrideBuild("nanachitent_mitty")
        inst.AnimState:ClearOverrideBuild("nanachitent_mittywake")
    end
    if inst.components.finiteuses then inst.components.finiteuses:Use() end
end

local function onsleep(inst, sleeper)
    sleeper:ListenForEvent("onignite", onignite, inst)

    if inst.sleep_anim ~= nil then
        inst.AnimState:PlayAnimation(inst.sleep_anim, true)
        startsleepsound(inst, inst.AnimState:GetCurrentAnimationLength())
    end

    local item = sleeper.components.inventory:GetEquippedItem(EQUIPSLOTS.BACK or EQUIPSLOTS.BODY)
    if sleeper:HasTag("nanachi") and item and item:HasTag("mitty") then
        local lefttime = item.components.timer:GetTimeLeft("sleep")
        if lefttime and lefttime > 0 then
            item.components.timer:StopTimer("sleep")
            inst.components.timer:StartTimer("mittysleep", lefttime / 3)
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

local function changephase(inst, phase)
    if phase == "day" then
        inst:AddTag("siestahut")
    else
        inst:RemoveTag("siestahut")
    end
end

local function onfinishedsound(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/tent_dis_twirl")
end

local function onfinished(inst)
    if not inst:HasTag("burnt") then
        stopsleepsound(inst)
        inst.AnimState:PlayAnimation("destroy")
        inst:ListenForEvent("animover", inst.Remove)
        inst.SoundEmitter:PlaySound("dontstarve/common/tent_dis_pre")
        inst.persists = false
        inst:DoTaskInTime(16 * FRAMES, onfinishedsound)
    end
end

local function onbuilt_tent(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", true)
    inst.SoundEmitter:PlaySound("dontstarve/common/tent_craft")
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then inst.components.burnable.onburnt(inst) end
end

local function temperaturetick(inst, sleeper)
    if sleeper.components.temperature ~= nil then
        if inst.is_cooling then
            if sleeper.components.temperature:GetCurrent() > TUNING.SLEEP_TARGET_TEMP_TENT then
                sleeper.components.temperature:SetTemperature(
                    sleeper.components.temperature:GetCurrent() - TUNING.SLEEP_TEMP_PER_TICK)
            end
        elseif sleeper.components.temperature:GetCurrent() < TUNING.SLEEP_TARGET_TEMP_TENT then
            sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent()
                                                              + TUNING.SLEEP_TEMP_PER_TICK)
        end
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
    inst:AddTag("structure")
    if tag ~= nil then inst:AddTag(tag) end

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle", true)

    inst.MiniMapEntity:SetIcon(icon)

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    -- inst:AddComponent("finiteuses")
    -- inst.components.finiteuses:SetOnFinished(onfinished)

    inst:AddComponent("sleepingbag")
    inst.components.sleepingbag.onsleep = onsleep
    inst.components.sleepingbag.onwake = onwake
    inst.components.sleepingbag.health_tick = TUNING.SLEEP_HEALTH_PER_TICK * 2
    -- convert wetness delta to drying rate
    inst.components.sleepingbag.dryingrate = math.max(0, -TUNING.SLEEP_WETNESS_PER_TICK / TUNING.SLEEP_TICK_PERIOD)
    inst.components.sleepingbag:SetTemperatureTickFn(temperaturetick)

    MakeSnowCovered(inst)
    inst:ListenForEvent("onbuilt", onbuiltfn)

    MakeLargeBurnable(inst, nil, nil, true)
    MakeMediumPropagator(inst)

    inst.OnSave = onsave
    inst.OnLoad = onload

    MakeHauntableWork(inst)

    return inst
end

local function nanachitent()
    local inst = common_fn("nanachitent", "nanachitent", "nanachitent.png", "nanachitent", onbuilt_tent)

    if not TheWorld.ismastersim then return inst end

    inst.sleep_anim = "sleep_loop"
    inst.components.sleepingbag.hunger_tick = TUNING.SLEEP_HUNGER_PER_TICK
    -- inst.is_cooling = false
    inst.sleep_phase = "day"
    inst.sleep_anim = "sleep_loop"
    inst.hunger_tick = TUNING.SLEEP_HUNGER_PER_TICK

    if TheWorld.worldprefab ~= "cave" then
        inst:WatchWorldState("phase", changephase)
        if TheWorld.state.phase == "day" then inst:AddTag("siestahut") end
    end

    inst:ListenForEvent("timerdone", OnTimerDone)
    return inst
end

return Prefab("nanachitent", nanachitent, assets),
    MakePlacer("nanachitent_placer", "nanachitent", "nanachitent", "idle")
