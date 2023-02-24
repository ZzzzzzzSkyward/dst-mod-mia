local oldactionstore = ACTIONS.STORE.fn
ACTIONS.STORE.fn = function(act)
    if act.target.prefab == "rikocookpot" and act.target.components.container ~= nil
        and act.invobject.components.inventoryitem ~= nil and act.doer.components.inventory ~= nil then
        if act.target.components.container:IsOpen() and not act.target.components.container:IsOpenedBy(act.doer) then
            return false, "INUSE"
        elseif not act.target.components.container:CanTakeItemInSlot(act.invobject) then
            return false, "NOTALLOWED"
        end
        local item = act.invobject.components.inventoryitem:RemoveFromOwner(
            act.target.components.container.acceptsstacks)
        if item ~= nil then
            act.target.components.container:Open(act.doer)
            if not act.target.components.container:GiveItem(item, nil, nil, false) then
                if act.doer.components.playercontroller ~= nil
                    and act.doer.components.playercontroller.isclientcontrollerattached then
                    act.doer.components.inventory:GiveItem(item)
                else
                    act.doer.components.inventory:GiveActiveItem(item)
                end
                return false
            end
            return true
        end
    end
    return oldactionstore(act)
end
local oldactionstorestr = ACTIONS.STORE.strfn
ACTIONS.STORE.strfn = function(act)
    if act.target ~= nil then if act.target.prefab == "rikocookpot" then return "COOK" end end
    return oldactionstorestr(act)
end
local oldactionpickup = ACTIONS.PICKUP.fn
ACTIONS.PICKUP.fn = function(act)
    if act.doer.components.inventory ~= nil and act.target ~= nil and act.target.components.pickupable ~= nil
        and not act.target:IsInLimbo() then
        act.doer:PushEvent("onpickupitem", {item = act.target})
        return act.target.components.pickupable:OnPickup(act.doer)
    end
    return oldactionpickup(act)
end

local function stewerfix(inst, doer, actions, right)
    local function CanBePickUp(inst)
        return not inst:HasTag("donecooking") and not inst:HasTag("readytocook") and inst.replica.container ~= nil
                   and #inst.replica.container:GetItems() == 0 and not inst:HasTag("isopen")
                   and not inst:HasTag("iscooking")
    end
    if inst.prefab == "rikocookpot" and right and CanBePickUp(inst) then table.insert(actions, ACTIONS.PICKUP) end
end
AddComponentAction("SCENE", "stewer", stewerfix)

local MITTYPUT = Action({mount_valid = true})
MITTYPUT.id = "MITTYPUT"
MITTYPUT.str = "放入米缇"
MITTYPUT.fn = function(act)
    if act.doer and act.target then
        local position = EQUIPSLOTS.BACK or EQUIPSLOTS.BODY
        item = inst.components.inventory:GetEquippedItem(position)
        inst.components.inventory:DropItem(item)
        item.empty = true
        item.mitty_num = 0
        item:RemoveTag("sleep")
        item.AnimState:PlayAnimation("empty")
        local lefttime = item.components.timer:GetTimeLeft("sleep")
        if lefttime and lefttime > 0 then
            item.components.timer:StopTimer("sleep")
            act.target.components.timer:StartTimer("mittysleep", lefttime / 3)
            act.target.AnimState:AddOverrideBuild("nanachitent_mitty")
        else
            act.target.AnimState:AddOverrideBuild("nanachitent_mittywake")
        end
        act.doer:RemoveTag("toadstool")
        act.target:AddTag("hassleeper")
        act.target:AddTag("mittysleep")
        return true
    end
    return false
end
AddAction(MITTYPUT)
AddComponentAction("SCENE", "sleepingbag", function(inst, doer, actions, right)
    -- if right then
    -- and inst:HasTag("nanachitent") and not inst:HasTag("hassleeper") then
    -- and doer:HasTag("mittybasket") then
    table.insert(actions, ACTIONS.MITTYPUT)
    -- end
end)
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.MITTYPUT, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.MITTYPUT, "doshortaction"))

local MITTYPICK = Action({mount_valid = true})
MITTYPICK.id = "MITTYPICK"
MITTYPICK.str = "取出米缇"
MITTYPICK.fn = function(act)
    if act.doer and act.target then
        local position = EQUIPSLOTS.BACK or EQUIPSLOTS.BODY
        item = inst.components.inventory:GetEquippedItem(position)
        inst.components.inventory:DropItem(item)
        item.empty = false
        item.AnimState:PlayAnimation("idle")
        local lefttime = act.target.components.timer:GetTimeLeft("mittysleep")
        if lefttime and lefttime > 0 then
            act.target.components.timer:StopTimer("mittysleep")
            item:AddTag("sleep")
            item.mitty_num = TUNING.MITTY_NUM
            item.components.timer:StartTimer("sleep", lefttime * 3)
            item.AnimState:PlayAnimation("sleep")
        end
        act.doer:AddTag("toadstool")
        act.target:RemoveTag("hassleeper")
        act.target:RemoveTag("mittysleep")
        act.target.AnimState:ClearOverrideBuild("nanachitent_mittywake")
        act.target.AnimState:ClearOverrideBuild("nanachitent_mitty")
        return true
    end
    return false
end
AddAction(MITTYPICK)
AddComponentAction("SCENE", "sleepingbag", function(inst, doer, actions, right)
    if right and inst:HasTag("nanachitent") and inst:HasTag("mittysleep") and not doer:HasTag("toadstool")
        and doer:HasTag("mittybasket") then table.insert(actions, ACTIONS.MITTYPICK) end
end)
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.MITTYPICK, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.MITTYPICK, "doshortaction"))
