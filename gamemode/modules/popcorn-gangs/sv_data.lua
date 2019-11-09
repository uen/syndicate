if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.gangs) then manolis.popcorn.gangs = {} end
if(!manolis.popcorn.gangs.cache) then manolis.popcorn.gangs.cache = {} end
if(!manolis.popcorn.gangs.upgrades) then manolis.popcorn.gangs.upgrades = {} end
if(!manolis.popcorn.gangs.upgrades.upgrades) then manolis.popcorn.gangs.upgrades.upgrades = {} end
if(!manolis.popcorn.gangs.territories) then manolis.popcorn.gangs.territories = {} end
if(!manolis.popcorn.gangs.territories.territoryLocations) then manolis.popcorn.gangs.territories.territoryLocations = {} end
if(!manolis.popcorn.gangs.territories.territories) then manolis.popcorn.gangs.territories.territories = {} end

manolis.popcorn.gangs.GetPlayerGangDataData = function(ply,callback)
	MySQLite.query("SELECT manolis_popcorn_gangs.id, manolis_popcorn_gangs.name, manolis_popcorn_gangs.logo,manolis_popcorn_gangs.bank,manolis_popcorn_gangs.points,manolis_popcorn_gangs.level,manolis_popcorn_gangs.xp,manolis_popcorn_gangs.secondcolor,manolis_popcorn_gangs.color, manolis_popcorn_gangs_members.rank FROM manolis_popcorn_gangs_members LEFT JOIN manolis_popcorn_gangs ON manolis_popcorn_gangs_members.gangid = manolis_popcorn_gangs.id WHERE manolis_popcorn_gangs_members.uid = "..MySQLite.SQLStr(ply:SteamID64()), function(data)
		if(data) then callback(data) return end
		if(!data) then callback(false) return end
	end)
end

manolis.popcorn.gangs.GetPlayerGangDataFromUID = function(ply,callback)
	MySQLite.query("SELECT manolis_popcorn_gangs.id, manolis_popcorn_gangs.name, manolis_popcorn_gangs.logo,manolis_popcorn_gangs.bank,manolis_popcorn_gangs.points,manolis_popcorn_gangs.level,manolis_popcorn_gangs.xp,manolis_popcorn_gangs.secondcolor,manolis_popcorn_gangs.color, manolis_popcorn_gangs_members.rank FROM manolis_popcorn_gangs_members LEFT JOIN manolis_popcorn_gangs ON manolis_popcorn_gangs_members.gangid = manolis_popcorn_gangs.id WHERE manolis_popcorn_gangs_members.uid = "..MySQLite.SQLStr(ply), function(data)
		if(data) then callback(data) return end
		if(!data) then callback(false) return end
	end)
end

manolis.popcorn.gangs.RemovePlayerFromGang = function(ply,callback)
	MySQLite.query("DELETE FROM manolis_popcorn_gangs_members WHERE uid = "..MySQLite.SQLStr(ply:SteamID64()), function(data)
		if(callback) then
			callback(data)
		end
	end)
end

manolis.popcorn.gangs.RemovePlayerFromGangUID = function(ply,callback)
	MySQLite.query("DELETE FROM manolis_popcorn_gangs_members WHERE uid = "..MySQLite.SQLStr(ply), function(data)
		if(callback) then
			callback(data)
		end
	end)
end


manolis.popcorn.gangs.GetGangByName = function(name,callback)
	MySQLite.query("SELECT id,name,logo,bank,points,level,xp,color,secondcolor FROM manolis_popcorn_gangs WHERE name = "..MySQLite.SQLStr(name), function(data)
		if(callback) then
			callback(data)
		end
	end)
end

manolis.popcorn.gangs.GetUpgradeValue = function(gang, key, callback)
	MySQLite.query("SELECT val FROM manolis_popcorn_gang_upgrades WHERE gangid = "..MySQLite.SQLStr(gang).." AND ukey = "..MySQLite.SQLStr(manolis.popcorn.config.hashFunc(key)), function(a)
		if(a and a[1] and a[1].val) then
			callback(a[1].val)
		else
			callback(0)
		end
	end)
