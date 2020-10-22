if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.temp) then manolis.popcorn.temp = {} end
if(!manolis.popcorn.core) then manolis.popcorn.core = {} end


util.AddNetworkString('ManolisPopcornInventoryFullRefresh')
util.AddNetworkString('ManolisPopcornEquipmentFullRefresh')
util.AddNetworkString('ManolisPopcornNewTrade')
util.AddNetworkString('ManolisPopcornStopTrade')
util.AddNetworkString('ManolisPopcornSetMoneyTrade')
util.AddNetworkString('ManolisPopcornTradeUpdate')
util.AddNetworkString('ManolisPopcornDoTrade')
util.AddNetworkString('ManolisPopcornLockTrade')
util.AddNetworkString('ManolisPopcornCancelTrade')
util.AddNetworkString('ManolisPopcornConfirmTrade')
util.AddNetworkString('ManolisPopcornRemoveItemFromTrade')
util.AddNetworkString('ManolisPopcornAddItemToTrade')
util.AddNetworkString('ManolisPopcornInventoryPartialRefresh')
util.AddNetworkString('ManolisPopcornBlacksmithOpen')
util.AddNetworkString('ManolisPopcornCraftItem')
util.AddNetworkString('ManolisPopcornRefineOpen')
util.AddNetworkString('ManolisPopcornRefineUpgrades')
util.AddNetworkString('ManolisPopcornDonOpen')
util.AddNetworkString('ManolisPopcornBuildingCreateMarker')
util.AddNetworkString('ManolisPopcornGangInfo')
util.AddNetworkString('ManolisPopcornSearchGangs')
util.AddNetworkString('ManolisPopcornGangInviteInfo')
util.AddNetworkString('ManolisPopcornShowF1')
util.AddNetworkString('ManolisPopcornGangShopPermissions')
util.AddNetworkString('ManolisPopcornAlert')
util.AddNetworkString('ManolisPopcornAlertRemove')
util.AddNetworkString('ManolisPopcornAlertRemoveTime')
util.AddNetworkString('ManolisPopcornAlertTime')
util.AddNetworkString('ManolisPopcornGangUpgradeChange')
util.AddNetworkString('ManolisPopcornBankOpen')
util.AddNetworkString('manolisPopcornBankFullRefresh')
util.AddNetworkString('ManolisPopcornSetupBuilding')
util.AddNetworkString('ManolisPopcornSetupBuildingPower')
util.AddNetworkString('ManolisPopcornSetupBuildingCash')
util.AddNetworkString('ManolisPopcornBuildingUpgradeData')
util.AddNetworkString('ManolisPopcornRivalChange')
util.AddNetworkString('ManolisPopcornBuildingUpgradeUpdate')
util.AddNetworkString('ManolisPopcornBuildingUpdate')
util.AddNetworkString('ManolisPopcornBuildingStartCapturing')
util.AddNetworkString('ManolisPopcornPartyUpdate')
util.AddNetworkString('ManolisPopcornGangStartCapturing')
util.AddNetworkString('ManolisPopcornTerritoryUpdate')
util.AddNetworkString('ManolisPopcornGangRankChange')
util.AddNetworkString('ManolisPopcornGangMemberUpdate')
util.AddNetworkString('ManolisPopcornAchievementUpdate')
util.AddNetworkString('ManolisPopcornAchievementWin')
util.AddNetworkString('ManolisPopcornAchievementPacket')
util.AddNetworkString('ManolisPopcornGarageUpdate')
util.AddNetworkString('ManolisPopcornGarageSpawnUpdate')
util.AddNetworkString('ManolisPopcornQuestOpen')
util.AddNetworkString('ManolisPopcornStartDialogue')
util.AddNetworkString('ManolisPopcornStartRadioDialogue')
util.AddNetworkString('ManolisPopcornNextDialogue')
util.AddNetworkString('ManolisPopcornQuickBuy')
util.AddNetworkString('ManolisPopcornPowerUpdate')

local ownEntity = function(ply,ent)
	ent.dt = ent.dt or {}
	ent.dt.owning_ent = ply
	if(ent.Setowning_ent) then ent:Setowning_ent(ply) end
	ent.SID = ply.SID
end

resource.AddFile('resource/fonts/alt-gothic.ttf')
resource.AddFile('resource/fonts/helsinki.ttf')
resource.AddFile('resource/fonts/boltssf.ttf')


hook.Add('PlayerInitialSpawn', 'manolis:popcorn:printerMax', function(ply)
	ply.PrinterAmount = 0
	ply.ForgeAmount = 0

	timer.Simple(1, function()
		ply:LimitSpeed()
		ply:LimitHealth()

		ply:SetHealth(ply:getDarkRPVar('maxhealth'))
		ply:SetArmor(ply:getDarkRPVar('maxarmor'))
	end)


	local sid = ply:SteamID64()
	for k,v in pairs(ents.FindByClass('popcorn_printer')) do
		if(v.origBuyer and v.origBuyer==sid) then
			ply.PrinterAmount = ply.PrinterAmount + 1
			ownEntity(ply,v)
		end
	end

	for k,v in pairs(ents.FindByClass('popcorn_forge')) do
		if(v.origBuyer and v.origBuyer==sid) then
			ply.ForgeAmount = ply.ForgeAmount + 1
			ownEntity(ply,v)
		end
	end


	net.Start('ManolisPopcornShowF1')
	net.Send(ply)

	ply.syndicateCreditShop = {}
end)


