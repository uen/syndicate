if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.inventory) then manolis.popcorn.inventory = {} end

resource.AddSingleFile('materials/manolis/popcorn/inventoryclose.png')

manolis.popcorn.inventory.retrievePlayerItemData = function(ply, callback)
	if(manolis.popcorn.inventory.retrievePlayerItems) then
		manolis.popcorn.inventory.retrievePlayerItems(ply,function(data)
			if(!data) then data = {} end
			if not IsValid(ply) then return end
			callback(data)
		end)
	end
end

manolis.popcorn.inventory.getFreeSlots = function(ply, callback)
	manolis.popcorn.inventory.retrievePlayerItems(ply, function(data)
		if(!data) then data = {} end
		callback((4*20)-#data or 0)
	end)
end

manolis.popcorn.inventory.retrieveItem = function(ply,id,callback)
	manolis.popcorn.inventory.retrieveSingleItemData(ply, id, function(data)
		if(data) then
			callback(data)
		else
			callback(false)
		end
	end)
end

manolis.popcorn.inventory.getFreePageSlot = function(ply,page,callback)
	manolis.popcorn.inventory.retrievePageItemsData(ply,page,function(data)
		if(!data or !data[1]) then return callback(1) end
		local temp = {}
		for k,v in pairs(data) do
			temp[math.Round(tonumber(v.slot))] = v	
		end

		for p=1, 20 do
			if(!temp[p]) then return callback(p) end
		end 

		return callback(false)
	end)
end

manolis.popcorn.inventory.getFreeSlot = function(ply,callback)
	manolis.popcorn.inventory.retrievePlayerItemData(ply,function(data)
		if(!data or !data[1]) then return callback(1,1) end

		local temp = {}
		for p=1,4 do
			temp[p] = {}
		end

		for k,v in pairs(data) do
			v.page,v.slot = tonumber(v.page),tonumber(v.slot)
			if(temp[v.page]) then 
				temp[v.page][v.slot] = true
			end
		end

		for pa=1, 4 do
			for ia=1, 20 do
				if(!temp[pa][ia]) then
					return callback(pa,ia)
				end
			end
		end

		return callback(false)
	end)
end

manolis.popcorn.inventory.isSlotFree = function(ply,page,slot,callback)
	manolis.popcorn.inventory.isSlotFreeData(ply,page,slot,function(data)
		if(!data) then return callback(true) end
		return callback(false)
	end)
end

manolis.popcorn.inventory.changeItemSlot = function (ply,id,slot,callback)
	manolis.popcorn.inventory.retrieveItem(ply,id,function(item)
		if(item) then
			manolis.popcorn.inventory.isSlotFree(ply,item.page,slot,function(slotFree)
				if(!slotFree) then return false end
				manolis.popcorn.inventory.moveInventoryItemData(ply,item.id,item.page,slot, function(data)
					if(callback) then callback() end
				end)
			end)
		end
	end)
end

manolis.popcorn.inventory.changeItemPage = function(ply,id,page,callback)
	manolis.popcorn.inventory.retrieveItem(ply,id,function(item)
		if(item) then
			manolis.popcorn.inventory.getFreePageSlot(ply,page,function(slot)
				if(!slot) then
					ply:RefreshInventory(item.page)
					return false 
				end
				manolis.popcorn.inventory.moveInventoryItemData(ply,item.id,page,slot, function(data)
					ply:RefreshInventory(page)
					if(callback) then callback() end
				end)
			end)
		end
	end)
end


local sendInventoryRefresh = function(ply, items)
	if(!(ply.lastInventoryRefresh>(CurTime()+.1))) then
		ply.lastInventoryRefresh = CurTime()

		net.Start('ManolisPopcornInventoryFullRefresh')
			net.WriteTable(items)
		net.Send(ply)

	end
end

local sendPartialInventoryRefresh = function(ply,page,items)
	net.Start('ManolisPopcornInventoryPartialRefresh')
		net.WriteTable(items)
		net.WriteInt(page,32)
	net.Send(ply)	
end

concommand.Add("ManolisPopcornUseItem", function(ply, cmd, args)
	if(!args[1] or !tonumber(args[1])) then return false end
	manolis.popcorn.inventory.retrieveSingleItemData(ply, args[1], function(item)
		if(!item) then return end
		if(item.type=='credit_item') then
			if(manolis.popcorn.creditShop) then
				manolis.popcorn.creditShop.useItem(ply, item)
			end
		else
			DarkRP.notify(ply,1,4,"You cannot use this")
		end
	end)
end)

concommand.Add("ManolisPopcornChangeItemSlot", function(ply, cmd, args)
	if(!args[1] or !args[2]) then return false end
	if(!tonumber(args[2])) then return false end
	if(!tonumber(args[1])) then return false end
	args[1] = math.floor(tonumber(args[1]))
	args[2] = math.floor(tonumber(args[2]))

	if((args[2] and tonumber(args[2]) and tonumber(args[2])>20 and tonumber(args[2])<=0)) then return false end
	manolis.popcorn.inventory.changeItemSlot(ply,args[1], tonumber(args[2]))
end)

concommand.Add("ManolisPopcornDropItem", function(ply, cmd, args)
	if(!args[1] or !tonumber(args[1])) then return false end 
	args[1] = math.floor(tonumber(args[1]))
	if(ply.isCrafting) then return end
	ply.isCrafting = true

	local id = args[1]
	manolis.popcorn.inventory.retrieveSingleItemData(ply,id,function(item)
		if(item) then
			if(ply.isTrading) then
				ply.isCrafting = false
				DarkRP.notify(ply,1,4,DarkRP.getPhrase('drop_trade_fail'))
				return
			end

			if(item.type=='armor') then
				ply.isCrafting = false
				DarkRP.notify(ply,1,4,DarkRP.getPhrase('drop_armor'))
				return
			end
					
			if(!manolis.popcorn.items.spawnableTypes[item.type]) then
				ply.isCrafting = false
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("drop_fail"))	
				return
			end
			
			manolis.popcorn.inventory.removeItem(ply,id,function(data)
				local ent = manolis.popcorn.items.SpawnItem(ply, item, function(a)
					ply:RefreshInventory(item.page)
				end)
				ply.isCrafting = false
			end)
		else
			ply.isCrafting = false
		end
	end)
end)