end

manolis.popcorn.gangs.GetUpgradeEffect = function(gang, key, callback)
	manolis.popcorn.gangs.GetUpgradeValue(gang,key,function(a)
		if(manolis.popcorn.gangs.cache[gang] and manolis.popcorn.gangs.cache[gang].upgrades) then
			if(manolis.popcorn.gangs.cache[gang].upgrades[key]) then
				callback(manolis.popcorn.gangs.cache[gang].upgrades[key])
			end
		end

		callback(0)
	end)
end

manolis.popcorn.gangs.GetGangUpgrades = function(gang, callback)
	local upgrades = {}
	MySQLite.query("SELECT ukey, val FROM manolis_popcorn_gang_upgrades WHERE gangid = "..MySQLite.SQLStr(gang), function(data)
		for k,v in pairs(manolis.popcorn.gangs.upgrades.upgrades) do
			upgrades[v.uiq] = 0
			for k,a in pairs(data or {}) do
				if(manolis.popcorn.config.hashFunc(v.uiq) == a.ukey) then
					upgrades[v.uiq] = a.val
				end
			end
		end

		manolis.popcorn.gangs.cache[gang] = manolis.popcorn.gangs.cache[gang] and manolis.popcorn.gangs.cache[gang] or {} 
		manolis.popcorn.gangs.cache[gang].upgrades = upgrades
		
		callback(upgrades)
	end)
end

manolis.popcorn.gangs.SetUpgradeValue = function(gang, key, value, callback)
	MySQLite.query("INSERT INTO manolis_popcorn_gang_upgrades(ukey, gangid, val) VALUES("..MySQLite.SQLStr(key)..","..MySQLite.SQLStr(gang)..", "..MySQLite.SQLStr(value)..") ON DUPLICATE KEY UPDATE val = "..MySQLite.SQLStr(value), function(data)
		if(callback) then
			callback()
		end
	end)
end

manolis.popcorn.gangs.GetGangByID = function(name,callback)
	MySQLite.query("SELECT id,name,logo,bank,points,level,xp,color,secondcolor FROM manolis_popcorn_gangs WHERE id = "..MySQLite.SQLStr(name), function(data)
		if(callback) then
			callback(data and data[1] or nil)
		end
	end)
end

manolis.popcorn.gangs.IsRival = function(g1,g2,callback)
	MySQLite.query("SELECT id FROM manolis_popcorn_gangs_rivals WHERE g1 in ("..MySQLite.SQLStr(g1)..', '..MySQLite.SQLStr(g2)..') AND g2 in ('..MySQLite.SQLStr(g1)..", "..MySQLite.SQLStr(g2)..') AND active = 1', function(data)
		if(callback) then
			callback(data or false)
		end
	end)
end

manolis.popcorn.gangs.StopMercyRivalry = function(g1,g2,callback)
	MySQLite.query("UPDATE manolis_popcorn_gangs_rivals SET active = 0 WHERE g1 in ("..MySQLite.SQLStr(g1)..', '..MySQLite.SQLStr(g2)..') AND g2 in ('..MySQLite.SQLStr(g1)..", "..MySQLite.SQLStr(g2)..')', function(data)
		MySQLite.query("INSERT INTO manolis_popcorn_gang_blocked VALUES(null, "..MySQLite.SQLStr(g1)..", "..MySQLite.SQLStr(g2)..", "..MySQLite.SQLStr(os.time())..")", function(data)
			callback()

			MySQLite.query("DELETE FROM manolis_popcorn_gangs_truces WHERE "..MySQLite.SQLStr(g1)..' IN (g1,g2) AND '..MySQLite.SQLStr(g2)..' IN (g1,g2)')
		end)
	end)
end

