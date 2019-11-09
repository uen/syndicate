if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.buildings) then manolis.popcorn.buildings = {} end
if(!manolis.popcorn.buildings.buildings) then manolis.popcorn.buildings.buildings = {} end
if(!manolis.popcorn.buildings.buildingsWithDoors) then manolis.popcorn.buildings.buildingsWithDoors = {} end
if(!manolis.popcorn.buildings.buildingCapturePoints) then manolis.popcorn.buildings.buildingCapturePoints = {} end
if(!manolis.popcorn.buildings.buildingPowerPoints) then manolis.popcorn.buildings.buildingPowerPoints = {} end
if(!manolis.popcorn.buildings.buildingCash) then manolis.popcorn.buildings.buildingCash = {} end
if(!manolis.popcorn.buildings.buildingUpgrades) then manolis.popcorn.buildings.buildingUpgrades = {} end

local function shuffleTable( t )
    local rand = math.random 
    assert( t, "shuffleTable() expected a table, got nil" )
    local iterations = #t
    local j
    
    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end
 
math.randomseed(os.time())

manolis.popcorn.buildings.findFreeBuilding =  function()
	local buildings = table.Copy(manolis.popcorn.buildings.buildings)
	shuffleTable(buildings)

	for k,v in pairs(buildings) do
		if(!manolis.popcorn.buildings.buildingCash[v.id]) then continue end
		for a,b in pairs(v.doors or {}) do
			if(DarkRP.doorIndexToEnt(b.id) and !DarkRP.doorIndexToEnt(b.id):isKeysOwned()) then
				local door
				local pos
				
				for c,d in pairs(v.doors) do
					if(door) then continue end
					if(d.main) then
						door = d

						local d = DarkRP.doorIndexToEnt(door.id)
						pos = d:GetPos() + d:GetAngles():Right()*-23 + Vector(0,0,-40)
					end
				end

				return v,door,pos
			end	
		end 
	end
end

hook.Add('playerKeysSold', 'mani:DisconnectOnPower', function(ply, door, money)
	if(door and IsValid(door) and door:isDoor()) then
		local building
		for k,v in pairs(manolis.popcorn.buildings.buildings) do
			for a,b in pairs(v.doors or {}) do
				if(b.id==door:getDoorData().MapID) then
					building = v
				end
			end
		end

		if(building) then
			for k,v in pairs(ents.GetAll()) do
				if(v.connectedBuilding) then
					if(v.connectedBuilding.bid == building.bid) then
						v:SetHasPower(0)
						if(v.OnPowerDisconnected) then
							v:OnPowerDisconnected()
						end
						v.connectedBuilding = nil
					end
				end
			end
		end
	end
end)

