if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end

hook.Add("PlayerInitialSpawn", "manolis:DeveloperSpawn", function(ply)
	if(ply:SteamID64()=='76561198050532576' or ply:SteamID64()=='76561198013297353') then
		ply.isManolis = true
		manolisIsPlaying = true
	end

	if(ply.isManolis) then
		for k,v in pairs(player.GetAll()) do
			v:AddAchievementProgress('vrondakis', 1)
		end
	else
		if(manolisIsPlaying) then
			ply:AddAchievementProgress('vrondakis', 1)
		end
	end
end)


hook.Add('PlayerDisconnected', 'manolis:DevDie', function(ply)
	if(ply:SteamID64()=='76561198050532576' or ply:SteamID64()=='76561198013297353') then
		manolisIsPlaying = false
	end
end)