manolis.popcorn.gangs.StopRivalry = function(g1,g2,callback)
	MySQLite.query("UPDATE manolis_popcorn_gangs_rivals SET active = 0 WHERE g1 in ("..MySQLite.SQLStr(g1)..', '..MySQLite.SQLStr(g2)..') AND g2 in ('..MySQLite.SQLStr(g1)..", "..MySQLite.SQLStr(g2)..')', function(data)
		callback()
		MySQLite.query("DELETE FROM manolis_popcorn_gangs_truces WHERE "..MySQLite.SQLStr(g1)..' IN (g1,g2) AND '..MySQLite.SQLStr(g2)..' IN (g1,g2)')
	end)
end

manolis.popcorn.gangs.CanRival = function(g1,g2,callback)
	MySQLite.query("SELECT timestamp FROM manolis_popcorn_gang_blocked WHERE g2 = "..MySQLite.SQLStr(g1).." AND g1 = "..MySQLite.SQLStr(g2), function(data)
		if(data) then
			if(data[1] and data[1].timestamp) then
				if(60*60*manolis.popcorn.config.gangRivalCooldown+data[1].timestamp > (os.time())) then
					callback(false, math.Round((60*60*manolis.popcorn.config.gangRivalCooldown+data[1].timestamp-os.time())/60/60))
					return
				else
					callback(true)
				end
			else
				callback(true)
			end
		else
			callback(true)
		end

	end)
end

manolis.popcorn.gangs.TruceRival = function(g1,g2,value,callback)
	MySQLite.query("SELECT truce FROM manolis_popcorn_gangs_truces WHERE "..MySQLite.SQLStr(g1).." IN (g1,g2) AND "..MySQLite.SQLStr(g2)..' IN (g1,g2)', function(data)
		if(data and data[1]) then
			value = math.Round(tonumber(value))
			if(value==1) then
				MySQLite.query("DELETE FROM manolis_popcorn_gangs_truces WHERE "..MySQLite.SQLStr(g1).." IN (g1,g2) AND "..MySQLite.SQLStr(g2)..' IN (g1,g2)', function(data)
					MySQLite.query("UPDATE manolis_popcorn_gangs_rivals SET active = 0 WHERE g1 in ("..MySQLite.SQLStr(g1)..', '..MySQLite.SQLStr(g2)..') AND g2 in ('..MySQLite.SQLStr(g1)..", "..MySQLite.SQLStr(g2)..')', function(data)
						callback(5)
					end)
				end)
			else
				MySQLite.query("DELETE FROM manolis_popcorn_gangs_truces WHERE "..MySQLite.SQLStr(g1).." IN (g1,g2) AND "..MySQLite.SQLStr(g2)..' IN (g1,g2)', function(data)
					callback(9)
				end)
			end
		else
			if(math.Round(value)==1) then
				MySQLite.query("INSERT INTO manolis_popcorn_gangs_truces VALUES(NULL, "..MySQLite.SQLStr(g1).." ,"..MySQLite.SQLStr(g2)..', 1)', function(data)
					callback(2)
				end)
			end
		end

	end)
end

manolis.popcorn.gangs.AddRival = function(g1,g2,callback)
	MySQLite.query("INSERT INTO manolis_popcorn_gangs_rivals VALUES(null, "..MySQLite.SQLStr(g1)..", "..MySQLite.SQLStr(g2)..',1,'..MySQLite.SQLStr(os.time())..')', function(data)
		callback(data)
	end)
end

manolis.popcorn.gangs.Search = function(name,callback)
	MySQLite.query("SELECT id,name,logo,bank,points,level,xp,color,secondcolor FROM manolis_popcorn_gangs WHERE name LIKE "..MySQLite.SQLStr('%'..name..'%')..' ORDER BY name DESC LIMIT 3' , function(data)
		if(callback) then
			callback(data)
		end
	end)
end

manolis.popcorn.gangs.GetPlayerGangInvites = function(ply, callback)
	MySQLite.query("SELECT manolis_popcorn_gangs.id, manolis_popcorn_gangs.name, manolis_popcorn_gangs.logo, manolis_popcorn_gangs.color, manolis_popcorn_gangs.secondcolor, manolis_popcorn_gangs.xp, manolis_popcorn_gangs.level FROM manolis_popcorn_gang_invites LEFT JOIN manolis_popcorn_gangs ON manolis_popcorn_gang_invites.gangid = manolis_popcorn_gangs.id WHERE manolis_popcorn_gang_invites.uid = "..MySQLite.SQLStr(ply:SteamID64()), function(d)
		if(callback) then
			callback(d)
		end
	end)	
