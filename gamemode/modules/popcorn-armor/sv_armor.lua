if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.armor) then manolis.popcorn.armor = {} end

manolis.popcorn.armor.CreateArmorData = function(ply, item, giga)
	local luck = ply:GetLuck()
	if(giga) then luck = luck + manolis.popcorn.config.gigaLuck end
	local json = item.json
	if(type(json)=='string') then
		json = util.JSONToTable(item.json)
	end


	local armor = {}
	armor.armorgroup = json.armorgroup
	armor.slot = json.slot

	armor.level = 1 + math.Round(math.random(0,5) * luck)

	local classes = {
		{name='Epic', chance = 0.99, slots = 8},
		{name='Elite', chance = 0.98, slots = 6},
		{name='Unique', chance= 0.60, slots = 4},
		{name='Rare', chance=0.30, slots = 2},
		{name='Uncommon', chance=0.1, slots = 1}
	}

	local bodygroupSlots = {
		body = 8,
		bottom = 8,
		head = 4,
		hands = 4,
		ring = 2,
	}

	local random = math.random()

	local foundClass = false 
	for k,v in pairs(classes) do
		if(foundClass) then continue end
	
		if((random*(luck))>v.chance) then
			armor.class = v
			foundClass = true
		end
	end

	if(json.classOverride) then
		for a,b in pairs(classes) do
			if(b.name==json.classOverride) then
				armor.class = b
			end
		end
	end

	if(json.base) then
		armor.base = json.base
	end

	if(!armor.class) then armor.class = {name='Standard', slots=0} end

	local maxSlots = bodygroupSlots[json.slot] or 4
	if(armor.class.name == 'Standard') then armor.class.slots = 0 end
	armor.slots = math.random()>0.5 and 2 or math.random()>0.5 and 1 or 0 
	armor.slots = math.Clamp(armor.slots + (maxSlots>4 and armor.class.slots or math.floor(armor.class.slots/2)), 0, maxSlots)
	armor.type = 'armor'
	armor.upgrades = {}
	armor.crafted = ply:Name()

	armor.class = armor.class.name

	return armor
end

manolis.popcorn.armor.CreateBase = function(data,base)
	local f = data.level/99

	local upgradesTemplate = {health=0,armor=0,healthboost=0,armorboost=0,speed=0,fireresist=0,iceresist=0,accuracyboost=0,basedamage=0,xp=0}

	local upgrades = {}
	for k,v in pairs(upgradesTemplate) do
		if(math.random()>0.6) then
			if(manolis.popcorn.config['max'..k..'Base']) then
				upgrades[k] = upgrades[k] or 0 + math.floor(math.random(0,f*manolis.popcorn.config['max'..k..'Base']))
			end
		end
	end

	for k,v in pairs(upgrades) do
		if(math.floor(v)<1) then
			upgrades[k] = nil
			continue
		end
		if(!manolis.popcorn.armor.CanUpgrade(data.json.slot or '', k)) then
			upgrades[k] = nil
		end
	end

	for k,v in pairs(base or {}) do
		upgrades[k] = upgrades[k] or 0 + v
	end

	return upgrades
end

hook.Add("PlayerSetModel", "manolis:popcorn:SetModel", function(ply)
	if(!IsValid(ply)) then return false end
	local jobTable = ply:getJobTable()
	local isOverridden = false
	if(jobTable) then
		if(jobTable.overrideModel) then
			      local EndModel = ""

				if istable(jobTable.model) then
				    local ChosenModel = string.lower(ply:getPreferredModel(ply:Team()) or "")

				    local found
				    for _,Models in pairs(jobTable.model) do
					if ChosenModel == string.lower(Models) then
					    EndModel = Models
					    found = true
					    break
					end
				    end

				    if not found then
					EndModel = jobTable.model[math.random(#jobTable.model)]
				    end

				else
				    EndModel = jobTable.model
				end
				
				isOverridden = true
				
				ply:SetModel(EndModel)
		end
	end
		
	if(!isOverridden) then
		
		local base = "models/manolis/player.mdl"
		util.PrecacheModel(base)
		ply:SetModel(base)

		ply:SetBodygroup(0,1)

		for i=1,4 do
			ply:SetBodygroup(i,0)
		end

		if(ply.isManolis) then
			ply:SetBodygroup(5,1)
		end

		local bodygroups = {}
		bodygroups.body = 1
		bodygroups.bottom = 2
		bodygroups.head = 4
		bodygroups.hands = 3

		if(!ply.armorSlots) then
			manolis.popcorn.equipment.getEquippedArmor(ply,function(armor)
				for k,v in pairs(bodygroups) do
					ply:SetBodygroup(v,0)
				end

				for k,v in pairs(armor) do
					v.json = util.JSONToTable(v.json)
					for k,va in pairs(bodygroups) do
						if(v.json and v.json.slot and v.json.armorgroup) then
							if(v.json.slot == k) then
								if(!ply.armorSlots) then ply.armorSlots = {} end
								ply.armorSlots[v.json.slot] = v
							end
						end
					end
				end

				if(ply.armorSlots) then
					for k,v in pairs(ply.armorSlots) do
						if(v.json.slot and bodygroups[v.json.slot]) then
							ply:SetBodygroup(bodygroups[v.json.slot], v.json.armorgroup)
						end
					end
				end
			end)
		else
			for k,v in pairs(bodygroups) do
				ply:SetBodygroup(v,0)
			end

			for k,v in pairs(ply.armorSlots) do
				if(v.json.slot and bodygroups[v.json.slot]) then
					ply:SetBodygroup(bodygroups[v.json.slot], v.json.armorgroup)
				end
			end
		end
	end

	if(!ply:isCP()) then
		return true
	end

end)
