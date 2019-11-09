if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.levels) then manolis.popcorn.levels = {} end

resource.AddSingleFile('materials/manolis/popcorn/xp_bar.png')

local meta = FindMetaTable("Player")

hook.Add("PlayerInitialSpawn", "manolis:popcorn:PlayerSpawnRetrieveLevels", function(ply)
	timer.Simple(.5, function()
		manolis.popcorn.levels.RetrievePlayerLevelData(ply)
	end)
end)

manolis.popcorn.levels.SetLevel = function(ply, level)
	if !level or !ply or !ply:IsPlayer() or !tonumber(level) then return end
	return ply:setDarkRPVar('level', tonumber(level))
end

manolis.popcorn.levels.SetXP = function(ply, xp)
	if !xp or !ply or !ply:IsPlayer() or !tonumber(xp) then return end
	return ply:setDarkRPVar('xp', tonumber(xp))
end

manolis.popcorn.levels.AddXP = function(ply, amount, notify)
	if(!IsValid(ply) or !tonumber(amount)) then return end

	local playerLevel = manolis.popcorn.levels.GetLevel(ply)
	local playerXP = manolis.popcorn.levels.GetXP(ply)

	amount = hook.Call("manolis:PlayerGetXP", DarkRP.hooks, ply, amount)

	if(ply.manolisXPMult) then amount = amount * ply.manolisXPMult end

	if(ply.syndicateCreditShop and ply.syndicateCreditShop.hasXPTalisman) then
		local credit = manolis.popcorn.creditShop.findItem('xp')
		if(credit) then
			amount = amount * (1+(credit.affectLevels[1]/100))
		end
	end

	amount = math.ceil(tonumber(amount))
	if !notify then
		DarkRP.notify(ply, 0, 4, DarkRP.getPhrase('level_xp_get',amount))
	end


	
	amount = amount * (manolis.popcorn.config.XPMult or 1)

	local totalXP = playerXP + amount

	if(playerLevel>=99) then return amount end

	if( totalXP >= manolis.popcorn.levels.GetMaxXP(playerLevel) ) then
		DarkRP.notifyAll(0,4,DarkRP.getPhrase('level_player_up', ply:Name(), playerLevel+1))
		hook.Call("manolis:PlayerLevelUp", DarkRP.hooks, ply, playerLevel+1)

		manolis.popcorn.levels.SetLevel(ply,playerLevel+1)
		manolis.popcorn.levels.SetXP(ply, 0)

		manolis.popcorn.levels.StoreXPData(ply, playerLevel+1, 0)
	else
		manolis.popcorn.levels.StoreXPData(ply, playerLevel, totalXP)
		manolis.popcorn.levels.SetXP(ply, totalXP)
	end

	return amount
end

local meta = FindMetaTable("Player")
function meta:AddXP(amount, supress)
	return manolis.popcorn.levels.AddXP(self, amount, supress)
end

meta.addXP = meta.AddXP