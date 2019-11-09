if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.achievements) then manolis.popcorn.achievements = {} end

manolis.popcorn.achievements.retrievePlayerAchievements = function(ply,callback)
	MySQLite.query("SELECT aid, progress FROM manolis_popcorn_achievements WHERE uid = "..MySQLite.SQLStr(ply:SteamID64()), function(data) 
		if(!data) then data = {} end 
		callback(data)
	end)
end


manolis.popcorn.achievements.sendSpecific = function(ply, aid, progress)
	local toSend = {aid=aid, progress = progress}
	net.Start("ManolisPopcornAchievementUpdate")
		net.WriteTable(toSend)
	net.Send(ply)
end

manolis.popcorn.achievements.sendWin = function(ply, aid, progress)
	net.Start("ManolisPopcornAchievementWin")
		net.WriteTable({aid=aid, progress = progress})
	net.Send(ply)
end

manolis.popcorn.achievements.getProgress = function(ply,aid,callback)
	MySQLite.query("SELECT progress FROM manolis_popcorn_achievements WHERE aid = "..MySQLite.SQLStr(aid).." AND uid = "..MySQLite.SQLStr(ply:SteamID64()), function(data)
		if(!data) then data = 0 
		else data = data[1] and data[1]['progress'] end
		callback(data)
	end)
end

manolis.popcorn.achievements.addProgress = function(ply, aid, progressA, callback)
	local a = manolis.popcorn.achievements.Find(aid)
	if(a) then
		MySQLite.query("SELECT progress FROM manolis_popcorn_achievements WHERE uid = "..MySQLite.SQLStr(ply:SteamID64()).." AND aid = "..MySQLite.SQLStr(aid), function(data)
			if(data and data[1]) then
				data = data[1].progress
			end


			local progress = data or 0
			local newProgress = progress + progressA
			if(progress>a.maxProgress) then
				MySQLite.query("UPDATE manolis_popcorn_achievements SET progress = "..newProgress.." WHERE aid = "..MySQLite.SQLStr(aid).." AND uid = "..MySQLite.SQLStr(ply:SteamID64()), function(d)
					manolis.popcorn.achievements.sendSpecific(ply,aid,newProgress)
				end)
				return
			end

			if(newProgress>=a.maxProgress) then
				MySQLite.query("INSERT INTO manolis_popcorn_achievements VALUES(null, "..MySQLite.SQLStr(aid)..", "..MySQLite.SQLStr(newProgress)..", "..MySQLite.SQLStr(ply:SteamID64())..") ON DUPLICATE KEY UPDATE progress =  "..MySQLite.SQLStr(newProgress), function(d)
					manolis.popcorn.achievements.sendWin(ply,aid,newProgress)
				end)
				return
			end
	
			MySQLite.query("INSERT INTO manolis_popcorn_achievements VALUES(null, "..MySQLite.SQLStr(aid)..", "..MySQLite.SQLStr(newProgress)..", "..MySQLite.SQLStr(ply:SteamID64())..") ON DUPLICATE KEY UPDATE progress =  "..MySQLite.SQLStr(newProgress), function()
				manolis.popcorn.achievements.sendSpecific(ply, aid, newProgress)
			end)
		end)
	else
		MySQLite.query("SELECT progress FROM manolis_popcorn_achievements WHERE uid = "..MySQLite.SQLStr(ply:SteamID64()).." AND aid = "..MySQLite.SQLStr(aid), function(data)
			if(data and data[1]) then
				data = data[1].progress
			end


			local progress = data or 0
			local newProgress = progress + progressA
	
			MySQLite.query("INSERT INTO manolis_popcorn_achievements VALUES(null, "..MySQLite.SQLStr(aid)..", "..MySQLite.SQLStr(newProgress)..", "..MySQLite.SQLStr(ply:SteamID64())..") ON DUPLICATE KEY UPDATE progress =  "..MySQLite.SQLStr(newProgress), function()
				manolis.popcorn.achievements.sendSpecific(ply, aid, newProgress)
			end)
		end)
	end
end
