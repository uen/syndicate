if(!manolis) then manolis = {} end
if(!manolis.popcorn) then manolis.popcorn = {} end
if(!manolis.popcorn.trade) then manolis.popcorn.trade = {} end
if(!manolis.popcorn.trade.trades) then manolis.popcorn.trade.trades = {} end

local deepcompare
deepcompare = function(t1,t2,ignore_mt)
    local ty1 = type(t1)
    local ty2 = type(t2)
    if ty1 ~= ty2 then return false end
    if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
    local mt = getmetatable(t1)
    if not ignore_mt and mt and mt.__eq then return t1 == t2 end
    for k1,v1 in pairs(t1) do
        local v2 = t2[k1]
        if v2 == nil or not deepcompare(v1,v2) then return false end
    end
    for k2,v2 in pairs(t2) do
        local v1 = t1[k2]
        if v1 == nil or not deepcompare(v1,v2) then return false end
    end
    return true
end

manolis.popcorn.trade.NewTrade = function(ply,p2)
	if(!(IsValid(ply) and IsValid(p2))) then return false end
	if(ply==p2) then return false end
	if(p2.isTrading) then
		DarkRP.notify(ply, 1,4,DarkRP.getPhrase('already_trading', p2:Name()))
		return
	end
	if(ply.isTrading) then
		DarkRP.notify(ply, 1,4,DarkRP.getPhrase('already_active_trade'))
		return
	end

	local newTrade = {}
	newTrade.players = {ply,p2}
	newTrade.items = {}
	newTrade.items[ply] = {}
	newTrade.items[p2] = {}
	newTrade.items[p2].items = {}
	newTrade.items[ply].items = {}

	table.insert(manolis.popcorn.trade.trades, newTrade)

	p2.isTrading = true
	ply.isTrading = true

	net.Start("ManolisPopcornNewTrade")
		net.WriteEntity(ply)
		net.WriteEntity(p2)
	net.Send({ply,p2})
end

net.Receive("ManolisPopcornSetMoneyTrade", function(len,ply)
	local money = net.ReadInt(32)
	if(money<=0) then
		DarkRP.notify(ply,1,4,DarkRP.getPhrase('trade_money_positive'))
		return 
	end 

	if(!money) then return false end

	if(ply:canAfford(money)) then
		if(ply.isTrading) then
			for k,v in pairs(manolis.popcorn.trade.trades) do
				for k2,v2 in pairs(v.players) do
					if(ply==v2) then
						for a,b in pairs(v.players) do
							if(v.items[b].locked) then 
								DarkRP.notify(ply,1,4,DarkRP.getPhrase('trade_change_lock'))
								return false 
							end
						end

						v.items[v2].money = money
						for ka,va in pairs(v.players) do
							net.Start("ManolisPopcornSetMoneyTrade")
								net.WriteEntity(ply)
								net.WriteInt(money, 32)
							net.Send(va)
						end
		
						return
					end
				end
			end
		else 
			return
		end	
	else
		DarkRP.notify(ply,1,4,DarkRP.getPhrase('trade_cannot_afford'))
	end
end)

net.Receive("ManolisPopcornAddItemToTrade", function(len,ply)
	local id = net.ReadInt(32)
	if(!id) then return end
	if(ply.isTrading) then
		manolis.popcorn.inventory.retrieveSingleItemData(ply,id, function(d)
			if(!d) then return DarkRP.notify(ply,1,4,DarkRP.getPhrase('trade_item_not_exist')) end
			for k,v in pairs(manolis.popcorn.trade.trades) do
				for k2,v2 in pairs(v.players) do
					if(ply==v2) then
						for p,item in pairs(v.items[v2].items or {}) do
							if(item.id==d.id) then return false end
						end
						

						for a,b in pairs(v.players) do
							if(v.items[b].locked) then 
								DarkRP.notify(ply,1,4,DarkRP.getPhrase('trade_change_lock'))
								return false
							end
						end

						table.insert(v.items[v2].items, d)
						for _,l in pairs(v.players) do
							net.Start("ManolisPopcornTradeUpdate")
								net.WriteEntity(v2)
								net.WriteTable(v.items[v2].items)
							net.Send(l)
						end						
						return
					end
				end
			end

		end)
	end
end)