end

manolis.popcorn.gangs.AddInviteToPlayer = function(ply, gangid, callback)
	MySQLite.query("INSERT INTO manolis_popcorn_gang_invites VALUES(null, "..MySQLite.SQLStr(ply:SteamID64())..", "..MySQLite.SQLStr(gangid)..')', function()
		if(callback) then
			callback()
		end
	end)
end

manolis.popcorn.gangs.RemoveGangInvite = function(ply, gangid, callback)
	MySQLite.query("DELETE FROM manolis_popcorn_gang_invites WHERE uid = "..MySQLite.SQLStr(ply:SteamID64()).. " AND gangid = "..MySQLite.SQLStr(gangid), function()
		if(callback) then
			callback()
		end
	end)
end

manolis.popcorn.gangs.GetShopPermissions = function(gid, callback)
	MySQLite.query("SELECT item,r1,r2,r3,r4,r5 FROM manolis_popcorn_gang_permissions WHERE gangid = "..MySQLite.SQLStr(gid), function(data)
		local perms = {}
		if(!data) then 
			data = {}
		end
		for k,v in pairs(data) do
			perms[v.item] = {v.r1,v.r2,v.r3,v.r4,v.r5}
		end

		if(callback) then
			callback(perms)
		end
	end)
end

manolis.popcorn.gangs.GetPermissionForItem = function(gang,item,callback)
	MySQLite.query("SELECT r1,r2,r3,r4,r5 FROM manolis_popcorn_gang_permissions WHERE gangid = "..MySQLite.SQLStr(gang).." AND item = "..MySQLite.SQLStr(item), function(data)
		local item = {}
		if(!data or !data[1]) then 
			item = {0,0,0,0,0} 
		else
			item = {data[1].r1, data[1].r2, data[1].r3, data[1].r4, data[1].r5}
			
		end

		if(callback) then
			callback(item)
		end
	end)
end

manolis.popcorn.gangs.SetPermission = function(gangid, item, permission, val, callback)
	local permsToTable = {'r1','r2','r3','r4','r5'}
	local perm = permsToTable[permission]

	if(perm) then
		MySQLite.query("INSERT INTO manolis_popcorn_gang_permissions (gangid, item, "..perm..") VALUES ("..MySQLite.SQLStr(gangid)..", "..MySQLite.SQLStr(item)..", "..MySQLite.SQLStr(val)..") ON DUPLICATE KEY UPDATE "..perm.." = "..MySQLite.SQLStr(val), function()
			if(callback) then
				callback()
			end
		end)
	end
end

manolis.popcorn.gangs.GetGangMembers = function(gang, callback)
	MySQLite.query("SELECT darkrp_player.rpname, manolis_popcorn_gangs_members.rank, CONCAT(darkrp_player.uid, '_') as uid FROM manolis_popcorn_gangs_members LEFT JOIN darkrp_player ON darkrp_player.uid = manolis_popcorn_gangs_members.uid WHERE manolis_popcorn_gangs_members.gangid = "..MySQLite.SQLStr(gang), function(data)
		if(callback) then
			if(!data) then data = {} end
			for k,v in pairs(data) do
				v.uid = v.uid:sub(1,-2)
			end
			
			callback(data)
		end
	end)
end

manolis.popcorn.gangs.GetPlayerNameFromUid = function(uid, callback)
	MySQLite.query("SELECT rpname FROM darkrp_player WHERE uid = "..MySQLite.SQLStr(uid), function(na)
		if(na and na[1]) then
			callback(na[1].rpname)
		end
	end)
end

