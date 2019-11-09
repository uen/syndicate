if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.equipment) then manolis.popcorn.equipment = {} end

local giveEquippedItem = function(ply,item)
	local a = manolis.popcorn.items.FindItem(item.name)
	if(a) then
		if(a.type=='primary' or a.type=='side') then
			local ent = ply:Give(a.entity, true)
			ply:SelectWeapon(a.entity)
			if(ent.Upgrade) then
				ent:Upgrade(ply, item.id)
			end
		elseif(a.type=='armor') then
			if(!ply.upgrades) then ply.upgrades = {} end

			manolis.popcorn.inventory.retrieveItem(ply,item.id,function(data)
            	if(!data) then return end
            	local dcD = ply.upgrades or {}
	            if(data.json) then

	                if(data.json.upgrades) then

	                    for k,v in pairs(data.json.upgrades) do
	                        if(manolis.popcorn.upgrades.upgrades[data.json.type]) then
	                            if(manolis.popcorn.upgrades.upgrades[data.json.type][v.class]) then
	                                if(!dcD[v.class]) then 
	                                    dcD[v.class] = 0
	                                end 
	                                if(manolis.popcorn.upgrades.upgrades[data.json.type][v.class].levels) then
	                                    dcD[v.class] = dcD[v.class] + manolis.popcorn.upgrades.upgrades[data.json.type][v.class].levels[v.level]    
	                                end         
	                            end
	                        end
	                    end
	                    if(!ply.armorSlots) then ply.armorSlots = {} end
	                    ply.armorSlots[data.json.slot] = data
	                end

	                if(data.json.base) then
	                	for a,b in pairs(data.json.base) do
	                		dcD[a] = (dcD[a] or 0) + b
	                	end
	                end
	            end

	            ply.upgrades = dcD

	            ply:LimitSpeed()
	            ply:LimitHealth()
				hook.Call("PlayerSetModel", DarkRP.hooks, ply)
            end)
		end
	end
end

manolis.popcorn.equipment.retrievePlayerEquipmentData = function(ply, callback)
	if(manolis.popcorn.equipment.retrievePlayerEquipment) then
		manolis.popcorn.equipment.retrievePlayerEquipment(ply,function(data)
			if(!data) then data = {} end
			if not IsValid(ply) then return end
			callback(data)
		end)
	end
end

manolis.popcorn.equipment.isSlotFree = function(ply,slot,callback)
	manolis.popcorn.equipment.isSlotFreeData(ply,slot,function(data)
		if(!data) then return callback(true) end
		return callback(false)
	end)
end

local sendEquipmentRefresh = function(ply, items)
	if(!(ply.lastEquipmentRefresh>(CurTime()+.1))) then
		ply.lastEquipmentRefresh = CurTime()

		net.Start('ManolisPopcornEquipmentFullRefresh')
			if(items) then
				for k,v in pairs(items) do
					v.json = !v.json and {} or util.JSONToTable(v.json) and util.JSONToTable(v.json)
				end
			else
				items = {}
			end
			net.WriteTable(items)
		net.Send(ply)
	end
end



concommand.Add('refreshManolisPopcornEquipment', function(ply)
	if(!(ply.lastEquipmentRefresh>(CurTime()+.1))) then
		ply:RefreshEquipment()
	end
end,nil,'Refreshes your equipment')

