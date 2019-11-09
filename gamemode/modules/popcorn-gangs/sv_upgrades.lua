if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.gangs) then manolis.popcorn.gangs = {} end
if(!manolis.popcorn.gangs.cache) then manolis.popcorn.gangs.cache = {} end
if(!manolis.popcorn.gangs.upgrades) then manolis.popcorn.gangs.upgrades = {} end
if(!manolis.popcorn.gangs.upgrades.upgrades) then manolis.popcorn.gangs.upgrades.upgrades = {} end

hook.Add("manolis:PlayerHealthSet", "manolis:GangSetHPMod", function(ply,health,armor)
	local healthIncreaseMult = 1
	local armorIncreaseMult = 1
	if(ply:getDarkRPVar('gang')) then
		local gangId = ply:getDarkRPVar('gang')
		if(manolis.popcorn.gangs.cache[gangId]) then

			if(manolis.popcorn.gangs.cache[gangId].upgrades['gangHealth']>0) then healthIncreaseMult = healthIncreaseMult + (manolis.popcorn.gangs.upgrades.upgrades['gangHealth'].effect[manolis.popcorn.gangs.cache[gangId].upgrades['gangHealth']]/100) end
			if(manolis.popcorn.gangs.cache[gangId].upgrades['gangArmor']>0) then armorIncreaseMult = armorIncreaseMult + (manolis.popcorn.gangs.upgrades.upgrades['gangArmor'].effect[manolis.popcorn.gangs.cache[gangId].upgrades['gangArmor']]/100) end
		end

	end
	return health*healthIncreaseMult,armor*armorIncreaseMult
end)

timer.Create("manolis:GangRegeneration", 3, 0, function()
	for k,v in pairs(player.GetAll()) do
		if(v:getDarkRPVar('gang') and v:getDarkRPVar('gang')>0) then
			local gangId = v:getDarkRPVar('gang')
		

			if(manolis.popcorn.gangs.cache[gangId] and manolis.popcorn.gangs.cache[gangId].upgrades and manolis.popcorn.gangs.cache[gangId].upgrades['gangRegen']) then
				if(manolis.popcorn.gangs.cache[gangId].upgrades['gangRegen'] or 0>0) then
					if(v.lastPlayerDamage and v.lastPlayerDamage>CurTime()-30) then continue end
					if(!v:Alive()) then continue end
					local maxHealth = v:getDarkRPVar('maxhealth')
					local pInc = manolis.popcorn.gangs.upgrades.upgrades['gangRegen'].effect[manolis.popcorn.gangs.cache[gangId].upgrades['gangRegen']] or 0
					if(v:Health()<maxHealth) then
						v:SetHealth(math.Clamp(v:Health()+(maxHealth*(pInc/100)),0,maxHealth))
					end
				end
			end
		end
	end
end)