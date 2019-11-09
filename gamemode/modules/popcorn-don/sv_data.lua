if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.don) then manolis.popcorn.don = {} end

manolis.popcorn.don.HasGift = function(ply, name, callback)
	MySQLite.query("SELECT id FROM manolis_popcorn_gifts WHERE uid = "..MySQLite.SQLStr(ply:SteamID64()).." AND name = "..MySQLite.SQLStr(name), function(data)
		if(data) then callback(true) end
		if(!data) then callback(false) end
	end)
end

manolis.popcorn.don.AddAcceptedGift = function(ply, name,callback)
	MySQLite.query("INSERT INTO manolis_popcorn_gifts VALUES (null, "..MySQLite.SQLStr(name)..", "..MySQLite.SQLStr(ply:SteamID64())..')', function()
		if(callback) then callback() end
	end)
end