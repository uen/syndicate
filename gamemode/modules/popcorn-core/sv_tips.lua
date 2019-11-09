local tips = {}
local newTip = function(tip)
	table.insert(tips, tip)
end

newTip("Press F4 to view the action menu")
newTip("Press F1 to view the server rules")
newTip("Reinforcement stones upgrade your armor and weapons")
newTip("Carbon Giga Crystals increase your crafting luck")
newTip("Police officers can inspect the evidence of murders and arrest suspects")
newTip("Hold shift to split crafting materials")

timer.Create("tips", 90, 0, function()
	for k,v in pairs(player.GetAll()) do
		DarkRP.notify(v,0,5,table.Random(tips))
	end
end)