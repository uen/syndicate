if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.don) then manolis.popcorn.don = {} end

local gifts = {}
concommand.Add("ManolisPopcornDoDon", function(ply,cmd,args)
	if(ply.LastDonUse and ply.LastDonUse > CurTime()-2) then 
		return
	end

	ply.LastDonUse = CurTime()

	if(!IsValid(ply)) then return end
	if(!args[1]) then return false end
	local gift = manolis.popcorn.don.GetGiftByKey(tonumber(math.Round(args[1])))

	if gift then
		if (!manolis.popcorn.levels.HasLevel(ply,gift.min) or manolis.popcorn.levels.GetLevel(ply)>gift.max) then
			DarkRP.notify(ply,1,4,DarkRP.getPhrase('wrong_don_level'))
			return
		end

		if(!ply:canAfford(gift.price)) then
			DarkRP.notify(ply,1,4,DarkRP.getPhrase('afford_don'))
			return
		end

		manolis.popcorn.don.HasGift(ply, manolis.popcorn.config.hashFunc(gift.name), function(data)
			if(data) then
				DarkRP.notify(ply,1,4,DarkRP.getPhrase('don_receives'))
				return
			end

			manolis.popcorn.inventory.getFreeSlots(ply, function(amount)
				if(amount<gift.slots) then
					DarkRP.notify(ply,1,4,DarkRP.getPhrase('don_inv'))
					return
				end

				manolis.popcorn.don.AddAcceptedGift(ply,manolis.popcorn.config.hashFunc(gift.name), function()
					ply:addMoney(-gift.price)
					DarkRP.notify(ply,0,4,DarkRP.getPhrase('don_suc'))
					if(gifts[manolis.popcorn.config.hashFunc(gift.name)]) then
						gifts[manolis.popcorn.config.hashFunc(gift.name)](ply)

						timer.Simple(3, function()
							ply:RefreshInventory()
						end)
					end
				end)
			end)


		end)
	end
end)

gifts[manolis.popcorn.config.hashFunc(DarkRP.getPhrase('don_gift_beginners'))] = function(ply)
	local bp = manolis.popcorn.crafting.FindBlueprint(DarkRP.getPhrase('rusty_mac10'))
	if(bp) then manolis.popcorn.inventory.addItem(ply,manolis.popcorn.crafting.CreateBlueprintData(bp)) end

	local mats = {
		rein_stone = 1,
		obsidian   = 10,
		amber      = 5,
		calcite    = 5,
		bloodstone = 5
	}

	for k,v in pairs(mats) do
		local mat = manolis.popcorn.crafting.FindMaterial(DarkRP.getPhrase(k))
		if(mat) then
			local mat = manolis.popcorn.crafting.CreateMaterialData(mat)
			mat.quantity = v
			manolis.popcorn.inventory.addItem(ply,mat)
		end
	end
end

gifts[manolis.popcorn.config.hashFunc(DarkRP.getPhrase('don_gift_beginnerpack'))] = function(ply)
	local bp = manolis.popcorn.crafting.FindBlueprint(DarkRP.getPhrase('mac10'))
	if(bp) then manolis.popcorn.inventory.addItem(ply,manolis.popcorn.crafting.CreateBlueprintData(bp)) end

	local bp = manolis.popcorn.crafting.FindBlueprint(DarkRP.getPhrase('mp5'))
	if(bp) then manolis.popcorn.inventory.addItem(ply,manolis.popcorn.crafting.CreateBlueprintData(bp)) end

	local mats = {
		rein_stone = 5,
		obsidian   = 10,
		amber      = 5,
		bloodstone = 5
	}

	for k,v in pairs(mats) do
		local mat = manolis.popcorn.crafting.FindMaterial(DarkRP.getPhrase(k))
		if(mat) then
			local mat = manolis.popcorn.crafting.CreateMaterialData(mat)
			mat.quantity = v
			manolis.popcorn.inventory.addItem(ply,mat)
		end
	end
end


gifts[manolis.popcorn.config.hashFunc(DarkRP.getPhrase('don_gift_beginnersarmor'))] = function(ply)
	local bp = manolis.popcorn.crafting.FindBlueprint(DarkRP.getPhrase('grey_beanie'))
	if(bp) then manolis.popcorn.inventory.addItem(ply,manolis.popcorn.crafting.CreateBlueprintData(bp)) end	

	local bp = manolis.popcorn.crafting.FindBlueprint(DarkRP.getPhrase('rebel_jacket'))
	if(bp) then manolis.popcorn.inventory.addItem(ply,manolis.popcorn.crafting.CreateBlueprintData(bp)) end	

	local bp = manolis.popcorn.crafting.FindBlueprint(DarkRP.getPhrase('rebel_pants'))
	if(bp) then manolis.popcorn.inventory.addItem(ply,manolis.popcorn.crafting.CreateBlueprintData(bp)) end	

	local bp = manolis.popcorn.crafting.FindBlueprint(DarkRP.getPhrase('combat_gloves'))
	if(bp) then manolis.popcorn.inventory.addItem(ply,manolis.popcorn.crafting.CreateBlueprintData(bp)) end	

	local bp = manolis.popcorn.crafting.FindBlueprint(DarkRP.getPhrase('m3'))
	if(bp) then manolis.popcorn.inventory.addItem(ply,manolis.popcorn.crafting.CreateBlueprintData(bp)) end	