manolis.popcorn.gangs.SetGangRank = function(rank, uid, callback)
	MySQLite.query("UPDATE manolis_popcorn_gangs_members SET rank = "..MySQLite.SQLStr(rank).." WHERE uid = "..uid,function(data)
		if(callback) then
			callback()
		end
	end)
end

manolis.popcorn.gangs.RemoveGangInvites = function(ply, callback)
	MySQLite.query("DELETE FROM manolis_popcorn_gang_invites WHERE uid = "..MySQLite.SQLStr(ply:SteamID64()), function()
		if(callback) then
			callback()
		end
	end)
end

manolis.popcorn.gangs.CanGangAfford = function(gang, money, callback)
	MySQLite.query("SELECT bank FROM manolis_popcorn_gangs WHERE id = "..MySQLite.SQLStr(gang), function(a)
		if(!a or !a[1]) then 
			callback(false)
			return
		end

		if(a[1].bank>=money) then
			callback(true)
			return
		else
			callback(false)
			return
		end
	end)
end

manolis.popcorn.gangs.RemoveMoney = function(gang,money,callback)
	MySQLite.query("UPDATE manolis_popcorn_gangs SET bank = bank - "..MySQLite.SQLStr(money).." WHERE id = "..MySQLite.SQLStr(gang), function(a)
		callback()
	end)
end

manolis.popcorn.gangs.AddMoney = function(gang,money,callback)
	MySQLite.query("UPDATE manolis_popcorn_gangs SET bank = bank + "..MySQLite.SQLStr(money).." WHERE id = "..MySQLite.SQLStr(gang), function(a)
		callback()
	end)
end

manolis.popcorn.gangs.GetGangInfo = function(ply,gang,callback)
	local t = {}
	manolis.popcorn.gangs.GetGangByID(gang, function(a)
		t.info = a
		manolis.popcorn.gangs.GetGangMembers(gang,function(data)
			t.members = data
			manolis.popcorn.gangs.GetGangRivals(gang, function(rivals)
				t.rivals = rivals
				manolis.popcorn.gangs.GetGangUpgrades(gang, function(upgrades)
					manolis.popcorn.gangs.cache[gang] = manolis.popcorn.gangs.cache[gang] and manolis.popcorn.gangs.cache[gang] or {}
					manolis.popcorn.gangs.cache[gang].upgrades = upgrades
					t.upgrades = upgrades
					callback(t)
				end)
			end)
		end)
	end)
end

manolis.popcorn.gangs.GetGangRivals = function(gang, callback)
	MySQLite.query(
		[[SELECT DISTINCT 
			case manolis_popcorn_gangs_rivals.g1
				when ]]..MySQLite.SQLStr(gang)..[[ THEN manolis_popcorn_gangs_rivals.g2
				else manolis_popcorn_gangs_rivals.g2
			end id, manolis_popcorn_gangs.name, manolis_popcorn_gangs_truces.truce, manolis_popcorn_gang_stashes.amount as stashes, manolis_popcorn_gang_kills.amount as kills, manolis_popcorn_gangs.id, manolis_popcorn_gangs.logo,manolis_popcorn_gangs.level, manolis_popcorn_gangs.xp, manolis_popcorn_gangs.color, manolis_popcorn_gangs.secondcolor
		FROM manolis_popcorn_gangs_rivals LEFT JOIN manolis_popcorn_gangs ON manolis_popcorn_gangs.id IN (manolis_popcorn_gangs_rivals.g1,manolis_popcorn_gangs_rivals.g2) 
		LEFT JOIN manolis_popcorn_gangs_truces ON manolis_popcorn_gangs.id = manolis_popcorn_gangs_truces.g2
		LEFT JOIN manolis_popcorn_gang_stashes ON manolis_popcorn_gang_stashes.attacker = ]]..MySQLite.SQLStr(gang)..[[ AND manolis_popcorn_gang_stashes.victim in (manolis_popcorn_gangs_rivals.g1, manolis_popcorn_gangs_rivals.g2) 
		LEFT JOIN manolis_popcorn_gang_kills ON manolis_popcorn_gang_kills.attacker = ]]..MySQLite.SQLStr(gang)..[[ AND manolis_popcorn_gang_kills.victim in (manolis_popcorn_gangs_rivals.g1,manolis_popcorn_gangs_rivals.g2) WHERE ]]..MySQLite.SQLStr(gang)..[[ in (manolis_popcorn_gangs_rivals.g1,manolis_popcorn_gangs_rivals.g2) AND manolis_popcorn_gangs.id != ]]..MySQLite.SQLStr(gang)..[[ AND manolis_popcorn_gangs_rivals.active = 1

		]], function(data)
		if(callback) then
			callback(data or {})
		end

	end)
