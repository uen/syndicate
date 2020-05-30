if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end

local meta = FindMetaTable('Player')

meta.LimitSpeed = function(ply)
	local walkSpeed = 150
	local runSpeed = 250

	local upgrade = 0
	if(ply.upgrades) then
		if(ply.upgrades.speed) then
			upgrade = upgrade + ply.upgrades.speed 
		end
	end

	walkSpeed = walkSpeed + (walkSpeed*(upgrade/100))
	runSpeed = runSpeed + (runSpeed*(upgrade/100))
	if(ply:getDarkRPVar('gang')) then
		if(manolis.popcorn.gangs.cache[ply:getDarkRPVar('gang')]) then
			local gangId = ply:getDarkRPVar('gang')
			if(manolis.popcorn.gangs.cache[gangId].upgrades['gangSpeed'] and (manolis.popcorn.gangs.cache[gangId].upgrades['gangSpeed']>0)) then

				local amount = manolis.popcorn.gangs.upgrades.upgrades['gangSpeed'].effect[manolis.popcorn.gangs.cache[gangId].upgrades['gangSpeed']]
				walkSpeed = walkSpeed + (walkSpeed*(amount/100))
				runSpeed = runSpeed + (runSpeed*(amount/100))
			end
		end
	end

	ply.WalkSpeed = math.Round(walkSpeed)
	ply.RunSpeed = math.Round(runSpeed)

	GAMEMODE:SetPlayerSpeed(ply, walkSpeed, runSpeed)
end


meta.LimitHealth = function(ply)
	local level = manolis.popcorn.levels.GetLevel(ply)

	local health = 100
	local armor = 0
	health = health + (level - 1) * 25
	armor = armor + (level)*10

	if(ply.upgrades) then
		if(ply.upgrades.health) then health = health + ply.upgrades.health end
		if(ply.upgrades.armor) then armor = armor + ply.upgrades.armor end
		if(ply.upgrades.healthboost) then health = health + (health * (ply.upgrades.healthboost/100)) end
		if(ply.upgrades.armorboost) then armor = armor + (armor * (ply.upgrades.armorboost/100)) end
	end

	if(ply:isCP()) then
		health = health + (health * (manolis.popcorn.config.policeHealthBoost/100))
	end

	
	local health,armor = hook.Call("manolis:PlayerHealthSet", DarkRP.hooks, ply, health, armor)
	ply:SetMaxHealth(health)

	ply:setDarkRPVar('maxhealth', health)
	ply:setDarkRPVar('maxarmor', armor)


end



meta.GetLuck = function(ply)
	local luck = 1
	if(ply:getDarkRPVar('gang')) then
		local gang = ply:getDarkRPVar('gang')
		if(manolis.popcorn.gangs.cache[gang] and manolis.popcorn.gangs.cache[gang].upgrades) then
			if(manolis.popcorn.gangs.upgrades.upgrades['gangLucky'].effect[manolis.popcorn.gangs.cache[gang].upgrades['gangLucky']]) then
				luck = luck + (1*(manolis.popcorn.gangs.cache[gang].upgrades['gangLucky'] or 0)/100)
			end
		end
	end

	if(ply.syndicateCreditShop.hasLuckTotem) then
		local credit = manolis.popcorn.creditShop.findItem('lucktotem2')
		if(credit) then
			if(credit.affectLevels[1]) then
				luck = luck + (1*(credit.affectLevels[1]/100))
			end	
		end
	end

	return luck
end


hook.Add("manolis:PlayerGetXP", "manolis:ringXPGang", function(ply,amount)

	local xpBoostMult = 1
	if(ply:getDarkRPVar('gang')) then
		local gangId = ply:getDarkRPVar('gang')
		if(manolis.popcorn.gangs.cache and manolis.popcorn.gangs.cache[gangId] and manolis.popcorn.gangs.cache[gangId].upgrades and manolis.popcorn.gangs.cache[gangId].upgrades['gangXp'] and (manolis.popcorn.gangs.cache[gangId].upgrades['gangXp']>0)) then
			xpBoostMult = xpBoostMult + (manolis.popcorn.gangs.upgrades.upgrades['gangXp'].effect[manolis.popcorn.gangs.cache[gangId].upgrades['gangXp']]/100)
		end
	end

	amount = amount * xpBoostMult

	if(ply.upgrades and (ply.upgrades.xp or 0) > 0) then
		amount = amount * (ply.upgrades.xp/100)
	end

	return amount
end)