concommand.Add("ManolisPopcornSellItem", function(ply,cmd,args)
	if(!args[1] or !tonumber(args[1])) then return false end 
	args[1] = math.floor(tonumber(args[1]))
	manolis.popcorn.inventory.sellItemCheck(ply,args[1],function(item)
		manolis.popcorn.inventory.removeItem(ply, item.id, function()
			DarkRP.notify(ply,0,4,DarkRP.getPhrase('inventory_sold', item.name, DarkRP.formatMoney(math.floor((item.value/100)*item.quantity))))
			ply:addMoney(math.floor(((item.value/100)*item.quantity)))
		end)
	end)
end)

concommand.Add("ManolisPopcornSplitItem", function(ply,cmd,args)
	if(ply.sQueDoing) then return end
	if(ply.isCrafting) then return end
	if(!args[1] or !args[2] or !args[3] or !args[4]) then return false end

	if(!tonumber(args[1]) or !tonumber(args[2]) or !tonumber(args[3]) or !tonumber(args[4])) then 
		DarkRP.notify(ply,1,4,DarkRP.getPhrase('invalid_args'))
		return
	end	

	args[1] = math.floor(args[1]) // id
	args[2] = math.floor(args[2]) // amount
	args[3] = math.floor(args[3]) // newslot
	args[4] = math.floor(args[4]) // page

	if(args[3]>20 or args[3]<=0) then return false end
	if(args[2]<=0) then return false end
	manolis.popcorn.inventory.retrieveItem(ply,args[1],function(data)
		if(!data) then return end
		if(data.quantity<=args[2]) then
			return	
		else
			manolis.popcorn.inventory.isSlotFree(ply,args[4],args[3], function(datas)
				if(datas) then
					manolis.popcorn.inventory.setQuantity(ply, data.id, data.quantity-args[2], function()
						manolis.popcorn.inventory.copyItemChange(ply,data.id, args[2], args[4], args[3], function()
							ply:RefreshInventory(args[4])
						end) 
					end)
				else
					return
				end
			end)
		end 
	end)
end)