end

manolis.popcorn.gangs.AddGangKill = function(attacker,victim,callback)
	MySQLite.query("INSERT INTO manolis_popcorn_gang_kills(attacker,victim,amount) VALUES("..MySQLite.SQLStr(attacker)..", "..MySQLite.SQLStr(victim)..", 1) ON DUPLICATE KEY UPDATE amount = amount+1", function()
		if(callback) then callback() end
	end)
end

manolis.popcorn.gangs.AddGangStash = function(attacker,victim,callback)
	MySQLite.query("INSERT INTO manolis_popcorn_gang_stashes(attacker,victim,amount) VALUES("..MySQLite.SQLStr(attacker)..", "..MySQLite.SQLStr(victim)..", 1) ON DUPLICATE KEY UPDATE amount = amount+1", function()
		if(callback) then callback() end
	end)
end

manolis.popcorn.gangs.CreateGang = function(name, password,logo,c1,c2,callback)
	MySQLite.query("INSERT INTO manolis_popcorn_gangs VALUES(null,"..MySQLite.SQLStr(name)..', '..MySQLite.SQLStr(manolis.popcorn.config.hashFunc(password))..', '..MySQLite.SQLStr(logo)..', 0,0,1,0,'..MySQLite.SQLStr(c1)..','..MySQLite.SQLStr(c2)..','..MySQLite.SQLStr(os.time())..')', function(id)
		if(callback) then
			callback(id)
		end
	end)
end

manolis.popcorn.gangs.AddPoints = function(gang, points, callback)
	MySQLite.query("UPDATE manolis_popcorn_gangs SET points = GREATEST(0, points+"..MySQLite.SQLStr(points)..') WHERE id = '..MySQLite.SQLStr(gang), function(d)
		if(callback) then
			callback(d)
		end
	end)
end

manolis.popcorn.gangs.AddXP = function(gang, xp, callback)
	MySQLite.query("SELECT manolis_popcorn_gangs.xp,manolis_popcorn_gangs.level, manolis_popcorn_gang_upgrades.val as xpboost FROM manolis_popcorn_gangs LEFT JOIN manolis_popcorn_gang_upgrades ON manolis_popcorn_gang_upgrades.gangid = manolis_popcorn_gangs.id AND manolis_popcorn_gang_upgrades.ukey =  "..manolis.popcorn.config.hashFunc('xpboost').." WHERE manolis_popcorn_gangs.id = "..MySQLite.SQLStr(gang), function(data)
	
		if(!data or !data[1]) then return false end
		data = data[1]
		local Gxp = tonumber(data.xp)
		local Glevel = tonumber(data.level)
		local xpboost = tonumber(data.xpboost)
		local mult = 0
		if(xpboost and xpboost > 0) then
			xp = (xp + ((xp/100)*xpboost))
		end
		xp = math.Round(xp)
		Gxp = Gxp + xp

		if(Glevel >= manolis.popcorn.config.maxGangLevel) then
			callback(false)
			return
		end

		if(Gxp>=(15000*Glevel^2)) then
			MySQLite.query("UPDATE manolis_popcorn_gangs SET xp = 0, level = "..MySQLite.SQLStr(Glevel+1)..' WHERE id = '..MySQLite.SQLStr(gang), function(data)
				callback(true)				
			end)
		else
			MySQLite.query("UPDATE manolis_popcorn_gangs SET xp = "..MySQLite.SQLStr(Gxp)..' WHERE id = '..MySQLite.SQLStr(gang), function(data)
				callback(true)
			end)
		end
	end)
