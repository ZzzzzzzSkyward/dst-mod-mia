local empty = {}
local function HasEquip(inst)
    if inst.replica.inventory then return inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil end
    return true
end
return {
    -- hamlet dodge
    DODGE = {
        str = "Dodge",
        fn = function(act, data)
            act.doer:PushEvent("redirect_locomote", {pos = act.pos or Vector3(act.target.Transform:GetWorldPosition())})
            return true
        end,
        distance = math.huge,
        instant = true
    },
    -- #FIXME once relicinventory is established, change these things to usepointwiserelicitem
    LAUNCHAOEPROJECTILE = {
        str = "LAUNCHAOEPROJECTILE",
        instant = true,
        canforce = true,
        priority = 1,
        distance = 40,
        pre_action_cb = function(act)
            local doer = act.doer
            return doer.inscinerator.components.aoetargeting:StopTargeting()
        end,
        fn = function(act)
            print("launch!")
            -- #FIXME
            local doer = act.doer
            doer.inscinerator.components.aoetargeting:StopTargeting()
            return doer.inscinerator.components.aoeprojectile:Launch({pos = act.pos, target = act.target})
        end
    },
    AOEPROJECTILE = {
        str = "AOEPROJECTILE",
        instant = true,
        rmb = true,
        priority = -3,
        paused_valid = true,
        distance = 40,
        pre_action_cb = function(act)
            local doer = act.doer
            return doer.inscinerator.components.aoetargeting:StartTargeting()
        end,
        fn = function(act)
            local doer = act.doer
            return doer.inscinerator.components.aoetargeting:StartTargeting()
        end
    },
    CANCELAOEPROJECTILE = {
        str = "CANCELAOEPROJECTILE",
        instant = true,
        paused_valid = true,
        canforce = true,
        rmb = true,
        encumbered_valid = true,
        mount_valid = true,
        priority = -3,
        distance = 40,
        pre_action_cb = function(act)
            local doer = act.doer
            return doer.inscinerator.components.aoetargeting:StopTargeting()
        end,
        fn = function(act)
            local doer = act.doer
            return doer.inscinerator.components.aoetargeting:StopTargeting()
        end
    }
}, {
    _reg = {
        type = "POINT",
        str = "发射",
        fn = function(inst, pos, useitem, right)
            if not inst.inscinerator then return empty end
            local active = inst.inscinerator.components.reticule ~= nil
            if active and right then return {ACTIONS.CANCELAOEPROJECTILE} end
            if useitem then return empty end
            if inst:HasTag("playerghost") then return empty end
            -- #TODO filter out other circumstances
            local hasequip = HasEquip(inst)
            if hasequip then return empty end
            if not active and right and not inst.inscinerator:HasTag("inscinerator_depleted") then
                return {ACTIONS.AOEPROJECTILE}
            end
            if active and not right and not inst.inscinerator:HasTag("inscinerator_depleted") then
                return {ACTIONS.LAUNCHAOEPROJECTILE}
            end
            return empty
        end
    }
}
