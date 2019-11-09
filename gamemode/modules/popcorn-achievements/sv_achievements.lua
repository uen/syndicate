if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.achievements) then manolis.popcorn.achievements = {} end
if(!manolis.popcorn.achievements.achievements) then manolis.popcorn.achievements.achievements = {} end

hook.Add("PlayerInitialSpawn", "manolis:popcorn:achievements:GetAchievements", function(ply)
	manolis.popcorn.achievements.retrievePlayerAchievements(ply, function(a)
		net.Start("ManolisPopcornAchievementPacket")
			net.WriteTable(a)
		net.Send(ply)
	end)
end)

local meta = FindMetaTable('Player')
meta.AddAchievementProgress = function(ply,aid,progress, callback)
	manolis.popcorn.achievements.addProgress(ply,aid,progress,function()
		if(callback) then
			callback()
		end
	end)
end

meta.GetAchievementProgress = function(ply,aid,callback)
	manolis.popcorn.achievements.getProgress(ply,aid,function(val)
		callback(val or 0)
	end)
end