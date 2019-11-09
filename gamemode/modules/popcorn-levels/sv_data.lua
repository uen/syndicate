if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.levels) then manolis.popcorn.levels = {} end

manolis.popcorn.levels.RetrievePlayerLevelXP = function(ply, callback)
	MySQLite.query("SELECT level, xp FROM manolis_popcorn_levels WHERE uid = "..MySQLite.SQLStr(ply:SteamID64()), function(data) callback(data) end)
end

manolis.popcorn.levels.RetrievePlayerLevelData = function(ply)
	if not IsValid(ply) then return end
	manolis.popcorn.levels.RetrievePlayerLevelXP(ply, function(data)
		local info = data and data[1] or {}
		info.xp = (info.xp or 0)
		info.level = (info.level or 1)
		manolis.popcorn.levels.SetLevel(ply, info.level)
		manolis.popcorn.levels.SetXP(ply, info.xp)
		if not data then manolis.popcorn.levels.CreatePlayerLevelData(ply) end
	end)
end

manolis.popcorn.levels.CreatePlayerLevelData = function(ply)
	MySQLite.query([[REPLACE INTO manolis_popcorn_levels VALUES(]]..MySQLite.SQLStr(ply:SteamID64()) .. [[,'1','0')]])
end

manolis.popcorn.levels.StoreXPData = function(ply, level, xp)
	xp = math.max(xp,0)
	MySQLite.query("UPDATE manolis_popcorn_levels SET level = " ..MySQLite.SQLStr(level) ..", xp = "..MySQLite.SQLStr(xp).." WHERE uid = "..MySQLite.SQLStr(ply:SteamID64()))
end