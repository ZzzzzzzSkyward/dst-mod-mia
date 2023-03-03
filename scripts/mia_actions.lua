-- componentaction is right
local function init()
    local modname = env.modname
    local actions, componentactions = dig("actions_def")
    for k, v in pairs(componentactions) do
        if v.type == "POINT" then
            AddPlayerPostInit(function(inst)
                if inst.prefab ~= k then return end
                inst:ListenForEvent("playeractivated", function(inst)
                    if inst == ThePlayer then
                        local ac = inst.components.playeractionpicker
                        if not ac then return end
                        local old = ac.pointspecialactionsfn
                        if not old then
                            ac.pointspecialactionsfn = v.fn
                        else
                            ac.pointspecialactionsfn = function(...)
                                return ArrayUnion(old(...), v.fn(...))
                            end
                        end
                    end
                end)
            end)
        else
            AddComponentAction(v.type, k, v.fn, modname)
        end
    end
    -- here we skirt around modutil
    for id, action in pairs(actions) do
        action.mod_name = modname
        action.id = id
        ACTIONS[id] = action
        if ACTION_MOD_IDS[modname] == nil then ACTION_MOD_IDS[modname] = {} end
        table.insert(ACTION_MOD_IDS[modname], action.id)
        action.code = #ACTION_MOD_IDS[modname]
        if MOD_ACTIONS_BY_ACTION_CODE[modname] == nil then MOD_ACTIONS_BY_ACTION_CODE[modname] = {} end
        MOD_ACTIONS_BY_ACTION_CODE[modname][action.code] = action
        -- only to comment this line!
        -- STRINGS.ACTIONS[action.id] = action.str
    end
end
init()