end


gifts[manolis.popcorn.config.hashFunc(DarkRP.getPhrase('don_gift_gang'))] = function(ply)
	local bp = manolis.popcorn.crafting.FindBlueprint(DarkRP.getPhrase('famas'))
	if(bp) then manolis.popcorn.inventory.addItem(ply,manolis.popcorn.crafting.CreateBlueprintData(bp)) end

	local bp = manolis.popcorn.crafting.FindBlueprint(DarkRP.getPhrase('cf05'))
	if(bp) then manolis.popcorn.inventory.addItem(ply,manolis.popcorn.crafting.CreateBlueprintData(bp)) end

	local bp = manolis.popcorn.crafting.FindBlueprint(DarkRP.getPhrase('mp9'))
	if(bp) then manolis.popcorn.inventory.addItem(ply,manolis.popcorn.crafting.CreateBlueprintData(bp)) end

	local mats = {
		rein_stone = 5,
	}

	for k,v in pairs(mats) do
		local mat = manolis.popcorn.crafting.FindMaterial(DarkRP.getPhrase(k))
		if(mat) then
			local mat = manolis.popcorn.crafting.CreateMaterialData(mat)
			mat.quantity = v
			manolis.popcorn.inventory.addItem(ply,mat)
		end
	end
end

gifts[manolis.popcorn.config.hashFunc(DarkRP.getPhrase('don_gift_power'))] = function(ply)
	local bp = manolis.popcorn.crafting.FindBlueprint(DarkRP.getPhrase('scout'))
	if(bp) then manolis.popcorn.inventory.addItem(ply,manolis.popcorn.crafting.CreateBlueprintData(bp)) end

	local bp = manolis.popcorn.crafting.FindBlueprint(DarkRP.getPhrase('winchester'))
	if(bp) then manolis.popcorn.inventory.addItem(ply,manolis.popcorn.crafting.CreateBlueprintData(bp)) end

	local mats = {
		rein_stone = 10,
	}

	for k,v in pairs(mats) do
		local mat = manolis.popcorn.crafting.FindMaterial(DarkRP.getPhrase(k))
		if(mat) then
			local mat = manolis.popcorn.crafting.CreateMaterialData(mat)
			mat.quantity = v
			manolis.popcorn.inventory.addItem(ply,mat)
		end
	end
end

gifts[manolis.popcorn.config.hashFunc(DarkRP.getPhrase('don_gift_criminal'))] = function(ply)
	local mats = {
		carbon_giga = 10,
	}

	for k,v in pairs(mats) do
		local mat = manolis.popcorn.crafting.FindMaterial(DarkRP.getPhrase(k))
		if(mat) then
			local mat = manolis.popcorn.crafting.CreateMaterialData(mat)
			mat.quantity = v
			manolis.popcorn.inventory.addItem(ply,mat)
		end
	end
end

gifts[manolis.popcorn.config.hashFunc(DarkRP.getPhrase('don_gift_a', DarkRP.getPhrase('don_gift_basic'), DarkRP.getPhrase('upgrade_weapon')))] = function(ply)
	local bps = manolis.popcorn.crafting.FindBlueprint(DarkRP.getPhrase('upgrade_b',DarkRP.getPhrase('upgrade_weapon')))
	if(bps) then
		for i=1, 5 do
			manolis.popcorn.inventory.addItem(ply,manolis.popcorn.crafting.CreateBlueprintData(bps))
		end
	end
end


gifts[manolis.popcorn.config.hashFunc(DarkRP.getPhrase('don_gift_a', DarkRP.getPhrase('don_gift_basic'), DarkRP.getPhrase('upgrade_armor')))] = function(ply)
	local bps = manolis.popcorn.crafting.FindBlueprint(DarkRP.getPhrase('upgrade_b',DarkRP.getPhrase('upgrade_armor')))
	if(bps) then
		for i=1, 5 do
			manolis.popcorn.inventory.addItem(ply,manolis.popcorn.crafting.CreateBlueprintData(bps))
		end
	end
end

gifts[manolis.popcorn.config.hashFunc(DarkRP.getPhrase('don_gift_a', DarkRP.getPhrase('don_gift_advanced'), DarkRP.getPhrase('upgrade_weapon')))] = function(ply)
	local bps = manolis.popcorn.crafting.FindBlueprint(DarkRP.getPhrase('upgrade_b',DarkRP.getPhrase('upgrade_weapon')))
	if(bps) then
		for i=1, 10 do
			manolis.popcorn.inventory.addItem(ply,manolis.popcorn.crafting.CreateBlueprintData(bps))
		end
	end
end


gifts[manolis.popcorn.config.hashFunc(DarkRP.getPhrase('don_gift_a', DarkRP.getPhrase('don_gift_advanced'), DarkRP.getPhrase('upgrade_armor')))] = function(ply)
	local bps = manolis.popcorn.crafting.FindBlueprint(DarkRP.getPhrase('upgrade_b',DarkRP.getPhrase('upgrade_armor')))
	if(bps) then
		for i=1, 10 do
			manolis.popcorn.inventory.addItem(ply,manolis.popcorn.crafting.CreateBlueprintData(bps))
		end
	end
end

manolis.popcorn.gif = gifts