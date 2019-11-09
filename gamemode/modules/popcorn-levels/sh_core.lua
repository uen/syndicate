if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.levels) then manolis.popcorn.levels = {} end

local function checkLevel(ply,entity)
	if(entity.level) then
		if not(manolis.popcorn.levels.HasLevel(ply, entity.level)) then
			if(SERVER) then
				DarkRP.notify(ply,1,2,DarkRP.getPhrase("wrong_level_item", entity.level, entity.name))
			end
			return false,true
		end
	end
end

hook.Add('canBuyPistol', 'manolis:popcorn:LevelPistolCheck', checkLevel)
hook.Add('canBuyAmmo', 'manolis:popcorn:LevelAmmoCheck', checkLevel)
hook.Add('canBuyShipment', 'manolis:popcorn:LevelShipmentCheck', checkLevel)
hook.Add('canBuyVehicle', 'manolis:popcorn:LevelVehicleCheck', checkLevel)
hook.Add('canBuyCustomEntity', 'manolis:popcorn:CEntCheck', checkLevel)

hook.Add('playerCanChangeTeam', 'manolis:popcorn:PlayerChangeTeam', function(ply, jobno) // Fun fact: The code below was taken from code that I wrote when I was 11!
	job = RPExtraTeams[jobno]
	if (job.level) then
		if not ((ply:getDarkRPVar('level') or 0) >= (job.level)) then	
			return false, DarkRP.getPhrase("wrong_level_job", job.level, job.name)
		end
	end
end)