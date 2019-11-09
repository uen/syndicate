if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.gangs) then manolis.popcorn.gangs = {} end
if(!manolis.popcorn.gangs.cache) then manolis.popcorn.gangs.cache = {} end
if(!manolis.popcorn.gangs.territories) then manolis.popcorn.gangs.territories = {} end
if(!manolis.popcorn.gangs.territories.territories) then manolis.popcorn.gangs.territories.territories = {} end
if(!manolis.popcorn.gangs.itemCache) then manolis.popcorn.gangs.itemCache = {} end


local meta = FindMetaTable('Player')
meta.SetGangInvites = function(ply, invites)
	if(!ply or !ply:IsPlayer()) then return end
	net.Start("ManolisPopcornGangInviteInfo")
		net.WriteTable(invites or {})
	net.Send(ply)
end

meta.GetGangInvitesAndSend = function(ply)
	manolis.popcorn.gangs.GetPlayerGangInvites(ply, function(invites)
		ply:SetGangInvites(invites or {})
	end)
end

meta.SetGang = function(ply, id, rank, data)
	if(!id or !rank or !ply:IsPlayer() or !tonumber(rank) or !tonumber(id)) then return end
	ply:setDarkRPVar('gangrank', math.Round(tonumber(rank)))
	ply:setDarkRPVar('gang', math.Round(tonumber(id)))
	ply:setDarkRPVar('gangdata', data)
	if(id!=0) then
		manolis.popcorn.gangs.GetGangInfo(ply, id, function(data)
			local t = {}
			t.members = data.members
			t.rivals = data.rivals
			t.upgrades = data.upgrades
			t.info = data.info

			net.Start("ManolisPopcornGangInfo")
				net.WriteTable(t)
			net.Send(ply)

			manolis.popcorn.gangs.GetShopPermissions(id, function(perms)
				net.Start("ManolisPopcornGangShopPermissions")
					net.WriteTable(perms)
				net.Send(ply)
			end)

			manolis.popcorn.gangs.cache[id] = t	
			manolis.popcorn.gangs.itemCache[id] = {printers=0}
		end)
	end
end


manolis.popcorn.gangs.GetPlayerGangData = function(ply,callback)
	manolis.popcorn.gangs.GetPlayerGangDataData(ply, function(gang)
		if(gang and gang[1]) then
			callback(gang[1])
			return
		end 

		callback(false)
		return
	end)
end

hook.Add("PlayerInitialSpawn", "manolis:popcorn:gangs:GetGang", function(ply)
	manolis.popcorn.gangs.GetPlayerGangData(ply, function(gang)
		if(gang) then

			ply:SetGang(gang.id, gang.rank, gang)
		else
			manolis.popcorn.gangs.GetPlayerGangInvites(ply, function(invites)
				ply:SetGangInvites(invites)
			end)			
		end

		manolis.popcorn.gangs.retrieveTerritories(function(data)
			net.Start("ManolisPopcornTerritoryUpdate")	
				net.WriteTable(data)
			net.Send(ply)
		end)
	end)
end)


concommand.Add("ManolisPopcornRefreshGang",function(ply,cmd,args)
	manolis.popcorn.gangs.ResendInfo(ply)
end)


concommand.Add("ManolisPopcornSetGangShopPermission", function(ply,cmd,args)
	if(!args[1] or !args[2] or !args[3] or !tonumber(args[2]) or !tonumber(args[3])) then return false end
	args[2] = math.Round(args[2])
	args[3] = math.Round(args[3])

	local found = false
	for k,v in pairs(manolis.popcorn.gangs.shop.items) do
		if(manolis.popcorn.config.hashFunc(v.name)==args[1]) then
			found = true
		end
	end

	if(!found) then return false end
	manolis.popcorn.gangs.GetPlayerGangData(ply, function(gang)
		if(gang) then
			if(gang.rank<=1) then
				if((args[3]>1) or (args[3]<0) or ((args[2]>5) or args[2]<1)) then
					return
				end  
				args[3] = (args[3] == 1) and 1 or 0
				manolis.popcorn.gangs.SetPermission(gang.id, args[1], args[2], args[3], function()
					manolis.popcorn.gangs.SendPermissions(gang.id, args[1], args[1], ply)
				end)
			end
		end
	end)
end)

