if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.garage) then manolis.popcorn.garage = {} end

manolis.popcorn.garage.HasCar = function(ply,name,callback)
	MySQLite.query("SELECT name FROM manolis_popcorn_garage WHERE uid = "..MySQLite.SQLStr(ply:SteamID64()).. " AND name = "..MySQLite.SQLStr(name), function(data)
		if(data and data[1]) then
			callback(true)
		else
			callback(false)
		end
	end)
end

manolis.popcorn.garage.AddCar = function(ply,name,callback)
	local car = manolis.popcorn.garage.Find(name)
	if(car) then
		local upgrades = {}
		upgrades.engine = 0
		upgrades.armor = 0
		upgrades.nitro = 0

		local upg = util.TableToJSON(upgrades)
		MySQLite.query("INSERT INTO manolis_popcorn_garage VALUES(null, "..MySQLite.SQLStr(ply:SteamID64())..", "..MySQLite.SQLStr(name)..', '..MySQLite.SQLStr(upg)..')', function(data)
			callback()
		end)
	end
end

manolis.popcorn.garage.GetCar = function(ply,name,callback)
	local car = manolis.popcorn.garage.Find(name)
	if(car) then
		MySQLite.query("SELECT name,json FROM manolis_popcorn_garage WHERE uid = "..MySQLite.SQLStr(ply:SteamID64()).." AND name = "..MySQLite.SQLStr(name), function(data)
			if(data and data[1]) then
				data[1].json = util.JSONToTable(data[1].json)
				callback(data[1])
			else
				callback(false)
			end
		end)

	end
end

manolis.popcorn.garage.retrievePlayerCars = function(ply,callback)
	MySQLite.query("SELECT name,json FROM manolis_popcorn_garage WHERE uid = "..MySQLite.SQLStr(ply:SteamID64()), function(data)
		if(data) then
			for k,v in pairs(data) do
				v.json = util.JSONToTable(v.json)
			end
			callback(data)
		else
			callback(false)
		end
	end)
end