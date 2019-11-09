AddCSLuaFile()

if CLIENT then
	-- clientsidemodel manager, taken from CW 2.0
	-- removes clientside models that have lost references to their weapon objects since they're not garbage collected anymore (wtf)

	FASCModelManager = {}
	FASCModelManager.curModels = {}

	function FASCModelManager:add(model, wep)
		model.wepParent = wep
		self.curModels[#self.curModels + 1] = model
	end

	function FASCModelManager:validate()
		local removalIndex = 1 -- increment the removalIndex value every time we don't remove an index, since table.remove reorganizes the table
		
		for i = 1, #self.curModels do
			local cmodel = self.curModels[removalIndex]
			
			if not IsValid(cmodel.wepParent) then
				SafeRemoveEntity(cmodel)
				table.remove(self.curModels, removalIndex)
			else
				removalIndex = removalIndex + 1
			end
		end
	end

	timer.Create("FA:S 2.0 CModel Manager", 5, 0, function()
		FASCModelManager:validate()
	end)
end