hook.Add("canBuyCustomEntity", "manolis:popcorn:customEntityPrinter", function(ply,ent)
	if(ply:getDarkRPVar('PopcornGhost')) then
		return false,false,"You cannot buy items as a ghost"
	end

	local extraPrints = 0
	local extraForges = 0
	if(ply.syndicateCreditShop and ply.syndicateCreditShop.printIncrease) then
		extraPrints = ply.syndicateCreditShop.printIncrease
	end

	if(ply.syndicateCreditShop and ply.syndicateCreditShop.forgeMaster) then
		extraForges = ply.syndicateCreditShop.forgeMaster
	end

	if(ent.ent == 'popcorn_printer') then
		if(ply.PrinterAmount>=manolis.popcorn.config.maxPrinters+extraPrints) then
			return false,false,"You can only have "..manolis.popcorn.config.maxPrinters+extraPrints..' money printers'
		end
	elseif(ent.ent=='popcorn_forge') then
		if(ply.ForgeAmount>=manolis.popcorn.config.maxForges+extraForges) then
			return false, false, "You can only have "..manolis.popcorn.config.maxForges+extraForges..' material forges'
		end
	end
end)

hook.Add("PlayerDeath", "manolis:popcorn:PlayerDeathDo", function(ply,weapon,murderer)
	if(ply!=murderer and murderer and murderer:IsPlayer()) then
		murderer:AddAchievementProgress('massmurder',1)
	end

	if(ply!=murderer and murderer and murderer:IsPlayer()) then


		if(!ply:isWanted()) then
			if(manolis.popcorn.config.demoteOnKill) then
				if(murderer:isCP()) then
					murderer:teamBan(murderer:Team())
					murderer:SetTeam(TEAM_HOBO)
					DarkRP.notify(murderer,1,4,'You have been demoted for killing an innocent')
				end
			end
			
			if(manolis.popcorn.config.murderEvidenceDrop) then
				manolis.popcorn.gangs.IsRival(ply:getDarkRPVar('gang') or 0,murderer:getDarkRPVar('gang') or 0, function(data)
					if(!data) then
						local e = ents.Create('ent_evidence')
						e.killed = ply
						e.murderer = murderer
						e:SetPos(ply:GetPos())
						e:Spawn()
					else
	
						manolis.popcorn.gangs.AddGangKill(murderer:getDarkRPVar('gang') or 0, ply:getDarkRPVar('gang') or 0, function()
							local money = manolis.popcorn.config.killMoneyAmount(ply:getDarkRPVar('level') or 0)
				
							local onceDone = function(a)
								manolis.popcorn.gangs.AddMoney(murderer:getDarkRPVar('gang'), a)
							end
							manolis.popcorn.gangs.GetUpgradeEffect(murderer:getDarkRPVar('gang'), 'rivalBoost', function(e)
						
								if(e>0) then
									onceDone(money + (money*(e/100)))
								else
									onceDone(money)
								end
							end)
						end)
					end
				end)
			end
		end
		

		if(ply:getDarkRPVar('level')>=manolis.popcorn.config.killXPLevel and manolis.popcorn.config.takeMoneyKilled) then
			local amount = ((ply:getDarkRPVar('level') or 1) * manolis.popcorn.config.killXPLevelAmount)
			if(ply:canAfford(amount)) then
				ply:addMoney(-amount)
				DarkRP.notify(ply,0,4,'You lost '..DarkRP.formatMoney(amount)..' for being killed')
			end
		end

		if((ply:getDarkRPVar('level') or 0) >= manolis.popcorn.config.killXPLevel and (murderer:getDarkRPVar('level') or 0) >= manolis.popcorn.config.killXPLevel) then
			local a = manolis.popcorn.config.killMoneyAmount(ply:getDarkRPVar('level') or 0)
			murderer:addMoney(a)
			murderer:addXP((ply:getDarkRPVar('level') or 1) * manolis.popcorn.config.killXPLevelAmount)
			DarkRP.notify(murderer, 0,4,'You got '..DarkRP.formatMoney(a)..' for killing '..ply:Name())
		end

	end

end)

hook.Add("PlayerSpawn", "manolis:SpawnPlayer:Hands", function(ply) ply:SetupHands() end)

hook.Add("PlayerUse", "manolis:Use:Block", function(ply,ent)
	if(ply.Ghost) then
		return false
	end
end)


hook.Add("PlayerSpawnProp", "manolis:popcorn:spawnProp", function(ply)
	local limit = manolis.popcorn.config.propLimit or 30
	if(!manolis.popcorn.creditShop) then return end

	local credit = manolis.popcorn.creditShop.findItem('builder')
	if(credit) then
		if(ply.syndicateCreditShop.propIncrease) then
			limit = limit + credit.affectLevels[ply.syndicateCreditShop.propIncrease]
		end
	end

	if(ply:GetCount('props')>=limit) then
		DarkRP.notify(ply,1,4,"You have reached your prop limit")
		return false
	end
end)

hook.Add("PlayerScaleDamage", "manolis:headDamage", function(ply, hitgroup, dmginfo)
	local scale = 1
	if ( hitgroup == HITGROUP_HEAD ) then
		scale = 1.5
	end

	if ( hitgroup == HITGROUP_LEFTARM or hitgroup == HITGROUP_RIGHTARM or hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG or hitgroup == HITGROUP_GEAR ) then
		scale = 0.75
	end

	dmginfo:ScaleDamage(scale)
end)