local stackQue = function(sque, ply, c)
	if(ply.isCrafting) then return end
	if(!ply.sQue) then
		ply.sQue = {}
	end

	local sQue = ply.sQue
	if(!c and ply.sQueDoing) then return end
	if(sQue[1]) then
		ply.sQueDoing = true
		local id = 1
		local args = {}

		args[1] = sQue[id].args[1]
		args[2] = sQue[id].args[2]
		ply = sQue[id].ply

		if(!args[1] or !args[2]) then return false end
		if(!tonumber(args[1]) or !tonumber(args[2])) then return false end

		args[1] = math.floor(args[1])
		args[2] = math.floor(args[2])
		local old = args[1]
		local new = args[2]

		manolis.popcorn.inventory.retrieveItem(ply,old,function(oldItem)
			if(!oldItem) then return end
			if(oldItem.type=='material') then
				manolis.popcorn.inventory.retrieveItem(ply,new,function(newItem)
					if(!newItem) then return end
					if(newItem.type=='material') then
						if(oldItem.name==newItem.name) then
							local words = {}
							for word in newItem.name:gmatch("%w+") do
								table.insert(words, word)
							end
							local mat = manolis.popcorn.crafting.FindMaterial(words[1])
							if(mat) then
								if((oldItem.quantity + newItem.quantity) < mat.maxStack) then
									manolis.popcorn.inventory.removeItem(ply, oldItem.id, function()
										manolis.popcorn.inventory.setQuantity(ply,newItem.id, oldItem.quantity + newItem.quantity, function(data)
											table.remove(ply.sQue, id)
											sque(sque,ply, true)	
										end)
									end)
								end
							end
						end
					end
				end)	
			end
		end)
	else
		ply.sQueDoing = false
	end
end

concommand.Add("ManolisPopcornStackItem", function(ply,cmd,args)
	if(!ply.sQue) then ply.sQue = {} end
	table.insert(ply.sQue, {ply=ply,cmd=cmd,args=args})
	stackQue(stackQue, ply)
end)

concommand.Add("ManolisPopcornChangeInventoryPage", function(ply, cmd, args)
	if(!args[1] and args[2]) then return false end
	if(!tonumber(args[2])) then return false end

	args[2] = math.Round(tonumber(args[2]))
	args[1] = math.Round(tonumber(args[1]))

	if((args[2] and tonumber(args[2]) and tonumber(args[2])>4 and tonumber(args[2])<=0)) then return false end
	manolis.popcorn.inventory.changeItemPage(ply,args[1], args[2])
end)

concommand.Add("ManolisPopcornReinforceItem", function(ply,cmd,args)
	if(!args or !args[1] or !args[2] or !tonumber(args[1]) or !tonumber(args[2])) then return false end
	if(ply.isCrafting) then return false end

	args[1] = math.floor(args[1])
	args[2] = math.floor(args[2])
	
	manolis.popcorn.inventory.retrieveSingleItemData(ply,args[1], function(stone)
		if(!stone) then 
			ply.isCrafting = false
			return false 
		end
		if(stone.name!=DarkRP.getPhrase('crystal',DarkRP.getPhrase('rein_stone'))) then
			ply.isCrafting = false
			return false 
		end

		manolis.popcorn.inventory.retrieveSingleItemData(ply,args[2],function(item)
			if(item.type=='primary' or item.type=='side' or item.type=='armor') then
				local json = item.json
				if(!json or !json.class) then 
					ply.isCrafting = false
					return 
				end

				local maxLevel = manolis.popcorn.crafting.MaxLevel(json.class)

				if(item.json.level+1>maxLevel) then
					DarkRP.notify(ply,1,4,DarkRP.getPhrase('cannot_reinforce'))
					ply.isCrafting = false
					return
				else
					item.json.level = item.json.level + 1
					manolis.popcorn.inventory.UpdateLevelOfItem(item, function()
						local onceFinished = function()
							DarkRP.notify(ply,0,4,DarkRP.getPhrase('reinforce_success'))
							ply:AddAchievementProgress('perfectionist',1)
							ply:RefreshInventory(item.page)
							ply.isCrafting = false
						end

						if(stone.quantity>1) then
							manolis.popcorn.inventory.setQuantity(ply, args[1], stone.quantity-1, function()
								onceFinished()
							end)
						else
							manolis.popcorn.inventory.removeItem(ply,args[1],function()
								onceFinished()
							end)
						end
					end)
				end
			else
				DarkRP.notify(ply,1,4,DarkRP.getPhrase('cannot_reinforce2'))
				ply.isCrafting = false
			end
		end)
	end)
end)