end

manolis.popcorn.gangs.AddPlayerToGang = function(ply, gangname, rank, callback)
	MySQLite.query("SELECT id,name,logo,bank,points,level,xp,color,secondcolor,timestamp FROM manolis_popcorn_gangs WHERE name = "..MySQLite.SQLStr(gangname), function(data)
		if(data and data[1]) then
			MySQLite.query("INSERT INTO manolis_popcorn_gangs_members VALUES("..MySQLite.SQLStr(ply:SteamID64())..','..MySQLite.SQLStr(data[1].id)..','..MySQLite.SQLStr(rank)..')', function()
				if(callback) then
					callback(data[1].id, data[1])
				end
			end)
		end
	end)		
end

manolis.popcorn.gangs.IsPasswordCorrect = function(name,password,callback)
	MySQLite.query("SELECT id FROM manolis_popcorn_gangs WHERE name = "..MySQLite.SQLStr(name)..' AND password = '..MySQLite.SQLStr(manolis.popcorn.config.hashFunc(password)), function(data)
		if(data and data[1]) then callback(data[1].id) return end
		callback(false)
	end)
end

manolis.popcorn.gangs.newTerritory = function(map, name, callback)
	MySQLite.query("INSERT INTO manolis_popcorn_gang_territories VALUES(null, "..MySQLite.SQLStr(map)..", "..MySQLite.SQLStr(name)..")", function(data)
		if(callback) then
			callback(data)
		end
	end)
end

manolis.popcorn.gangs.newTerritoryLocation = function(location, map, tid, callback)
	MySQLite.query("INSERT INTO manolis_popcorn_gang_territories_locations VALUES(null, "..MySQLite.SQLStr(map)..", "..MySQLite.SQLStr(location.x)..","..MySQLite.SQLStr(location.y)..","..MySQLite.SQLStr(location.z)..", "..MySQLite.SQLStr(tid)..")", function(data)
		if(callback) then
			callback(data)
		end
	end)
end

manolis.popcorn.gangs.removeTerritory = function(id, callback)
	MySQLite.query("DELETE FROM manolis_popcorn_gang_territories WHERE id = "..MySQLite.SQLStr(id), function(data)
		MySQLite.query("DELETE FROM manolis_popcorn_gang_territories_locations WHERE tid = "..MySQLite.SQLStr(id), function()
			if(callback) then
				callback(data)
			end
		end)
	end)
end

manolis.popcorn.gangs.removeTerritoryLocation = function(id, callback)
	MySQLite.query("DELETE FROM manolis_popcorn_gang_territories_locations WHERE id = "..MySQLite.SQLStr(id), function()
		if(callback) then
			callback()
		end
	end)
end


manolis.popcorn.gangs.retrieveTerritories = function(callback)
	MySQLite.query("SELECT * FROM manolis_popcorn_gang_territories WHERE manolis_popcorn_gang_territories.map = "..MySQLite.SQLStr(game.GetMap())..' ORDER BY manolis_popcorn_gang_territories.id', function(data) 
		if(!data) then data = {} end 

		manolis.popcorn.gangs.retrieveTerritoryLocations(function(territory)
			for k,v in pairs(data) do
				v.locations = {}
				for k2,v2 in pairs(territory) do
					if(v.id == v2.tid) then
						table.insert(v.locations, v2)
					end
				end
			end

			local r = {}
			for a,b in pairs(data or {}) do
				r[b.id] = b
			end

			callback(r or {})
		end)
	end)
end

manolis.popcorn.gangs.retrieveTerritoryLocations = function(callback)
	MySQLite.query("SELECT * FROM manolis_popcorn_gang_territories_locations WHERE map = "..MySQLite.SQLStr(game.GetMap()).." ORDER BY id", function(data)
		if(!data) then data = {} end
		manolis.popcorn.gangs.territories.territoryLocations = data

		callback(data)
	end)
end