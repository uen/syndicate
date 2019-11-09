if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.crafting) then manolis.popcorn.crafting = {} end
if(!manolis.popcorn.crafting.materials) then manolis.popcorn.crafting.materials = {} end
if(!manolis.popcorn.crafting.blueprints) then manolis.popcorn.crafting.blueprints = {} end

manolis.popcorn.crafting.CreateMaterialData = function(item)
	local n = {}
	n.slot = 1
	n.name = DarkRP.getPhrase('crystal',item.name)
	n.entity = "popcorn_material"
	n.class = string.lower(item.name)
	n.value = item.value or 100
	n.type = "material"
	n.json = item.json or {}
	n.page = item.page or 1
	n.icon = "materials/"..item.name..'.png'
	n.level = 1
	n.quantity = item.quantity or 1
	return n
end

manolis.popcorn.crafting.CreateBlueprintData = function(blueprint)
	if(!blueprint) then return false end
	local n = {}
	n.slot = 1
	n.name = DarkRP.getPhrase('blueprint', blueprint.name)
	n.entity = "popcorn_blueprint"
	n.class = string.lower(blueprint.name)
	n.value = blueprint.value
	n.type = 'blueprint'
	n.page = 1
	n.icon = "misc/blueprint.png"
	n.json = blueprint
	n.level = 1
	n.quantity = 1
	return n
end

manolis.popcorn.crafting.RandomMaterial = function(sway)
	if(!sway) then sway = 0 end
	local found = {}
	for k,v in pairs(manolis.popcorn.crafting.materials) do
		if(v.forgeable) then
			table.insert(found, v)
		end
	end

	local mat = table.Random(found)
	for i=1,50 do
		local matT = table.Random(found)
		if(matT.rarity > math.Clamp(math.random(1,100)-sway, 1, 100)) then
			return manolis.popcorn.crafting.CreateMaterialData(matT)
		end
	end

	return manolis.popcorn.crafting.CreateMaterialData(mat)
end

manolis.popcorn.crafting.RandomBlueprint = function()
	local found = {}
	for k,v in pairs(manolis.popcorn.crafting.blueprints) do
		if(v.nodrop) then continue end
		table.insert(found,v)
	end

	local bp = table.Random(found)
	for i=1,50 do
		local bp = table.Random(found)
		if(bp.rarity > math.random(1,100)) then
			return manolis.popcorn.crafting.CreateBlueprintData(bp)
		end
	end

	return manolis.popcorn.crafting.CreateBlueprintData(bp)
end

manolis.popcorn.crafting.PlayerRandomBlueprint = function(ply)
	local bp = manolis.popcorn.crafting.RandomBlueprint()
	for i=1, 50 do
		local bp = manolis.popcorn.crafting.RandomBlueprint()
		local level = manolis.popcorn.items.LevelFromName(bp.name, bp.json.type)
		if(!level) then continue end
		if(level<=(ply:getDarkRPVar('level') or 1)) then
			return bp
		end
	end

	return bp
end

manolis.popcorn.crafting.MaxLevel = function(class)
	local classes = {
		{name=DarkRP.getPhrase('epic'), max=25},
		{name=DarkRP.getPhrase('elite'), max=15},
		{name=DarkRP.getPhrase('unique'), max=12},
		{name=DarkRP.getPhrase('rare'), max=10},
		{name=DarkRP.getPhrase('uncommon'), max=8},
		{name=DarkRP.getPhrase('standard'),max=5}
	}

	for k,v in pairs(classes) do
		if(v.name==class) then
			return v.max
		end
	end

	return 5
end

local failCraft = function(ply, message)
	ply.isCrafting = false
	DarkRP.notify(ply,0,4,message)
end

