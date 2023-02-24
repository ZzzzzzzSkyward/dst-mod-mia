require "prefabutil"
local cooking = require("cooking")
local assets = {Asset("ANIM", "anim/cook_pot_riko.zip"), Asset("ANIM", "anim/cook_pot_food.zip")}
local prefabs = {"collapse_small", "ash"}
for k, v in pairs(cooking.recipes.cookpot) do table.insert(prefabs, v.name) end
local foods = require("preparedfoods")
for k, recipe in pairs(foods) do AddCookerRecipe("rikocookpot", recipe) end
local function ChangeToItem(inst)
    if inst.components.stewer.product ~= nil and inst.components.stewer:IsDone() then
        inst.components.stewer:Harvest()
    end
    if inst.components.container ~= nil then inst.components.container:DropEverything() end

    local item = SpawnPrefab("rikocookpot_item", inst.linked_skinname, inst.skin_id)
    item.Transform:SetPosition(inst.Transform:GetWorldPosition())
    item.AnimState:PlayAnimation("collapse")
    item.SoundEmitter:PlaySound("dontstarve/common/together/portable/cookpot/collapse")
end
local function ondeploy(inst, pt, deployer)
    local pot = SpawnPrefab("rikocookpot")
    if pot ~= nil then
        pt = Vector3(pt.x, 0, pt.z)
        pot.Physics:SetCollides(false)
        pot.Physics:Teleport(pt.x, pt.y, pt.z)
        pot.Physics:SetCollides(true)
        pot.AnimState:PlayAnimation("place")
        pot.AnimState:PlayAnimation("idle_empty", false)
        pot.SoundEmitter:PlaySound("dontstarve/common/place_structure_stone")
        inst:Remove()
    end
end
local function item_droppedfn(inst)
    if inst.components.deployable and inst.components.deployable:CanDeploy(inst:GetPosition()) then
        inst.components.deployable:Deploy(inst:GetPosition(), inst)
    end
end
local function storeincontainer(inst, container)
    if container ~= nil and container.components.container ~= nil then
        inst:ListenForEvent("onputininventory", inst._oncontainerownerchanged, container)
        inst:ListenForEvent("ondropped", inst._oncontainerownerchanged, container)
        inst._container = container
    end
end
local function unstore(inst)
    if inst._container ~= nil then
        inst:RemoveEventCallback("onputininventory", inst._oncontainerownerchanged, inst._container)
        inst:RemoveEventCallback("ondropped", inst._oncontainerownerchanged, inst._container)
        inst._container = nil
    end
end
local function topocket(inst, owner)
    if inst._container ~= owner then
        unstore(inst)
        storeincontainer(inst, owner)
    end
end
local function toground(inst)
    unstore(inst)
end
local function itemfn(Sim)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    MakeInventoryPhysics(inst)
    inst.AnimState:SetBank("portable_cook_pot")
    inst.AnimState:SetBuild("cook_pot_riko")
    inst.AnimState:PlayAnimation("idle_empty")
    MakeInventoryFloatable(inst)
    inst.MiniMapEntity:SetIcon("rikocookpot.png")
    if not TheWorld.ismastersim then return inst end
    inst._container = nil
    inst._oncontainerownerchanged = function(container)
        topocket(inst, container)
    end
    inst._oncontainerremoved = function()
        unstore(inst)
    end
    inst:AddComponent("chosenowner")
    inst.components.chosenowner:SetOwner("riko")
    inst:ListenForEvent("onputininventory", topocket)
    inst:ListenForEvent("ondropped", toground)
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(item_droppedfn)
    inst:AddComponent("deployable")
    -- inst.components.deployable:SetDeployMode(DEPLOYMODE.DEFAULT)
    inst.components.deployable.ondeploy = ondeploy
    MakeHauntableLaunch(inst)
    return inst
end
local function onhammered(inst, worker)
    if inst.components.stewer.product ~= nil and inst.components.stewer:IsDone() then
        inst.components.lootdropper:AddChanceLoot(inst.components.stewer.product, 1)
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end
local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("hit_empty")
    inst.AnimState:PushAnimation((inst.components.stewer:IsCooking() and "cooking_loop")
                                     or (inst.components.stewer:IsDone() and "idle_full") or "idle_empty")
end
local function startcookfn(inst)
    if not inst:HasTag("iscooking") then inst:AddTag("iscooking") end
    inst.AnimState:PlayAnimation("cooking_loop", true)
    inst.SoundEmitter:KillSound("snd")
    inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle", "snd")
    inst.Light:Enable(true)
end
local function onopen(inst)
    if not inst:HasTag("isopen") then inst:AddTag("isopen") end
    inst.AnimState:PlayAnimation("cooking_pre_loop", true)
    inst.SoundEmitter:KillSound("snd")
    inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_open")
    inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot", "snd")
    if inst.components.container.opener and not inst.components.container.opener:HasTag("riko") then
        inst.components.container:DropEverything()
        inst.components.container:Close()
    end
end
local function onclose(inst)
    if inst:HasTag("isopen") then inst:RemoveTag("isopen") end
    if not inst.components.stewer:IsCooking() then
        inst.AnimState:PlayAnimation("idle_empty")
        inst.SoundEmitter:KillSound("snd")
    end
    inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close")