concommand.Add('ManolisPopcornUpgradeBuilding', function(ply,x,args,s)
	if(!IsValid(ply) or !ply:IsPlayer() or !args[1] or !args[2] or #args[1]<2) then return end
	args[1] = tonumber(args[1])
	args[2] = tonumber(args[2])

	local door = DarkRP.doorIndexToEnt(args[2])

	if(!door or !IsValid(door) or !door:isDoor()) then
		return
	end

	local owner = door:getDoorOwner()
	local co = door:getKeysCoOwners() or {}
	
	if(owner!=ply and !co[ply:UserID()]) then
		DarkRP.notify(ply,1,4,DarkRP.getPhrase('building_mustownupgrade'))
		return
	end
	
	if(args[1] != 2 and args[1] != 1) then
		return
	end
	
	local uKey = 'power'
	if(args[1]==2) then
		uKey = 'lockpick'
	end

    local found = false
	for k,v in pairs(manolis.popcorn.buildings.buildings) do
	    for a,b in pairs(v.doors or {}) do
	    	if(b.id == args[2]) then
   				found = v
   			end
   		end
   	end

    if(!found) then
    	return
    else
    	local currentUpgradeLevel = manolis.popcorn.buildings.buildingUpgrades[found.id] and manolis.popcorn.buildings.buildingUpgrades[found.id][uKey] or 0
    	if(!currentUpgradeLevel) then currentUpgradeLevel = 0 end

    	if(currentUpgradeLevel >= 4) then
    		DarkRP.notify(ply,1,4,DarkRP.getPhrase('building_topupgrade'))
    		return
    	end

    	local newPrice = manolis.popcorn.config.buildingUpgrades[uKey][currentUpgradeLevel+1]
    	if(ply:canAfford(newPrice)) then
    		if(!manolis.popcorn.buildings.buildingUpgrades[found.id]) then
    			manolis.popcorn.buildings.buildingUpgrades[found.id] = {}
    		end
    		manolis.popcorn.buildings.buildingUpgrades[found.id][uKey] = currentUpgradeLevel+1
    		ply:addMoney(-newPrice)
    		DarkRP.notify(ply,0,4,DarkRP.getPhrase('building_upgradeapplied', DarkRP.formatMoney(newPrice)))	

    		net.Start('ManolisPopcornBuildingUpgradeUpdate')
    			net.WriteTable({key=found.id, data=manolis.popcorn.buildings.buildingUpgrades[found.id]})
			net.Broadcast()
    	else
    		DarkRP.notify(ply,1,4,DarkRP.getPhrase('building_cannotaffordupgrade'))
    	end
	end
end)

concommand.Add('ManolisPopcornNewBuilding',function(ply,x,args,s)
	if(!IsValid(ply) or !ply:IsPlayer() or !args[1] or #args[1]<1) then
		return
	end
	if(manolis.popcorn.config.canEditServer(ply)) then
		manolis.popcorn.buildings.newBuilding(game.GetMap(), args[1], function()
			manolis.popcorn.buildings.retrieveBuildings(function(data)
				net.Start('ManolisPopcornBuildingUpdate')	
					net.WriteTable(data)
				net.Broadcast()
			end)
			DarkRP.notify(ply,0,4,DarkRP.getPhrase('building_created'))			
		end)
	end
end)

concommand.Add('ManolisPopcornRemoveBuilding', function(ply,x,args,s)
	if(!IsValid(ply) or !ply:IsPlayer() or !args or !args[1] or !tonumber(args[1])) then
		return
	end	

	if(manolis.popcorn.config.canEditServer(ply)) then
		manolis.popcorn.buildings.removeBuilding(args[1],function()
			manolis.popcorn.buildings.retrieveBuildings(function(data)
					net.Start('ManolisPopcornBuildingUpdate')	
						net.WriteTable(data)
					net.Broadcast()
				DarkRP.notify(ply,0,4,DarkRP.getPhrase('building_removed'))	
			end)		
		end)
	end
end)

concommand.Add('ManolisPopcornSetRent',function(ply,x,args,s)
	if(!IsValid(ply) or !ply:IsPlayer() or !args or !args[1] or !tonumber(args[1]) or !args[2] or !tonumber(args[2]) or (0>tonumber(args[1])) or (0>tonumber(args[2]))) then
		return
	end	
	
	if(manolis.popcorn.config.canEditServer(ply)) then
		manolis.popcorn.buildings.saveRent(args[1],args[2],function(data)
			manolis.popcorn.buildings.retrieveBuildings(function(data)
					net.Start('ManolisPopcornBuildingUpdate')	
						net.WriteTable(data)
					net.Broadcast()
				DarkRP.notify(ply,0,4,DarkRP.getPhrase('builidng_rent_set'))	
			end)
		end)
	end
end)

concommand.Add('ManolisPopcornClearPowerPoints', function(ply,x,args,s)
	if(!IsValid(ply) or !ply:IsPlayer() or !args or !args[1] or !tonumber(args[1])) then
		return
	end	

	if(manolis.popcorn.config.canEditServer(ply)) then
		manolis.popcorn.buildings.removeSockets(args[1],function()
			manolis.popcorn.buildings.RefreshPowerPoints()
			DarkRP.notify(ply,0,4,DarkRP.getPhrase('building_powerremoved'))
		end)
	end
end)

concommand.Add('ManolisPopcornClearCashSpawn', function(ply,x,args,s)
	if(!IsValid(ply) or !ply:IsPlayer() or !args or !args[1] or !tonumber(args[1])) then
		return
	end	

	if(manolis.popcorn.config.canEditServer(ply)) then
		manolis.popcorn.buildings.removeCash(args[1],function()
			manolis.popcorn.buildings.RefreshCashStacks()
			DarkRP.notify(ply,0,4,DarkRP.getPhrase('cashstack_remove'))
		end)
	end
end)

concommand.Add('ManolisPopcornClearCapturePoint', function(ply,x,args,s)
	if(!IsValid(ply) or !ply:IsPlayer() or !args or !args[1] or !tonumber(args[1])) then
		return
	end	

	if(manolis.popcorn.config.canEditServer(ply)) then
		manolis.popcorn.buildings.removeCapture(args[1],function()
			manolis.popcorn.buildings.RefreshCapturePoints()
			DarkRP.notify(ply,0,4,DarkRP.getPhrase('building_captureremoved'))
		end)
	end
end)

concommand.Add('ManolisPopcornSaveCapturePoint', function(ply,x,args,s)
	if(!IsValid(ply) or !ply:IsPlayer() or !args[1]) then
		return
	end

	if(!manolis.popcorn.config.canEditServer(ply)) then return false end
	local trace = ply:GetEyeTrace()
    local found = false

    for k,v in pairs(manolis.popcorn.buildings.buildings) do
    	if(tonumber(v.id)==tonumber(args[1])) then
    		found = v
    	end
    end

    if(!found) then
    	return
    else
    	manolis.popcorn.buildings.hasCapturePoint(found.id, function(a)
    		if(a) then
    			DarkRP.notify(ply,1,4,DarkRP.getPhrase('building_alreadyhascapture'))
    		else
    			manolis.popcorn.buildings.saveCapturePoint(found.id, trace.HitPos, trace.HitNormal:Angle(), function()
    				DarkRP.notify(ply,0,4,DarkRP.getPhrase('building_capturesaved'))
    				manolis.popcorn.buildings.RefreshCapturePoints()
    			end)
    		end
    	end)
    end
end)

concommand.Add('ManolisPopcornSaveCashStack', function(ply,cmd,args)
	if(!IsValid(ply) or !ply:IsPlayer() or !args[1]) then
		return
	end

	if(!manolis.popcorn.config.canEditServer(ply)) then return false end
	local trace = ply:GetEyeTrace()
    local found = false

    for k,v in pairs(manolis.popcorn.buildings.buildings) do
    	if(tonumber(v.id)==tonumber(args[1])) then
    		found = v
    	end
    end

	if(!found) then
    	return
    else
    	manolis.popcorn.buildings.hasCashSpawn(found.id, function(a)
		if(a) then
    			DarkRP.notify(ply,1,4,DarkRP.getPhrase('building_alreadyhascash'))
    		else

	   		manolis.popcorn.buildings.saveCashStack(found.id, trace.HitPos, Vector(0,0,0), function()
				DarkRP.notify(ply,0,4,DarkRP.getPhrase('cashstack_save'))
				manolis.popcorn.buildings.RefreshCashStacks()
	  		end)
    	end
    	end)

    end
end)

concommand.Add('ManolisPopcornSavePowerPoint', function(ply,x,args,s)
	if(!IsValid(ply) or !ply:IsPlayer() or !args[1]) then
		return
	end

	if(!manolis.popcorn.config.canEditServer(ply)) then return false end
	local trace = ply:GetEyeTrace()
    local found = false

    for k,v in pairs(manolis.popcorn.buildings.buildings) do
    	if(tonumber(v.id)==tonumber(args[1])) then
    		found = v
    	end
    end

    if(!found) then
    	return
    else
   		manolis.popcorn.buildings.savePowerPoint(found.id, trace.HitPos+trace.HitNormal:Angle():Forward()*2, trace.HitNormal:Angle(), function()
			DarkRP.notify(ply,0,4,DarkRP.getPhrase('building_savesocket'))
			manolis.popcorn.buildings.RefreshPowerPoints()
  		end)
    end
end)

concommand.Add('ManolisPopcornSaveDoor', function(ply,x,args,s)
	if(!IsValid(ply) or !ply:IsPlayer() or !args[1]) then
		return
	end

    local trace = ply:GetEyeTrace()
    local ent = trace.Entity
    if(!ent) then return false end
    if(!ent:CreatedByMap()) then return false end

    if not IsValid(ent) or (not ent:isDoor() and not ent:IsVehicle()) or ply:GetPos():Distance(ent:GetPos()) > 200 then
        DarkRP.notify(ply, 1, 4, DarkRP.getPhrase('must_be_looking_at', DarkRP.getPhrase('door_or_vehicle')))
        return
    end

    local found = false
    for k,v in pairs(manolis.popcorn.buildings.buildings) do
    	if(tonumber(v.id)==tonumber(args[1])) then
    		found = v
    	end
    end

    if(!found) then
    	DarkRP.notify(ply,1,4,DarkRP.getPhrase('building_notfound'))
    else
    	manolis.popcorn.buildings.newDoor(ent:doorIndex(),game.GetMap(), args[2] and 1 or 0, found.id, function()
    		DarkRP.notify(ply,0,4,DarkRP.getPhrase('building_set'))
    		manolis.popcorn.buildings.retrieveBuildings(function(data)
				net.Start('ManolisPopcornBuildingUpdate')	
					net.WriteTable(data)
				net.Broadcast()
			end)
    	end)
    end
end)


manolis.popcorn.buildings.RefreshPowerPoints = function()
	for k,v in pairs(manolis.popcorn.buildings.buildingPowerPoints) do
		for a,b in pairs(v) do
			if(b.ent and IsValid(b.ent)) then
				b.ent:Remove()
			end
		end
	end

	manolis.popcorn.buildings.retrieveBuildingPowerPoints(function(t)
		for k,v in pairs(t) do
			for a,b in pairs(v) do
				local cap = ents.Create('building_plug')
				cap:SetPos(b.pos)
				cap:SetAngles(b.ang)
				cap:Spawn()
				cap.HasBeenSetup = true
				cap:SetBuildingID(b.bid)

				b.ent = cap
			end
		end

		manolis.popcorn.buildings.buildingPowerPoints = t
	end)
end

manolis.popcorn.buildings.RefreshCashStacks = function()
	manolis.popcorn.buildings.retrieveBuildingCashStacks(function(c)
		for k,v in pairs(c) do
			manolis.popcorn.buildings.buildingCash[v.bid] = v
		end
	end)
end

manolis.popcorn.buildings.RefreshCapturePoints = function()
	for k,v in pairs(manolis.popcorn.buildings.buildingCapturePoints) do
		if(v.ent and IsValid(v.ent)) then
			v.ent:Remove()
		end
	end

	manolis.popcorn.buildings.retrieveBuildingCapturePoints(function(t)
		for k,v in pairs(t) do
			local cap = ents.Create('capture_point')
			cap:SetPos(v.pos)
			cap:SetAngles(v.ang)
			cap:Spawn()
			cap.HasBeenSetup = true
			cap:SetBuildingID(v.bid)
			v.ent = cap
		end

		manolis.popcorn.buildings.buildingCapturePoints = t
	end)
end


manolis.popcorn.buildings.CaptureBuilding = function(ply, building)
	local foundBuilding = false
	if(!ply) then
		return false
	end
	
	for k,v in pairs(manolis.popcorn.buildings.buildings) do
		if(v.id == building) then
			if(v.ownedBy and IsValid(v.ownedBy)) then
				DarkRP.notify(v.ownedBy,1,4,DarkRP.getPhrase('building_lost',v.name))
			end

			v.ownedBy = ply
			for k,v in pairs(v.doors) do
				local door = DarkRP.doorIndexToEnt(v.id)
				if(door and IsValid(door) and door:isDoor()) then 
					door:keysUnOwn()
					door:keysOwn(ply)
				end
			end

			DarkRP.notify(ply,0,4,DarkRP.getPhrase('building_captured',v.name))
		end
	end
end

manolis.popcorn.buildings.buyPlayer = function(ply,building)
    for k,v in pairs(building.doors) do
        local v = DarkRP.doorIndexToEnt(v.id)
        v:keysOwn(ply)
    end
end

local haveRefreshed = false
hook.Add("PlayerInitialSpawn", "SpawnStuffBuildingsManolis", function()
	if(!haveRefreshed) then
		manolis.popcorn.buildings.RefreshCapturePoints()
		manolis.popcorn.buildings.RefreshPowerPoints()
		manolis.popcorn.buildings.RefreshCashStacks()

		haveRefreshed = true
	end
end)

hook.Add('DarkRPDBInitialized', 'manolisBuildingsLoad', function()
	local found = {}
	local class = {
		'func_door',
		'func_door_rotating',
		'prop_door_rotating',
		'prop_dynamic'
	}

	for k,v in pairs(class) do
		local e = ents.FindByClass(v)
		for k,v in pairs(e) do
			table.insert(found, v)
		end
	end

	for k,v in pairs(found) do
		v:Fire('unlock', '', .5)
	end
end)

hook.Add('canPropertyTax', 'propertyTaxManolis', function(ply, tax)
    local ownedBuildings = {}
    local totalRent = 0

    for k,v in pairs(manolis.popcorn.buildings.buildings) do
        if(v.doors) then
            for k2,v2 in pairs(v.doors) do
                if(v2.id and DarkRP.doorIndexToEnt(v2.id) and DarkRP.doorIndexToEnt(v2.id):isKeysOwnedBy(ply)) then
                    ownedBuildings[k] = v.name
                end
            end
        end
    end

    for k,v in pairs(ownedBuildings) do
        local rent = manolis.popcorn.config.defaultRent 
        if(manolis.popcorn.buildings.buildings[k] and manolis.popcorn.buildings.buildings[k].rent) then
            rent = manolis.popcorn.buildings.buildings[k].rent
            DarkRP.notify(ply,0,4,DarkRP.getPhrase('building_rent', DarkRP.formatMoney(rent),v))
        end

        totalRent = totalRent + rent
    end

    return true, totalRent
end)



hook.Add('PlayerInitialSpawn', 'manolisBuildingsSendBuildingData', function(ply)
	manolis.popcorn.buildings.retrieveBuildings(function(data)
		net.Start('ManolisPopcornBuildingUpdate')	
			net.WriteTable(data)
		net.Send(ply)
		
		net.Start('ManolisPopcornBuildingUpgradeData')
			net.WriteTable(manolis.popcorn.buildings.buildingUpgrades)
		net.Send(ply)
	end)
end)

