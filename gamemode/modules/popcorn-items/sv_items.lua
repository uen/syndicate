if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.items) then manolis.popcorn.items = {} end
if(!manolis.popcorn.items.items) then manolis.popcorn.items.items = {} end

manolis.popcorn.items.NewWeapon = function(level, type_, name, ent, icon, price, model)
	local weapon = {}
	weapon.level = level
	weapon.type = type_
	weapon.name = name
	weapon.entity = ent
	weapon.price = price
	weapon.icon = icon
	weapon.model = model 
	manolis.popcorn.items.NewItem(weapon)
end

manolis.popcorn.items.NewArmor = function(level,name,icon,price,data)
	local armor = {}
	armor.level = level
	armor.type = 'armor'
	armor.name = name
	armor.entity = ''
	armor.price = price
	armor.icon = 'armor/'..icon..'.png'
	armor.json = data
	manolis.popcorn.items.NewItem(armor)
end

manolis.popcorn.items.NewItem = function(data)
	local t = {
		name = data.name or 'Unknown',
		icon = data.icon or '',
		entity = data.entity or '',
		price = data.price or 100,
		amount = data.amount or 1,
		type = data.type or 'item',
		level = data.level or 1,
		model = data.model or "",
		json = data.json and util.TableToJSON(data.json) or '{}'
	}

	table.insert(manolis.popcorn.items.items, t)
end

manolis.popcorn.items.CreateItemData = function(item)
	local n = {}
	n.slot = 1
	n.name = item.name or "Unknown"
	n.entity = item.entity or ""
	n.value = item.value or 1000
	n.type = item.type or ""
	n.json = item.json or {}
	n.page = item.page or 1
	n.icon = string.lower(string.gsub((item.icon or ""), "%s+", "-")) or ""
	n.level = item.level or 1
	n.model = item.model or ""
	n.quantity = item.quantity or 1

	return n
end


manolis.popcorn.items.LevelFromName = function(name,type)
	for k,v in pairs(manolis.popcorn.items.items) do
		if(v.name==name and v.type==type) then
			return v.level
		end
	end
end


manolis.popcorn.items.NewBlueprint = function(name, type, materials, value, rarity, nodrop)
	local newMaterials = {}
	for k,v in pairs(materials) do
		if(DarkRP.getPhrase(k)) then
			newMaterials[DarkRP.getPhrase(k)] = v
		end
	end
	
	local blueprint = {name=name,type=type,materials=materials,value=value,rarity=rarity,nodrop=nodrop}
	table.insert(manolis.popcorn.crafting.blueprints, blueprint)
end

manolis.popcorn.items.GetModel = function(item)
	if(item.type=='upgrade') then return "models/maxofs2d/hover_rings.mdl" end
	if(item.type=='blueprint') then return "models/lecoffee/alchemy/blueprint.mdl" end
	if(item.type=='material') then return "models/props_c17/FurnitureCouch002a.mdl" end
	if(item.type=='shipment') then return "models/Items/item_item_crate.mdl" end
	if(item.json and item.json.model) then return item.json.model end
	if(item.type=='side' or item.type=='primary') then
		
		for k,v in pairs(manolis.popcorn.items.items) do
			if(v.type=='primary' or v.type=='side') then
	
				if(v.entity == item.entity) then
					
					return v.model
				end
			end
		end
	end


	return false
end

manolis.popcorn.items.spawnableTypes = {primary=true,side=true,upgrade=true,blueprint=true,material=true}
manolis.popcorn.items.SpawnItem = function(ply, item, callback, pos)
	if(!item or !item.entity) then return end

	local entName = item.entity
	if(manolis.popcorn.items.spawnableTypes[item.type]) then
		entName = 'spawned_entity'
	end

	if(!entName) then
		return
	end

	local model = manolis.popcorn.items.GetModel(item)
	if(!model) then
		Msg('Item spawn failed: ',item.entity,' model not found. Player ID:',ply:SteamID64())
		return
	end

	local tr = false
	if(!pos) then
	    local trace = {}
	    trace.start = ply:EyePos()
	    trace.endpos = trace.start + ply:GetAimVector() * 85
	    trace.filter = ply
	    tr = util.TraceLine(trace)
	end

	local ent = ents.Create(entName)
	if(!ent) then
		Msg('Item spawn failed: ',item.entity,' not found. Player ID: ',ply:SteamID64())
		return 
	end
	
	ent:SetPos(tr and tr.HitPos or pos)

	if(ent.Setowning_ent) then
		ent:Setowning_ent(ply)
	end

	local t = {}
    t.name = item.name
    t.entity = item.entity
    t.json = item.json
    t.model = model
	t.icon = item.icon
	t.quantity = item.quantity
    t.type = item.type
    t.level = item.level

	t = manolis.popcorn.items.CreateItemData(t)

	if(ent.SetItemData) then
		ent:SetItemData(t)
	end

	if(entName=='spawned_entity') then
		ent.mdl = model
	else
		ent:SetModel(model or "models/maxofs2d/cube_tool.mdl")
	end

	if(entName=='spawned_shipment') then
    	local found, foundKey = DarkRP.getShipmentByName(item.json.name)
    	if(found) then
    		ent.DarkRPItem = found
			ent:SetContents(foundKey or '', item.json.quantity or 0)
		end
	end

	ent:Spawn()

	if(!pos) then DarkRP.notify(ply,0,4,DarkRP.getPhrase('inventory_dropped', item.name) or 'You dropped an item') end
	callback()
	return ent
end

manolis.popcorn.items.Find = function(k,v)
	for k2,v2 in pairs(manolis.popcorn.items.items) do
		if(string.lower(v2[k] or '')==string.lower(v)) then return v2 end
	end

	return false
end

manolis.popcorn.items.FindItem = function(name)
	return manolis.popcorn.items.Find('name', name)
end

manolis.popcorn.items.FindWeapon = function(name)
	for k,v in pairs(manolis.popcorn.items.items) do
		if(v.type=='primary' or v.type=='side') then
			if(string.lower(v.name)==string.lower(name)) then return v end
		end
	end
end

manolis.popcorn.items.FindArmor = function(name)
	for k,v in pairs(manolis.popcorn.items.items) do
		if(v.type=='armor') then
			if(string.lower(v.name)==string.lower(name)) then return v end
		end
	end
end


manolis.popcorn.items.NewArmor(1, "Ring of Power", "purple-ring", 10000000, {
	slot = 'ring',
	armorgroup = '-1',
	base = {health=1000},
	classOverride = "Epic"
})



manolis.popcorn.items.NewArmor(1, "Ring of Lua", "purple-ring", 1000000000, {
	slot = 'ring',
	armorgroup = '-1',
	base = {health=10000},
	classOverride = "Epic"
})

manolis.popcorn.items.NewBlueprint(DarkRP.getPhrase("weapon_upgrade"), "weaponupgrade", {Obsidian=1}, 10000, 95)
manolis.popcorn.items.NewBlueprint(DarkRP.getPhrase("armor_upgrade"), "armorupgrade", {Azurite=1, Zincite=1}, 10000, 95)
