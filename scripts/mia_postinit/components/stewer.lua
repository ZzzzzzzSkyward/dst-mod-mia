function Stewer:StartCooking(doer)
    if self.targettime == nil and self.inst.components.container ~= nil then
		self.chef_id = (doer ~= nil and doer.player_classified ~= nil) and doer.userid
		self.ingredient_prefabs = {}

        self.done = nil
        self.spoiltime = nil

        if self.onstartcooking ~= nil then
            self.onstartcooking(self.inst)
        end

		for k, v in pairs (self.inst.components.container.slots) do
			table.insert(self.ingredient_prefabs, v.prefab)
		end

        local cooktime = 1
        self.product, cooktime = cooking.CalculateRecipe(self.inst.prefab, self.ingredient_prefabs)
        local productperishtime = cooking.GetRecipe(self.inst.prefab, self.product).perishtime or 0

        if productperishtime > 0 then
			local spoilage_total = 0
			local spoilage_n = 0
			for k, v in pairs (self.inst.components.container.slots) do
				if v.components.perishable ~= nil then
					spoilage_n = spoilage_n + 1
					spoilage_total = spoilage_total + v.components.perishable:GetPercent()
				end
			end
            self.product_spoilage =
                (spoilage_n <= 0 and 1) or
                (self.keepspoilage and spoilage_total / spoilage_n) or
                1 - (1 - spoilage_total / spoilage_n) * .5
		else
			self.product_spoilage = nil
		end

        cooktime = TUNING.BASE_COOK_TIME * cooktime * self.cooktimemult
        self.targettime = GetTime() + cooktime
        if self.task ~= nil then
            self.task:Cancel()
        end
        self.task = self.inst:DoTaskInTime(cooktime, dostew, self)

        self.inst.components.container:Close()
        self.inst.components.container:DestroyContents()
        self.inst.components.container.canbeopened = false
    end
end