end
local function spoilfn(inst)
    inst.components.stewer.product = inst.components.stewer.spoiledproduct
    inst.AnimState:OverrideSymbol("swap_cooked", "cook_pot_food", inst.components.stewer.product)
end
local function ShowProduct(inst)
    local product = inst.components.stewer.product
    if IsModCookingProduct(inst.prefab, product) then
        inst.AnimState:OverrideSymbol("swap_cooked", product, product)
    else
        inst.AnimState:OverrideSymbol("swap_cooked", "cook_pot_food", product)
    end
end
local function donecookfn(inst)
    if inst:HasTag("iscooking") then inst:RemoveTag("iscooking") end
    inst.AnimState:PlayAnimation("cooking_pst")
    inst.AnimState:PushAnimation("idle_full")
    ShowProduct(inst)
    inst.SoundEmitter:KillSound("snd")
    inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_finish")
    inst.Light:Enable(false)
end
local function continuedonefn(inst)
    inst.AnimState:PlayAnimation("idle_full")
    ShowProduct(inst)
end
local function continuecookfn(inst)
    inst.AnimState:PlayAnimation("cooking_loop", true)
    inst.Light:Enable(true)
    inst.SoundEmitter:KillSound("snd")
    inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle", "snd")
end
local function harvestfn(inst)
    inst.AnimState:PlayAnimation("idle_empty")
end
local function getstatus(inst)
    if inst.components.stewer:IsCooking() and inst.components.stewer:GetTimeToCook() > 15 then
        return "COOKING_LONG"
    elseif inst.components.stewer:IsCooking() then
        return "COOKING_SHORT"
    elseif inst.components.stewer:IsDone() then
        return "DONE"
    else
        return "EMPTY"
    end
end
local function onfar(inst)
    if inst.components.container ~= nil then inst.components.container:Close() end
end
local function onbuilt(inst)
    if inst.components.workable ~= nil then inst:RemoveComponent("workable") end
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle_empty")
end
local function OnHaunt(inst, haunter)
    local ret = false
    if inst.components.stewer ~= nil and inst.components.stewer.product ~= "wetgoop" and math.random()
        <= TUNING.HAUNT_CHANCE_ALWAYS then
        if inst.components.stewer:IsCooking() then
            inst.components.stewer.product = "wetgoop"
            inst.components.hauntable.hauntvalue = TUNING.HAUNT_MEDIUM
            ret = true
        elseif inst.components.stewer:IsDone() then
            inst.components.stewer.product = "wetgoop"
            inst.components.hauntable.hauntvalue = TUNING.HAUNT_MEDIUM
            continuedonefn(inst)
            ret = true
        end
    end
    return ret
end
local function pickupfn(inst, guy)
    if guy.components.inventory ~= nil then
        local potitem = SpawnPrefab("rikocookpot_item")
        ChangeToItem(inst)
        inst:Remove()
        guy.components.inventory:GiveItem(potitem)
        return true
    end
end
local function OnDismantle(inst) -- , doer)
    ChangeToItem(inst)
    inst:Remove()
end
local function fn(Sim)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
    MakeObstaclePhysics(inst, .6)
    inst.MiniMapEntity:SetIcon("rikocookpot.png")
    inst.Light:Enable(false)
    inst.Light:SetRadius(.6)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(235 / 255, 62 / 255, 12 / 255)
    inst:AddTag("structure")
    inst:AddTag("stewer")
    inst.AnimState:SetBank("portable_cook_pot")
    inst.AnimState:SetBuild("cook_pot_riko")
    inst.AnimState:PlayAnimation("idle_empty")
    inst:SetPrefabNameOverride("rikocookpot_item")
    -- MakeSnowCoveredPristine(inst)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst:AddComponent("portablestructure")
    inst.components.portablestructure:SetOnDismantleFn(OnDismantle)
    inst:AddComponent("stewer")
    inst.components.stewer.onstartcooking = startcookfn
    inst.components.stewer.oncontinuecooking = continuecookfn
    inst.components.stewer.oncontinuedone = continuedonefn
    inst.components.stewer.ondonecooking = donecookfn
    inst.components.stewer.onharvest = harvestfn
    inst.components.stewer.onspoil = spoilfn
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("cookpot")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(2)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.canbepickedup = false
    inst:AddComponent("pickupable")
    inst.components.pickupable:SetOnPickupFn(pickupfn)
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus
    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(3, 5)
    inst.components.playerprox:SetOnPlayerFar(onfar)
    inst:AddComponent("hauntable")
    inst.components.hauntable:SetOnHauntFn(OnHaunt)
    -- MakeSnowCovered(inst, .01)
    -- MakeMediumBurnable(inst, nil, nil, true)
    -- MakeSmallPropagator(inst)
    -- inst.components.burnable:SetFXLevel(2)
    -- inst.components.burnable:SetOnBurntFn(BurntFn)
    inst:ListenForEvent("onbuilt", onbuilt)
    return inst
end
return Prefab("rikocookpot", fn, assets, prefabs), Prefab("rikocookpot_item", itemfn, assets, prefabs),
    MakePlacer("rikocookpot_item_placer", "cook_pot_riko", "cook_pot_riko", "idle_empty")
