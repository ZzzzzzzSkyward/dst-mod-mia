AddStategraphEvent("wilson", EventHandler("redirect_locomote", function(inst, data)
    inst.sg:GoToState("dodge", data)
end))
local fns = dig("common_physics")
local vel = {20, 0, 0}
AddStategraphState("wilson", State {
    name = "dodge",
    tags = {"busy", "evade", "no_stun", "canrotate"},

    onenter = function(inst, data)
        inst.sg.statemem.isphysicstoggle = true
        inst.components.locomotor:Stop()
        if data and data.pos then
            local pos = data.pos:GetPosition()
            inst:ForceFacePoint(pos.x, 0, pos.z)
        end

        inst.AnimState:PlayAnimation("slide_pre")

        inst.AnimState:PushAnimation("slide_loop")
        if not inst._nosoundwhendodge then
            inst.SoundEmitter:PlaySound("hamletcharactersound/characters/wheeler/slide")
        end
        inst.Physics:SetMotorVelOverride(unpack(vel))
        fns.MakeCharacterPassThrough(inst)
        inst.components.locomotor:EnableGroundSpeedMultiplier(false)
        if not inst._dodgenotinvincible then
            inst.was_invincible = inst.components.health.invincible
            inst.components.health:SetInvincible(true)
        end
        inst.last_dodge_time = GetTime()
        if inst.dodgetime then inst.dodgetime:set(inst.dodgetime:value() == false and true or false) end

        if inst.components.playercontroller ~= nil then inst.components.playercontroller:RemotePausePrediction() end
        inst.sg:SetTimeout(0.25)
    end,

    ontimeout = function(inst)
        inst.sg:GoToState("dodge_pst")
    end,

    onexit = function(inst)
        inst.sg.statemem.isphysicstoggle = nil
        inst.Physics:ClearMotorVelOverride()
        inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        fns.MakeCharacterNoPassThrough(inst)
        -- inst.components.locomotor:Stop()

        inst.components.locomotor:SetBufferedAction(nil)
        if not inst._dodgenotinvincible then
            if not inst.was_invincible then inst.components.health:SetInvincible(false) end
            inst.was_invincible = nil
        end
    end
})

AddStategraphState("wilson", State {
    name = "dodge_pst",
    tags = {"evade", "no_stun"},

    onenter = function(inst)
        inst.AnimState:PlayAnimation("slide_pst")
        -- inst.Physics:SetMotorVel(unpack(vel))
    end,

    events = {
        EventHandler("animover", function(inst)
            inst.sg:GoToState("idle")
        end)
    }
})

AddStategraphState("wilson_client", State {
    name = "dodge",
    tags = {"busy", "evade", "no_stun", "canrotate"},

    onenter = function(inst, data)
        inst.entity:SetIsPredictingMovement(false)
        if data and data.pos then
            local pos = data.pos:GetPosition()
            inst:ForceFacePoint(pos.x, 0, pos.z)
        end

        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("slide_pre")
        inst.AnimState:PushAnimation("slide_loop", false)

        inst.components.locomotor:EnableGroundSpeedMultiplier(false)

        inst.last_dodge_time = GetTime()
        inst.dodgetime:set(inst.dodgetime:value() == false and true or false)
        inst:PerformPreviewBufferedAction()
        inst.sg:SetTimeout(2)
    end,

    onupdate = function(inst)
        if inst:HasTag("working") then
            if inst.entity:FlattenMovementPrediction() then inst.sg:GoToState("idle", "noanim") end
        elseif inst.bufferedaction == nil then
            inst.sg:GoToState("idle")
        end
    end,

    ontimeout = function(inst)
        inst:ClearBufferedAction()
        inst.sg:GoToState("idle")
    end,

    onexit = function(inst)
        inst.entity:SetIsPredictingMovement(true)
    end
})