hook.Add("PlayerInitialSpawn", "giveplayerhealthspawn:double", function(ply)
	timer.Simple(1.5, function()

		manolis.popcorn.equipment.retrievePlayerEquipmentData(ply, function(equipment) 

			for k,data in pairs(equipment or {}) do
		

				data.json = util.JSONToTable(data.json)


				if(data.json) then

					local dcD = ply.upgrades or {}
					if(data.json.upgrades) then
						if(data.json.type=="weapon") then continue end


						for k,v in pairs(data.json.upgrades) do

							if(manolis.popcorn.upgrades.upgrades[data.json.type]) then

								if(manolis.popcorn.upgrades.upgrades[data.json.type][v.class]) then
									if(!dcD[v.class]) then 
										dcD[v.class] = 0
									end 
									if(manolis.popcorn.upgrades.upgrades[data.json.type][v.class].levels) then
										dcD[v.class] = dcD[v.class] + manolis.popcorn.upgrades.upgrades[data.json.type][v.class].levels[v.level]    
									end         
								end
							end

						end

						if(!ply.armorSlots) then ply.armorSlots = {} end
						ply.armorSlots[data.json.slot] = data
					end

					if(data.json.base) then
	
						for a,b in pairs(data.json.base) do
							dcD[a] = (dcD[a] or 0) + b
						end
					end


					ply.upgrades = dcD

				end
			end

			ply:LimitHealth()

			ply:SetHealth(ply:getDarkRPVar('maxhealth'))
			ply:SetArmor(ply:getDarkRPVar('maxarmor'))
		end)

	end)
end)

hook.Add("PlayerSpawnProp", "canghostSpawnBlock", function(ply)
	if(ply:getDarkRPVar('PopcornGhost')) then
		DarkRP.notify(ply,1,4,'You cannot spawn props when you are a ghost')
		return false
	end
end)

timer.Create('maniMySQLIdiotTracerv4', 2, 0, function()
	if(MySQLite_config.EnableMySQL) then
		timer.Remove('maniMySQLIdiotTracerv4')
	else
		DarkRP.notifyAll(1,4,"You must setup MySQL for this gamemode to work.")
		DarkRP.notifyAll(1,4,"Edit /gamemode/config/mysql.lua")
	end
end)

timer.Create('maniCheckTheyHaveIt', 15, 1, function()
	if(manolis.popcorn.creditShop && !manolis.popcorn.creditShop.valid_) then
		manolis.popcorn.creditShop = nil
	end
end)


concommand.Add("GiveSyndicateWeapon",function(ply,cmd,args) 
	if(!manolis.popcorn.config.canEditServer(ply)) then return end
	local item = manolis.popcorn.items.FindWeapon(args[1])
	if(item) then
		item.json = manolis.popcorn.weapons.CreateWeaponData(ply, item, true)
		item.json.slots = 8
		item.json.class = 'Epic'

		local i = manolis.popcorn.items.CreateItemData(item)
		manolis.popcorn.inventory.addItem(ply,i,function()
			DarkRP.notify(ply,0,4,DarkRP.getPhrase('craft_success'))
			ply:RefreshInventory()
		end)
	else
		DarkRP.notify(ply,1,4,'Item not found')
	end
end)

concommand.Add("GiveSyndicateBlueprint", function(ply, cmd, args)
	if(!manolis.popcorn.config.canEditServer(ply)) then return end
	
	local bp = manolis.popcorn.crafting.FindBlueprint(DarkRP.getPhrase(args[1]))
	if(bp) then
		manolis.popcorn.inventory.addItem(ply,manolis.popcorn.crafting.CreateBlueprintData(bp)) 
		DarkRP.notify(ply,0,4,DarkRP.getPhrase('craft_success'))
	else
		DarkRP.notify(ply,1,4,'Item not found')
	end
end)

concommand.Add("GiveSyndicateArmor",function(ply,cmd,args) 
	if(!manolis.popcorn.config.canEditServer(ply)) then return end
	local item = manolis.popcorn.items.FindArmor(DarkRP.getPhrase(args[1]))
	if(item) then
		item.json = manolis.popcorn.armor.CreateArmorData(ply, item, true)
		item.json.slots = 8
		item.json.class = 'Epic'

		local i = manolis.popcorn.items.CreateItemData(item)
		manolis.popcorn.inventory.addItem(ply,i,function()
			DarkRP.notify(ply,0,4,DarkRP.getPhrase('craft_success'))
			ply:RefreshInventory()
		end)
	else
		DarkRP.notify(ply,1,4,'Item not found')
	end
end)

concommand.Add("GiveSyndicateLevel",function(ply,cmd,args) 
	if(!manolis.popcorn.config.canEditServer(ply)) then return end
	ply:addXP(999999999)
end)
