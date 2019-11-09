if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.buildings) then manolis.popcorn.buildings = {} end
if(!manolis.popcorn.buildings.buildings) then manolis.popcorn.buildings.buildings = {} end
if(!manolis.popcorn.buildings.buildingsWithDoors) then manolis.popcorn.buildings.buildingsWithDoors = {} end

manolis.popcorn.buildings.retrieveBuildings = function(callback)
	MySQLite.query("SELECT * FROM manolis_popcorn_buildings LEFT JOIN manolis_popcorn_buildings_rent ON manolis_popcorn_buildings_rent.bid = manolis_popcorn_buildings.id WHERE manolis_popcorn_buildings.map = "..MySQLite.SQLStr(game.GetMap())..' ORDER BY manolis_popcorn_buildings.id', function(data) 
		if(!data) then data = {} end 
		manolis.popcorn.buildings.buildings = data
		manolis.popcorn.buildings.retrieveBuildingDoors(function(door)
			for k,v in pairs(manolis.popcorn.buildings.buildings) do
				v.doors = {}
				for k2,v2 in pairs(door) do
					if(v.id == v2.bid) then
						table.insert(v.doors, v2)
					end
				end
			end

			callback(manolis.popcorn.buildings.buildings)
		end)
	end)
end

manolis.popcorn.buildings.retrieveBuildingCapturePoints = function(callback)
	MySQLite.query("SELECT bid,px,py,pz,a1,a2,a3 FROM manolis_popcorn_buildings_capturepoints WHERE map = "..MySQLite.SQLStr(game.GetMap()), function(a)
		local points = {}
		for k,v in pairs(a or {}) do

			local pos = Vector(v.px, v.py, v.pz)
			local ang = Angle(v.a1,v.a2,v.a3)
			local bid = v.bid

			points[bid] = {pos = pos, ang = ang, bid = bid}
		end

		if(callback) then
			callback(points)
		end
	end)	
end 

manolis.popcorn.buildings.retrieveBuildingPowerPoints = function(callback)
	local buildings = {}
	manolis.popcorn.buildings.retrieveBuildings(function(a)
		for k,v in pairs(a) do
			buildings[v.id] = {}
		end

		MySQLite.query("SELECT bid,px,py,pz,a1,a2,a3 FROM manolis_popcorn_buildings_power WHERE map = "..MySQLite.SQLStr(game.GetMap()), function(a)
				
			for k,v in pairs(a or {}) do
				if(buildings[v.bid]) then
					local pos = Vector(v.px, v.py, v.pz)
					local ang = Angle(v.a1,v.a2,v.a3)
					local bid = v.bid
					local bins = {pos=pos,ang=ang,bid=bid}
					table.insert(buildings[v.bid],bins)
				end
			end
		
			if(callback) then
				callback(buildings)
			end
		end)
	end)
end

manolis.popcorn.buildings.retrieveBuildingCashStacks = function(callback)
	MySQLite.query("SELECT bid,px,py,pz,a1,a2,a3 FROM manolis_popcorn_buildings_cash WHERE map = "..MySQLite.SQLStr(game.GetMap()), function(a)
		local points = {}
		for k,v in pairs(a or {}) do

			local pos = Vector(v.px, v.py, v.pz)
			local ang = Angle(v.a1,v.a2,v.a3)
			local bid = v.bid

			table.insert(points, {pos = pos, ang = ang, bid = bid})
		end


		if(callback) then
			callback(points)
		end
	end)	
end 

manolis.popcorn.buildings.hasCapturePoint = function(b, callback)
	MySQLite.query("SELECT id FROM manolis_popcorn_buildings_capturepoints WHERE map = "..MySQLite.SQLStr(game.GetMap()).." AND bid = "..MySQLite.SQLStr(b), function(a)
		if(!a or !a[1]) then
			callback(false)
		else
			callback(true)
		end
	end)
end

manolis.popcorn.buildings.hasCashSpawn = function(b, callback)
	MySQLite.query("SELECT id FROM manolis_popcorn_buildings_cash WHERE map = "..MySQLite.SQLStr(game.GetMap()).." AND bid = "..MySQLite.SQLStr(b), function(a)
		if(!a or !a[1]) then
			callback(false)
		else
			callback(true)
		end
	end)
end