local spawnPlayer = function(ply)
	ply:SetCollisionGroup(COLLISION_GROUP_WORLD)

	ply.ToGhost = false
	ply:SetColor(Color(255,255,255,255))
	ply:Spawn()

	timer.Simple(0,function()
		ply:LimitSpeed()
		ply:LimitHealth()

		ply:SetHealth(ply:getDarkRPVar('maxhealth'))
		ply:SetArmor(ply:getDarkRPVar('maxarmor'))
	end)

end


manolis.popcorn.core.spawnPlayer = spawnPlayer

hook.Add('PlayerDeath', 'manolis:popcorn:plyDeathInit', function(ply)
	ply.ToGhost = true
end)

hook.Add('PlayerSpawn', 'manolis:popcorn:plySpawnInit', function(ply)
	if(!ply.Access) then
		ply.Access = true
		spawnPlayer(ply)
	else
		if(ply.ToGhost) then
			//if(!ply.isManolis) then
				ply:setDarkRPVar('PopcornGhost', true)
				ply.Ghost = true
				ply:GodEnable()
				ply:SetCollisionGroup(COLLISION_GROUP_WORLD)
				ply:SetRenderMode(RENDERMODE_TRANSALPHA)
				ply:SetColor(Color(255,255,255,100))

				local time = math.Clamp(10+(ply:GetLevel()*2.5),20,250)

				if(ply:getDarkRPVar('gang')) then
					local gang = ply:getDarkRPVar('gang')
					if(manolis.popcorn.gangs.cache[gang] and manolis.popcorn.gangs.cache[gang].upgrades) then
						time = time - (time*(manolis.popcorn.gangs.cache[gang].upgrades['gangGhost'] or 0))
					end
				end

				if(ply.syndicateCreditShop.spiritExpansion) then
					local credit = manolis.popcorn.creditShop.findItem('spirit')
					if(credit) then
						if(credit.affectLevels[ply.syndicateCreditShop.spiritExpansion]) then
							time = time * (1-(credit.affectLevels[ply.syndicateCreditShop.spiritExpansion]/100))
						end
					end	
				end

				time = math.Clamp(time,20,300)


				timer.Simple(time, function()
					if(IsValid(ply)) then
						ply.Ghost = false
						ply:GodDisable()
						ply:SetColor(Color(255,255,255,255))
						ply:setDarkRPVar('PopcornGhost', false)
						ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
						spawnPlayer(ply)
					end
				end)
			//else
			//	spawnPlayer(ply)
			//end
		end
	end
end)

hook.Add('EntityTakeDamage', 'manolis:popcorn:etd:', function(ply,dmg)
	if(IsValid(ply)) then
		if(ply:IsPlayer()) then
			if(IsValid(dmg:GetAttacker()) and dmg:GetAttacker():IsPlayer()) then
				ply.lastPlayerDamage = CurTime()
			end
		end
	end
end)

hook.Add('ScalePlayerDamage', 'manolis:popcorn:groupScale', function(ply,hitgroup,dmginfo)
	local hitgroups = {HITGROUP_CHEST,HITGROUP_STOMACH,HITGROUP_LEFTARM,HITGROUP_RIGHTARM,HITGROUP_LEFTLEFT,HITGROUP_RIGHTLEG,HITGROUP_GEAR}
	for k,v in pairs(hitgroups) do
		if(v==hitgroup) then
			dmginfo:ScaleDamage(0.75)
		end
	end

	if(hitgroup==HITGROUP_HEAD) then
		dmginfo:ScameDamage(1.5)
	end
end)

hook.Add('CanPlayerSuicide', 'manolis:popcorn:canSuicide', function(ply)
	if(ply.lastPlayerDamage and ply.lastPlayerDamage>CurTime()-60) then
		DarkRP.notify(ply,1,4,'You cannot suicide whilst in battle')
		return false
	end

	if(ply.Ghost) then
		DarkRP.notify(ply,1,4,'Ghosts cannot die!')
		return false
	end
end)


hook.Add('PlayerLoadout', 'manolis:popcorn:loadout', function(ply)
	if(ply.Ghost) then
		return false
	end

	if(ply:isArrested()) then
		return false
	end

	manolis.popcorn.equipment.getEquippedWeapons(ply,function(weapons)
		for k,v in pairs(weapons) do

			local a = manolis.popcorn.items.FindItem(v.name)
			if(a) then
				local ent = ply:Give(a.entity, true)
				ply:SelectWeapon(a.entity)
				if(ent.Upgrade) then
					ent:Upgrade(ply, v.id)
				end
			end
		end
	end)

	
	ply:Give('fists')
	ply:Give('inventory')
end)

local noPickup = {
	building_plug 			= true,
	capture_point 			= true,
	npc_bank 				= true,
	npc_blacksmith 			= true,
	npc_bob 				= true,
	npc_don 				= true,
	npc_michael 			= true,
	npc_quest 				= true,
	npc_quest 				= true,
	npc_refine 				= true,
	npc_simon 				= true,
	npc_turkish 			= true,
	npc_wendy 				= true,
	gang_territory			= true,
	popcorn_cash 			= true,
	popcorn_bomb			= true
}

hook.Add('PhysgunPickup', 'manolis:DisablePhys', function(ply, ent)
	if(IsValid(ent)) then
		local c = ent:GetClass()
		if(noPickup[c]) then return false end
	end
end)

hook.Add('canDropWeapon', 'manolis:DisableWeaponDrop', function()
	return false
end)

local OldTime = 0
hook.Add('Think', 'manolisFrameTimer', function()
	manolis.popcorn.tickTime = SysTime() - OldTime
	OldTime = SysTime()
end)

if(manolis.popcorn.config.changeSky) then RunConsoleCommand('sv_skyname', 'painted') end