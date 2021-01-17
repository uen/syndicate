if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.inventory) then manolis.popcorn.inventory = {} end

local addingItem = false
local cachedItems = {}

local insertItem = function(ply,item,callback,page,slot)
	MySQLite.query("INSERT INTO manolis_popcorn_inventory VALUES(null, "..MySQLite.SQLStr(ply:SteamID64())..", "..slot..", "..MySQLite.SQLStr(item.name)..","..MySQLite.SQLStr(item.entity)..","..MySQLite.SQLStr(item.value)..','..MySQLite.SQLStr(item.type)..','..MySQLite.SQLStr(item.json)..','..MySQLite.SQLStr(page)..','..MySQLite.SQLStr(item.icon)..','..MySQLite.SQLStr(item.level)..','..MySQLite.SQLStr(item.quantity)..') '..manolis.popcorn.data.duplicateUpdate("id")..' slot = slot + 1', function(data)
		if(callback) then
			callback({page=page,slot=slot})
		end
	end)
end

local addItem = function(ply,item,callback)
	addingItem = true
	local steamId = ply:SteamID64()
	
	manolis.popcorn.inventory.getFreeSlot(ply, function(page, slot)
		if(!page or !slot) then
			callback(false)
			return
		end

		if(item.json) then
			item.json = util.TableToJSON(item.json)
		else
			item.json = '{}'
		end

		if(item.icon) then
			item.icon = string.lower(string.gsub((item.icon or ""), "%s+", "-")) or ""
		end

		if((!item.checked) and (item.type == "material" or item.type == "reinstone")) then
			MySQLite.query("SELECT id,quantity,page,slot FROM manolis_popcorn_inventory WHERE uid = "..MySQLite.SQLStr(steamId).." AND type = "..MySQLite.SQLStr(item.type).." AND name = "..MySQLite.SQLStr(item.name).." AND quantity<99", function(stackable)
				if(stackable and stackable[1]) then
					stackable = stackable[1]
					MySQLite.query("UPDATE manolis_popcorn_inventory SET quantity = quantity + 1 WHERE uid = "..MySQLite.SQLStr(steamId).." AND id = "..MySQLite.SQLStr(stackable.id), function()
						if(callback) then
							callback({page=stackable.page,slot=stackable.slot})
						end
					end)
				else
					item.checked = true
					insertItem(ply,item,callback,page,slot)
				end
			end)
		else
			insertItem(ply,item,callback,page,slot)
		end
	end)
end

manolis.popcorn.inventory.addItem = function(ply, item, callback)
	item.callback = callback
	item.ply = ply
	table.insert(cachedItems, item)
end

manolis.popcorn.inventory.addWorldItem = function(ply,item,callback)
	manolis.popcorn.inventory.addItem(ply,item,function(data)
 		DarkRP.notify(ply,0,4,DarkRP.getPhrase('inventory_world_add', item.name))
		if(data.page) then
			ply:RefreshInventory(data.page)
		end
		callback(true)
	end)
end