manolis.popcorn.buildings.saveCapturePoint = function(building, pos, angles, callback)
	MySQLite.query("INSERT INTO manolis_popcorn_buildings_capturepoints VALUES(null,"..MySQLite.SQLStr(game.GetMap())..", "..MySQLite.SQLStr(building)..", "..MySQLite.SQLStr(pos.x)..","..MySQLite.SQLStr(pos.y)..","..MySQLite.SQLStr(pos.z)..","..MySQLite.SQLStr(angles.x)..","..MySQLite.SQLStr(angles.y)..","..MySQLite.SQLStr(angles.z)..")", function(a)
		callback()
	end)
end

manolis.popcorn.buildings.saveRent = function(building, rent, callback)
	MySQLite.query("INSERT INTO manolis_popcorn_buildings_rent VALUES("..MySQLite.SQLStr(building)..","..MySQLite.SQLStr(rent)..") ON DUPLICATE KEY UPDATE rent = "..MySQLite.SQLStr(rent), function()
		if(callback) then callback() end
	end)
end

manolis.popcorn.buildings.saveCashStack = function(building,pos,angles,callback)
	MySQLite.query("INSERT INTO manolis_popcorn_buildings_cash VALUES(null,"..MySQLite.SQLStr(game.GetMap())..", "..MySQLite.SQLStr(building)..", "..MySQLite.SQLStr(pos.x)..","..MySQLite.SQLStr(pos.y)..","..MySQLite.SQLStr(pos.z)..","..MySQLite.SQLStr(angles.x)..","..MySQLite.SQLStr(angles.y)..","..MySQLite.SQLStr(angles.z)..")", function(a)
		callback()
	end)
end

manolis.popcorn.buildings.savePowerPoint = function(building, pos, angles, callback)
	MySQLite.query("INSERT INTO manolis_popcorn_buildings_power VALUES(null,"..MySQLite.SQLStr(game.GetMap())..", "..MySQLite.SQLStr(building)..", "..MySQLite.SQLStr(pos.x)..","..MySQLite.SQLStr(pos.y)..","..MySQLite.SQLStr(pos.z)..","..MySQLite.SQLStr(angles.x)..","..MySQLite.SQLStr(angles.y)..","..MySQLite.SQLStr(angles.z)..")", function(a)
		callback()
	end)
end

manolis.popcorn.buildings.retrieveBuildingDoors = function(callback)
	MySQLite.query("SELECT * FROM manolis_popcorn_buildings_doors WHERE map = "..MySQLite.SQLStr(game.GetMap()).." ORDER BY id", function(data)
		if(!data) then data = {} end
		manolis.popcorn.buildings.buildingsWithDoors = data

		callback(data)
	end)
end


manolis.popcorn.buildings.newBuilding = function(map, name, callback)
	MySQLite.query("INSERT INTO manolis_popcorn_buildings VALUES(null, "..MySQLite.SQLStr(map)..", "..MySQLite.SQLStr(name)..")", function(data)
		if(callback) then
			callback(data)
		end
	end)
end

manolis.popcorn.buildings.newDoor = function(door, map, main, bid, callback)
	MySQLite.query("INSERT INTO manolis_popcorn_buildings_doors VALUES("..MySQLite.SQLStr(door)..", "..MySQLite.SQLStr(map)..", "..MySQLite.SQLStr(main)..","..MySQLite.SQLStr(bid)..") ON DUPLICATE KEY UPDATE main ="..MySQLite.SQLStr(main).." , bid = "..MySQLite.SQLStr(bid), function(data)
		if(callback) then
			callback(data)
		end
	end)
end

manolis.popcorn.buildings.removeBuilding = function(id, callback)
	MySQLite.query("DELETE FROM manolis_popcorn_buildings WHERE id = "..MySQLite.SQLStr(id), function(data)
		MySQLite.query("DELETE FROM manolis_popcorn_buildings_doors WHERE bid = "..MySQLite.SQLStr(id), function()
			if(callback) then
				callback(data)
			end
		end)
	end)
end

manolis.popcorn.buildings.removeSockets = function(id,callback)
	MySQLite.query("DELETE FROM manolis_popcorn_buildings_power WHERE bid = "..MySQLite.SQLStr(id),function(d)
		if(callback) then
			callback(data)
		end
	end)
end

manolis.popcorn.buildings.removeCapture = function(id,callback)
	MySQLite.query("DELETE FROM manolis_popcorn_buildings_capturepoints WHERE bid = "..MySQLite.SQLStr(id),function(d)
		if(callback) then
			callback(data)
		end
	end)
end

manolis.popcorn.buildings.removeCash = function(id,callback)
	MySQLite.query("DELETE FROM manolis_popcorn_buildings_cash WHERE bid = "..MySQLite.SQLStr(id),function(d)
		if(callback) then
			callback(data)
		end
	end)
end