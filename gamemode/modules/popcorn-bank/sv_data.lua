if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.bank) then manolis.popcorn.bank = {} end

manolis.popcorn.bank.retrievePlayerItems = function(ply,callback)

	MySQLite.query("SELECT * FROM manolis_popcorn_bank WHERE uid = "..MySQLite.SQLStr(ply:SteamID64())..' ORDER BY slot', function(data) 
		if(!data) then data = {} end 

		for k,v in pairs(data) do
			v.json = !v.json and {} or util.JSONToTable(v.json) and util.JSONToTable(v.json) or {}
		end

		callback(data)
	end)
end

manolis.popcorn.bank.retrieveSingleItemData = function(ply,id,callback)
	MySQLite.query("SELECT * FROM manolis_popcorn_bank WHERE id = "..MySQLite.SQLStr(id)..' AND uid = '..MySQLite.SQLStr(ply:SteamID64()), function(data)
		if(data) then
			if(data[1]) then
				if(callback) then callback(data[1]) end
			else
				if(callback) then callback(false) end
			end
		else
			if(callback) then callback(false) end
		end
	end)
end


manolis.popcorn.bank.isSlotFreeData = function(ply,slot,callback)
	if(!slot) then return false end
	if(slot>36) then callback(false) return end

	MySQLite.query("SELECT id FROM manolis_popcorn_bank WHERE slot = "..MySQLite.SQLStr(slot).." AND uid = "..MySQLite.SQLStr(ply:SteamID64()), function(data)
		if(callback) then callback(!data) end
	end)
end

manolis.popcorn.bank.AddItemToBank = function(ply,item,slot,callback)
	manolis.popcorn.bank.isSlotFreeData(ply,slot,function(data)
		if(data) then
			manolis.popcorn.inventory.retrieveSingleItemData(ply, item, function(data)
				if(data) then
					data.json = data.json and util.TableToJSON(data.json) or '{}'
					MySQLite.query("DELETE FROM manolis_popcorn_inventory WHERE id = "..MySQLite.SQLStr(item).." AND uid = "..MySQLite.SQLStr(ply:SteamID64()), function()
						MySQLite.query("INSERT INTO manolis_popcorn_bank VALUES(null, "..MySQLite.SQLStr(ply:SteamID64())..", "..MySQLite.SQLStr(slot)..", "..MySQLite.SQLStr(data.name)..", "..MySQLite.SQLStr(data.entity)..", "..MySQLite.SQLStr(data.value)..","..MySQLite.SQLStr(data.type)..","..MySQLite.SQLStr(data.json)..","..MySQLite.SQLStr(data.icon)..","..MySQLite.SQLStr(data.level)..","..MySQLite.SQLStr(data.quantity)..")", function()
							if(callback) then callback() end
						end)
					end)
				else
					if(callback) then callback(false) end
				end
			end)			
		else
			if(callback) then callback(false) end
		end
	end)
end

manolis.popcorn.bank.AddItemToInventory = function(ply,item,page,slot,callback)
	manolis.popcorn.inventory.isSlotFree(ply,page,slot,function(data)
		if(data) then
			manolis.popcorn.bank.retrieveSingleItemData(ply, item, function(data)
				if(data) then
					MySQLite.query("DELETE FROM manolis_popcorn_bank WHERE id = "..MySQLite.SQLStr(item).." AND uid = "..MySQLite.SQLStr(ply:SteamID64()), function()
						MySQLite.query("INSERT INTO manolis_popcorn_inventory VALUES(null, "..MySQLite.SQLStr(ply:SteamID64())..", "..MySQLite.SQLStr(slot)..", "..MySQLite.SQLStr(data.name)..", "..MySQLite.SQLStr(data.entity)..", "..MySQLite.SQLStr(data.value)..","..MySQLite.SQLStr(data.type)..","..MySQLite.SQLStr(data.json)..","..MySQLite.SQLStr(page)..","..MySQLite.SQLStr(data.icon)..","..MySQLite.SQLStr(data.level)..","..MySQLite.SQLStr(data.quantity)..")", function()
							if(callback) then callback() end
						end)
					end)
				else
					if(callback) then callback(false) end
				end
			end)			
		else
			if(callback) then callback(false) end
		end
	end)
end

manolis.popcorn.bank.ChangeSlotData = function(ply,item,slot,callback)
	item = tonumber(item)
	slot = tonumber(slot)
	if(!item or !slot or slot>36 or slot<1) then return false end

	MySQLite.query("UPDATE manolis_popcorn_bank SET slot = "..MySQLite.SQLStr(math.Round(slot)).." WHERE uid = "..MySQLite.SQLStr(ply:SteamID64()) .. " AND id = "..MySQLite.SQLStr(math.Round(item)), function()
		if(callback) then callback() end
	end)
end