concommand.Add("ManolisPopcornUpgradeItem", function(ply,cmd,args)
	if(!args or !args[1] or !args[2] or !tonumber(args[1]) or !tonumber(args[2])) then return false end
	args[1] = math.floor(args[1])
	args[2] = math.floor(args[2])

	manolis.popcorn.inventory.retrieveSingleItemData(ply,args[1], function(upgrade)
		if(!upgrade) then return false end
		if(upgrade.entity != 'manolis_popcorn_upgrade') then return end
		if(!upgrade.json) then return false end

		manolis.popcorn.inventory.retrieveSingleItemData(ply,args[2], function(item)
			if(!item) then return false end
			if(item.type =='primary' or item.type=='side' or item.type=='armor') then
				local json = item.json
				if(!json) then return false end
				item.json = json
				if(json.slots > 0) then
					if(json.upgrades and json.slots <= #json.upgrades) then
						DarkRP.notify(ply,1,4,DarkRP.getPhrase('cannot_upgrade'))
					else
						if((item.type=='primary' and upgrade.json.type == 'weapon') or (item.type=='side' and upgrade.json.type=='weapon') or (json.type=='armor' and upgrade.json.type=='armor')) then
							if(upgrade.json.type=='armor') then
								if(!manolis.popcorn.armor.CanUpgrade(json.slot,upgrade.json.class)) then
									DarkRP.notify(ply,1,4,DarkRP.getPhrase('upgrade_wrong_item'))
									return
								end
							end
							manolis.popcorn.inventory.upgradeItem(item, upgrade, upgrade.json, function(d)
								ply:RefreshInventory(item.page)
								DarkRP.notify(ply,0,4,DarkRP.getPhrase('upgrade_success'))
							end)
						end
					end
				else
					DarkRP.notify(ply,1,4,DarkRP.getPhrase('item_cannot_upgrade'))
				end
			else
				DarkRP.notify(ply,1,4,DarkRP.getPhrase('item_cannot_upgrade'))
			end
		end)
	end)
end)

local meta = FindMetaTable("Player")
meta.isRefreshingSyndicateInventory = false
meta.RefreshInventory = function(self,page)

	if(self.isRefreshingSyndicateInventory) then return end
	self.isRefreshingSyndicateInventory = true
	if(!page) then
		manolis.popcorn.inventory.retrievePlayerItemData(self, function(items)
			if(!items) then items = {} end
			sendInventoryRefresh(self,items)
			self.isRefreshingSyndicateInventory = false
		end)
	else
		manolis.popcorn.inventory.retrievePageItemsData(self,page,function(data)
			if(!data) then data = {} end
			self.isRefreshingSyndicateInventory = false
			sendPartialInventoryRefresh(self,page,data)
		end)
	end
end

concommand.Add('manolisRefreshInventory', function(ply)
	if(!(ply.lastInventoryRefresh>(CurTime()+.3))) then
		ply:RefreshInventory()
	end
end,nil,'Refreshes your inventory')

hook.Add("PlayerInitialSpawn", "manolis:popcorn:InitialSpawnPlyInventory", function(ply)
	ply.lastInventoryRefresh = 0
	ply.lastEquipmentRefresh = 0

	timer.Simple(.5, function()
		ply:RefreshInventory()
		ply:RefreshEquipment()
	end)
end)