concommand.Add("ManolisPopcornJoinGang",function(ply,cmd,args)
	if(!args or !args[1] or !tonumber(args[1])) then return end
	args[1] = math.Round(tonumber(args[1]))

	manolis.popcorn.gangs.GetPlayerGangData(ply, function(gang)
		if(gang) then
			DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_already'))
		else
			manolis.popcorn.gangs.GetPlayerGangInvites(ply, function(invites)
				if(!invites) then return false end
				for k,v in pairs(invites) do
					if(v.id==args[1]) then
						manolis.popcorn.gangs.GetGangByID(v.id, function(g)
							if(g) then
								manolis.popcorn.gangs.GetUpgradeEffect(v.gangid, "memberExpansion", function(val)
									local maxMembers = manolis.popcorn.config.initialGangMaxMembers + val
									manolis.popcorn.gangs.GetGangMembers(v.gangid, function(members)
										if((#members+1)>maxMembers) then
											DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_full'))
											manolis.popcorn.gangs.RemoveGangInvite(ply,v.gangid, function()
												ply:GetGangInvitesAndSend()
											end)
										else
											manolis.popcorn.gangs.AddPlayerToGang(ply, v.name, 5, function(data)
												ply:SetGang(v.id, 5, g)
												DarkRP.notify(ply, 0,4,DarkRP.getPhrase('gang_joined',v.name))
												manolis.popcorn.gangs.RemoveGangInvites(ply)

												manolis.popcorn.gangs.GetGangMembers(v.id, function(members)
													local toSend = manolis.popcorn.gangs.GetConnected(v.id)
													net.Start("ManolisPopcornGangMemberUpdate")
														net.WriteTable(members)
													net.Send(toSend)

												end)
											end)
										end
									end)
								end)
							end
						end)
					end
				end
			end)
		end
	end)
end)

concommand.Add("ManolisPopcornDeclineInvite", function(ply,cmd,args)	
	manolis.popcorn.gangs.RemoveGangInvite(ply,args[1], function()
		DarkRP.notify(ply,0,4,DarkRP.getPhrase('gang_rejected'))
		ply:GetGangInvitesAndSend()
	end)
end)

concommand.Add("ManolisPopcornRecoverGang", function(ply,cmd,args)
	if(!ply.lastGangRecover) then 
		ply.lastGangRecover = CurTime()
	else
		if(CurTime()-10<ply.lastGangRecover) then
			DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_attempt_spam'))
			return
		end
	end

	if((ply:getDarkRPVar('gang') or 0)>0) then DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_recover_already')) end

	if(!args[1] or !args[2]) then DarkRP.notify(ply,1,4,DarkRP.getPhrase('invalid_args')) return end
	ply.lastGangRecover = CurTime()
	manolis.popcorn.gangs.IsPasswordCorrect(args[1], args[2], function(a)
		if(a) then
			manolis.popcorn.gangs.AddPlayerToGang(ply, args[1], 1, function(data, gang)
				ply:SetGang(a,1,gang)
				manolis.popcorn.gangs.RemoveGangInvites(ply)

				DarkRP.notify(ply,0,4,DarkRP.getPhrase('gang_recover_suc'))
			end)
		else
			DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_recover_fail'))
		end
	end)
end)
 
concommand.Add("ManolisPopcornCreateGang",function(ply,cmd,args)
	// name, password, logo, color, secondcolor
	if(!args[1] or !args[2] or !args[3] or !args[4] or !args[5]) then return end

	if(!table.HasValue(manolis.popcorn.gangs.logos, args[3])) then
		return // Will never happen unless entered manually
	end

	// Check the allowed characters
	if(#args[1]>=4 and #args[1]<=20 and args[1]:find('^[a-zA-Z -]*$')) then

		args[1] = (args[1]:gsub("^%s*(.-)%s*$", "%1"))

		manolis.popcorn.gangs.GetPlayerGangData(ply, function(data)
			if(data) then
				DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_create_fail_al'))
				return false
			else
				manolis.popcorn.gangs.GetGangByName(args[1], function(data)
					if(data) then
						DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_create_exists'))
						return
					else
						if(ply:canAfford(manolis.popcorn.config.gangCreateCost)) then
							manolis.popcorn.gangs.CreateGang(args[1], args[2], args[3],args[4],args[5],function(data)
								manolis.popcorn.gangs.AddPlayerToGang(ply, args[1], 1, function(data, gang)
									ply:addMoney(-manolis.popcorn.config.gangCreateCost)
									ply:SetGang(data, 1, gang)
									manolis.popcorn.gangs.RemoveGangInvites(ply)

									DarkRP.notify(ply,0,4,DarkRP.getPhrase('gang_create_success'))
								end)
							end)
						else
							DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_create_fail_afford'))
							return
						end
					end
				end)
			end

		end)
	else
		DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_create_fail_args'))
	end
end)

concommand.Add("ManolisPopcornRivalGang", function(ply,cmd,args)
	if(!args[1]) then return end
	manolis.popcorn.gangs.GetGangByID(args[1], function(gang)
		if(!gang) then
			DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_rival_notfound'))
			return
		end

		manolis.popcorn.gangs.GetPlayerGangData(ply,function(owngang)
			if(!owngang) then return false end
			if(gang.id==owngang.id) then
				DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_rival_owngang'))
				return
			end 

			if(tonumber(owngang.rank)>2) then
				DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_rival_rival_fails'))
				return false
			end

			if(tonumber(gang.level) < (tonumber(owngang.level)-5)) then
				DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_rival_attempt_fail',gang.name))
				return
			end

			manolis.popcorn.gangs.IsRival(gang.id,owngang.id, function(data)
				if(data) then
					DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_rival_already',gang.name))
					return
				else
					manolis.popcorn.gangs.CanRival(owngang.id,gang.id, function(v, amount)
						if(!v) then
							DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_rival_time',amount))
							return
						else
							manolis.popcorn.gangs.AddRival(owngang.id,gang.id,function()
								manolis.popcorn.gangs.Notify(owngang.id,4,4,DarkRP.getPhrase('gang_rival_start', gang.name))
								manolis.popcorn.gangs.Notify(gang.id,4,4,DarkRP.getPhrase('gang_rival_start2', owngang.name))

								for k,v in pairs(player.GetAll()) do
									if(v:getDarkRPVar('gang')==gang.id or v:getDarkRPVar('gang')==owngang.id) then
										manolis.popcorn.gangs.GetGangInfo(ply, v:getDarkRPVar('gang'), function(data)
											local t = {}
											t.members = data.members
											t.rivals = data.rivals

											net.Start("ManolisPopcornGangInfo")
												net.WriteTable(t)
											net.Send(v)
										end)
									end
								end								
							end)
						end
					end)
				end
			end) 
		end)
	end)
end)	

manolis.popcorn.gangs.CanPurchaseItem = function(ply,itemname, callback)
	manolis.popcorn.gangs.GetPlayerGangData(ply, function(gang)
		if(!gang or !gang.rank) then
			callback(false, DarkRP.getPhrase('you_not_gang'))
			return
		else
			local playerRank = gang.rank or 5
			local foundItem = false
			for k,v in pairs(manolis.popcorn.gangs.shop.items) do
				if(manolis.popcorn.config.hashFunc(v.name)==itemname) then
					foundItem = v
				end
			end

			if(!foundItem) then
				callback(false, DarkRP.getPhrase('gang_not_found_item'))
				return
			end

			if(gang.level < foundItem.level) then
				callback(false, DarkRP.getPhrase('gang_wrong_level'))
				return
			end
			
			manolis.popcorn.gangs.GetPermissionForItem(gang.id, manolis.popcorn.config.hashFunc(foundItem.name), function(perms)
				if(perms[playerRank]>0) then
					manolis.popcorn.gangs.CanGangAfford(gang.id,foundItem.price,function(a)
						if(a) then
							if(foundItem.isPrinter) then
								if(manolis.popcorn.gangs.itemCache[gang.id].printers) then
									if(manolis.popcorn.gangs.itemCache[gang.id].printers >= manolis.popcorn.config.gangPrinters) then
										callback(false, "Your gang can only have "..manolis.popcorn.config.gangPrinters.." printers at once")
										return
									end
								else
									manolis.popcorn.gangs.itemCache[gang.id].printers = 0
								end

								manolis.popcorn.gangs.itemCache[gang.id].printers = manolis.popcorn.gangs.itemCache[gang.id].printers + 1
							end
							callback(true, foundItem, gang.id)
							return
						else
							callback(false, DarkRP.getPhrase('gang_cannot_afford'))
							return
						end
					end)
				else
					callback(false, DarkRP.getPhrase('gang_cannot_rank'))
				end
			end)
		end
	end)
end

concommand.Add("ManolisPopcornGangKick", function(ply,cmd,args)
	if(!args[1]) then return false end
	manolis.popcorn.gangs.GetPlayerGangData(ply,function(gang)
		if(gang.rank>2) then 
			DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_kick_rank'))
			return
		end

		if(ply:SteamID64() == args[1]) then
			DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_kick_Self'))
			return
		end

		manolis.popcorn.gangs.GetPlayerGangDataFromUID(args[1], function(pGang)
			if(!pGang or !pGang[1]) then return false end
			pGang = pGang[1]
			if(pGang.id == gang.id) then
				if(pGang.rank < gang.rank) then
					DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_kick_higher_rank'))
					return
				end
				
				manolis.popcorn.gangs.RemovePlayerFromGangUID(args[1], function()
					manolis.popcorn.gangs.GetPlayerNameFromUid(args[1], function(name)
						if(name) then
							
							for k,v in pairs(player.GetAll()) do
								if(v:SteamID64()==args[1]) then
									v:SetGang(0, 0)
									v:setDarkRPVar('gang', 0)
									DarkRP.notify(v,0,4,DarkRP.getPhrase('gang_kicked',ply:Name()))
								end
							end

							manolis.popcorn.gangs.Notify(pGang.id,0,4,DarkRP.getPhrase('gang_kicked_by',ply:Name(), name))

							manolis.popcorn.gangs.GetGangMembers(pGang.id, function(members)
								local toSend = manolis.popcorn.gangs.GetConnected(pGang.id)
								net.Start("ManolisPopcornGangMemberUpdate")
									net.WriteTable(members)
								net.Send(toSend)
							end)
						end
					end)
				end)
			end
		end)
	end)
end)


concommand.Add("ManolisPopcornGangPromote", function(ply,cmd,args)
	if((!args[1])) then return false end
	if(!args[2]) then return false end
	if(!tonumber(args[2])) then return false end
	args[2] = tonumber(args[2])

	args[2] = math.floor(args[2])
	if(args[2]>5 or args[2]<1) then return false end

	manolis.popcorn.gangs.GetPlayerGangData(ply,function(gang)
		if(!gang) then return false end

		if(gang.rank>2) then
			DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_promote_leader'))
			return
		end

		if(ply:SteamID64() == args[1]) then
			DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_promote_self'))
			return
		end

		if(args[2]<gang.rank) then
			DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_promote_leader'))
			return
		end

		manolis.popcorn.gangs.GetPlayerGangDataFromUID(args[1],function(pGang)
			if(!pGang or !pGang[1]) then return false end
			pGang = pGang[1]

			if(pGang.id == gang.id) then
				if(args[2] == pGang.rank) then
					DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_promote_already'))
					return
				end

				if(pGang.rank < gang.rank) then
					DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_promote_higher'))
					return
				end

				manolis.popcorn.gangs.SetGangRank(args[2], args[1], function()
					manolis.popcorn.gangs.GetPlayerNameFromUid(args[1], function(name)
						if(name) then
							manolis.popcorn.gangs.Notify(gang.id,0,4,DarkRP.getPhrase('gang_promote_notify', ply:Name(), name, manolis.popcorn.gangs.GetRank(args[2])))
							local toSend = manolis.popcorn.gangs.GetConnected(gang.id)
							net.Start("ManolisPopcornGangRankChange")
								net.WriteTable({player=args[1], rank=args[2]})
							net.Send(toSend)
						end
					end)
					
				end)
			end
		end)
	end)
end)

concommand.Add("ManolisPopcornGangUpgradeBuy", function(ply,cmd,args)
	if(!args[1]) then return false end
	local key = args[1]
	manolis.popcorn.gangs.GetPlayerGangData(ply, function(gang)
		if(!gang) then return false end
		if(gang.rank>2) then
			DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_upgrade_buy_rank'))
			return
		end

		manolis.popcorn.gangs.GetUpgradeValue(gang.id,key,function(level)

			if(level>=manolis.popcorn.config.maxGangUpgrade) then
				DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_upgrade_max'))
			else
				// Is upgrade valid?
				for k,v in pairs(manolis.popcorn.gangs.upgrades.upgrades) do
					if(manolis.popcorn.config.hashFunc(v.uiq)==manolis.popcorn.config.hashFunc(key)) then
						local newLevel = level + 1
						local p = 0

						if(type(v.prices)=='table') then
							p = v.prices[newLevel] or (1000000*newLevel)
						else
							p = v.prices*newLevel
						end

						manolis.popcorn.gangs.CanGangAfford(gang.id,p,function(a)
						
							if(!a) then
								DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_upgrade_afford'))
								return
							end

							manolis.popcorn.gangs.RemoveMoney(gang.id,p,function()
								manolis.popcorn.gangs.SetUpgradeValue(gang.id,manolis.popcorn.config.hashFunc(v.uiq),newLevel, function()
									manolis.popcorn.gangs.Notify(gang.id, 0, 4, DarkRP.getPhrase('gang_upgrade_do', v.name, newLevel))	
									manolis.popcorn.gangs.SendUpgrades(gang.id)

									local connected = manolis.popcorn.gangs.GetConnected(id)
									for k,v in pairs(connected) do
										v:LimitHealth()
										v:LimitSpeed()
									end
								end)
							end)
						end)
						return
					end
				end
			end
		end)
	end)
end)

				
concommand.Add("ManolisPopcornGangDonate",function(ply,cmd,args)
	if(!args or !args[1] or !IsValid(ply) or !ply:IsPlayer()) then
		DarkRP.notify(ply,1,4,DarkRP.getPhrase('invalid_args'))
		return false
	end

	if(!tonumber(args[1])) then 
		DarkRP.notify(ply,1,4,DarkRP.getPhrase('invalid_args'))
		return
	end

	args[1] = math.Round(tonumber(args[1]))
	if(args[1]<1) then
		DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_donate_negative'))
	end

	if(!ply:canAfford(args[1])) then
		DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_donate_afford'))
		return
	else
		manolis.popcorn.gangs.GetPlayerGangData(ply, function(gang)
			if(!gang or !gang.rank) then
				return
			else
				ply:addMoney(-args[1])
				manolis.popcorn.gangs.AddMoney(gang.id, args[1], function(d)
					DarkRP.notify(ply,0,4,DarkRP.getPhrase('gang_donate_success', DarkRP.formatMoney(args[1])))
				end)
			end
		end)
	end
end)

concommand.Add("ManolisPopcornGangShopBuy",function(ply,cmd,args)
	if(!args or !args[1] or !IsValid(ply) or !ply:IsPlayer()) then
		return false
	end

	manolis.popcorn.gangs.CanPurchaseItem(ply,args[1], function(can,message, gid)
		if(!can) then
			DarkRP.notify(ply,1,4,message)
			return
		end

		manolis.popcorn.gangs.AddMoney(gid, -message.price, function(d)
			local trace = {}
			trace.start = ply:EyePos()
			trace.endpos = trace.start + ply:GetAimVector()*85
			trace.filter = ply

			local tr = util.TraceLine(trace)

			local item = ents.Create(message.entity)

			item.gangid = ply:getDarkRPVar('gang')
			item.spawnedBy = ply
			item:SetPos(tr.HitPos)
			
			message.owningGang = gid
			message.owningGangName = manolis.popcorn.gangs.cache[gid].info.name

			item.DarkRPItem = {}
			item.DarkRPItem.name = message.name
			item.DarkRPItem.pTable = message



			if(item.SetItemData) then
				local t = {}
				t.name = message.name
				t.entity = message.entity
				t.value = message.price / 5
				t.type = message.type
				t.icon = message.icon or ""
				t.json = {}
				if(message.model) then
					t.json.model = message.model
					t.model = message.model
				end
				t.level = message.level or 1
				t = manolis.popcorn.items.CreateItemData(t)
				item:SetItemData(t)
			end

			item:Spawn() 

			if(message.model) then
				item:SetModel(message.model)
			end

			if(message.isPrinter) then
				item.PrinterRemoved = function(gid)
					manolis.popcorn.gangs.itemCache[item.gangid].printers = manolis.popcorn.gangs.itemCache[item.gangid].printers - 1
				end				
			end


			DarkRP.notify(ply,0,4,DarkRP.getPhrase('gang_shop_buy', message.name, DarkRP.formatMoney(message.price)))
		end)

		
	end)
end)

manolis.popcorn.gangs.Mercy = function(loose,win, callback)
	manolis.popcorn.gangs.IsRival(loose.id,win.id, function(d)
		if(!d) then callback(false, DarkRP.getPhrase('gang_mercy_fail')) return end
		
		manolis.popcorn.gangs.StopMercyRivalry(loose.id,win.id,function(d)
			local xp = math.max(0, 10+(100*loose.level-win.level))
			manolis.popcorn.gangs.AddPoints(win.id, xp)
			manolis.popcorn.gangs.AddPoints(loose.id, -xp)

			manolis.popcorn.gangs.Notify(win.id, 4,4,DarkRP.getPhrase('gang_mercy_succ',xp,loose.name))
			manolis.popcorn.gangs.Notify(loose.id, 4,4,DarkRP.getPhrase('gang_mercy_loss',xp,win.name))

			for k,v in pairs(player.GetAll()) do
				if(v:getDarkRPVar('gang')==win.id or v:getDarkRPVar('gang')==loose.id) then
					manolis.popcorn.gangs.GetGangInfo(ply, v:getDarkRPVar('gang'), function(data)
						local t = {}
						t.members = data.members
						t.rivals = data.rivals
						net.Start("ManolisPopcornGangInfo")
							net.WriteTable(t)
						net.Send(v)
					end)
				end
			end

		end)
	end)
end		

manolis.popcorn.gangs.Notify = function(gang,msgtype,len,msg)
	local rcp = RecipientFilter()

	for k,v in pairs(player.GetAll()) do
		if(v:getDarkRPVar('gang')==gang) then
			rcp:AddPlayer(v)
		end
	end

	umsg.Start("_GangNotify", rcp)
		umsg.String(msg)
		umsg.Short(msgtype)
		umsg.Long(len)
	umsg.End()
end		

manolis.popcorn.gangs.GetConnected = function(gangid)
	local playersToSend = {}
	for k,v in pairs(player.GetAll()) do
		if(v:getDarkRPVar('gang')==gangid) then
			if(v!=nosend) then
				table.insert(playersToSend, v)
			end
		end
	end

	return playersToSend
end

manolis.popcorn.gangs.SendUpgrades = function(gangid)
	manolis.popcorn.gangs.GetGangUpgrades(gangid, function(a)
		local playersToSend = manolis.popcorn.gangs.GetConnected(gangid)
		net.Start("ManolisPopcornGangUpgradeChange")
			net.WriteTable(a)
		net.Send(playersToSend)
	end)
end

manolis.popcorn.gangs.SendPermissions = function(gangid, item,itemname,nosend)
	manolis.popcorn.gangs.GetPermissionForItem(gangid,item,function(perms)
		local playersToSend = manolis.popcorn.gangs.GetConnected(gangid)

		local p = {}
		p[itemname] = perms

		net.Start("ManolisPopcornGangShopPermissions")
			net.WriteTable(p)
		net.Send(playersToSend)
	end)
end

manolis.popcorn.gangs.ResendInfo = function(ply)
	if(ply.isRefreshingGang) then return false end
	ply.isRefreshingGang = true
	if(ply:getDarkRPVar('gang')) then
		manolis.popcorn.gangs.GetGangByID(ply:getDarkRPVar('gang'), function(gang)
			net.Start("ManolisPopcornGangInfo")
				net.WriteTable({info=gang})
			net.Send(ply)

			timer.Simple(1, function()
				ply.isRefreshingGang = false
			end)
		end)
	end
end


concommand.Add("ManolisPopcornNewTerritory",function(ply,x,args,s)
	if(!IsValid(ply) or !ply:IsPlayer() or !args[1] or #args[1]<1) then
		return
	end
	if(manolis.popcorn.config.canEditServer(ply)) then
		manolis.popcorn.gangs.newTerritory(game.GetMap(), args[1], function()
			manolis.popcorn.gangs.retrieveTerritories(function(data)
				net.Start("ManolisPopcornTerritoryUpdate")	
					net.WriteTable(data)
				net.Broadcast()
			end)
			DarkRP.notify(ply,0,4,DarkRP.getPhrase('gang_territory_created'))			
		end)
	end
end)

concommand.Add("ManolisPopcornSaveTerritoryLocation",function(ply,x,args,s)
	if(!IsValid(ply) or !ply:IsPlayer() or !args[1] or #args[1]<1) then
		return
	end

	if(manolis.popcorn.config.canEditServer(ply)) then
		manolis.popcorn.gangs.newTerritoryLocation(ply:GetPos(), game.GetMap(), args[1], function()
			manolis.popcorn.gangs.retrieveTerritories(function(data)
				net.Start("ManolisPopcornTerritoryUpdate")	
					net.WriteTable(data)
				net.Broadcast()
			end)
			DarkRP.notify(ply,0,4,DarkRP.getPhrase('gang_territory_locationsave'))		
		end)
		
	end
end)

concommand.Add("ManolisPopcornRemoveTerritory", function(ply,x,args,s)
	if(!IsValid(ply) or !ply:IsPlayer() or !args or !args[1]) then
		return
	end	

	if(!tonumber(args[1])) then return false end

	if(manolis.popcorn.config.canEditServer(ply)) then
		manolis.popcorn.gangs.removeTerritory(args[1],function()
			manolis.popcorn.gangs.retrieveTerritories(function(data)
				net.Start("ManolisPopcornTerritoryUpdate")	
					net.WriteTable(data)
				net.Broadcast()
			end)
			DarkRP.notify(ply,0,4,DarkRP.getPhrase('gang_territory_remove'))		
		end)		
	end
end)

concommand.Add("ManolisPopcornRemoveTerritoryLocation", function(ply,x,args,s)
	if(!IsValid(ply) or !ply:IsPlayer() or !args or !args[1]) then
		return
	end	

	if(!tonumber(args[1])) then return false end
 
	if(manolis.popcorn.config.canEditServer(ply)) then

		manolis.popcorn.gangs.removeTerritoryLocation(args[1],function()
			manolis.popcorn.gangs.retrieveTerritories(function(data)
				net.Start("ManolisPopcornTerritoryUpdate")	
					net.WriteTable(data)
				net.Broadcast()
			end)

			DarkRP.notify(ply,0,4,DarkRP.getPhrase('gang_capture_remove'))		
		end)		
	end
end)


concommand.Add("ManolisPopcornTruceGang", function(ply,cmd,args)
	if(!args[2] or !args[1]) then return false end

	manolis.popcorn.gangs.GetPlayerGangData(ply,function(owngang)
		if(!owngang) then return false end
		if(tonumber(owngang.rank)>2) then
			DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_truce_rank'))
			return false
		end

		manolis.popcorn.gangs.GetGangByID(args[1], function(gang)
			if(!gang) then
				DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_not_found'))
				return
			end

			manolis.popcorn.gangs.IsRival(owngang.id,gang.id, function(datas)
				if(datas) then

					manolis.popcorn.gangs.TruceRival(owngang.id, gang.id, args[2], function(v)
						local isTruced = false
						if(v==5) then
							manolis.popcorn.gangs.Notify(owngang.id,4,4,DarkRP.getPhrase('gang_truce_y',gang.name))
							manolis.popcorn.gangs.Notify(gang.id, 4,4,DarkRP.getPhrase('gang_truce_y',owngang.name))
							manolis.popcorn.gangs.StopRivalry(gang.id,owngang.id, function()
								for k,v in pairs(player.GetAll()) do
									if(v:getDarkRPVar('gang')==owngang.id or v:getDarkRPVar('gang')==gang.id) then
										manolis.popcorn.gangs.GetGangInfo(ply, v:getDarkRPVar('gang'), function(data)
											local t = {}
											t.members = data.members
											t.rivals = data.rivals
											net.Start("ManolisPopcornGangInfo")
												net.WriteTable(t)
											net.Send(v)
										end)
									end
								end
							end)
							return


						elseif(v==2) then
							manolis.popcorn.gangs.Notify(owngang.id,4,4,DarkRP.getPhrase('gang_truce_request', gang.name))
							manolis.popcorn.gangs.Notify(gang.id,4,4,DarkRP.getPhrase('gang_truce_request2', owngang.name))
							isTruced = true
						elseif(v==9) then
							manolis.popcorn.gangs.Notify(gang.id,4,4,DarkRP.getPhrase('gang_truce_cancel',owngang.name))
							manolis.popcorn.gangs.Notify(owngang.id,4,4,DarkRP.getPhrase('gang_truce_cancel2', gang.name))
							isTruced = false
						end

						for k,v in pairs(player.GetAll()) do
							if(v:getDarkRPVar('gang')==gang.id) then
								net.Start("ManolisPopcornRivalChange")
									net.WriteTable(owngang)
								net.Send(v)
							elseif(v:getDarkRPVar('gang')==owngang.id) then
								net.Start("ManolisPopcornRivalChange")
									gang.truce = isTruced
									net.WriteTable(gang)
								net.Send(v)
							end
						end

					end)
				else
					DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_truce_fail'))
				end
			end)
		end)
	end)
end)

concommand.Add("ManolisPopcornMercyGang", function(ply,cmd,args)
	if(!args[1]) then return false end
	manolis.popcorn.gangs.GetGangByID(args[1], function(gang)
		if(!gang) then
			DarkRP.notify(ply,1,4,'Gang not found')
			return
		end

		manolis.popcorn.gangs.GetPlayerGangData(ply,function(owngang)
			if(!owngang) then return false end
			if(tonumber(owngang.rank)>2) then
				DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_mercy_fail'))
				return false
			end


			if(owngang.id==gang.id) then
				return
			end

			manolis.popcorn.gangs.Mercy(owngang,gang, function(suc, msg)
				DarkRP.notify(ply,1,4,msg)
			end)
		end)
	end)	
end)

concommand.Add("ManolisPopcornLeaveGang", function(ply,cmd,args)
	manolis.popcorn.gangs.GetPlayerGangData(ply, function(data)
		if(data) then
			manolis.popcorn.gangs.RemovePlayerFromGang(ply, function(s)
				DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_left',data.name))
				ply:SetGang(0, 0)
				ply:setDarkRPVar('gang', 0)

				manolis.popcorn.gangs.Notify(data.id, 1,4,DarkRP.getPhrase('gang_other_left', ply:Name()))

				manolis.popcorn.gangs.GetGangMembers(data.id, function(members)
					local toSend = manolis.popcorn.gangs.GetConnected(data.id)
					net.Start("ManolisPopcornGangMemberUpdate")
						net.WriteTable(members)
					net.Send(toSend)
				end)
			end)
		else
			DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_no_gang'))
		end

	end)
end)


concommand.Add("ManolisPopcornInviteToGang", function(ply,cmd,args)
	if(!args[1]) then return false end
	local newPlayer = DarkRP.findPlayer(args[1])
	if(!IsValid(newPlayer) or !(newPlayer:IsPlayer() or newPlayer:IsBot())) then return false end

	manolis.popcorn.gangs.GetPlayerGangData(newPlayer, function(data)
		if(data) then
			DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_invite_fail', newPlayer:Name()))
			return
		end

		manolis.popcorn.gangs.GetPlayerGangData(ply, function(pdata)
			if(!pdata) then
				DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_invite_nogang'))
			else
				if(pdata.rank and pdata.rank<=2) then
					manolis.popcorn.gangs.GetPlayerGangInvites(newPlayer, function(invites)
						if(invites) then
							for k,v in pairs(invites) do
								if(v.id == pdata.id) then
									DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_invite_already', newPlayer:Name()))
									return
								end
							end
						end

						manolis.popcorn.gangs.AddInviteToPlayer(newPlayer, pdata.id, function()
							DarkRP.notify(ply,0,4,DarkRP.getPhrase('gang_invite_suc',newPlayer:Name()))
							DarkRP.notify(newPlayer,0,4,DarkRP.getPhrase('gang_invite_suc2', pdata.name, ply:Name()))
							manolis.popcorn.gangs.GetPlayerGangInvites(newPlayer, function(invites)
								newPlayer:SetGangInvites(invites)
							end)
						end)
					end)
				else
					DarkRP.notify(ply,1,4,DarkRP.getPhrase('gang_invite_rank'))
				end
			end
		end)

	end)
end)

net.Receive("ManolisPopcornSearchGangs", function(len,ply)
	if(!IsValid(ply)) then
		return
	end
	if(ply.IsSearchingGangs) then
		return
	else
		ply.IsSearchingGangs = true
		local str = net.ReadString()
		if(#str<=0) then
			ply.IsSearchingGangs = false
		else
			manolis.popcorn.gangs.Search(str, function(data)
				net.Start("ManolisPopcornSearchGangs")
					net.WriteTable(data or {})
				net.Send(ply)

				ply.IsSearchingGangs = false
			end)
		end
	end
end)


timer.Create("ManolisPopcornGangXP", manolis.popcorn.config.gangPoleTime, 0, function()
	local poles = ents.FindByClass("gang_territory")

	local territories = {}

	local allPlayers = player.GetAll()
	if(#allPlayers < (manolis.popcorn.config.territoryPlayers or 10)) then
		return false
	end

	local xpGangAdd = {}

	local got = {}
	for k,v in pairs(poles) do
		if(v:GetGangID() > 0) then
			v.gang = v:GetGangID()
			if(!got[v.gang]) then got[v.gang] = {} end
			if(!got[v.gang].territories) then got[v.gang].territories = {} end
			got[v.gang].territories[v:GetTerritory()] = (got[v.gang].territories[v:GetTerritory()] or 0) + manolis.popcorn.config.xpPerPole

		end
	end

	for k,v in pairs(got) do
		local total = 0
		for a,b in pairs(v.territories) do
			total = total + b
			manolis.popcorn.gangs.Notify(k, 0,4,'Your gang got '..b..'XP for the '..manolis.popcorn.gangs.territories.territories[a].name..' territory')
		end
		xpGangAdd[k] = (xpGangAdd[k] or 0) + total

	end
			

	for k,v in pairs(manolis.popcorn.gangs.territories.territories) do
		local cap = 0
		local setF = false
		for a,b in pairs(v.locations) do
			if((b.captured and b.captured == cap) or !(setF)) then
				setF = true
				if(b.captured) then
					cap = b.captured
				else
					cap = 0
				end
			else
				cap = 0
			end
		end

		if(cap>0) then
			xpGangAdd[cap] = (xpGangAdd[cap] or 0) + manolis.popcorn.config.xpTerritoryExtra
			
			manolis.popcorn.gangs.Notify(cap, 0,4,DarkRP.getPhrase('gang_territory_xp', manolis.popcorn.config.xpTerritoryExtra, v.name))
  			
		end
	end
	
	for k,v in pairs(manolis.popcorn.gangs.territories.territories) do
	    if(v.id == id) then
	        local cap = 0
	        for ka,va in pairs(v.locations) do
	            for kx,vx in pairs(poles) do
		            if(vx:GetLocationID() == va.id) then
		            	if(vx:GetGangID() == LocalPlayer():getDarkRPVar('gang')) then
		           			cap = cap + 1
		           		end
		            end

	                manolis.popcorn.gangs.ShowInfo.numCaptured = cap
	            end

	            if(cap>=#v.locations) then
	            	ownsLocations[v] = true
	            end
	        end
	    end

	end

	for k,v in pairs(xpGangAdd) do

		manolis.popcorn.gangs.AddXP(k, v, function() 

		end)
	end
	

end)


local haveRefreshed = false
hook.Add("PlayerInitialSpawn", "SpawnGangStuff", function()
	if(!haveRefreshed) then
		manolis.popcorn.gangs.retrieveTerritories(function(t)
			for k,v in pairs(t) do
				for a,b in pairs(v.locations) do 
					local territory = ents.Create("gang_territory")
						if(IsValid(territory)) then
						territory:SetName(v.name)
						territory:SetUniqueID(b.id)
						territory:SetTerritory(v.id)
						territory:SetPos(Vector(b.x,b.y,b.z) - Vector(0,0,5))
						territory:SetLocationID(b.id)
						territory:Spawn()
					end
				end
			end
			manolis.popcorn.gangs.territories.territories = t
		end)

		haveRefreshed = true
	end
end)