concommand.Add("ManolisPopcornDequipItem", function(ply,c,args)
	if(#args==0) or (!args[1]) or(!args[2]) or (!args[3]) or (!tonumber(args[1])) or (!tonumber(args[2])) or (!tonumber(args[3])) then return false end

	args[1] = math.floor(tonumber(args[1])) // ID
	args[2] = math.floor(tonumber(args[2])) // Page
	args[3] = math.floor(tonumber(args[3])) // Slot

	manolis.popcorn.equipment.IsItemEquipped(ply, args[1], function(data)
		if(data) then
		
			manolis.popcorn.inventory.isSlotFree(ply,args[2],args[3], function(a)
		
				if(a) then
				
					manolis.popcorn.equipment.DequipItem(ply,args[1],args[2],args[3], function()
					
						if(IsValid(ply)) then
				
							manolis.popcorn.inventory.retrieveSingleItemData(ply,args[1],function(data)
								if(data) then
			
									if(data.type=='primary' or data.type=='side') then
										ply:StripWeapon(data.entity)
									end
					
									if(!data) then return end
					
					            	local dcD = ply.upgrades or {}
						            if(data.json) then
						                if(data.json.upgrades) then
						                    for k,v in pairs(data.json.upgrades) do
						                        if(manolis.popcorn.upgrades.upgrades[data.json.type]) then
						                            if(manolis.popcorn.upgrades.upgrades[data.json.type][v.class]) then
						                                if(!dcD[v.class]) then 
						                                    dcD[v.class] = 0
						                                end 
						                                if(manolis.popcorn.upgrades.upgrades[data.json.type][v.class].levels) then
						                                    dcD[v.class] = dcD[v.class] - manolis.popcorn.upgrades.upgrades[data.json.type][v.class].levels[v.level]    
						                                end         
						                            end
						                        end
						                    end
						                end

						                 if(data.json.base) then
						                	for a,b in pairs(data.json.base) do
						                		dcD[a] = (dcD[a] or 0) - b
						                	end
						                end
						            end

		
						            ply.upgrades = dcD

						            if(data.type!='primary' or data.type!='side') then
						            	ply.armorSlots = false
							            ply:LimitSpeed()
							            ply:LimitHealth()
							         
							            hook.Call("PlayerSetModel", DarkRP.hooks, ply)
						        	end
								end
							end)	
						end
					end)
				else
					DarkRP.notify(ply,1,4,DarkRP.getPhrase('slot_not_free'))
					ply:RefreshInventory()
					ply:RefreshEquipment()
				end
			end)
		else
			ply:RefreshInventory()
			ply:RefreshEquipment()
		end
	end)
end)

local equipItem = function(ply,c,args, callback)
	if(#args==0) or (!args[1]) or(!args[2]) or (!tonumber(args[2])) then return false end
	args[2] = math.floor(args[2])
	manolis.popcorn.inventory.retrieveItem(ply, args[2], function(data)
		if(!data) then return false end
		local item = data

		local json = item.json
		if(!json) then return false end
		if(!json.armorgroup) then 
			if(args[1]!='primary' and args[1]!='side') then

				DarkRP.notify(ply,1,4,DarkRP.getPhrase('wrong_slot'))
				ply:RefreshEquipment()
				ply:RefreshInventory(data.page)
				return false 
			else
				json.slot = item.type
			end
		end

		if(args[1]==json.slot) then
			manolis.popcorn.equipment.isSlotFree(ply, json.slot, function(free)
				if(!free) then
					DarkRP.notify(ply,1,4,DarkRP.getPhrase('slot_unequip'))
					ply:RefreshInventory(data.page)

					return
				end
				if(manolis.popcorn.levels.HasLevel(ply, data.level)) then
					manolis.popcorn.equipment.IsItemEquipped(ply, item.id, function(s)
						if(s) then 
							DarkRP.notify(ply,1,4,DarkRP.getPhrase('item_already_equipped'))
							return 
						else
							manolis.popcorn.equipment.EquipItem(ply, item.id, json.slot, function()
								if(callback and type(callback)=='function') then
									callback()
								end
								giveEquippedItem(ply, item)								
							end)
						end
					end)
				else
					ply:RefreshEquipment()
					ply:RefreshInventory(data.page)
					DarkRP.notify(ply, 0, 4,DarkRP.getPhrase('wrong_level_equip', data.level))
					return
				end
			end)
		else
			ply:RefreshEquipment()
			ply:RefreshInventory(data.page)
			DarkRP.notify(ply, 1,4, DarkRP.getPhrase('slot_not_free'))
		end	
	end)
end

concommand.Add("ManolisPopcornEquipItemAlt", function(ply,c,args)
	if(#args==0) or (!args[1]) or (!tonumber(args[1])) then return false end
	manolis.popcorn.inventory.retrieveItem(ply, args[1], function(data)
		if(!data) then return false end
		if(data.json and data.json.slot) then
			equipItem(ply,c,{data.json.slot, args[1]}, function()
				ply:RefreshEquipment()
				ply:RefreshInventory(data.page)
			end)
		else
			if(data.json and data.json.type=='weapon') then
				equipItem(ply,c,{data.type, args[1]}, function()
					ply:RefreshEquipment()
				end)
			end
		end
	end)
end)

concommand.Add('ManolisPopcornEquipItem', equipItem)

local meta = FindMetaTable('Player')
function meta:RefreshEquipment()
	manolis.popcorn.equipment.retrievePlayerEquipmentData(self, function(items)
		sendEquipmentRefresh(self,items)
	end)
end

concommand.Add('manolisRefreshEquipment', function(ply)
	if(!(ply.lastInventoryRefresh>(CurTime()+.3))) then
		ply:RefreshEquipment()
	end
end,nil,'Refreshes your equipment')