net.Receive("ManolisPopcornRemoveItemFromTrade", function(len,ply)
	local id = net.ReadInt(32)
	if(!id) then return end
	if(ply.isTrading) then
		for k,v in pairs(manolis.popcorn.trade.trades) do
			for k2,v2 in pairs(v.players) do
				if(ply==v2) then
					for p,item in pairs(v.items[v2].items) do
						if(item.id==id) then
							table.remove(v.items[v2].items, p)
							return
						end
					end
					for _,a in pairs(v.players) do
						net.Start("ManolisPopcornTradeUpdate")
							net.WriteEntity(v2)
							net.WriteTable(v.items[v2].items)
						net.Send(a)
					end
					return
				end
			end
		end
	end
end)

local canCompleteTrade = function(trade, callback)
	if(!trade) then callback(false) return end
	if(!trade.items) then callback(false) return end

	for k,items in pairs(trade.items) do
		if(!IsValid(k)) then
			callback(false)
			return
		end
		local money = items.money or 0
		if(money>0) then
			if(!k:canAfford(money)) then
				callback(false)
				return 
			end
		end
	end

	local countOfItems = 0
	for k,items in pairs(trade.items) do
		for k,v in pairs(items.items) do
			countOfItems = countOfItems + 1
		end
	end

	if(countOfItems==0) then 
		callback(true)
		return
	end

	local p = {}
	for k,items in pairs(trade.items) do
		table.insert(p, k)
	end

	MySQLite.query("SELECT id FROM manolis_popcorn_inventory WHERE uid = "..MySQLite.SQLStr(p[1]:SteamID64()).." AND slot >= 0", function(data) 
		if(data and #data+(#trade.items[p[1]].items)>80) then
			callback(false)
			return
		else
			MySQLite.query("SELECT id FROM manolis_popcorn_inventory WHERE uid = "..MySQLite.SQLStr(p[2]:SteamID64()).." AND slot >= 0", function(data)
				if(data and #data+(#trade.items[p[2]].items) >80) then
					callback(false)
					return
				else
					local checked = 0

					for k,va in pairs(trade.items) do
						for k2,v in pairs(va.items) do
							manolis.popcorn.inventory.retrieveSingleItemData(k,v.id,function(data)
								if(!data) then callback(false) return end
								if(tonumber(data.slot)<0) then
									callback(false)
									return
								end
								if(!deepcompare(v, data)) then
									callback(false)
									return
								end

								checked = checked + 1
								if(checked>=countOfItems) then
									callback(true)
								end
							end)
						end
					end
				end
			end)
		end
	end)	
end

net.Receive("ManolisPopcornDoTrade", function(len,ply)
	if(ply.isTrading) then
		for kx,v in pairs(manolis.popcorn.trade.trades) do
			for k2,v2 in pairs(v.players) do
				if(v2.isCrafting) then return end
				if(ply.isCrafting) then return end
				
				if(ply==v2) then
					for a,b in pairs(v.players) do
						if(!v.items[b].locked) then
							DarkRP.notify(ply,1,4,DarkRP.getPhrase('cannot_trade_until_locked'))
							return
						end
					end

					v.items[v2].traded = true

					
					for _,o in pairs(v.players) do
						net.Start("ManolisPopcornConfirmTrade")
							net.WriteEntity(v2)
						net.Send(o)
					end

					local count = 0
					for ko,vo in pairs(v.items) do
						if(vo.traded) then
							count = count + 1
						end
					end

					if(count>1) then
						canCompleteTrade(v, function(c)
							if(!c) then 
								for k,v in pairs(v.players) do
									DarkRP.notify(v,1,4,DarkRP.getPhrase('trade_fail'))
								end
								return 
							end

							for k,v2 in pairs(v.players) do
								DarkRP.notify(v2,0,4,DarkRP.getPhrase('trade_success'))
								for a,b in pairs(v.items) do
									if(a!=v2) then
										if((v.items[a].money or 0)>0) then
											v2:addMoney(v.items[a].money)
											a:addMoney(-v.items[a].money)
											DarkRP.notify(v2,0,4,DarkRP.getPhrase('trade_money', DarkRP.formatMoney(v.items[a].money)))
										end
							
										local d = 1
										local doQue = function(doQue, a,v2, callback)
											manolis.popcorn.inventory.getFreeSlot(v2, function(page,slot)
												if(!page or !slot) then
													for k,v in pairs(v.players) do
														DarkRP.notify(v,1,4,DarkRP.getPhrase('trade_fail_inventory'))
														return
													end
												else
													manolis.popcorn.inventory.switchPlayer(a,v2,v.items[a].items[d].id,page,slot, function()
														d = d+1
														if(!v.items[a].items[d]) then
															if(callback) then callback() end
														else
															doQue(doQue, a,v2,callback)
														end
													end)
												end
											end)
										end

										if(#v.items[a].items>0) then
											doQue(doQue, a,v2,function() end)
										end
									end
								end
							end
						end)

						table.remove(manolis.popcorn.trade.trades, kx)
						for k,v in pairs(v.players) do
							v.isTrading = false
							net.Start("ManolisPopcornStopTrade")
							net.Send(v)
						end
					end

					return
				end
			end
		end
	end
end)

net.Receive("ManolisPopcornLockTrade", function(len,ply)
	local t = net.ReadBool()
	if(ply.isTrading) then
		for k,v in pairs(manolis.popcorn.trade.trades) do
			for k2,v2 in pairs(v.players) do
				if(ply==v2) then
					if(t==false) then
						for k,b in pairs(v.players) do
							if(v.items[b].traded) then
								DarkRP.notify(ply,1,4,DarkRP.getPhrase('trade_cannot_unlock'))
								return
							end
						end
					end
					v.items[v2].locked = t
					
					for _,o in pairs(v.players) do
						net.Start("ManolisPopcornLockTrade")
							net.WriteEntity(v2)
							net.WriteBool(t)
						net.Send(o)
					end
					return
				end
			end
		end
	end
end)

net.Receive("ManolisPopcornCancelTrade", function(len,ply)
	if(ply.isTrading) then
		for k,v in pairs(manolis.popcorn.trade.trades) do
			for k2,v2 in pairs(v.players) do
				if(ply==v2) then
					for k,v in pairs(v.players) do
						v.isTrading = false
						DarkRP.notify(p,1,4,DarkRP.getPhrase('trade_cancel'))
						net.Start("ManolisPopcornStopTrade")
						net.Send(v)
					end
					table.remove(manolis.popcorn.trade.trades, k)
					return
				end
			end
		end
	end
end)

hook.Add("PlayerDisconnected", "manolis:popcorn:trade:Disconnect", function(ply)
	for k,v in pairs(manolis.popcorn.trade.trades) do
		for k2,v2 in pairs(v.players) do
			if(ply==v2) then
				for _,p in pairs(v.players) do
					if(IsValid(p)) then
						p.isTrading = false
						DarkRP.notify(p,1,4,DarkRP.getPhrase('trade_cancel'))
						net.Start("ManolisPopcornStopTrade")
						net.Send(p)
					end
				end
				return
			end
		end
	end
end)

local startTrade = function(ply,newPlayer)
	if(ply.isTrading) then 
		DarkRP.notify(ply,1,4,DarkRP.getPhrase('already_active_trade'))
		return 
	end

	if(newPlayer.isTrading) then
		DarkRP.notify(ply,1,4,DarkRP.getPhrase('already_trading', newPlayer:Nick()))
	end

	if(newPlayer:SteamID64() == ply:SteamID64()) then
		DarkRP.notify(ply,0,4,'@vrondakis was here')
		return
	end

	DarkRP.createQuestion(DarkRP.getPhrase('trade_question',ply:Nick()), CurTime().."Trade", newPlayer, 20, function(answer, ent, init, target, timeisup)
		if(answer!=0) then
			manolis.popcorn.trade.NewTrade(ply, newPlayer)
		else
			DarkRP.notify(ply,1,4,DarkRP.getPhrase('trade_reject', newPlayer:Nick()))
		end
	end)

	DarkRP.notify(ply,0,4,DarkRP.getPhrase('trade_request', newPlayer:Nick()))
end


concommand.Add("ManolisPopcornStartTrade", function(ply,cmd,args)
	if(!args[1]) then return false end
	local newPlayer = DarkRP.findPlayer(args[1])
	if(!IsValid(newPlayer) or !(newPlayer:IsPlayer() or newPlayer:IsBot())) then return false end
	startTrade(ply,newPlayer)
end)

DarkRP.defineChatCommand(DarkRP.getPhrase('trade_trade'), function(ply, args)

	local tr = util.TraceLine(util.GetPlayerTrace(ply))
	if(IsValid(tr.Entity) and tr.Entity:IsPlayer() and !args!='') then
		startTrade(ply,tr.Entity)
		return ''
	else
		if(args[1] and #args[1]>1) then
   			local target = DarkRP.findPlayer(args[1])
   			if(target) then
   				startTrade(ply,target)
   				return ''
   			end
		end
	end

	DarkRP.notify(ply,1,4,DarkRP.getPhrase('player_notfound'))

	return ''
end, 1.5)