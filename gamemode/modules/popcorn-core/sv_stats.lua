local meta = FindMetaTable('Player')
meta.SendStats = function(ply)
	ply:setDarkRPVar('playerstatsmv', ply.playerStats)
end

hook.Add( "PlayerDeath", "MVLoadingScreen:PlayerDeathX", function(victim)
	if(victim:IsPlayer()) then
		victim:AddAchievementProgress('deaths', 1)
	end
end)


hook.Add( "PlayerInitialSpawn", "MVLoadingScreen:PlayerJoin:XGWM", function(ply)
	timer.Simple(2, function()
		ply.playerStats = {
			joins = 0,
			kills = 0,
			deaths = 0
		}
		
		ply:GetAchievementProgress('massmurder', function(kills)
			ply.playerStats['kills'] = kills or 0
			ply.playerStats['level'] = ply:getDarkRPVar('level') or 1
			ply:GetAchievementProgress('joins', function(joins)
				ply.playerStats['joins'] = joins + 1
				ply:AddAchievementProgress('joins',1)
				ply:GetAchievementProgress('deaths', function(deaths)
					ply.playerStats['deaths'] = deaths
					ply:SendStats()
				end)
			end)
		end)
	end)
end)
