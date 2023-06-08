local shaders = {
  INSCINERATOR_CENTER = {
    path = "shaders/mia_inscinerator_glow.ksh",
    -- 变量: x,y,radius
    params = 3,
    after = "Lunacy"
  },
  INSCINERATOR_TIME = {
    path = "shaders/mia_inscinerator_ember.ksh",
    -- 变量: t
    params = 2,
    after = "INSCINERATOR_CENTER"
  }
}
AddModShadersInit(function()
  for k, v in pairs(shaders) do
    UniformVariables[k] = PostProcessor:AddUniformVariable(k, v.params)
    local path = resolvefilepath(v.path)
    PostProcessorEffects[k] = PostProcessor:AddPostProcessEffect(path)
    PostProcessor:SetEffectUniformVariables(PostProcessorEffects[k], UniformVariables[k])
  end
end)
AddModShadersSortAndEnable(function()
  for k, v in pairs(shaders) do
    if v.after then PostProcessor:SetPostProcessEffectAfter(PostProcessorEffects[k], PostProcessorEffects[v.after]) end
    PostProcessor:EnablePostProcessEffect(PostProcessorEffects[k], false)
    local zeros = {}
    for i = 1, v.params do zeros[i] = 0 end
    PostProcessor:SetUniformVariable(UniformVariables[k], unpack(zeros))
  end
end)
--[[
  AddPlayerPostInit(function(inst)
    inst:DoPeriodicTask(0.3, function()
      local x, y, z = TheInput:GetScreenPosition():Get()
      local w, h = TheSim:GetScreenSize()
      PostProcessor:SetUniformVariable(UniformVariables.INSCINERATOR_CENTER, x, y, 1)
    end)
  end)
  ]]
