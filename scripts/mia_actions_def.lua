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
        distance = 40,
        fn = function(act, data)
            local doer = act.doer
            dumptable(act, 1, 2)
            dumptable(data, 1, 2)
            -- doer.inscinerator.components.aoeprojectile:Launch()
            doer.inscinerator.components.aoetargeting:StopTargeting()
        end
    },
    AOEPROJECTILE = {
        str = "AOEPROJECTILE",
        instant = true,
        distance = 40,
        fn = function(act)
            local doer = act.doer
            dumptable(act, 1, 2)
            doer.inscinerator.components.aoetargeting:StartTargeting()
        end
    },
    CANCELAOEPROJECTILE = {
        str = "CANCELAOEPROJECTILE",
        instant = true,
        distance = 40,
        fn = function(act, data)
            local doer = act.doer
            dumptable(act, 1, 2)
            dumptable(data, 1, 2)
            doer.inscinerator.components.aoetargeting:StopTargeting()
        end
    }
}, {
    {
        type = "POINT",
        str = "发射",
        fn = function(inst, pos, useitem, right)
            if not inst.inscinerator then return empty end
            if useitem then return empty end
            if inst:HasTag("playerghost") then return empty end
            -- #TODO filter out other circumstances
            local hasequip = HasEquip(inst)
            if hasequip then return empty end
            local active = inst.inscinerator.components.reticule ~= nil
            if active and right then return {ACTIONS.CANCELAOEPROJECTILE} end
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