hook.Add("Think", "manolisUpdateItem:new", function()
	if(#cachedItems > 0 and !addingItem) then
		addItem(cachedItems[1].ply, cachedItems[1], function(data)
			if(cachedItems[1].callback) then
				cachedItems[1].callback(data)
			end

			addingItem = false

			table.remove(cachedItems, 1)
		end)
	end
end)

manolis.popcorn.inventory.upgradeItem = function(item,upgrade, json, callback)
	MySQLite.query("DELETE FROM manolis_popcorn_inventory WHERE id = "..MySQLite.SQLStr(upgrade.id), function(data)
		if(item.json.upgrades) then
			table.insert(item.json.upgrades,{class=json.class, level=json.level})
		end

		item.json = util.TableToJSON(item.json)
		MySQLite.query("UPDATE manolis_popcorn_inventory SET json = "..MySQLite.SQLStr(item.json)..' WHERE id = '..MySQLite.SQLStr(item.id), function(d)
			callback()
		end)
	end)
end

manolis.popcorn.inventory.retrievePlayerItems = function(ply,callback)
	MySQLite.query("SELECT * FROM manolis_popcorn_inventory WHERE uid = "..MySQLite.SQLStr(ply:SteamID64())..' AND NOT EXISTS ( SELECT item FROM manolis_popcorn_equipment WHERE manolis_popcorn_equipment.item = manolis_popcorn_inventory.id) ORDER BY slot', function(data) 
		if(!data) then data = {} end 

		for k,v in pairs(data) do
			v.json = !v.json and {} or util.JSONToTable(v.json) and util.JSONToTable(v.json) or {}
		end
		callback(data)
	end)
end

manolis.popcorn.inventory.UpdateLevelOfItem = function(item,callback)
	local json = util.TableToJSON(item.json)
	MySQLite.query("UPDATE manolis_popcorn_inventory SET json = "..MySQLite.SQLStr(json).." WHERE id = "..MySQLite.SQLStr(item.id), function()
		if(callback) then callback() end	
	end)
end

manolis.popcorn.inventory.retrieveSingleItemData = function(ply,id,callback)
	MySQLite.query("SELECT * FROM manolis_popcorn_inventory WHERE id = "..MySQLite.SQLStr(id)..' AND uid = '..MySQLite.SQLStr(ply:SteamID64()), function(data)
		if(data) then
			if(data[1]) then
				if(callback) then
					data[1].json = !data[1].json and {} or util.JSONToTable(data[1].json) and util.JSONToTable(data[1].json) or {}
					callback(data[1])
					return
				end
			end
		end
		callback(false)
		return
	end)
end

manolis.popcorn.inventory.setQuantity = function(ply, id, quantity, callback)
	MySQLite.query("UPDATE manolis_popcorn_inventory SET quantity = "..MySQLite.SQLStr(quantity)..' WHERE id = '..MySQLite.SQLStr(id)..' AND uid = '..MySQLite.SQLStr(ply:SteamID64()), function(data)
		if(callback) then
			callback(data)
		end
	end)
end

manolis.popcorn.inventory.removeItem = function(ply,id,callback)
	MySQLite.query("DELETE FROM manolis_popcorn_inventory WHERE id = "..MySQLite.SQLStr(id)..' AND uid = '..MySQLite.SQLStr(ply:SteamID64()), function(data)
		if(callback) then
			callback(data)
		end
	end)
end

manolis.popcorn.inventory.sellItemCheck = function(ply,id,callback)
	manolis.popcorn.inventory.retrieveSingleItemData(ply,id,function(item)
		if(item) then
			callback(item)
		end
	end)
end

manolis.popcorn.inventory.removeItems = function(ply, items, callback)
	local q = "DELETE FROM manolis_popcorn_inventory WHERE uid = "..MySQLite.SQLStr(ply:SteamID64()).." AND ("
	for k,v in pairs(items) do
		q = q .."id = "..MySQLite.SQLStr(v)..(k==#items and '' or ' OR ')
	end
	q = q ..')'
	MySQLite.query(q, function(d)
		if(callback) then
			callback(d)
		end
	end)
end

manolis.popcorn.inventory.copyItemChange = function(ply,id,newquantity,newpage, newslot, callback)
	MySQLite.query("INSERT INTO manolis_popcorn_inventory(id, uid, slot,name,entity,value,type,json,page,icon,level,quantity) SELECT null, uid, "..MySQLite.SQLStr(newslot)..", name, entity, value, type, json, "..MySQLite.SQLStr(newpage)..", icon, level,"..MySQLite.SQLStr(newquantity).." FROM manolis_popcorn_inventory WHERE id = "..MySQLite.SQLStr(id), function(d)
		if(callback) then callback() end
	end)
end

manolis.popcorn.inventory.switchPlayer = function(old,new,id, page, slot, callback)
	MySQLite.query("UPDATE manolis_popcorn_inventory SET page = "..MySQLite.SQLStr(page)..", slot = "..MySQLite.SQLStr(slot)..', uid = '..MySQLite.SQLStr(new:SteamID64())..' WHERE uid = '..MySQLite.SQLStr(old:SteamID64())..' AND id = '..MySQLite.SQLStr(id), function()
		if(callback) then callback() end
	end)
end

manolis.popcorn.inventory.isSlotFreeData = function(ply,page, slot,callback)
	if(!slot) or (!page) then return false end
	MySQLite.query("SELECT id FROM manolis_popcorn_inventory WHERE page = "..MySQLite.SQLStr(page).." AND slot = "..MySQLite.SQLStr(slot).." AND NOT EXISTS ( SELECT item FROM manolis_popcorn_equipment WHERE manolis_popcorn_equipment.item = manolis_popcorn_inventory.id) AND uid = "..MySQLite.SQLStr(ply:SteamID64()), function(data)
		if(callback) then callback(data) end
	end)
end

manolis.popcorn.inventory.moveInventoryItemData = function(ply, id,page,slot, callback)
	page = tonumber(page)
	slot = tonumber(slot)
	id = tonumber(id)

	if(!page or !slot or !id) then return false end
	if(slot>20 or slot<=0) then return false end
	if(page>4) then return false end
	if(!id) then return false end

	MySQLite.query("UPDATE manolis_popcorn_inventory SET page = "..MySQLite.SQLStr(page)..', slot = '..MySQLite.SQLStr(slot)..' WHERE uid = '..MySQLite.SQLStr(ply:SteamID64())..' AND id = '..MySQLite.SQLStr((tonumber(math.Round(id)))), function(d)
		if(callback) then callback() end
	end)
end

manolis.popcorn.inventory.retrievePageItemsData = function(ply, page,callback)
	MySQLite.query("SELECT * FROM manolis_popcorn_inventory WHERE uid = "..ply:SteamID64().." AND page = "..MySQLite.SQLStr(page)..' ORDER BY slot', function(data)
		if(!data) then data = {} end
		for k,v in pairs(data) do
			v.json = !v.json and {} or util.JSONToTable(v.json) and util.JSONToTable(v.json) or {}
		end
		if(callback) then callback(data) end
	end)
end

manolis.popcorn.inventory.getSpace = function(ply, callback)
	MySQLite.query("SELECT id FROM manolis_popcorn_inventory WHERE uid = "..ply:SteamID64(), function(data)
		callback(data and #data or false)
	end)	
end