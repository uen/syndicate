if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.equipment) then manolis.popcorn.equipment = {} end

manolis.popcorn.equipment.EquipItem = function(ply, id, slot, callback)
	MySQLite.query("INSERT INTO manolis_popcorn_equipment VALUES(null, "..MySQLite.SQLStr(ply:SteamID64())..", "..MySQLite.SQLStr(slot)..', '..MySQLite.SQLStr(id)..')', function()
		MySQLite.query("UPDATE manolis_popcorn_inventory SET slot = "..MySQLite.SQLStr(-id).." WHERE id = "..MySQLite.SQLStr(id),function()
			if(callback) then callback() end
		end)
	end)	
end

manolis.popcorn.equipment.IsItemEquipped = function(ply,item, callback)
	MySQLite.query("SELECT id FROM manolis_popcorn_equipment WHERE item = "..MySQLite.SQLStr(item)..' AND uid = '..MySQLite.SQLStr(ply:SteamID64()), function(data)
		if(callback) then callback(data) end
	end)
end

manolis.popcorn.equipment.DequipItem = function(ply,id,page,slot,callback)
	MySQLite.query("DELETE FROM manolis_popcorn_equipment WHERE item = "..MySQLite.SQLStr(id), function(da)
		MySQLite.query("UPDATE manolis_popcorn_inventory SET slot = "..MySQLite.SQLStr(slot)..", page = "..MySQLite.SQLStr(page).." WHERE id = "..MySQLite.SQLStr(id).. " AND uid = "..MySQLite.SQLStr(ply:SteamID64()), function(data)
			callback(true)
		end)
	end)
end

manolis.popcorn.equipment.isSlotFreeData = function(ply,slot,callback)
	if(!slot) then return false end
	MySQLite.query("SELECT id FROM manolis_popcorn_equipment WHERE slot = "..MySQLite.SQLStr(slot)..' AND uid = '..MySQLite.SQLStr(ply:SteamID64()), function(data)
		if(callback) then callback(data) end
	end)
end

manolis.popcorn.equipment.retrievePlayerEquipment = function(ply,callback)
	MySQLite.query("SELECT manolis_popcorn_inventory.*, manolis_popcorn_equipment.slot FROM manolis_popcorn_equipment INNER JOIN manolis_popcorn_inventory ON manolis_popcorn_equipment.item = manolis_popcorn_inventory.id WHERE manolis_popcorn_inventory.uid = "..MySQLite.SQLStr(ply:SteamID64())..' AND manolis_popcorn_equipment.uid = '..MySQLite.SQLStr(ply:SteamID64()), function(data) if(!data) then data = {} end callback(data)end)
end

manolis.popcorn.equipment.getEquippedArmor = function(ply,callback)
	MySQLite.query("SELECT manolis_popcorn_inventory.*, manolis_popcorn_equipment.slot FROM manolis_popcorn_equipment INNER JOIN manolis_popcorn_inventory ON manolis_popcorn_equipment.item = manolis_popcorn_inventory.id WHERE manolis_popcorn_inventory.uid = "..MySQLite.SQLStr(ply:SteamID64())..' AND manolis_popcorn_equipment.uid = '..MySQLite.SQLStr(ply:SteamID64()).." AND (manolis_popcorn_equipment.slot IN('hands','head','body','bottom'))", function(d)
		callback(d or {})
	end)
end

manolis.popcorn.equipment.getEquippedWeapons = function(ply,callback)
	MySQLite.query("SELECT manolis_popcorn_inventory.*, manolis_popcorn_equipment.slot FROM manolis_popcorn_equipment INNER JOIN manolis_popcorn_inventory ON manolis_popcorn_equipment.item = manolis_popcorn_inventory.id WHERE manolis_popcorn_inventory.uid = "..MySQLite.SQLStr(ply:SteamID64())..' AND manolis_popcorn_equipment.uid = '..MySQLite.SQLStr(ply:SteamID64()).." AND (manolis_popcorn_equipment.slot = 'primary' OR manolis_popcorn_equipment.slot = 'side')", function(d)
		callback(d or {})
	end)
end