net.Receive("ManolisPopcornRefineUpgrades", function(len,ply)
	if(ply.isCrafting) then
		return
	end

	if(IsValid(manolis.popcorn.positions.positionSpawns['Refiner'])) then
		if(ply:GetPos():Distance(manolis.popcorn.positions.positionSpawns['Refiner']:GetPos())>250) then return end
	end

	ply.isCrafting = true
	DarkRP.notify(ply,0,4,DarkRP.getPhrase('refining'))

	local items = net.ReadTable()
	if(!items or (#items<=0)) then 
		DarkRP.notify(ply,0,4,DarkRP.getPhrase('refine_fail_items'))
		return 
	end	

	if(#items!=3) then
		failCraft(ply,DarkRP.getPhrase('refine_fail_upg'))
		return
	end

	local dupeTest = {}
	for k,v in pairs(items) do
		dupeTest[v] = true
	end

	local c = 0
	for k,v in pairs(dupeTest) do
		c = c+1
	end
	
	if(c!=#items) then
		failCraft(ply,DarkRP.getPhrase('dupe_item'))
		return
	end

	local idItems = {}
	manolis.popcorn.inventory.retrievePlayerItemData(ply,function(pitems)
		for k,v in pairs(pitems) do
			idItems[v.id] = v
		end

		for k,v in pairs(items) do
			if(!idItems[v]) then
				failCraft(ply,DarkRP.getPhrase('refine_fail_items'))
				return
			end

			if(idItems[v].type!='upgrade') then
				failCraft(ply,DarkRP.getPhrase('refine_fail_items'))
				return
			end
			if(!idItems[v].json or !idItems[v].json.type or !idItems[v].json.level) then
				failCraft(ply,DarkRP.getPhrase('refine_fail_items'))
				return
			end

			for k2,vx in pairs(items) do
				v2 = idItems[vx]
				if(!v2) then
					failCraft(ply,DarkRP.getPhrase('refine_fail_items'))
					return		
				end
				if(!v2.json or !v2.json.type or !v2.json.level) then
					failCraft(ply,DarkRP.getPhrase('refine_fail_upg'))
					return
				end

				if(v2.json.class != idItems[v].json.class) then
					failCraft(ply,DarkRP.getPhrase('refine_fail_upg'))
					return
				end
				
				if(v2.json.type!=idItems[v].json.type) then
					failCraft(ply,DarkRP.getPhrase('refine_fail_upg'))
					return
				end

				if(v2.json.level!=idItems[v].json.level) then
					failCraft(ply,DarkRP.getPhrase('refine_fail_upg'))
					return
				end
			end
		end

		if(idItems[items[1]].level>=5) then
			failCraft(ply,DarkRP.getPhrase('refine_level'))
			return
		end

		manolis.popcorn.inventory.removeItems(ply, items, function(d)
			local level = idItems[items[1]].json.level+1
			local a = idItems[items[1]]
			local item = manolis.popcorn.upgrades.FindUpgrade(a.json.type, a.json.class, level)
			if(item) then
				local i = manolis.popcorn.items.CreateItemData(item)
				manolis.popcorn.inventory.addItem(ply,i,function()
					DarkRP.notify(ply,0,4,DarkRP.getPhrase('refine_success'))
					ply:AddAchievementProgress('refiner', 1)
					ply:RefreshInventory()
					ply.isCrafting = false
					return
				end)
			end
		end)
	end)
end)

net.Receive("ManolisPopcornCraftItem", function(len,ply)
	if(ply.isCrafting) then
		return
	end

	if(IsValid(manolis.popcorn.positions.positionSpawns['Blacksmith'])) then
		if(ply:GetPos():Distance(manolis.popcorn.positions.positionSpawns['Blacksmith']:GetPos())>250) then return end
	end

	ply.isCrafting = true
	local bp = net.ReadInt(32)
	if(!bp) then return false end
	local items = net.ReadTable()

	if(!items or (#items<=0)) then 
		failCraft(ply, DarkRP.getPhrase('craft_fail'))
		return 
	end

	local dupeTest = {}
	for k,v in pairs(items) do
		dupeTest[v] = true
	end

	local c = 0
	for k,v in pairs(dupeTest) do
		c = c+1
	end

	if(c!=#items) then
		failCraft(ply,DarkRP.getPhrase('dupe_item'))
		return
	end

	local idItems = {}
	local blueprint = false
	manolis.popcorn.inventory.retrievePlayerItemData(ply, function(pitems)
		for k,v in pairs(pitems) do
			idItems[v.id] = v
		end

		if(!idItems[bp]) then 
			failCraft(ply, DarkRP.getPhrase('craft_fail_bp'))
			return 
		end
		if(idItems[bp].type!='blueprint') then
			failCraft(ply,DarkRP.getPhrase('craft_fail_bp'))
			return
		end

		local bpname = string.sub((idItems[bp].name),1,-11)
		if(!bpname) then
			failCraft(ply, DarkRP.getPhrase('craft_fail_bp'))
			return
		end

		local blueprintData = manolis.popcorn.crafting.FindBlueprint(bpname)
		if(!blueprintData) then
			failCraft(ply, DarkRP.getPhrase('craft_fail_bp'))
			return
		end

		local matsWeHave = {}
		for k,v in pairs(items) do
			if(!idItems[v]) then
				failCraft(ply,DarkRP.getPhrase('craft_fail'))
				return
			end

			if(idItems[v].type=='material') then
				idItems[v].crafted = true
				matsWeHave[string.sub(idItems[v].name,1,-(#DarkRP.getPhrase('crystal_')+2))] = (matsWeHave[string.sub(idItems[v].name,1,-(#DarkRP.getPhrase('crystal_')+2))] or 0) + idItems[v].quantity
			end
		end

		for k,v in pairs(blueprintData.materials) do
			if(matsWeHave[k]) then
				if(matsWeHave[k]<v) then
					failCraft(ply,DarkRP.getPhrase('craft_fail_item', k))
					return
				end
			else
				failCraft(ply,DarkRP.getPhrase('craft_fail_item', k))
				return
			end
		end


		local matsWeNeed = table.Copy(blueprintData.materials)

		local hasGiga = false
		for k,v in pairs(idItems) do
			if(v.crafted) then
				if(matsWeNeed[string.sub(v.name,1,-#DarkRP.getPhrase('crystal_')-2)] and matsWeNeed[string.sub(v.name,1,-9)]>0) then
					local needed = matsWeNeed[string.sub(v.name,1,-9)]
					local a = 0
					if(needed>=v.quantity) then
						v.removeTheItem = true
						a = v.quantity
					else
						v.changeQuantity = v.quantity - matsWeNeed[string.sub(v.name,1,-9)]
						a = matsWeNeed[string.sub(v.name,1,-9)]
					end
					matsWeNeed[string.sub(v.name,1,-9)] = matsWeNeed[string.sub(v.name,1,-9)]-v.quantity
				end
				if(string.sub(v.name,1,-(#DarkRP.getPhrase('crystal_')+2))==DarkRP.getPhrase('carbon_giga')) then
					if(!hasGiga) then 
						hasGiga = k
						v.changeQuantity = v.quantity-1
					end
				end
			end
		end

		local toDo = function(ply, c)
			ply.toDoCraft = (ply.toDoCraft or 0) - 1
			if(ply.toDoCraft<=0) then
				ply.isCrafting = false
				if(blueprintData.type=='weapon') then
					local item = manolis.popcorn.items.FindWeapon(blueprintData.name)
					if(item) then
						item.json = manolis.popcorn.weapons.CreateWeaponData(ply, item, hasGiga)
						local i = manolis.popcorn.items.CreateItemData(item)
						if(ply.syndicateCreditShop.hasCraftersHandbook) then
							local credit = manolis.popcorn.creditShop.findItem('crafters')
							if(credit) then
								if(math.random()<=(credit.affectLevels[ply.syndicateCreditShop.hasCraftersHandbook]/100)) then
									i.type='side'
								end
							end
						end
						manolis.popcorn.inventory.addItem(ply,i,function()
							DarkRP.notify(ply,0,4,DarkRP.getPhrase('craft_success'))
							
							ply:AddAchievementProgress('crafter', 1)
							ply:AddAchievementProgress('craft2', 1)
							ply:RefreshInventory()
							ply.isCrafting = false
						end)
					end
				end

				if(blueprintData.type=='armor') then
					local item = manolis.popcorn.items.FindArmor(blueprintData.name)
					if(item) then
						item.json = manolis.popcorn.armor.CreateArmorData(ply, item)
						item.json.base = manolis.popcorn.armor.CreateBase(item,item.json.base or {})
						local i = manolis.popcorn.items.CreateItemData(item)
						manolis.popcorn.inventory.addItem(ply,i,function()
							DarkRP.notify(ply,0,4,DarkRP.getPhrase('craft_success'))
							ply:AddAchievementProgress('crafter', 1)
							ply:AddAchievementProgress('craft2', 1)
							ply:RefreshInventory()
							ply.isCrafting = false
						end)
					end
				end

				if(blueprintData.type=='car') then
					manolis.popcorn.garage.HasCar(ply,blueprintData.name, function(l)
						if(!l) then
							
							ply:RefreshInventory()
							manolis.popcorn.garage.AddCar(ply,blueprintData.name, function(a)
								DarkRP.notify(ply,0,4,DarkRP.getPhrase('craft_success'))
								ply:AddAchievementProgress('crafter', 1)
								ply:AddAchievementProgress('craft2', 1)
								ply:AddAchievementProgress('mechanic', 1)
								ply:RefreshGarage()
								ply.isCrafting = false
							end)
						else
							DarkRP.notify(ply,0,4,DarkRP.getPhrase('craft_success'))
							ply:AddAchievementProgress('crafter', 1)
							ply:AddAchievementProgress('craft2', 1)
							ply:AddAchievementProgress('mechanic', 1)
							ply.isCrafting = false

							ply:RefreshInventory()
						end
					end)
				end

				if(blueprintData.type=='weaponupgrade') then
					local types = {}
					for k,v in pairs(manolis.popcorn.upgrades.upgrades['weapon']) do
						table.insert(types,v.class)
					end

					local level = math.random(1,3)
					if( (!hasGiga and (level==3 and math.random(1,5)>1)) or (hasGiga and (level==3 and math.random(1,3)==1))) then
						level = 2
					end

					local item = manolis.popcorn.upgrades.FindUpgrade('weapon', table.Random(types), level)
					if(item) then
						local i = manolis.popcorn.items.CreateItemData(item)
						manolis.popcorn.inventory.addItem(ply,i,function()
							DarkRP.notify(ply,0,4,DarkRP.getPhrase('craft_success'))
							ply:AddAchievementProgress('crafter', 1)
							ply:AddAchievementProgress('craft2', 1)
							ply:RefreshInventory()
							ply.isCrafting = false
						end)						
					end
				end

				if(blueprintData.type=='armorupgrade') then
					local types = {}
					for k,v in pairs(manolis.popcorn.upgrades.upgrades['armor']) do
						table.insert(types,v.class)
					end
					local level = math.random(1,3)
					if(level==3 and (!math.random(1,6)==6)) then
						level = 2
					end

					local item = manolis.popcorn.upgrades.FindUpgrade('armor', table.Random(types), level)
					if(item) then
						local i = manolis.popcorn.items.CreateItemData(item)
						manolis.popcorn.inventory.addItem(ply,i,function()
							DarkRP.notify(ply,0,4,DarkRP.getPhrase('craft_success'))
							ply:AddAchievementProgress('crafter', 1)
							ply:AddAchievementProgress('craft2', 1)
							ply:RefreshInventory()
							ply.isCrafting = false
						end)						
					end
				end 
			end
		end


		for k,v in pairs(idItems) do
			if(v.removeTheItem) then
				ply.toDoCraft = (ply.toDoCraft or 0) + 1
				manolis.popcorn.inventory.removeItem(ply,v.id, function()
					toDo(ply)
				end)
			elseif(v.changeQuantity) then
				ply.toDoCraft = (ply.toDoCraft or 0) + 1
				manolis.popcorn.inventory.setQuantity(ply, v.id, v.changeQuantity, function()
					toDo(ply)
				end)

			end
		end

		if(hasGiga) then
			manolis.popcorn.inventory.removeItem(ply,hasGiga)
		end

		ply.toDoCraft = (ply.toDoCraft or 0) + 1
		manolis.popcorn.inventory.removeItem(ply,bp, function()
			toDo(ply)
		end)


	end)
end)